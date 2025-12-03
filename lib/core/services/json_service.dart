import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:dynamic_widget_renderer/core/models/component.dart';

class JsonService {
  Future<PageSchema> loadPageSchema() async {
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final jsonString = await rootBundle.loadString('assets/page_schema.json');
      
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return PageSchema.fromJson(jsonMap);
    } catch (e) {
      throw Exception('Failed to load or parse JSON: $e');
    }
  }
}