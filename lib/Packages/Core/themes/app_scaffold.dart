import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../features/navigation/widgets/custom_navigation_bar.dart';
import '../utils/helpers/refresh_widgets.dart';
import '../utils/helpers/themes_helpers.dart';
import 'app_theme.dart';
import 'glass_appbar.dart';
import '../widgets/shared/error_widget.dart';


class AppScaffold extends StatelessWidget {
  final String? title;
  final Widget? body;
  final bool showAppBar;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final Widget? drawer;
  final Widget? endDrawer;
  final PreferredSizeWidget? appBar;
  final bool resizeToAvoidBottomInset;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final String? heroTag;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final bool showLoading;
  final String? errorMessage;
  final VoidCallback? onErrorRetry;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final bool safeArea;
  final ScrollController? scrollController;
  final bool useGlassSliverAppBar;
  final List<Widget>? slivers;
  final Widget? customBody;

  // Refresh functionality
  final RefreshController? refreshController;
  // final VoidCallback? onRefreshVoid; // For simple void callbacks
  final Future<void> Function()? onRefreshFuture;
  final dynamic onRefresh;
  final VoidCallback? onLoading;
  final bool enablePullUp;
  final bool enablePullDown;
  final bool useRefreshIndicator;

  // GlassSliverAppBar specific properties
  final UserGender? userGender;
  final bool isDarkMode;
  final Color? glassBackgroundColor;
  final Color? glassTextColor;
  final List<Color>? glassGradientColors;
  final VoidCallback? onGlassBackPressed;
  final bool glassPinned;
  final bool glassFloating;
  final bool glassSnap;
  final double glassExpandedHeight;
  final double glassCollapsedHeight;
  final Widget? glassLeading;

  // Navigation specific
  final dynamic user; // User object for navigation bar

