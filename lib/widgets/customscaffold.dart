import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:xpenso/services/authenticate.dart';

class CustomScaffold extends StatelessWidget {
  
   CustomScaffold({
    super.key,
    this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.drawer,
    this.endDrawer,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.drawerEnableOpenDragGesture = true,
    this.endDrawerEnableOpenDragGesture = true,
    this.floatingActionButtonLocation,
    this.floatingActionButtonAnimator,
    this.resizeToAvoidBottomInset,
    this.drawerDragStartBehavior = DragStartBehavior.start,
    this.drawerScrimColor,
    this.drawerEdgeDragWidth,
    this.showiconbutton = false,
    this.signout,
  });

  final Widget? body,
      floatingActionButton,
      bottomNavigationBar,
      drawer,
      bottomSheet,
      endDrawer;
  final bool? resizeToAvoidBottomInset;
  final bool extendBody,
      extendBodyBehindAppBar,
      endDrawerEnableOpenDragGesture,
      drawerEnableOpenDragGesture,
      showiconbutton;
  final PreferredSizeWidget? appBar;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final FloatingActionButtonAnimator? floatingActionButtonAnimator;
  final DragStartBehavior drawerDragStartBehavior;
  final Color? drawerScrimColor;
  final double? drawerEdgeDragWidth;
  final void Function()? signout;
  final Authenticate _auth = Authenticate();

  @override
  Widget build(BuildContext context) {
    List<Color> dark = [
      Color(0xffff007f),
      Colors.pinkAccent,
      Colors.amberAccent
    ];

        List<Color> light = [
           Colors.amberAccent,
     
    
      Colors.amberAccent
    ];
    return Stack(
      children: [
        Container(
          height: double.infinity,
          width: double.infinity,
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.blue
              : Colors.black,
        ),
        ClipPath(
          clipper: CustomClipPath(),
          child: Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: Theme.of(context).brightness == Brightness.light
              ? light
              : dark, begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            
            leading: IconButton(
                onPressed: () {
                  if (ZoomDrawer.of(context)!.isOpen()) {
                    ZoomDrawer.of(context)!.close();
                  } else {
                    ZoomDrawer.of(context)!.open();
                  }
                },
                icon: Icon(Icons.menu)),
            backgroundColor   :    Colors.transparent,
            elevation: 0,
            flexibleSpace: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ClipRRect(
                  child: Align(
                    heightFactor: 10,
                    widthFactor: 90,
                    child: Image.asset(
                      'assets/images/appbarlogo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            actions: showiconbutton
                ? <Widget>[
                    IconButton(
                        icon: Icon(
                          Icons.exit_to_app_sharp,
                          color: Colors.white,
                        ),
                        onPressed: signout)
                  ]
                : null,
          ),
          body: body,
          floatingActionButton: floatingActionButton,
          floatingActionButtonLocation: floatingActionButtonLocation,
          extendBody: extendBody,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          bottomNavigationBar: bottomNavigationBar,
          drawer: drawer,
          endDrawer: endDrawer,
          drawerDragStartBehavior: drawerDragStartBehavior,
          bottomSheet: bottomSheet,
          extendBodyBehindAppBar: extendBodyBehindAppBar,
          drawerEdgeDragWidth: drawerEdgeDragWidth,
          floatingActionButtonAnimator: floatingActionButtonAnimator,
          drawerEnableOpenDragGesture: drawerEnableOpenDragGesture,
          drawerScrimColor: drawerScrimColor,
          endDrawerEnableOpenDragGesture: endDrawerEnableOpenDragGesture,
        )
      ],
    );
  }
  

}

class CustomClipPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path_0 = Path();
    path_0.moveTo(0, 0);
    path_0.lineTo(size.width * -0.0085714, size.height * 0.8531429);
    path_0.quadraticBezierTo(size.width * 0.5257143, size.height * 1.1200000,
        size.width * 0.8005714, size.height * 0.8965714);
    path_0.quadraticBezierTo(size.width * 1.0097143, size.height * 0.7274286,
        size.width * 1.0022857, size.height * 0.3211429);
    path_0.lineTo(size.width, size.height * 0.0028571);
    path_0.close();
    return path_0;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
