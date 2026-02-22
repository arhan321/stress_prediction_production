import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

/// Custom scroll behavior that hides scrollbars while maintaining scroll functionality
class NoScrollbarBehavior extends ScrollBehavior {
  const NoScrollbarBehavior();

  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    // Return child without scrollbar wrapper to completely hide scrollbar
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    // Use ClampingScrollPhysics for smooth scrolling on all platforms
    return const ClampingScrollPhysics();
  }

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    // Remove overscroll glow effect on Android
    return child;
  }

  @override
  Set<PointerDeviceKind> get dragDevices {
    // Enable scrolling for all device types (touch, mouse, stylus)
    return {
      PointerDeviceKind.touch,
      PointerDeviceKind.mouse,
      PointerDeviceKind.stylus,
      PointerDeviceKind.trackpad,
    };
  }
} 