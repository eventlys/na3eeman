class ReportResult {
  final bool success;
  final String? downloadUrl;
  final String? fileName;
  final String? errorMessage;

  ReportResult({
    required this.success,
    this.downloadUrl,
    this.fileName,
    this.errorMessage,
  });
}
