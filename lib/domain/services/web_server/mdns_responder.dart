import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:keklist/domain/services/web_server/name_announcer.dart';

/// Answers for a name like "keklist.local" in the local network with
/// multicast DNS (RFC 6762), so that browsers reach the phone by a name that
/// stays the same when its address changes. Android can advertise services
/// but not a host name of the app's choosing, hence this responder.
class MdnsResponder implements NameAnnouncer {
  MdnsResponder(this.hostName, {this.port = mdnsPort})
    : _labels = hostName.split('.');

  static const mdnsPort = 5353;
  static final group = InternetAddress('224.0.0.251');

  /// How long others may remember the answer, as RFC 6762 suggests for
  /// host addresses.
  static const ttl = Duration(minutes: 2);

  /// Answers to queries that are not mDNS-aware (sent from a port other than
  /// 5353) are remembered for at most this long.
  static const legacyTtl = Duration(seconds: 10);

  final String hostName;

  /// 5353, except in tests.
  final int port;

  final List<String> _labels;
  RawDatagramSocket? _socket;
  InternetAddress? _address;
  Timer? _announcing;

  /// The address [hostName] stands for while answering.
  InternetAddress? get address => _address;

  @override
  Future<String?> announce({
    required InternetAddress address,
    required int port,
  }) async => address == this.address || await start(address) ? hostName : null;

  @override
  Future<void> withdraw() => stop();

  @override
  String? get problem => null;

  /// Starts answering that [hostName] is [address], an IPv4 address of this
  /// device's Wi-Fi. Returns whether the network allows it.
  Future<bool> start(InternetAddress address) async {
    await stop(goodbye: false);
    final socket = await _bind();
    if (socket == null) return false;
    try {
      final interface = await _interfaceWith(address);
      socket
        ..multicastHops = 255
        // Multicast answers leave by the Wi-Fi even when mobile data carries
        // the internet.
        ..setRawOption(
          RawSocketOption(
            RawSocketOption.levelIPv4,
            RawSocketOption.IPv4MulticastInterface,
            address.rawAddress,
          ),
        )
        ..joinMulticast(group, interface);
    } on Object {
      socket.close();
      return false;
    }
    _socket = socket;
    _address = address;
    socket.listen((event) {
      if (event == RawSocketEvent.read) _read(socket);
    });
    // Announced twice, a second apart, so that caches pick up a new address.
    _send(socket, _announcement(address, ttl), group, port);
    _announcing = Timer(const Duration(seconds: 1), () {
      if (identical(_socket, socket)) {
        _send(socket, _announcement(address, ttl), group, port);
      }
    });
    return true;
  }

  /// Stops answering; with [goodbye], tells the network to forget the name.
  Future<void> stop({bool goodbye = true}) async {
    _announcing?.cancel();
    final socket = _socket;
    final address = _address;
    _socket = null;
    _address = null;
    if (socket == null) return;
    if (goodbye && address != null) {
      _send(socket, _announcement(address, Duration.zero), group, port);
    }
    socket.close();
  }

  /// Binds the mDNS port, which the system's own responder holds too.
  Future<RawDatagramSocket?> _bind() async {
    // Linux (Android) shares the port through SO_REUSEADDR; macOS and iOS
    // need SO_REUSEPORT as well.
    for (final reusePort in [false, true]) {
      try {
        return await RawDatagramSocket.bind(
          InternetAddress.anyIPv4,
          port,
          reusePort: reusePort,
          ttl: 255,
        );
      } on SocketException {
        continue;
      }
    }
    return null;
  }

  static Future<NetworkInterface?> _interfaceWith(
    InternetAddress address,
  ) async {
    for (final interface in await NetworkInterface.list(
      type: InternetAddressType.IPv4,
    )) {
      if (interface.addresses.contains(address)) return interface;
    }
    return null;
  }

  void _read(RawDatagramSocket socket) {
    final datagram = socket.receive();
    final address = _address;
    if (datagram == null || address == null) return;
    // A query from a port other than 5353 comes from a plain DNS client,
    // which waits for a direct answer.
    final legacy = datagram.port != mdnsPort;
    final Reply? reply;
    try {
      reply = replyTo(datagram.data, address, legacy: legacy);
    } on RangeError {
      return;
    } on FormatException {
      return;
    }
    if (reply == null) return;
    if (reply.direct) {
      _send(socket, reply.packet, datagram.address, datagram.port);
    } else {
      _send(socket, reply.packet, group, port);
    }
  }

  static void _send(
    RawDatagramSocket socket,
    Uint8List packet,
    InternetAddress to,
    int port,
  ) {
    try {
      socket.send(packet, to, port);
    } on SocketException {
      // Wi-Fi gone; the next query or start tries again.
    }
  }

