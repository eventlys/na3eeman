class ReportModel {
  final String id;
  final String reporterName;
  final String description;
  final DateTime date;
  final ReportType type;

  ReportModel({
    required this.id,
    required this.reporterName,
    required this.description,
    required this.date,
    required this.type,
  });
}

enum ReportType {
  user,
  shop,
  content,
}

enum ReportTime {
  daily,
  weekly,
  monthly,
  annually
}

enum ReportFormat {
  pdf,
  excel,
}

class ReportRequest {
  final ReportTime time;
  final DateTime startDate;
  final DateTime endDate;
  final String? branchId;
  final ReportFormat format;
  final String fileName;

  ReportRequest({
    required this.time,
    required this.startDate,
    required this.endDate,
    this.branchId,
    this.format = ReportFormat.pdf,
    required this.fileName,
  });
}

class ReportData {
  final String id;
  final ReportTime time;
  final DateTime generatedAt;
  final Map<String, dynamic> data;
  final String downloadUrl;

  ReportData({
    required this.id,
    required this.time,
    required this.generatedAt,
    required this.data,
    required this.downloadUrl,
  });
}
