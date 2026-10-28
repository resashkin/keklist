import 'package:equatable/equatable.dart';

enum AiModelFormat { liteRtLm, gguf }

/// A model file on Hugging Face that runs on the phone: a `.litertlm` from the AI Edge Gallery list or any GGUF.
final class AiModelInfo with EquatableMixin {
  const AiModelInfo({
    required this.name,
    required this.repo,
    required this.file,
    required this.revision,
    required this.sizeBytes,
    required this.format,
    this.minMemoryGb,
    this.description,
    this.contextSize = 4096,
  });

  final String name;
  final String repo;
  final String file;
  final String revision;
  final int sizeBytes;
  final AiModelFormat format;
  final double? minMemoryGb;
  final String? description;
  final int contextSize;

  String get id => '$repo/$file';

  /// Models below a billion parameters rarely keep up a conversation.
  bool get isWeak => isWeakName('$name $repo $file');

  /// The largest size like "1.5B" or "360M" named in [text], in billions.
  static double? parameterBillions(String text) {
    final Iterable<double> sizes = RegExp(r'(?<![A-Za-z\d.])(\d+(?:\.\d+)?)([BbMm])(?![A-Za-z])')
        .allMatches(text)
        .map((match) => double.parse(match[1]!) / (match[2]!.toUpperCase() == 'M' ? 1000 : 1));
    return sizes.isEmpty ? null : sizes.reduce((a, b) => a > b ? a : b);
  }

  static bool isWeakName(String text) => (parameterBillions(text) ?? 1) < 1;

  Uri get url => Uri.https('huggingface.co', '/$repo/resolve/$revision/$file', {'download': 'true'});

  static AiModelFormat formatOf(String file) =>
      file.toLowerCase().endsWith('.gguf') ? AiModelFormat.gguf : AiModelFormat.liteRtLm;

  Map<String, dynamic> toJson() => {
    'name': name,
    'repo': repo,
    'file': file,
    'revision': revision,
    'sizeBytes': sizeBytes,
    'format': format.name,
    'minMemoryGb': minMemoryGb,
    'description': description,
    'contextSize': contextSize,
  };

  factory AiModelInfo.fromJson(Map<String, dynamic> json) => AiModelInfo(
    name: json['name'] as String,
    repo: json['repo'] as String,
    file: json['file'] as String,
    revision: json['revision'] as String? ?? 'main',
    sizeBytes: (json['sizeBytes'] as num?)?.toInt() ?? 0,
    format: AiModelFormat.values.asNameMap()[json['format']] ?? formatOf(json['file'] as String),
    minMemoryGb: (json['minMemoryGb'] as num?)?.toDouble(),
    description: json['description'] as String?,
    contextSize: (json['contextSize'] as num?)?.toInt() ?? 4096,
  );

  @override
  List<Object?> get props => [repo, file, revision, sizeBytes];
}

/// A GGUF repository found on Hugging Face; its files are listed on demand.
final class HfRepoInfo {
  const HfRepoInfo({required this.id, required this.downloads, required this.likes});

  final String id;
  final int downloads;
  final int likes;
}
