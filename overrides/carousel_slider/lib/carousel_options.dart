import 'package:flutter/animation.dart';

typedef OnPageChangedCallback = void Function(int index, CarouselPageChangedReason reason);

enum CarouselPageChangedReason { manual, timed }

class CarouselOptions {
  final double? height;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final Duration autoPlayAnimationDuration;
  final Curve autoPlayCurve;
  final bool enlargeCenterPage;
  final double viewportFraction;
  final OnPageChangedCallback? onPageChanged;

  const CarouselOptions({
    this.height,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 3),
    this.autoPlayAnimationDuration = const Duration(milliseconds: 800),
    this.autoPlayCurve = Curves.linear,
    this.enlargeCenterPage = false,
    this.viewportFraction = 1.0,
    this.onPageChanged,
  });
}
