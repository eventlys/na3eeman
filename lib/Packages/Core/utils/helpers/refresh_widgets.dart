import 'package:na3eeman/l10n/app_localizations.dart';
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
            body = Text(AppLocalizations.of(context)!.pullDownToRefresh);
          } else if (mode == RefreshStatus.refreshing) {
            body = const CircularProgressIndicator();
          } else if (mode == RefreshStatus.failed) {
            body = Text(AppLocalizations.of(context)!.refreshFailed);
          } else if (mode == RefreshStatus.canRefresh) {
            body = Text(AppLocalizations.of(context)!.releaseToRefresh);
          } else {
            body = Text(AppLocalizations.of(context)!.refreshCompleted);
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
            body = Text(AppLocalizations.of(context)!.pullUpToLoadMore);
          } else if (mode == LoadStatus.loading) {
            body = const CircularProgressIndicator();
          } else if (mode == LoadStatus.failed) {
            body = Text(AppLocalizations.of(context)!.loadFailed);
          } else if (mode == LoadStatus.canLoading) {
            body = Text(AppLocalizations.of(context)!.releaseToLoadMore);
          } else {
            body = Text(AppLocalizations.of(context)!.noMoreData);
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
