import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../Helpers/customized/reports_helper.dart';
import '../../Helpers/logger.dart';
import '../../Models/appointments/salon_appointments_model.dart';
import '../../Models/inventory/inventory_item.dart';
import '../../Models/reports/earnings_model.dart';
import '../../Models/reports/profit_data.dart';
import '../../Models/staff/expert.dart';
import '../../Packages/Core/utils/formatters.dart';
import '../api/api_service.dart';
import '../enums/appointment_status.dart';
import '../enums/report_enums.dart';
import 'appointment_repository.dart';
import 'staff_repository.dart';

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

class ReportService {
  final ApiService _apiService = ApiService();
  final ReportRepository _reportRepository = ReportRepository();

  Future<ReportResult> generateReport({
    required ReportType reportType,
    required ReportTime timePeriod,
    required DateTime startDate,
    required DateTime endDate,
    String? fileName,
    String? branchId,
    ReportFormat format = ReportFormat.pdf,
  }) async {
    try {
      final request = ReportRequest(
        time: timePeriod,
        startDate: startDate,
        endDate: endDate,
        branchId: branchId,
        format: format,
        fileName: fileName ?? 'report_${DateTime.now().millisecondsSinceEpoch}',
        reportType: reportType,
      );

      final response = await _apiService.post(
        '/reports/generate',
        data: request.toJson(),
      );

      return ReportResult(
        success: true,
        downloadUrl: response['download_url'],
        fileName: response['file_name'],
      );
    } catch (e) {
      return ReportResult(success: false, errorMessage: e.toString());
    }
  }