  const AppScaffold({
    super.key,
    this.title,
    this.body,
    this.showAppBar = true,
    this.showBackButton = false,
    this.actions,
    this.floatingActionButton,
    this.backgroundColor,
    this.drawer,
    this.endDrawer,
    this.appBar,
    this.resizeToAvoidBottomInset = true,
    this.extendBody = true,
    this.extendBodyBehindAppBar = false,
    this.heroTag,
    this.scaffoldKey,
    this.showLoading = false,
    this.errorMessage,
    this.onErrorRetry,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.safeArea = true,
    this.scrollController,
    this.useGlassSliverAppBar = false,
    this.slivers,
    this.customBody,

    // GlassSliverAppBar properties
    this.userGender,
    this.isDarkMode = false,
    this.glassBackgroundColor,
    this.glassTextColor,
    this.glassGradientColors,
    this.onGlassBackPressed,
    this.glassPinned = true,
    this.glassFloating = false,
    this.glassSnap = false,
    this.glassExpandedHeight = 200,
    this.glassCollapsedHeight = kToolbarHeight,
    this.glassLeading,

    // Refresh parameters
    this.refreshController,
    // this.onRefreshVoid,
    this.onRefresh,
    this.onRefreshFuture,
    this.onLoading,
    this.enablePullUp = true,
    this.enablePullDown = true,
    this.useRefreshIndicator = false,

    // Navigation
    this.user,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradientColors = AppThemes.getGradientColors(context);

    return HeroControllerScope(
      controller: MaterialApp.createMaterialHeroController(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.transparent,
        appBar: showAppBar && !useGlassSliverAppBar ? _buildAppBar(context) : null,
        drawer: drawer,
        endDrawer: endDrawer,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                gradientColors.startColor,
                gradientColors.endColor,
              ],
            ),
          ),
          child: _buildRefreshableBody(context),
        ),
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        extendBody: extendBody,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
        bottomNavigationBar: bottomNavigationBar ?? (user != null ? _buildNavigationBar(context) : null),
        bottomSheet: bottomSheet,
      ),
    );
  }

  PreferredSizeWidget? _buildAppBar(BuildContext context) {
    if (appBar != null) return appBar;

    if (!showAppBar) return null;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: showBackButton
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onBackground),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      title: title != null
          ? Text(
              title!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onBackground,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
      actions: actions,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
      ),
      centerTitle: true,
      automaticallyImplyLeading: showBackButton,
    );
  }

  Widget _buildBody(BuildContext context) {
    Widget content;

    if (customBody != null) {
      content = customBody!;
    } else if (useGlassSliverAppBar) {
      content = _buildSliverContent();
    } else {
      content = body ?? const SizedBox.shrink();
    }

    // Wrap with SafeArea if enabled
    if (safeArea && !useGlassSliverAppBar) {
      content = SafeArea(
        top: true,
        bottom: true,
        left: true,
        right: true,
        minimum: const EdgeInsets.all(16.0),
        child: content,
      );
    }

    // Handle loading state
    if (showLoading) {
      content = Stack(
        children: [
          content,
          const Positioned.fill(
            child: ColoredBox(
              color: Colors.black26,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ],
      );
    }

    // Handle error state
    if (errorMessage != null) {
      content = AppErrorWidget(
        message: errorMessage!,
        onRetry: onErrorRetry,
        showRetryButton: onErrorRetry != null,
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: content,
    );
  }

  Widget _buildSliverContent() {
    final sliverList = slivers ?? [
      _buildGlassSliverAppBar(),
      SliverList(
        delegate: SliverChildListDelegate([
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: body ?? const SizedBox.shrink(),
          ),
        ]),
      ),
    ];

    return CustomScrollView(
      controller: scrollController,
      slivers: sliverList,
    );
  }

  GlassSliverAppBar _buildGlassSliverAppBar() {
    return GlassSliverAppBar(
      title: title ?? '',
      showBackButton: showBackButton,
      backgroundColor: glassBackgroundColor ?? Colors.transparent,
      textColor: glassTextColor ?? Colors.white,
      gradientColors: glassGradientColors,
      onBackPressed: onGlassBackPressed,
      actions: actions,
      pinned: glassPinned,
      floating: glassFloating,
      snap: glassSnap,
      expandedHeight: glassExpandedHeight,
      collapsedHeight: glassCollapsedHeight,
      leading: glassLeading,
      userGender: userGender,
      isDarkMode: isDarkMode,
    );
  }

  Widget _buildNavigationBar(BuildContext context) {
    return CustomNavigationBar(
      user: user,
      currentRoute: ModalRoute.of(context)?.settings.name ?? '/',
    );
  }

  Future<void> _executeRefresh() async {
    if (onRefresh == null) return;

    if (onRefresh is Future<void> Function()) {
      await (onRefresh as Future<void> Function())();
    } else if (onRefresh is VoidCallback) {
      (onRefresh as VoidCallback)();
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  Widget _buildRefreshableBody(BuildContext context) {
    Widget content = _buildBody(context);

    if (onRefresh != null) {
      if (useRefreshIndicator) {
        content = RefreshIndicatorWrapper(
          onRefresh: _executeRefresh,
          child: content,
        );
      } else if (refreshController != null) {
        content = RefreshableList(
          refreshController: refreshController!,
          onRefresh: _executeRefresh,
          onLoading: onLoading,
          enablePullUp: enablePullUp,
          enablePullDown: enablePullDown,
          child: content,
        );
      }
    }

    return content;
  }
}

/// Template for standard pages with navigation bar
class StandardPage extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool showAppBar;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool showLoading;
  final String? errorMessage;
  final VoidCallback? onErrorRetry;
  final dynamic user;
  final ScrollController? scrollController;

  const StandardPage({
    super.key,
    required this.child,
    this.title,
    this.showAppBar = true,
    this.showBackButton = false,
    this.actions,
    this.floatingActionButton,
    this.showLoading = false,
    this.errorMessage,
    this.onErrorRetry,
    required this.user,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: title,
      showAppBar: showAppBar,
      showBackButton: showBackButton,
      actions: actions,
      floatingActionButton: floatingActionButton,
      showLoading: showLoading,
      errorMessage: errorMessage,
      onErrorRetry: onErrorRetry,
      scrollController: scrollController,
      user: user,
      body: child,
    );
  }
}

/// Template for pages with glass sliver app bar
class GlassPage extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool showLoading;
  final String? errorMessage;
  final VoidCallback? onErrorRetry;
  final dynamic user;
  final ScrollController? scrollController;
  final List<Widget>? slivers;

  // GlassSliverAppBar specific
  final UserGender? userGender;
  final bool isDarkMode;
  final Color? glassBackgroundColor;
  final Color? glassTextColor;
  final List<Color>? glassGradientColors;
  final VoidCallback? onGlassBackPressed;
  final bool glassPinned;
  final bool glassFloating;
  final bool glassSnap;
  final double glassExpandedHeight;
  final double glassCollapsedHeight;
  final Widget? glassLeading;

  const GlassPage({
    super.key,
    required this.child,
    this.title,
    this.showBackButton = false,
    this.actions,
    this.floatingActionButton,
    this.showLoading = false,
    this.errorMessage,
    this.onErrorRetry,
    required this.user,
    this.scrollController,
    this.slivers,

    // GlassSliverAppBar properties
    this.userGender,
    this.isDarkMode = false,
    this.glassBackgroundColor,
    this.glassTextColor,
    this.glassGradientColors,
    this.onGlassBackPressed,
    this.glassPinned = true,
    this.glassFloating = false,
    this.glassSnap = false,
    this.glassExpandedHeight = 200,
    this.glassCollapsedHeight = kToolbarHeight,
    this.glassLeading,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: title,
      showAppBar: false,
      showBackButton: showBackButton,
      actions: actions,
      floatingActionButton: floatingActionButton,
      showLoading: showLoading,
      errorMessage: errorMessage,
      onErrorRetry: onErrorRetry,
      scrollController: scrollController,
      useGlassSliverAppBar: true,
      slivers: slivers,
      body: child,
      user: user,

      // GlassSliverAppBar properties
      userGender: userGender,
      isDarkMode: isDarkMode,
      glassBackgroundColor: glassBackgroundColor,
      glassTextColor: glassTextColor,
      glassGradientColors: glassGradientColors,
      onGlassBackPressed: onGlassBackPressed,
      glassPinned: glassPinned,
      glassFloating: glassFloating,
      glassSnap: glassSnap,
      glassExpandedHeight: glassExpandedHeight,
      glassCollapsedHeight: glassCollapsedHeight,
      glassLeading: glassLeading,
    );
  }
}

/// Template for full-screen pages without navigation bar
class FullScreenPage extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool showAppBar;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool showLoading;
  final String? errorMessage;
  final VoidCallback? onErrorRetry;
  final bool useGlassSliverAppBar;
  final ScrollController? scrollController;

  // Optional GlassSliverAppBar properties
  final UserGender? userGender;
  final bool isDarkMode;

  const FullScreenPage({
    super.key,
    required this.child,
    this.title,
    this.showAppBar = true,
    this.showBackButton = false,
    this.actions,
    this.floatingActionButton,
    this.showLoading = false,
    this.errorMessage,
    this.onErrorRetry,
    this.useGlassSliverAppBar = false,
    this.scrollController,
    this.userGender,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: title,
      showAppBar: showAppBar,
      showBackButton: showBackButton,
      actions: actions,
      floatingActionButton: floatingActionButton,
      showLoading: showLoading,
      errorMessage: errorMessage,
      onErrorRetry: onErrorRetry,
      scrollController: scrollController,
      useGlassSliverAppBar: useGlassSliverAppBar,
      body: child,
      userGender: userGender,
      isDarkMode: isDarkMode,
      // No user provided = no navigation bar
    );
  }
}

