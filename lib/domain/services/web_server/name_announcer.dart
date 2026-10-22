import 'dart:io';

/// Makes the phone reachable by name in the Wi-Fi, so that the web version
/// keeps its address when the phone's IP address changes.
abstract interface class NameAnnouncer {
  /// Announces the server on [port], reached at [address] in the Wi-Fi.
  /// Returns the name it goes by, or `null` while the network doesn't allow
  /// one.
  Future<String?> announce({
    required InternetAddress address,
    required int port,
  });

  Future<void> withdraw();

  /// What the user can do about a missing name, if anything.
  String? get problem;
}
