import 'package:flutter/material.dart';
import '../core/models/component.dart';
import '../core/services/json_service.dart';

enum HomeState {
  initial,
  loading,
  loaded,
  error,
  empty,
}

class HomeViewModel {
  final JsonService _jsonService = JsonService();
  
  HomeState _state = HomeState.initial;
  PageSchema? _pageSchema;
  String? _errorMessage;
  bool _isDisposed = false;

  HomeState get state => _state;
  PageSchema? get pageSchema => _pageSchema;
  String? get errorMessage => _errorMessage;

  Future<void> loadPageData({VoidCallback? onStateChanged}) async {
    _state = HomeState.loading;
    onStateChanged?.call();

    try {
      _pageSchema = await _jsonService.loadPageSchema();
      
      if (_pageSchema == null || _pageSchema!.components.isEmpty) {
        _state = HomeState.empty;
      } else {
        _state = HomeState.loaded;
      }
    } catch (e) {
      _state = HomeState.error;
      _errorMessage = e.toString();
    }
    
    onStateChanged?.call();
  }

  void retry(VoidCallback onStateChanged) {
    loadPageData(onStateChanged: onStateChanged);
  }

  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
  }
}