// Keep your existing specialized scaffolds (they work well with the new system)
class ScaffoldWithSidebar extends StatefulWidget {
  final Widget child;
  final Widget sidebar;
  final bool isSidebarOpen;
  final VoidCallback onSidebarToggle;
  final double sidebarWidth;
  final double maxSidebarWidth;

  const ScaffoldWithSidebar({
    super.key,
    required this.child,
    required this.sidebar,
    required this.isSidebarOpen,
    required this.onSidebarToggle,
    this.sidebarWidth = 280,
    this.maxSidebarWidth = 320,
  });

  @override
  State<ScaffoldWithSidebar> createState() => _ScaffoldWithSidebarState();
}

class _ScaffoldWithSidebarState extends State<ScaffoldWithSidebar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _sidebarAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _sidebarAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    if (widget.isSidebarOpen) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(ScaffoldWithSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSidebarOpen != oldWidget.isSidebarOpen) {
      if (widget.isSidebarOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = AppThemes.getGradientColors(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              gradientColors.startColor,
              gradientColors.endColor,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Main content
            AnimatedBuilder(
              animation: _sidebarAnimation,
              builder: (context, child) {
                return Transform(
                  transform: Matrix4.identity()
                    ..translate(
                      _sidebarAnimation.value * widget.sidebarWidth,
                      _sidebarAnimation.value * 50,
                    )
                    ..scale(1 - _sidebarAnimation.value * 0.1),
                  alignment: Alignment.centerLeft,
                  child: Opacity(
                    opacity: 1 - _sidebarAnimation.value * 0.3,
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha:
                                _sidebarAnimation.value * 0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: child,
                    ),
                  ),
                );
              },
              child: widget.child,
            ),

            // Sidebar
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: AnimatedBuilder(
                animation: _sidebarAnimation,
                builder: (context, child) {
                  return SizedBox(
                    width: widget.sidebarWidth * _sidebarAnimation.value,
                    child: child,
                  );
                },
                child: widget.sidebar,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthScaffold extends StatelessWidget {
  final Widget child;
  final String title;
  final String? subtitle;
  final bool showBackButton;

  const AuthScaffold({
    super.key,
    required this.child,
    required this.title,
    this.subtitle,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: Colors.transparent,
      showAppBar: true,
      showBackButton: showBackButton,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onBackground.withValues(alpha: 0.7),
                ),
              ),
            ],
            const SizedBox(height: 32),
            child,
          ],
        ),
      ),
    );
  }
}

class DialogScaffold extends StatelessWidget {
  final Widget child;
  final bool isDismissible;
  final Color? backgroundColor;
  final double borderRadius;
  final EdgeInsets? padding;

  const DialogScaffold({
    super.key,
    required this.child,
    this.isDismissible = true,
    this.backgroundColor,
    this.borderRadius = 16,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      insetPadding: const EdgeInsets.all(20),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(24),
        child: child,
      ),
    );
  }
}
