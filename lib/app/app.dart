import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../Packages/features/navigation/sidebar.dart';
import '../Packages/features/navigation/sidebar_controller.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with SingleTickerProviderStateMixin {
  final SidebarController sidebarController = SidebarController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    sidebarController.init(this);
  }

  @override
  void dispose() {
    sidebarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("home_page".tr()),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => sidebarController.toggleSidebar(),
        ),
      ),
      body: Stack(
        children: [
          // Home Page Content
          AnimatedBuilder(
            animation: sidebarController.animation,
            builder: (context, child) {
              return Transform(
                transform: Matrix4.identity()
                  ..translate(
                    sidebarController.animation.value * 200,
                    sidebarController.animation.value * 50,
                  )
                  ..scale(1 - sidebarController.animation.value * 0.1),
                alignment: Alignment.centerLeft,
                child: Opacity(
                  opacity: 1 - sidebarController.animation.value * 0.3,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha:
                            sidebarController.animation.value * 0.3,
                          ),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const HomePage(),
                  ),
                ),
              );
            },
          ),

          // Sidebar
          Sidebar(controller: sidebarController),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Text(
          "home_page_content".tr(),
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
