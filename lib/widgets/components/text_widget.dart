import 'package:flutter/material.dart';
import '../../core/models/component.dart';
import 'package:dynamic_widget_renderer/core/models/app_theme.dart';

class TextWidget extends StatelessWidget {
  final String value;
  final double size;
  final String? font;
  final FontWeight weight;
  final TextAlign align;
  final double padding;
  final Color? color;

  const TextWidget({
    super.key,
    required this.value,
    required this.size,
    this.font,
    required this.weight,
    required this.align,
    required this.padding,
    this.color,
  });

  factory TextWidget.fromComponent(Component component) {
    final props = component.properties;
    
    final weightString = props['weight'] as String? ?? 'normal';
    FontWeight weight = FontWeight.normal;
    
    switch (weightString.toLowerCase()) {
      case 'bold':
        weight = FontWeight.w700;
        break;
      case 'w100':
        weight = FontWeight.w100;
        break;
      case 'w200':
        weight = FontWeight.w200;
        break;
      case 'w300':
        weight = FontWeight.w300;
        break;
      case 'w400':
        weight = FontWeight.w400;
        break;
      case 'w500':
        weight = FontWeight.w500;
        break;
      case 'w600':
        weight = FontWeight.w600;
        break;
      case 'w700':
        weight = FontWeight.w700;
        break;
      case 'w800':
        weight = FontWeight.w800;
        break;
      case 'w900':
        weight = FontWeight.w900;
        break;
    }
    
    // Parse text align
    final alignString = props['align'] as String? ?? 'left';
    TextAlign align = TextAlign.left;
    
    switch (alignString.toLowerCase()) {
      case 'left':
        align = TextAlign.left;
        break;
      case 'right':
        align = TextAlign.right;
        break;
      case 'center':
        align = TextAlign.center;
        break;
      case 'justify':
        align = TextAlign.justify;
        break;
    }
    
    Color? color;
    final colorString = props['color'] as String?;
    if (colorString != null && colorString.isNotEmpty) {
      final hexColor = colorString.replaceFirst('#', '');
      if (hexColor.length == 6) {
        color = Color(int.parse('FF$hexColor', radix: 16));
      }
    }

    return TextWidget(
      value: props['value'] as String? ?? '',
      size: (props['size'] as num?)?.toDouble() ?? 16,
      font: props['font'] as String?,
      weight: weight,
      align: align,
      padding: (props['padding'] as num?)?.toDouble() ?? 16,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = color ?? (isDarkMode ? Colors.white : const Color(0xFF333333));
    
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [
                  const Color(0xFF1E1E1E),
                  const Color(0xFF121212),
                ]
              : [
                  Colors.white,
                  const Color(0xFFF8F9FF),
                ],
        ),
      ),
      child: Column(
        children: [
          if (weight == FontWeight.w700 && size >= 20) ...[
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
          ShaderMask(
            shaderCallback: (bounds) {
              if (weight == FontWeight.w700 && size >= 20) {
                return LinearGradient(
                  colors: [
                    textColor,
                    Color.lerp(textColor, Colors.black, 0.3)!,
                  ],
                ).createShader(bounds);
              }
              return LinearGradient(colors: [textColor]).createShader(bounds);
            },
            child: Text(
              value,
              textAlign: align,
              style: TextStyle(
                fontSize: size,
                fontWeight: weight,
                fontFamily: font,
                height: 1.5,
                letterSpacing: weight == FontWeight.w700 ? 0.5 : 0,
              ),
            ),
          ),
          if (weight == FontWeight.w700 && size >= 20) ...[
            const SizedBox(height: 8),
            Container(
              width: 60,
              height: 1,
              color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
            ),
          ],
        ],
      ),
    );
  }
}