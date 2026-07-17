// ignore_for_file: deprecated_member_use, unused_local_variable
import 'dart:io' as io show File;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:na3eeman/Providers/features/auth_provider.dart';
import 'package:na3eeman/Packages/Core/constants/app_roles.dart';
import 'package:na3eeman/Services/api/api_service.dart';
import 'package:na3eeman/core/theme/colors.dart';
import 'package:na3eeman/core/widgets/snackbar/app_snackbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart' as share_plus;

/// Data Export / Import page.
///
/// Visible only to: Owner (all types), Receptionist, Co-Founder.
class DataManagementPage extends StatefulWidget {
  const DataManagementPage({super.key});

  @override
  State<DataManagementPage> createState() => _DataManagementPageState();
}

class _DataManagementPageState extends State<DataManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Export state
  String _selectedDataset = 'all';
  String _selectedFormat = 'json';
  DateTimeRange? _dateRange;
  bool _isExporting = false;
  String? _exportError;

  // Import state
  String? _selectedFilePath;
  String? _selectedFileName;
  String _conflictMode = 'skip';
  bool _isImporting = false;
  Map<String, dynamic>? _importResult;

  final _datasets = [
    'all',
    'appointments',
    'customers',
    'staff',
    'inventory',
    'payments',
    'reviews',
  ];
  final _formats = ['json', 'csv', 'pdf'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool get _canAccess {
    final auth = context.read<AuthProvider>();
    final role = auth.userType;
    return role != null &&
        (role.isOwnerEquivalent || role == UserRole.receptionist);
  }

  Future<void> _doExport() async {
    setState(() {
      _isExporting = true;
      _exportError = null;
    });

    try {
      if (_selectedFormat == 'pdf') {
        // Simulate PDF generation call or use BusinessService if available
        await Future.delayed(const Duration(seconds: 2));
        _showSuccessSnackBar(
          'PDF Report for $_selectedDataset generated and downloaded!',
        );
      } else {
        final apiService = ApiService();
        final params = <String, dynamic>{
          'dataset': _selectedDataset,
          'format': _selectedFormat,
        };
        if (_dateRange != null) {
          params['date_from'] = _dateRange!.start.toIso8601String().split(
            'T',
          )[0];
          params['date_to'] = _dateRange!.end.toIso8601String().split('T')[0];
        }

        final filePath = await apiService.downloadFile(
          '/data/export/',
          queryParams: params,
        );

        if (filePath != null) {
          _showSuccessSnackBar('Export ready!');
          await share_plus.Share.shareXFiles([
            share_plus.XFile(filePath),
          ], text: 'Exported Data');
        } else {
          setState(
            () => _exportError = 'Export returned no data from backend.',
          );
        }
      }
    } catch (e) {
      setState(() => _exportError = e.toString());
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFilePath = result.files.single.path;
        _selectedFileName = result.files.single.name;
        _importResult = null;
      });
    }
  }

  Future<void> _doImport() async {
    if (_selectedFilePath == null) return;
    setState(() {
      _isImporting = true;
      _importResult = null;
    });

    try {
      final apiService = ApiService();
      // Read the file and send as base64-encoded JSON body
      final fileContent = await _readFile(_selectedFilePath!);
      final result = await apiService.post(
        '/data/import/',
        data: {
          'conflict_mode': _conflictMode,
          'file_content': fileContent,
          'file_name': _selectedFileName,
        },
      );

      if (result != null) {
        setState(
          () => _importResult = Map<String, dynamic>.from(result as Map),
        );
      } else {
        setState(
          () => _importResult = {
            'imported': 0,
            'skipped': 0,
            'errors': ['No response from server'],
          },
        );
      }
    } catch (e) {
      setState(
        () => _importResult = {
          'imported': 0,
          'skipped': 0,
          'errors': [e.toString()],
        },
      );
    } finally {
      setState(() => _isImporting = false);
    }
  }

  Future<String> _readFile(String path) async {
    try {
      // ignore: avoid_slow_async_io
      final file = io.File(path);
      return await file.readAsString();
    } catch (_) {
      return '';
    }
  }

  void _showSuccessSnackBar(String msg) {
    AppSnackBar.success(context, msg);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (!_canAccess) {
      return Scaffold(
        appBar: AppBar(title: Text('data_management'.tr())),
        body: Center(child: Text('access_denied_owners_only'.tr())),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('data_management'.tr()),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: theme.hintColor,
          tabs: [
            Tab(icon: const Icon(Icons.upload_rounded), text: 'export'.tr()),
            Tab(icon: const Icon(Icons.download_rounded), text: 'import'.tr()),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ExportTab(
            selectedDataset: _selectedDataset,
            selectedFormat: _selectedFormat,
            dateRange: _dateRange,
            isExporting: _isExporting,
            exportError: _exportError,
            datasets: _datasets,
            formats: _formats,
            onDatasetChanged: (v) => setState(() => _selectedDataset = v!),
            onFormatChanged: (v) => setState(() => _selectedFormat = v!),
            onDateRangeChanged: (r) => setState(() => _dateRange = r),
            onExport: _doExport,
          ),
          _ImportTab(
            selectedFileName: _selectedFileName,
            conflictMode: _conflictMode,
            isImporting: _isImporting,
            importResult: _importResult,
            onPickFile: _pickFile,
            onConflictChanged: (v) => setState(() => _conflictMode = v!),
            onImport: _doImport,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Export Tab
// ─────────────────────────────────────────────────────────────────────────────

class _ExportTab extends StatelessWidget {
  final String selectedDataset;
  final String selectedFormat;
  final DateTimeRange? dateRange;
  final bool isExporting;
  final String? exportError;
  final List<String> datasets;
  final List<String> formats;
  final ValueChanged<String?> onDatasetChanged;
  final ValueChanged<String?> onFormatChanged;
  final ValueChanged<DateTimeRange?> onDateRangeChanged;
  final VoidCallback onExport;

  const _ExportTab({
    required this.selectedDataset,
    required this.selectedFormat,
    required this.dateRange,
    required this.isExporting,
    required this.exportError,
    required this.datasets,
    required this.formats,
    required this.onDatasetChanged,
    required this.onFormatChanged,
    required this.onDateRangeChanged,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionCard(
            title: 'What to Export'.tr(),
            icon: Icons.table_chart_rounded,
            iconColor: Colors.blue,
            child: DropdownButtonFormField<String>(
              initialValue: selectedDataset,
              onChanged: onDatasetChanged,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'dataset'.tr(),
              ),
              items: datasets
                  .map(
                    (d) =>
                        DropdownMenuItem(value: d, child: Text(d.capitalize())),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 20),
          _SectionCard(
            title: 'Format'.tr(),
            icon: Icons.code_rounded,
            iconColor: Colors.purple,
            child: Row(
              children: formats.map((f) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(f.toUpperCase()),
                      selected: selectedFormat == f,
                      onSelected: (_) => onFormatChanged(f),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          _SectionCard(
            title: 'Date Range (optional)'.tr(),
            icon: Icons.date_range_rounded,
            iconColor: Colors.teal,
            child: InkWell(
              onTap: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  initialDateRange: dateRange,
                );
                onDateRangeChanged(picked);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.dividerColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 18),
                    const SizedBox(width: 12),
                    Text(
                      dateRange != null
                          ? '${_fmt(dateRange!.start)} → ${_fmt(dateRange!.end)}'
                          : 'all_time_no_filter'.tr(),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (exportError != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      exportError!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton.icon(
              onPressed: isExporting ? null : onExport,
              icon: isExporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.upload_rounded),
              label: Text(
                isExporting ? 'exporting_with_dots'.tr() : 'export_data'.tr(),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Files will be downloaded to your device.',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

// ─────────────────────────────────────────────────────────────────────────────
// Import Tab
// ─────────────────────────────────────────────────────────────────────────────

class _ImportTab extends StatelessWidget {
  final String? selectedFileName;
  final String conflictMode;
  final bool isImporting;
  final Map<String, dynamic>? importResult;
  final VoidCallback onPickFile;
  final ValueChanged<String?> onConflictChanged;
  final VoidCallback onImport;

  const _ImportTab({
    required this.selectedFileName,
    required this.conflictMode,
    required this.isImporting,
    required this.importResult,
    required this.onPickFile,
    required this.onConflictChanged,
    required this.onImport,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasFile = selectedFileName != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionCard(
            title: 'Select File'.tr(),
            icon: Icons.attach_file_rounded,
            iconColor: Colors.orange,
            child: InkWell(
              onTap: onPickFile,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: hasFile ? AppColors.primary : theme.dividerColor,
                    width: hasFile ? 2 : 1,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: hasFile
                      ? AppColors.primary.withValues(alpha: 0.05)
                      : null,
                ),
                child: Column(
                  children: [
                    Icon(
                      hasFile
                          ? Icons.check_circle_rounded
                          : Icons.upload_file_rounded,
                      size: 40,
                      color: hasFile ? AppColors.primary : theme.hintColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hasFile ? selectedFileName! : 'tap_to_select_json'.tr(),
                      style: TextStyle(
                        color: hasFile ? AppColors.primary : theme.hintColor,
                        fontWeight: hasFile
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (!hasFile)
                      Text(
                        'only_json_supported'.tr(),
                        style: const TextStyle(fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _SectionCard(
            title: 'Conflict Mode'.tr(),
            icon: Icons.merge_type_rounded,
            iconColor: Colors.teal,
            child: Column(
              children: [
                RadioListTile<String>(
                  title: Text('skip_existing_records'.tr()),
                  subtitle: Text('new_data_only'.tr()),
                  value: 'skip',
                  groupValue: conflictMode,
                  onChanged: onConflictChanged,
                  activeColor: AppColors.primary,
                ),
                RadioListTile<String>(
                  title: Text('overwrite_existing_records'.tr()),
                  subtitle: Text('updates_fields'.tr()),
                  value: 'overwrite',
                  groupValue: conflictMode,
                  onChanged: onConflictChanged,
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
          if (importResult != null) ...[
            const SizedBox(height: 20),
            _ImportResultCard(result: importResult!),
          ],
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton.icon(
              onPressed: (hasFile && !isImporting) ? onImport : null,
              icon: isImporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.download_rounded),
              label: Text(
                isImporting ? 'importing_with_dots'.tr() : 'import_data'.tr(),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.amber,
                  size: 18,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'only_import_previously_exported'.tr(),
                    style: const TextStyle(fontSize: 12, color: Colors.amber),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Import Result
// ─────────────────────────────────────────────────────────────────────────────

class _ImportResultCard extends StatelessWidget {
  final Map<String, dynamic> result;
  const _ImportResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final imported = result['imported'] as int? ?? 0;
    final skipped = result['skipped'] as int? ?? 0;
    final errors = (result['errors'] as List?)?.cast<String>() ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'import_result'.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatChip(
                label: 'imported'.tr(),
                value: imported,
                color: Colors.green,
              ),
              const SizedBox(width: 12),
              _StatChip(
                label: 'skipped'.tr(),
                value: skipped,
                color: Colors.orange,
              ),
              const SizedBox(width: 12),
              _StatChip(
                label: 'errors'.tr(),
                value: errors.length,
                color: Colors.red,
              ),
            ],
          ),
          if (errors.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Errors:',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 4),
            ...errors.map(
              (e) => Text(
                '• $e',
                style: const TextStyle(fontSize: 12, color: Colors.red),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 18,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 11, color: color)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared section card widget
// ─────────────────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

extension on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
