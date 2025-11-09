import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../Utils/formatters.dart';
import '../Models/profit_data.dart';
import '../Models/staff_models.dart';
import '../Models/barber.dart';
import 'package:intl/intl.dart';

class PdfService {
  // Your existing method
  static Future<void> generateProfitReport(
    List<ProfitData> data,
    String period,
    String fileName
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(level: 0, child: pw.Text('Profit Report - $period')),
              pw.SizedBox(height: 20),
              _buildProfitTable(data),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  // NEW: Staff performance report
  static Future<void> generateStaffPerformanceReport(
    List<Barber> barbers,
    StaffReportRequest request,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
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
              _buildStaffPerformanceTable(barbers),
              pw.SizedBox(height: 30),
              _buildPerformanceSummary(barbers),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  // NEW: Staff payroll report
  static Future<void> generatePayrollReport(
    List<StaffMember> staff,
    DateTime period,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Payroll Report - ${DateFormat('MMMM yyyy').format(period)}',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              _buildPayrollTable(staff),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static pw.Widget _buildProfitTable(List<ProfitData> data) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text('Revenue', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text('Profit', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text('Expenses', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),
        for (var item in data)
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8.0),
                child: pw.Text(Formatters.formatDate(item.date)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8.0),
                child: pw.Text(Formatters.formatCurrency(item.revenue)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8.0),
                child: pw.Text(Formatters.formatCurrency(item.profit)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8.0),
                child: pw.Text(Formatters.formatCurrency(item.expenses)),
              ),
            ],
          ),
      ],
    );
  }

  static pw.Widget _buildStaffPerformanceTable(List<Barber> barbers) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          children: [
            pw.Padding(padding: const pw.EdgeInsets.all(8.0), child: pw.Text('Name', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Padding(padding: const pw.EdgeInsets.all(8.0), child: pw.Text('Appointments', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Padding(padding: const pw.EdgeInsets.all(8.0), child: pw.Text('Earnings', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Padding(padding: const pw.EdgeInsets.all(8.0), child: pw.Text('Rating', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Padding(padding: const pw.EdgeInsets.all(8.0), child: pw.Text('Specialties', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
          ],
        ),
        for (var barber in barbers)
          pw.TableRow(
            children: [
              pw.Padding(padding: const pw.EdgeInsets.all(8.0), child: pw.Text(barber.name)),
              pw.Padding(padding: const pw.EdgeInsets.all(8.0), child: pw.Text(barber.totalAppointments.toString())),
              pw.Padding(padding: const pw.EdgeInsets.all(8.0), child: pw.Text(Formatters.formatCurrency(barber.totalEarnings))),
              pw.Padding(padding: const pw.EdgeInsets.all(8.0), child: pw.Text(barber.rating.toStringAsFixed(1))),
              pw.Padding(padding: const pw.EdgeInsets.all(8.0), child: pw.Text(barber.specialties.join(', '))),
            ],
          ),
      ],
    );
  }

  static pw.Widget _buildPerformanceSummary(List<Barber> barbers) {
    final totalAppointments = barbers.fold(0, (sum, barber) => sum + barber.totalAppointments);
    final totalEarnings = barbers.fold(0.0, (sum, barber) => sum + barber.totalEarnings);
    final averageRating = barbers.fold(0.0, (sum, barber) => sum + barber.rating) / barbers.length;

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Performance Summary', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
          pw.SizedBox(height: 10),
          pw.Text('Total Appointments: $totalAppointments'),
          pw.Text('Total Earnings: ${Formatters.formatCurrency(totalEarnings)}'),
          pw.Text('Average Rating: ${averageRating.toStringAsFixed(1)}'),
          pw.Text('Number of Barbers: ${barbers.length}'),
        ],
      ),
    );
  }

  static pw.Widget _buildPayrollTable(List<StaffMember> staff) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          children: [
            pw.Padding(padding: const pw.EdgeInsets.all(8.0), child: pw.Text('Name', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Padding(padding: const pw.EdgeInsets.all(8.0), child: pw.Text('Role', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Padding(padding: const pw.EdgeInsets.all(8.0), child: pw.Text('Hourly Rate', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Padding(padding: const pw.EdgeInsets.all(8.0), child: pw.Text('Estimated Hours', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Padding(padding: const pw.EdgeInsets.all(8.0), child: pw.Text('Monthly Pay', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
          ],
        ),
        for (var member in staff)
          pw.TableRow(
            children: [
              pw.Padding(padding: const pw.EdgeInsets.all(8.0), child: pw.Text(member.name)),
              pw.Padding(padding: const pw.EdgeInsets.all(8.0), child: pw.Text(member.roleString)),
              pw.Padding(padding: const pw.EdgeInsets.all(8.0), child: pw.Text(member.hourlyRate != null ? Formatters.formatCurrency(member.hourlyRate!) : 'N/A')),
              pw.Padding(padding: const pw.EdgeInsets.all(8.0), child: pw.Text('160')), // Assuming 160 hours/month
              pw.Padding(padding: const pw.EdgeInsets.all(8.0), child: pw.Text(member.hourlyRate != null ? Formatters.formatCurrency(member.hourlyRate! * 160) : 'N/A')),
            ],
          ),
      ],
    );
  }
}

