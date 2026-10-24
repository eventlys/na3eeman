import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' hide RefreshIndicator;

// import 'package:easy_localization/easy_localization.dart';

class RefreshableList extends StatelessWidget {
  final RefreshController refreshController;
  final VoidCallback onRefresh;
  final VoidCallback? onLoading;
  final Widget child;
  final bool enablePullUp;
  final bool enablePullDown;

  const RefreshableList({
    super.key,
    required this.refreshController,
    required this.onRefresh,
    this.onLoading,
    required this.child,
    this.enablePullUp = true,
    this.enablePullDown = true,
  });

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: refreshController,
      enablePullDown: enablePullDown,
      enablePullUp: enablePullUp,
      onRefresh: onRefresh,
      onLoading: onLoading,
      header: CustomHeader(
        builder: (context, mode) {
          Widget body;
          if (mode == RefreshStatus.idle) {
            body = Text("pull_down_to_refresh".tr());
          } else if (mode == RefreshStatus.refreshing) {
            body = const CircularProgressIndicator();
          } else if (mode == RefreshStatus.failed) {
            body = Text("refresh_failed".tr());
          } else if (mode == RefreshStatus.canRefresh) {
            body = Text("release_to_refresh".tr());
          } else {
            body = Text("refresh_completed".tr());
          }
          return SizedBox(height: 60, child: Center(child: body));
        },
      ),
      footer: CustomFooter(
        builder: (context, mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
            body = Text("pull_up_to_load_more".tr());
          } else if (mode == LoadStatus.loading) {
            body = const CircularProgressIndicator();
          } else if (mode == LoadStatus.failed) {
            body = Text("load_failed".tr());
          } else if (mode == LoadStatus.canLoading) {
            body = Text("release_to_load_more".tr());
          } else {
            body = Text("no_more_data".tr());
          }
          return SizedBox(height: 60, child: Center(child: body));
        },
      ),
      child: child,
    );
  }
}

class RefreshIndicatorWrapper extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;

  const RefreshIndicatorWrapper({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(onRefresh: onRefresh, child: child);
  }
}
