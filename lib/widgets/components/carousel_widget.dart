import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../core/models/component.dart';
import '../../utils/network_image_builder.dart';
import 'package:dynamic_widget_renderer/core/models/app_theme.dart';

class CarouselWidget extends StatefulWidget {
  final List<String> images;
  final double height;
  final bool autoPlay;
  final double padding;

  const CarouselWidget({
    super.key,
    required this.images,
    required this.height,
    required this.autoPlay,
    required this.padding,
  });

  factory CarouselWidget.fromComponent(Component component) {
    final props = component.properties;
    return CarouselWidget(
      images: List<String>.from(props['images'] ?? []),
      height: (props['height'] as num?)?.toDouble() ?? 220,
      autoPlay: props['autoPlay'] as bool? ?? true,
      padding: (props['padding'] as num?)?.toDouble() ?? 12,
    );
  }

  @override
  State<CarouselWidget> createState() => _CarouselWidgetState();
}

class _CarouselWidgetState extends State<CarouselWidget> {
  int _currentIndex = 0;
  bool _isDisposed = false;
  
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    if (widget.images.isEmpty) {
      return Container(
        height: widget.height,
        margin: EdgeInsets.all(widget.padding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: isDarkMode
                ? [
                    Colors.grey.shade800,
                    Colors.grey.shade900,
                  ]
                : [
                    Colors.grey.shade100,
                    Colors.grey.shade200,
                  ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.broken_image_rounded,
                size: 48,
                color: isDarkMode ? Colors.grey[400] : Colors.grey,
              ),
              const SizedBox(height: 8),
              Text(
                'No images available',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(widget.padding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: widget.height,
            width: double.infinity,
            child: CarouselSlider.builder(
              options: CarouselOptions(
                height: widget.height,
                autoPlay: widget.autoPlay,
                autoPlayInterval: const Duration(seconds: 3),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: true,
                viewportFraction: 0.85,
                onPageChanged: (index, reason) {
                  if (mounted && !_isDisposed) {
                    try {
                      setState(() {
                        _currentIndex = index;
                      });
                    } catch (e) {
                    }
                  }
                },
              ),
            itemCount: widget.images.length,
            itemBuilder: (context, index, realIndex) {
              return AnimatedScale(
                duration: const Duration(milliseconds: 300),
                scale: _currentIndex == index ? 1 : 0.95,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: -5,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        NetworkImageBuilder(
                          imageUrl: widget.images[index],
                          height: widget.height,
                          fit: BoxFit.cover,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.2),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${index + 1}/${widget.images.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.images.asMap().entries.map((entry) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _currentIndex == entry.key ? 24 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          gradient: _currentIndex == entry.key
            ? AppTheme.primaryGradient
            : LinearGradient(
                          colors: [
                            Colors.grey.shade300,
                            Colors.grey.shade400,
                          ],
                        ),
                  boxShadow: _currentIndex == entry.key
                      ? [
                          BoxShadow(
                            color: const Color(0xFF4361EE).withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 0,
                          ),
                        ]
                      : [],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}