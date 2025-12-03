import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dynamic_widget_renderer/app/app.dart';
import 'package:dynamic_widget_renderer/utils/audio_manager.dart';

void main() async {
  runZonedGuarded(() async {
  WidgetsFlutterBinding.ensureInitialized();
  
    await AudioManager.setAudioSession();
    
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
  ]);
  
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
    
    FlutterError.onError = (FlutterErrorDetails details) {
      final errorString = details.exception.toString();
      if (errorString.contains('setState() or markNeedsBuild() called when widget tree was locked')) {
        return; 
      }
      if (errorString.contains('PlayerNotifier was used after being disposed') ||
          errorString.contains('A PlayerNotifier was used after being disposed')) {
        return; 
      }
      if (errorString.contains('setState() called after dispose()') ||
          errorString.contains('setState() called after dispose')) {
        return; 
      }
     
      if (errorString.contains('Failed to change device orientation') ||
          errorString.contains('UISceneErrorDomain Code=101')) {
        return; 
      }
      FlutterError.presentError(details);
    };
  
    runApp(const DynamicWidgetRendererApp());
  }, (error, stack) {
    final errorString = error.toString();
    if (errorString.contains('setState() or markNeedsBuild() called when widget tree was locked')) {
      return; 
    }
    if (errorString.contains('PlayerNotifier was used after being disposed') ||
        errorString.contains('A PlayerNotifier was used after being disposed')) {
      return; 
    }
    if (errorString.contains('setState() called after dispose()') ||
        errorString.contains('setState() called after dispose')) {
      return; 
    }
    if (errorString.contains('Failed to change device orientation') ||
        errorString.contains('UISceneErrorDomain Code=101')) {
      return; 
    }
    print('Unhandled exception: $error\n$stack');
  });
}