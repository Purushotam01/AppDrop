import 'package:flutter/material.dart';
import '../core/models/component.dart';
import 'components/banner_widget.dart';
import 'components/carousel_widget.dart';
import 'components/grid_widget.dart';
import 'components/video_widget.dart';
import 'components/text_widget.dart';
import 'package:dynamic_widget_renderer/core/models/app_theme.dart';

class ComponentFactory {
  static Widget createComponent(Component component) {
    final widget = _createWidget(component);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
    boxShadow: AppTheme.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: widget,
      ),
    );
  }

  static Widget _createWidget(Component component) {
    switch (component.type) {
      case ComponentType.banner:
        return BannerWidget.fromComponent(component);
      case ComponentType.carousel:
        return CarouselWidget.fromComponent(component);
      case ComponentType.grid:
        return GridWidget.fromComponent(component);
      case ComponentType.video:
        final props = component.properties;
        final url = props['url'] as String? ?? '';
        return VideoWidget.fromComponent(component, key: ValueKey('video_$url'));
      case ComponentType.text:
        return TextWidget.fromComponent(component);
    }
  }
}