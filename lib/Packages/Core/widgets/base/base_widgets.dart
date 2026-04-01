import 'package:flutter/material.dart';
import 'package:na3eeman/Helpers/error_handler.dart';
import '../../constants/app_color.dart';
import '../../constants/app_images.dart';
import '../../themes/glass_appbar.dart';
import '../../utils/helpers/themes_helpers.dart';
import 'package:easy_localization/easy_localization.dart';


abstract class BaseState<T extends StatefulWidget> extends State<T> {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  // Theme and gender properties - to be overridden by subclasses
  bool get isDarkMode => Theme.of(context).brightness == Brightness.dark;
  UserGender? get userGender => null; // Override in subclasses

  void setLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  void setError(String? error) {
    setState(() {
      _error = error;
    });
  }

  void clearError() {
    setState(() {
      _error = null;
    });
  }

  Future<void> handleApiCall<T>(
    Future<T> Function() apiCall, {
    Function(T)? onSuccess,
    Function(AppError)? onError,
    bool showLoading = true,
  }) async {
    try {
      if (showLoading) setLoading(true);
      clearError();

      final result = await apiCall();

      if (onSuccess != null) {
        onSuccess(result);
      }
    } catch (e) {
      final errorMessage = ErrorHandler.getUserFriendlyMessage(e);
      setError(errorMessage);

      final handledError = ErrorHandler.handleException(e);
      if (onError != null && handledError is AppError) {
        onError(handledError);
      } else if (handledError is AppError) {
        _showErrorSnackbar(handledError.message);
      } else {
        _showErrorSnackbar(errorMessage);
      }
    } finally {
      if (showLoading) setLoading(false);
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _getErrorColor(),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color _getErrorColor() {
    return isDarkMode ? AppColor.darkError : AppColor.lightError;
  }

  Color _getIconColor() {
    if (userGender != null) {
      switch (userGender!) { // Add ! to handle null case
        case UserGender.male:
          return AppColor.maleAccent;
        case UserGender.female:
          return AppColor.femaleAccent;
        case UserGender.nonBinary:
          return AppColor.nonBinaryAccent;
      }
    }
    return isDarkMode ? AppColor.darkText : AppColor.lightText;
  }

  Widget buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_getIconColor()),
          ),
          const SizedBox(height: 16),
          Text('loading'.tr(),
            style: TextStyle(
              color: isDarkMode ? AppColor.darkText : AppColor.lightText,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildErrorState() {
    final errorIcon = isDarkMode ? AppImages.dislike_view : AppImages.dislike;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              errorIcon,
              width: 64,
              height: 64,
              color: _getErrorColor(),
            ),
            const SizedBox(height: 16),
            Text('oops_something_went_wrong'.tr(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? AppColor.darkText : AppColor.lightText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'An unexpected error occurred',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => retry(),
              icon: Icon(
                Icons.refresh,
                color: _getIconColor(),
              ),
              label: Text('try_again'.tr(),
                style: TextStyle(
                  color: isDarkMode ? AppColor.darkText : AppColor.lightText,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode ? AppColor.darkCard : AppColor.lightCard,
                foregroundColor: _getIconColor(),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void retry() {
    // To be implemented by subclasses
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return buildLoadingState();
    }

    if (_error != null) {
      return buildErrorState();
    }

    return buildContent();
  }

  Widget buildContent();
}

class BasePage extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final bool showBackButton;
  final bool centerTitle;
  final bool useGlassAppBar;
  final UserGender? userGender;
  final bool? forceDarkMode;
  final double expandedHeight;
  final Widget? flexibleSpace;

  const BasePage({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.showBackButton = true,
    this.centerTitle = true,
    this.useGlassAppBar = false,
    this.userGender,
    this.forceDarkMode,
    this.expandedHeight = 200,
    this.flexibleSpace,
  });

  bool _isDarkMode(BuildContext context) {
    return forceDarkMode ?? Theme.of(context).brightness == Brightness.dark;
  }

  PreferredSizeWidget _buildStandardAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: _isDarkMode(context) ? AppColor.darkText : AppColor.lightText,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: _isDarkMode(context) ? AppColor.darkCard : AppColor.lightCard,
      elevation: 2,
      leading: showBackButton
          ? IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: _getIconColor(context),
              ),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      actions: actions,
      iconTheme: IconThemeData(
        color: _getIconColor(context),
      ),
    );
  }

  Widget _buildGlassAppBar(BuildContext context) {
    return GlassSliverAppBar(
      title: title,
      showBackButton: showBackButton,
      userGender: userGender,
      isDarkMode: _isDarkMode(context),
      actions: actions,
      expandedHeight: expandedHeight,
    );
  }

  Color _getIconColor(BuildContext context) {
    if (userGender != null) {
      switch (userGender!) { // Add ! to handle null case
        case UserGender.male:
          return AppColor.maleAccent;
        case UserGender.female:
          return AppColor.femaleAccent;
        case UserGender.nonBinary:
          return AppColor.nonBinaryAccent;
      }
    }
    return _isDarkMode(context) ? AppColor.darkText : AppColor.lightText;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: useGlassAppBar ? null : _buildStandardAppBar(context),
      body: useGlassAppBar
          ? CustomScrollView(
              slivers: [
                _buildGlassAppBar(context),
                SliverToBoxAdapter(
                  child: SafeArea(child: body),
                ),
              ],
            )
          : SafeArea(child: body),
      backgroundColor: _isDarkMode(context) ? AppColor.darkBackground : AppColor.lightBackground,
    );
  }
}

// Enhanced version with flexible space support
class BasePageWithFlexibleSpace extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final bool showBackButton;
  final bool centerTitle;
  final UserGender? userGender;
  final bool? forceDarkMode;
  final double expandedHeight;
  final Widget? flexibleSpace;
  final List<Widget>? slivers;

  const BasePageWithFlexibleSpace({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.showBackButton = true,
    this.centerTitle = true,
    this.userGender,
    this.forceDarkMode,
    this.expandedHeight = 200,
    this.flexibleSpace,
    this.slivers,
  });

  bool _isDarkMode(BuildContext context) {
    return forceDarkMode ?? Theme.of(context).brightness == Brightness.dark;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          GlassSliverAppBar(
            title: title,
            showBackButton: showBackButton,
            userGender: userGender,
            isDarkMode: _isDarkMode(context),
            actions: actions,
            expandedHeight: expandedHeight,
          ),
          if (slivers != null) ...slivers!,
          if (slivers == null)
            SliverToBoxAdapter(
              child: SafeArea(child: body),
            ),
        ],
      ),
      backgroundColor: _isDarkMode(context) ? AppColor.darkBackground : AppColor.lightBackground,
    );
  }
}
