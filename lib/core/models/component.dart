enum ComponentType {
  banner,
  carousel,
  grid,
  video,
  text,
}

class Component {
  final ComponentType type;
  final Map<String, dynamic> properties;

  Component({
    required this.type,
    required this.properties,
  });

  factory Component.fromJson(Map<String, dynamic> json) {
    final typeString = json['type'] as String? ?? '';
    final properties = Map<String, dynamic>.from(json);
    properties.remove('type');

    return Component(
      type: _parseType(typeString),
      properties: properties,
    );
  }

  static ComponentType _parseType(String type) {
    switch (type) {
      case 'banner':
        return ComponentType.banner;
      case 'carousel':
        return ComponentType.carousel;
      case 'grid':
        return ComponentType.grid;
      case 'video':
        return ComponentType.video;
      case 'text':
        return ComponentType.text;
      default:
        throw ArgumentError('Unknown component type: $type');
    }
  }
}

class PageSchema {
  final List<Component> components;

  PageSchema({required this.components});

  factory PageSchema.fromJson(Map<String, dynamic> json) {
    final pageData = json['page'] as Map<String, dynamic>? ?? {};
    final componentsList = pageData['components'] as List<dynamic>? ?? [];

    return PageSchema(
      components: componentsList
          .map((componentJson) => Component.fromJson(
                Map<String, dynamic>.from(componentJson),
              ))
          .toList(),
    );
  }
}