  /// The answer to the DNS message [packet], or `null` when it asks nothing
  /// about [hostName]. Throws [RangeError] or [FormatException] for
  /// malformed packets.
  Reply? replyTo(
    Uint8List packet,
    InternetAddress address, {
    bool legacy = false,
  }) {
    final reader = _Reader(packet);
    final id = reader.u16();
    final flags = reader.u16();
    // Only standard queries; answers and other opcodes are not for us.
    if (flags & 0xF800 != 0) return null;
    final questions = reader.u16();
    reader
      ..u16()
      ..u16()
      ..u16();
    final asked = <({int type, bool direct})>[];
    for (var i = 0; i < questions; i++) {
      final name = reader.name();
      final type = reader.u16();
      final klass = reader.u16();
      if ((klass & 0x7FFF) != _classIn && (klass & 0x7FFF) != _classAny) {
        continue;
      }
      if (_isOurs(name)) {
        asked.add((type: type, direct: klass & 0x8000 != 0));
      }
    }
    if (asked.isEmpty) return null;

    final wantsAddress = asked.any(
      (q) => q.type == _typeA || q.type == _typeAny,
    );
    // For AAAA and anything else: there is only an IPv4 address, which
    // spares the asking computer from waiting for an IPv6 one.
    final wantsAbsence = asked.any((q) => q.type != _typeA);
    final recordTtl = legacy ? legacyTtl : ttl;

    final writer = _Writer()
      ..u16(legacy ? id : 0)
      ..u16(0x8400) // A response, authoritative.
      ..u16(legacy ? asked.length : 0)
      ..u16((wantsAddress ? 1 : 0) + (wantsAbsence ? 1 : 0))
      ..u16(0)
      ..u16(wantsAbsence ? 0 : 1);
    if (legacy) {
      for (final question in asked) {
        writer
          ..name(_labels)
          ..u16(question.type)
          ..u16(_classIn);
      }
    }
    if (wantsAddress) {
      _addressRecord(writer, address, recordTtl, flush: !legacy);
    }
    _absenceRecord(writer, recordTtl, flush: !legacy);
    return Reply(
      writer.bytes(),
      direct: legacy || asked.every((q) => q.direct),
    );
  }

  /// An unsolicited answer, sent when starting and, with no time to live,
  /// when stopping.
  Uint8List _announcement(InternetAddress address, Duration ttl) {
    final writer = _Writer()
      ..u16(0)
      ..u16(0x8400)
      ..u16(0)
      ..u16(1)
      ..u16(0)
      ..u16(0);
    _addressRecord(writer, address, ttl, flush: true);
    return writer.bytes();
  }

  void _addressRecord(
    _Writer writer,
    InternetAddress address,
    Duration ttl, {
    required bool flush,
  }) {
    writer
      ..name(_labels)
      ..u16(_typeA)
      ..u16(flush ? _classIn | _cacheFlush : _classIn)
      ..u32(ttl.inSeconds)
      ..u16(4)
      ..raw(address.rawAddress);
  }

  /// An NSEC record saying [hostName] has an A record and nothing else.
  void _absenceRecord(_Writer writer, Duration ttl, {required bool flush}) {
    final next = _Writer()..name(_labels);
    final nextName = next.bytes();
    writer
      ..name(_labels)
      ..u16(_typeNsec)
      ..u16(flush ? _classIn | _cacheFlush : _classIn)
      ..u32(ttl.inSeconds)
      ..u16(nextName.length + 3)
      ..raw(nextName)
      // Window 0, one byte of bitmap, the bit for type 1 (A).
      ..raw(const [0, 1, 0x40]);
  }

  bool _isOurs(List<String> name) {
    if (name.length != _labels.length) return false;
    for (var i = 0; i < name.length; i++) {
      if (name[i].toLowerCase() != _labels[i].toLowerCase()) return false;
    }
    return true;
  }

  static const _typeA = 1;
  static const _typeNsec = 47;
  static const _typeAny = 255;
  static const _classIn = 1;
  static const _classAny = 255;
  static const _cacheFlush = 0x8000;
}

/// A packet answering a query, and whether it goes back to the asker alone
/// rather than to the whole network.
class Reply {
  const Reply(this.packet, {required this.direct});

  final Uint8List packet;
  final bool direct;
}

class _Reader {
  _Reader(Uint8List bytes) : _data = ByteData.sublistView(bytes);

  final ByteData _data;
  var _offset = 0;

  int u16() {
    final value = _data.getUint16(_offset);
    _offset += 2;
    return value;
  }

  /// A domain name, following compression pointers (RFC 1035 4.1.4).
  List<String> name() {
    final labels = <String>[];
    var offset = _offset;
    int? resumeAt;
    for (var jumps = 0; ; jumps++) {
      final length = _data.getUint8(offset);
      if (length == 0) {
        _offset = resumeAt ?? offset + 1;
        return labels;
      }
      if (length & 0xC0 == 0xC0) {
        if (jumps > 16) throw const FormatException('Name pointer loop');
        resumeAt ??= offset + 2;
        offset = _data.getUint16(offset) & 0x3FFF;
        continue;
      }
      if (length > 63) throw const FormatException('Bad label');
      labels.add(
        utf8.decode(
          Uint8List.sublistView(_data, offset + 1, offset + 1 + length),
          allowMalformed: true,
        ),
      );
      offset += 1 + length;
    }
  }
}

class _Writer {
  final _builder = BytesBuilder();

  void u16(int value) => _builder.add([value >> 8 & 0xFF, value & 0xFF]);

  void u32(int value) {
    u16(value >> 16 & 0xFFFF);
    u16(value & 0xFFFF);
  }

  void raw(List<int> bytes) => _builder.add(bytes);

  void name(List<String> labels) {
    for (final label in labels) {
      final bytes = utf8.encode(label);
      _builder
        ..addByte(bytes.length)
        ..add(bytes);
    }
    _builder.addByte(0);
  }

  Uint8List bytes() => _builder.toBytes();
}
