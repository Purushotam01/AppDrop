import 'package:dynamic_widget_renderer/core/models/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_widget_renderer/widgets/splash_screen.dart';
import 'package:dynamic_widget_renderer/home/home_view.dart';

class DynamicWidgetRendererApp extends StatefulWidget {
  const DynamicWidgetRendererApp({super.key});

  @override
  State<DynamicWidgetRendererApp> createState() => _DynamicWidgetRendererAppState();
}

class _DynamicWidgetRendererAppState extends State<DynamicWidgetRendererApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Drop',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: SplashScreen(
        child: const HomeView(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}