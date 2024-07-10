import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:xpenso/Data/defaulttxnaccountdata.dart';
import 'package:xpenso/Data/themes.dart';
import 'package:xpenso/Models/accountmodel.dart';
import 'package:xpenso/Models/budgetmodel.dart';
import 'package:xpenso/Models/categorymodel.dart';
import 'package:xpenso/Models/transactionmodel.dart';
import 'package:xpenso/firebase_options.dart';
import 'package:xpenso/notification/notificationpage.dart';
import 'package:xpenso/notification/budgetnotification.dart';
import 'package:xpenso/screens/otherscreens/accounts.dart';
import 'package:xpenso/screens/otherscreens/homescreen.dart';
import 'package:xpenso/screens/otherscreens/transactionrecord.dart';
import 'package:xpenso/services/Provider/categoryservices.dart';
import 'package:xpenso/services/new.dart';
import 'package:xpenso/services/Provider/themePreference.dart';
import 'package:xpenso/services/Provider/transactionservices.dart';
import 'package:xpenso/services/other/streambuilder.dart';
import 'package:xpenso/widgets/layout/mainscreenlayout.dart';

final navigatorKey = GlobalKey<NavigatorState>();
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
   await LocalNotifications.init();

    var initialNotification =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  if (initialNotification?.didNotificationLaunchApp == true) {
    // LocalNotifications.onClickNotification.stream.listen((event) {
    Future.delayed(Duration(seconds: 1), () {
      // print(event);
      navigatorKey.currentState!.pushNamed('/another',
          arguments: initialNotification?.notificationResponse?.payload);
    });
  }
  
   

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();

  // Register Hive adapters

  Hive.registerAdapter(CategoryAdapter());

  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(AccountsAdapter());

  // Open Hive boxes
  Hive.registerAdapter(BudgetAdapter());
  await Hive.openBox<Budget>('budgets');

  await Hive.openBox<Category>('categories');

  await Hive.openBox<Transaction>('transactions');
  await Hive.openBox<Accounts>('Accounts');
  await Hive.openBox('themeBox');
  await Hive.openBox('fexpdel');
  await Hive.openBox('fexpadd');
  await Hive.openBox('facadd');
  await Hive.openBox('facdel');
  await Hive.openBox('fbudadd');
  await Hive.openBox('fbuddel');

  await Hive.openBox('fcatadd');
  await Hive.openBox('fcatdel');





  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CategoryService()),
        ChangeNotifierProvider(create: (context) => TransactionServices()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            themeMode: themeProvider.theme,
            theme: ThemeClass.lightTheme,
            darkTheme: ThemeClass.darkTheme,
            home: Start());
      },
    );
  }
}
