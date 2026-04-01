import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Providers/main_providers.dart';
import '../../../../Services/business_service.dart';
import '../../../../Services/enums/report_enums.dart';
import '../../constants/app_color.dart';
import 'package:easy_localization/easy_localization.dart';

class ReportDownloadDialog extends StatefulWidget {
  final BusinessService businessService;
  final String initialFileName;
  final DateTime startDate;
  final DateTime endDate;
  final String? branchId;
  final String? staffId;

  const ReportDownloadDialog({
    super.key,
    required this.businessService,
    required this.initialFileName,
    required this.startDate,
    required this.endDate,
    this.branchId,
    this.staffId,
  });

  @override
  State<ReportDownloadDialog> createState() => _ReportDownloadDialogState();
}

class _ReportDownloadDialogState extends State<ReportDownloadDialog> {
  final _fileNameController = TextEditingController();
  ReportTime _selectedTime = ReportTime.monthly;
  StaffReportType _selectedReportType = StaffReportType.performance;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _fileNameController.text = widget.initialFileName;
  }

  void _generateReport() async {
    if (_isGenerating) return;

    setState(() {
      _isGenerating = true;
    });

    try {
      // Get shopId from provider
      final shopProvider = Provider.of<ShopProvider>(context, listen: false);
      final selectedShop = shopProvider.selectedShop;

      if (selectedShop == null) {
        throw Exception('No shop selected. Please select a shop first.');
      }

      final request = StaffReportRequest(
        time: _selectedTime,
        startDate: widget.startDate,
        endDate: widget.endDate,
        branchId: widget.branchId,
        staffId: widget.staffId,
        fileName: _fileNameController.text.isEmpty
            ? 'report_${DateTime.now().millisecondsSinceEpoch}'
            : _fileNameController.text,
        reportType: _selectedReportType,
      );

      // Pass the shopId to the service method
      await widget.businessService.generateStaffReport(
        request,
        shopId: selectedShop.id, // Use the shop ID from provider
      );

      if (mounted) {
        Navigator.of(context).pop(true);
        _showSuccessSnackbar();
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  void _showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('report_success'.tr()),
        backgroundColor: AppColor.lightSuccess,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackbar(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to generate report: $error'),
        backgroundColor: AppColor.lightError,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final shopProvider = Provider.of<ShopProvider>(context);
    final selectedShop = shopProvider.selectedShop;

    return AlertDialog(
      title: Text('download_report'.tr()),
      backgroundColor: isDarkTheme ? AppColor.darkCard : AppColor.lightCard,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('file_format_pdf'.tr(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDarkTheme ? AppColor.darkText : AppColor.lightText,
              ),
            ),
            const SizedBox(height: 16),

            // Shop Information
            if (selectedShop != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDarkTheme ? AppColor.darkBackground : AppColor.lightBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDarkTheme ? AppColor.darkTextHint : AppColor.lightTextHint,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.store,
                      color: isDarkTheme ? AppColor.darkPrimary : AppColor.lightPrimary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        selectedShop.shopName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDarkTheme ? AppColor.darkText : AppColor.lightText,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Report Type Dropdown
            DropdownButtonFormField<StaffReportType>(
              initialValue: _selectedReportType,
              decoration: InputDecoration(
                labelText: 'report_type'.tr(),
                labelStyle: TextStyle(
                  color: isDarkTheme ? AppColor.darkText : AppColor.lightText,
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: isDarkTheme ? AppColor.darkTextHint : AppColor.lightTextHint,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: isDarkTheme ? AppColor.darkTextHint : AppColor.lightTextHint,
                  ),
                ),
              ),
              dropdownColor: isDarkTheme ? AppColor.darkCard : AppColor.lightCard,
              style: TextStyle(
                color: isDarkTheme ? AppColor.darkText : AppColor.lightText,
              ),
              items: StaffReportType.values.map((type) {
                return DropdownMenuItem<StaffReportType>(
                  value: type,
                  child: Text(
                    _getReportTypeDisplayName(type),
                    style: TextStyle(
                      color: isDarkTheme ? AppColor.darkText : AppColor.lightText,
                    ),
                  ),
                );
              }).toList(),
              onChanged: _isGenerating ? null : (value) {
                if (value != null) {
                  setState(() {
                    _selectedReportType = value;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // Time Period Dropdown
            DropdownButtonFormField<ReportTime>(
              initialValue: _selectedTime,
              decoration: InputDecoration(
                labelText: 'time_period'.tr(),
                labelStyle: TextStyle(
                  color: isDarkTheme ? AppColor.darkText : AppColor.lightText,
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: isDarkTheme ? AppColor.darkTextHint : AppColor.lightTextHint,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: isDarkTheme ? AppColor.darkTextHint : AppColor.lightTextHint,
                  ),
                ),
              ),
              dropdownColor: isDarkTheme ? AppColor.darkCard : AppColor.lightCard,
              style: TextStyle(
                color: isDarkTheme ? AppColor.darkText : AppColor.lightText,
              ),
              items: ReportTime.values.map((time) {
                return DropdownMenuItem<ReportTime>(
                  value: time,
                  child: Text(
                    _getTimeDisplayName(time),
                    style: TextStyle(
                      color: isDarkTheme ? AppColor.darkText : AppColor.lightText,
                    ),
                  ),
                );
              }).toList(),
              onChanged: _isGenerating ? null : (value) {
                if (value != null) {
                  setState(() {
                    _selectedTime = value;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // File Name Input
            TextFormField(
              controller: _fileNameController,
              enabled: !_isGenerating,
              decoration: InputDecoration(
                labelText: 'file_name'.tr(),
                labelStyle: TextStyle(
                  color: isDarkTheme ? AppColor.darkText : AppColor.lightText,
                ),
                hintText: 'enter_file_name'.tr(),
                hintStyle: TextStyle(
                  color: isDarkTheme ? AppColor.darkTextHint : AppColor.lightTextHint,
                ),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: isDarkTheme ? AppColor.darkTextHint : AppColor.lightTextHint,
                  ),
                ),
              ),
              style: TextStyle(
                color: isDarkTheme ? AppColor.darkText : AppColor.lightText,
              ),
            ),

            const SizedBox(height: 16),

            // Report Information
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDarkTheme ? AppColor.darkBackground : AppColor.lightBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDarkTheme ? AppColor.darkTextHint : AppColor.lightTextHint,
                  width: 0.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('report_details'.tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDarkTheme ? AppColor.darkText : AppColor.lightText,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Period: ${_getTimeDisplayName(_selectedTime)}',
                    style: TextStyle(
                      color: isDarkTheme ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Date Range: ${_formatDate(widget.startDate)} - ${_formatDate(widget.endDate)}',
                    style: TextStyle(
                      color: isDarkTheme ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
                      fontSize: 12,
                    ),
                  ),
                  if (selectedShop != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Shop: ${selectedShop.shopName}',
                      style: TextStyle(
                        color: isDarkTheme ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  if (widget.branchId != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Branch ID: ${widget.branchId}',
                      style: TextStyle(
                        color: isDarkTheme ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  if (widget.staffId != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Staff ID: ${widget.staffId}',
                      style: TextStyle(
                        color: isDarkTheme ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            if (_isGenerating) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDarkTheme ? AppColor.loadingPrimaryDark : AppColor.loadingPrimaryLight,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('generating_report'.tr(),
                    style: TextStyle(
                      color: isDarkTheme ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isGenerating ? null : () => Navigator.of(context).pop(false),
          child: Text('cancel'.tr(),
            style: TextStyle(
              color: isDarkTheme ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: (selectedShop == null || _isGenerating) ? null : _generateReport,
          style: ElevatedButton.styleFrom(
            backgroundColor: (selectedShop == null || _isGenerating)
                ? (isDarkTheme ? AppColor.darkTextHint : AppColor.lightTextHint)
                : AppColor.lightPrimary,
            foregroundColor: Colors.white,
          ),
          child: _isGenerating
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDarkTheme ? AppColor.loadingPrimaryDark : AppColor.loadingPrimaryLight,
                    ),
                  ),
                )
              : Text('download'.tr()),
        ),
      ],
    );
  }

  String _getTimeDisplayName(ReportTime time) {
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

  String _getReportTypeDisplayName(StaffReportType type) {
    switch (type) {
      case StaffReportType.daily:
        return 'Daily Report';
      case StaffReportType.weekly:
        return 'Weekly Report';
      case StaffReportType.monthly:
        return 'Monthly Report';
      case StaffReportType.annually:
        return 'Annual Report';
      case StaffReportType.performance:
        return 'Performance Report';
      case StaffReportType.payroll:
        return 'Payroll Report';
      case StaffReportType.attendance:
        return 'Attendance Report';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
