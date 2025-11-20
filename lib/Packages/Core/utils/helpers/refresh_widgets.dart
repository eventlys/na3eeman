import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' hide RefreshIndicator;

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
            body = const Text("Pull down to refresh");
          } else if (mode == RefreshStatus.refreshing) {
            body = const CircularProgressIndicator();
          } else if (mode == RefreshStatus.failed) {
            body = const Text("Refresh failed!");
          } else if (mode == RefreshStatus.canRefresh) {
            body = const Text("Release to refresh");
          } else {
            body = const Text("Refresh completed");
          }
          return Container(
            height: 60,
            child: Center(child: body),
          );
        },
      ),
      footer: CustomFooter(
        builder: (context, mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
            body = const Text("Pull up to load more");
          } else if (mode == LoadStatus.loading) {
            body = const CircularProgressIndicator();
          } else if (mode == LoadStatus.failed) {
            body = const Text("Load failed!");
          } else if (mode == LoadStatus.canLoading) {
            body = const Text("Release to load more");
          } else {
            body = const Text("No more data");
          }
          return Container(
            height: 60,
            child: Center(child: body),
          );
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
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: child,
    );
  }
}
