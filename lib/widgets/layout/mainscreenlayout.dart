import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:xpenso/screens/otherscreens/homescreen.dart';

import 'package:xpenso/widgets/layout/mainscreenpageslayout.dart';
import 'package:xpenso/widgets/draweritems.dart';

class MainScreenLayout extends StatefulWidget {
  const MainScreenLayout({super.key});

  @override
  State<MainScreenLayout> createState() => _MainScreenLayoutState();
}

class _MainScreenLayoutState extends State<MainScreenLayout> {
  final zoomDrawerController = ZoomDrawerController();
  @override
  Widget build(BuildContext context) {
    return ZoomDrawer(
      controller: zoomDrawerController,
      menuScreen: Drawermenu(),
      mainScreen: MainScreenPagesLayout(),
      duration: Duration(milliseconds: 200),
      menuBackgroundColor: Theme.of(context).brightness==Brightness.light?Colors.amberAccent:Color.fromARGB(255, 68, 58, 58),
    
    );
  }
}
