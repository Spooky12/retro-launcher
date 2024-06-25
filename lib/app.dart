import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nes_ui/nes_ui.dart';

import 'presentation/pages/home_page.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    Future(updateBrightness);
  }

  void updateBrightness() {
    final brightness = View.of(context).platformDispatcher.platformBrightness;
    final reverse =
        brightness == Brightness.light ? Brightness.dark : Brightness.light;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarIconBrightness: reverse,
        systemNavigationBarIconBrightness: reverse,
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();

    updateBrightness();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Retro launcher',
      theme: flutterNesTheme(),
      darkTheme: flutterNesTheme(brightness: Brightness.dark),
      home: const HomePage(),
    );
  }
}