  Future<ReportResult> generateStaffReport(
    StaffReportRequest request, {
    int? salonId,
  }) async {
    try {
      final activeSalonId = salonId;
      if (activeSalonId == null) {
        throw Exception('No active salon ID provided for report generation');
      }

      // Use the ReportRepository method for staff reports
      await _reportRepository.generateStaffReport(
        request,
        salonId: activeSalonId,
      );

      return ReportResult(
        success: true,
        downloadUrl:
            'generated_staff_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
        fileName: request.fileName,
      );
    } catch (e) {
      return ReportResult(success: false, errorMessage: e.toString());
    }
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

/// Repository for report generation: backend report requests, staff-report
/// orchestration, and client-side PDF report rendering.
///
/// Extracted verbatim from the former god service `BusinessService`
/// (see `lib/Services/business_service.dart`, now a delegating facade).
class ReportRepository {
  final StaffRepository _staffRepository;
  final AppointmentRepository _appointmentRepository;

  ReportRepository({
    StaffRepository? staffRepository,
    AppointmentRepository? appointmentRepository,
  }) : _staffRepository = staffRepository ?? StaffRepository(),
       _appointmentRepository =
           appointmentRepository ?? AppointmentRepository();

  Future<void> generateStaffReport(
    StaffReportRequest request, {
    required int salonId,
  }) async {
    try {
      AppLogger.debug(
        'Generating staff report: ${request.reportType} for salon: $salonId',
      );

      switch (request.reportType) {
        case StaffReportType.performance:
          final experts = await _staffRepository.getExperts(
            salonId: salonId,
            includePerformance: true,
          );
          await generateStaffPerformanceReport(experts, request);
          break;

        case StaffReportType.attendance:
          final appointments = await _appointmentRepository.getAppointments(
            salonId: salonId,
            status: 'completed',
          );
          await generateAppointmentReport(
            appointments,
            getTimeDisplayName(request.time),
            request.fileName,
          );
          break;

        case StaffReportType.payroll:
          final experts = await _staffRepository.getExperts(
            salonId: salonId,
            includePerformance: true,
          );
          final earningsData = experts
              .map(
                (expert) => EarningsData(
                  date: DateTime.now(),
                  amount: expert.totalEarnings,
                  appointments: expert.totalAppointments,
                  tips: 0.0,
                  salonId: salonId, // Add the required salonId
                  expertId: expert.userId, // Add expertId
                ),
              )
              .toList();

          await generateEarningsReport(
            earningsData,
            getTimeDisplayName(request.time),
            request.fileName,
          );
          break;

        case StaffReportType.daily:
        case StaffReportType.weekly:
        case StaffReportType.monthly:
        case StaffReportType.annually:
          // Generate summary report for the time period
          final experts = await _staffRepository.getExperts(
            salonId: salonId,
            includePerformance: true,
          );
          await generateStaffPerformanceReport(experts, request);
          break;
      }

      AppLogger.debug('Staff report generated successfully');
    } catch (e) {
      AppLogger.error('Error generating staff report: $e');
      rethrow;
    }
  }

  String getTimeDisplayName(ReportTime time) {
    switch (time) {
      case ReportTime.daily:
        return 'Daily';
      case ReportTime.weekly:
        return 'Weekly';
      case ReportTime.monthly:
        return 'Monthly';
      case ReportTime.annually:
        return 'Annually';
    }
  }

  // ============ PDF REPORT SERVICES ============

  static Future<void> generateProfitReport(
    List<ProfitData> data,
    String period,
    String fileName,
  ) async {
    final pdf = pw.Document();
    pdf.addPage(_buildProfitReportPage(data, period));
    await _savePdf(pdf, fileName);
  }

  static Future<void> generateEarningsReport(
    List<EarningsData> data,
    String period,
    String fileName,
  ) async {
    final pdf = pw.Document();
    pdf.addPage(_buildEarningsReportPage(data, period));
    await _savePdf(pdf, fileName);
  }

  static Future<void> generateStaffPerformanceReport(
    List<Expert> experts,
    StaffReportRequest request,
  ) async {
    final pdf = pw.Document();
    pdf.addPage(_buildStaffPerformancePage(experts, request));
    await _savePdf(
      pdf,
      'staff_performance_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  static Future<void> generateInventoryReport(
    List<InventoryItem> items,
    String reportType,
    String fileName,
  ) async {
    final pdf = pw.Document();
    pdf.addPage(_buildInventoryReportPage(items, reportType));
    await _savePdf(pdf, fileName);
  }

  static Future<void> generateAppointmentReport(
    List<SalonAppointment> appointments,
    String period,
    String fileName,
  ) async {
    final pdf = pw.Document();
    pdf.addPage(_buildAppointmentReportPage(appointments, period));
    await _savePdf(pdf, fileName);
  }

  // ============ PDF HELPER METHODS ============

  static Future<void> _savePdf(pw.Document pdf, String fileName) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static pw.Page _buildProfitReportPage(List<ProfitData> data, String period) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(level: 0, child: pw.Text('Profit Report - $period')),
            pw.SizedBox(height: 20),
            _buildProfitTable(data),
            pw.SizedBox(height: 20),
            _buildProfitSummary(data),
          ],
        );
      },
    );
  }

  static pw.Page _buildEarningsReportPage(
    List<EarningsData> data,
    String period,
  ) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(level: 0, child: pw.Text('Earnings Report - $period')),
            pw.SizedBox(height: 20),
            _buildEarningsTable(data),
            pw.SizedBox(height: 20),
            _buildEarningsSummary(data),
          ],
        );
      },
    );
  }

  static pw.Page _buildStaffPerformancePage(
    List<Expert> experts,
    StaffReportRequest request,
  ) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Staff Performance Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Period: ${Formatters.formatDate(request.startDate)} - ${Formatters.formatDate(request.endDate)}',
              style: const pw.TextStyle(fontSize: 12),
            ),
            pw.SizedBox(height: 20),
            _buildStaffPerformanceTable(experts),
            pw.SizedBox(height: 30),
            _buildPerformanceSummary(experts),
          ],
        );
      },
    );
  }

  static pw.Page _buildInventoryReportPage(
    List<InventoryItem> items,
    String reportType,
  ) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Inventory Report - $reportType',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            _buildInventoryTable(items),
            pw.SizedBox(height: 20),
            _buildInventorySummary(items),
          ],
        );
      },
    );
  }

  static pw.Page _buildAppointmentReportPage(
    List<SalonAppointment> appointments,
    String period,
  ) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Appointment Report - $period',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            _buildAppointmentTable(appointments),
            pw.SizedBox(height: 20),
            _buildAppointmentSummary(appointments),
          ],
        );
      },
    );
  }

  // Table builders (static methods from original PdfService)
  static pw.Widget _buildProfitTable(List<ProfitData> data) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          children: [
            _buildTableHeader('Date'),
            _buildTableHeader('Revenue'),
            _buildTableHeader('Profit'),
            _buildTableHeader('Expenses'),
            _buildTableHeader('Profit Margin'),
          ],
        ),
        for (var item in data)
          pw.TableRow(
            children: [
              _buildTableCell(Formatters.formatDate(item.date)),
              _buildTableCell(Formatters.formatCurrency(item.revenue)),
              _buildTableCell(Formatters.formatCurrency(item.profit)),
              _buildTableCell(Formatters.formatCurrency(item.expenses)),
              _buildTableCell('${item.profitMargin.toStringAsFixed(1)}%'),
            ],
          ),
      ],
    );
  }

  static pw.Widget _buildEarningsTable(List<EarningsData> data) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          children: [
            _buildTableHeader('Date'),
            _buildTableHeader('Amount'),
            _buildTableHeader('Appointments'),
            _buildTableHeader('Tips'),
            _buildTableHeader('Avg per Appointment'),
          ],
        ),
        for (var item in data)
          pw.TableRow(
            children: [
              _buildTableCell(Formatters.formatDate(item.date)),
              _buildTableCell(Formatters.formatCurrency(item.amount)),
              _buildTableCell(item.appointments.toString()),
              _buildTableCell(Formatters.formatCurrency(item.tips)),
              _buildTableCell(
                Formatters.formatCurrency(
                  item.appointments > 0 ? item.amount / item.appointments : 0,
                ),
              ),
            ],
          ),
      ],
    );
  }

  static pw.Widget _buildStaffPerformanceTable(List<Expert> experts) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          children: [
            _buildTableHeader('Name'),
            _buildTableHeader('Appointments'),
            _buildTableHeader('Earnings'),
            _buildTableHeader('Rating'),
            _buildTableHeader('Specialties'),
          ],
        ),
        for (var expert in experts)
          pw.TableRow(
            children: [
              _buildTableCell(expert.name),
              _buildTableCell(expert.totalAppointments.toString()),
              _buildTableCell(Formatters.formatCurrency(expert.totalEarnings)),
              _buildTableCell(expert.rating.toStringAsFixed(1)),
              _buildTableCell(expert.specialties.join(', ')),
            ],
          ),
      ],
    );
  }

  static pw.Widget _buildInventoryTable(List<InventoryItem> items) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          children: [
            _buildTableHeader('Product'),
            _buildTableHeader('Quantity'),
            _buildTableHeader('Price'),
            _buildTableHeader('Status'),
            _buildTableHeader('Last Updated'),
          ],
        ),
        for (var item in items)
          pw.TableRow(
            children: [
              _buildTableCell(item.productName ?? 'Unknown'),
              _buildTableCell(item.quantityInStock.toString()),
              _buildTableCell(
                Formatters.formatCurrency(item.productPrice ?? 0),
              ),
              _buildTableCell(
                item.isCriticalStock
                    ? 'Critical'
                    : item.isLowStock
                    ? 'Low'
                    : 'Good',
              ),
              _buildTableCell(Formatters.formatDate(item.lastUpdated)),
            ],
          ),
      ],
    );
  }

  static pw.Widget _buildAppointmentTable(List<SalonAppointment> appointments) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          children: [
            _buildTableHeader('Date'),
            _buildTableHeader('Customer'),
            _buildTableHeader('Service'),
            _buildTableHeader('Status'),
            _buildTableHeader('Amount'),
          ],
        ),
        for (var appointment in appointments)
          pw.TableRow(
            children: [
              _buildTableCell(Formatters.formatDate(appointment.startTime)),
              _buildTableCell('Customer ${appointment.customerId}'),
              _buildTableCell(
                appointment.services.isNotEmpty
                    ? appointment.services.first.serviceType
                    : 'Unknown',
              ),
              _buildTableCell(appointment.status.toString().split('.').last),
              _buildTableCell(
                appointment.payment != null
                    ? Formatters.formatCurrency(appointment.payment!.amount)
                    : 'N/A',
              ),
            ],
          ),
      ],
    );
  }

  // Summary builders
  static pw.Widget _buildProfitSummary(List<ProfitData> data) {
    final totalRevenue = data.fold(0.0, (sum, item) => sum + item.revenue);
    final totalProfit = data.fold(0.0, (sum, item) => sum + item.profit);
    final totalExpenses = data.fold(0.0, (sum, item) => sum + item.expenses);
    final avgProfitMargin = totalRevenue > 0
        ? (totalProfit / totalRevenue) * 100
        : 0;

    return _buildSummaryContainer('Profit Summary', [
      'Total Revenue: ${Formatters.formatCurrency(totalRevenue)}',
      'Total Profit: ${Formatters.formatCurrency(totalProfit)}',
      'Total Expenses: ${Formatters.formatCurrency(totalExpenses)}',
      'Average Profit Margin: ${avgProfitMargin.toStringAsFixed(1)}%',
      'Number of Records: ${data.length}',
    ]);
  }

  static pw.Widget _buildEarningsSummary(List<EarningsData> data) {
    final totalEarnings = data.fold(0.0, (sum, item) => sum + item.amount);
    final totalTips = data.fold(0.0, (sum, item) => sum + item.tips);
    final totalAppointments = data.fold(
      0,
      (sum, item) => sum + item.appointments,
    );
    final avgPerAppointment = totalAppointments > 0.0
        ? totalEarnings / totalAppointments
        : 0.0;

    return _buildSummaryContainer('Earnings Summary', [
      'Total Earnings: ${Formatters.formatCurrency(totalEarnings)}',
      'Total Tips: ${Formatters.formatCurrency(totalTips)}',
      'Total Appointments: $totalAppointments',
      'Average per Appointment: ${Formatters.formatCurrency(avgPerAppointment)}',
    ]);
  }

  static pw.Widget _buildPerformanceSummary(List<Expert> experts) {
    final totalAppointments = experts.fold(
      0,
      (sum, expert) => sum + expert.totalAppointments,
    );
    final totalEarnings = experts.fold(
      0.0,
      (sum, expert) => sum + expert.totalEarnings,
    );
    final averageRating =
        experts.fold(0.0, (sum, expert) => sum + expert.rating) /
        experts.length;

    return _buildSummaryContainer('Performance Summary', [
      'Total Appointments: $totalAppointments',
      'Total Earnings: ${Formatters.formatCurrency(totalEarnings)}',
      'Average Rating: ${averageRating.toStringAsFixed(1)}',
      'Number of Experts: ${experts.length}',
    ]);
  }

  static pw.Widget _buildInventorySummary(List<InventoryItem> items) {
    final lowStockCount = items.where((item) => item.isLowStock).length;
    final criticalStockCount = items
        .where((item) => item.isCriticalStock)
        .length;
    final totalValue = items.fold(0.0, (sum, item) {
      final price = item.productPrice ?? 0;
      return sum + (price * item.quantityInStock);
    });

    return _buildSummaryContainer('Inventory Summary', [
      'Total Items: ${items.length}',
      'Low Stock Items: $lowStockCount',
      'Critical Stock Items: $criticalStockCount',
      'Total Inventory Value: ${Formatters.formatCurrency(totalValue)}',
    ]);
  }

  static pw.Widget _buildAppointmentSummary(
    List<SalonAppointment> appointments,
  ) {
    final completed = appointments
        .where((a) => a.status == AppointmentStatus.completed)
        .length;
    final cancelled = appointments
        .where((a) => a.status == AppointmentStatus.cancelled)
        .length;
    final scheduled = appointments
        .where((a) => a.status == AppointmentStatus.scheduled)
        .length;
    final totalRevenue = appointments.fold(0.0, (sum, appointment) {
      if (appointment.payment != null &&
          appointment.status == AppointmentStatus.completed) {
        return sum + appointment.payment!.amount;
      }
      return sum;
    });

    return _buildSummaryContainer('Appointment Summary', [
      'Total Appointments: ${appointments.length}',
      'Completed: $completed',
      'Scheduled: $scheduled',
      'Cancelled: $cancelled',
      'Total Revenue: ${Formatters.formatCurrency(totalRevenue)}',
    ]);
  }

  // Helper methods for table building
  static pw.Widget _buildTableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8.0),
      child: pw.Text(text, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
    );
  }

  static pw.Widget _buildTableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8.0),
      child: pw.Text(text),
    );
  }

  static pw.Widget _buildSummaryContainer(String title, List<String> items) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
          ),
          pw.SizedBox(height: 10),
          for (var item in items) pw.Text(item),
        ],
      ),
    );
  }
}
