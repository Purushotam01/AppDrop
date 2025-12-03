export 'carousel_options.dart';
// Note: carousel_controller.dart export removed to avoid conflict with Flutter's CarouselController

import 'dart:async';

import 'package:flutter/material.dart';
import 'carousel_options.dart';

typedef CarouselItemBuilder = Widget Function(BuildContext context, int index, int realIndex);

class CarouselSlider extends StatefulWidget {
  final CarouselOptions options;
  final int itemCount;
  final CarouselItemBuilder? itemBuilder;
  final List<Widget>? items;

  const CarouselSlider._internal({
    Key? key,
    required this.options,
    required this.itemCount,
    this.itemBuilder,
    this.items,
  }) : super(key: key);

  factory CarouselSlider.builder({
    Key? key,
    required CarouselOptions options,
    required int itemCount,
    required CarouselItemBuilder itemBuilder,
  }) {
    return CarouselSlider._internal(
      key: key,
      options: options,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }

  @override
  State<CarouselSlider> createState() => _CarouselSliderState();
}

class _CarouselSliderState extends State<CarouselSlider> {
  late final PageController _controller;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: widget.options.viewportFraction);
    _setupAutoPlay();
  }

  void _setupAutoPlay() {
    if (widget.options.autoPlay) {
      _autoPlayTimer?.cancel();
      _autoPlayTimer = Timer.periodic(widget.options.autoPlayInterval, (_) {
        if (!mounted) return;
        try {
          final next = (_controller.page ?? _controller.initialPage).round() + 1;
          final target = next % widget.itemCount;
          _controller.animateToPage(
            target,
            duration: widget.options.autoPlayAnimationDuration,
            curve: widget.options.autoPlayCurve,
          ).then((_) {
            if (mounted) {
              widget.options.onPageChanged?.call(target, CarouselPageChangedReason.timed);
            }
          }).catchError((e) {
            // Ignore errors if controller is disposed
          });
        } catch (e) {
          // Ignore errors if widget is disposed
        }
      });
    }
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.options.height;
    Widget slider = SizedBox(
      height: height,
      child: PageView.builder(
        controller: _controller,
        itemCount: widget.itemCount,
        onPageChanged: (index) => widget.options.onPageChanged?.call(index, CarouselPageChangedReason.manual),
        itemBuilder: (context, index) {
          if (widget.itemBuilder != null) return widget.itemBuilder!(context, index, index);
          if (widget.items != null) return widget.items![index];
          return const SizedBox.shrink();
        },
      ),
    );

    if (widget.options.enlargeCenterPage) {
      // Simple transform to mimic enlarge effect: wrap with Center
      slider = Center(child: slider);
    }

    return slider;
  }
}
