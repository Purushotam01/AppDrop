class PageConfig {
  final String title;
  final String backgroundColor;
  final double padding;

  PageConfig({
    required this.title,
    required this.backgroundColor,
    required this.padding,
  });

  factory PageConfig.fromJson(Map<String, dynamic> json) {
    return PageConfig(
      title: json['title'] as String? ?? 'Dynamic Page',
      backgroundColor: json['backgroundColor'] as String? ?? '#FFFFFF',
      padding: (json['padding'] as num?)?.toDouble() ?? 16.0,
    );
  }
}