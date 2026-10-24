import '../../Services/enums/report_enums.dart';

class ReportRequest {
  final ReportTime time;
  final DateTime startDate;
  final DateTime endDate;
  final String? branchId;
  final ReportFormat format;
  final String fileName;
  final ReportType? reportType;

  ReportRequest({
    required this.time,
    required this.startDate,
    required this.endDate,
    this.branchId,
    this.format = ReportFormat.pdf,
    required this.fileName,
    this.reportType,
  });

  Map<String, dynamic> toJson() {
    return {
      'time': time.toString().split('.').last,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'branch_id': branchId,
      'format': format.toString().split('.').last,
      'file_name': fileName,
      'report_type': reportType?.toString().split('.').last,
    };
  }
}

class StaffReportRequest {
  final ReportTime time;
  final DateTime startDate;
  final DateTime endDate;
  final String? branchId;
  final String? staffId;
  final String fileName;
  final StaffReportType reportType;

  StaffReportRequest({
    required this.time,
    required this.startDate,
    required this.endDate,
    this.branchId,
    this.staffId,
    required this.fileName,
    required this.reportType,
  });

  Map<String, dynamic> toJson() {
    return {
      'time': time.toString().split('.').last,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'branch_id': branchId,
      'staff_id': staffId,
      'file_name': fileName,
      'report_type': reportType.toString().split('.').last,
    };
  }
}

class ReportData {
  final String id;
  final ReportTime time;
  final DateTime generatedAt;
  final Map<String, dynamic> data;
  final String downloadUrl;
  final String fileName;

  ReportData({
    required this.id,
    required this.time,
    required this.generatedAt,
    required this.data,
    required this.downloadUrl,
    required this.fileName,
  });

  factory ReportData.fromJson(Map<String, dynamic> json) {
    return ReportData(
      id: json['id']?.toString() ?? '',
      time: ReportTime.values.firstWhere(
        (e) => e.toString().split('.').last == json['time'],
        orElse: () => ReportTime.monthly,
      ),
      generatedAt: DateTime.parse(json['generated_at'] as String),
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      downloadUrl: json['download_url'] as String,
      fileName: json['file_name'] as String,
    );
  }
}
