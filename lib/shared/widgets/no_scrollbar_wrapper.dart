import 'package:flutter/material.dart';
import '../../core/theme/custom_scroll_behavior.dart';

/// A wrapper widget that ensures no scrollbar is visible for any scrollable content
class NoScrollbarWrapper extends StatelessWidget {
  final Widget child;
  final ScrollPhysics? physics;

  const NoScrollbarWrapper({
    super.key,
    required this.child,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const NoScrollbarBehavior(),
      child: child,
    );
  }
}

/// Extension to easily hide scrollbars on any scrollable widget
extension NoScrollbarExtension on Widget {
  /// Wraps the widget with NoScrollbarWrapper to hide scrollbars
  Widget withoutScrollbar() {
    return NoScrollbarWrapper(child: this);
  }
}

/// Custom ListView that automatically hides scrollbars
class NoScrollbarListView extends ListView {
  NoScrollbarListView({
    super.key,
    super.scrollDirection,
    super.reverse,
    super.controller,
    super.primary,
    super.physics,
    super.shrinkWrap,
    super.padding,
    super.itemExtent,
    super.prototypeItem,
    super.addAutomaticKeepAlives,
    super.addRepaintBoundaries,
    super.addSemanticIndexes,
    super.cacheExtent,
    super.children,
    super.semanticChildCount,
    super.dragStartBehavior,
    super.keyboardDismissBehavior,
    super.restorationId,
    super.clipBehavior,
  });

  NoScrollbarListView.builder({
    super.key,
    super.scrollDirection,
    super.reverse,
    super.controller,
    super.primary,
    super.physics,
    super.shrinkWrap,
    super.padding,
    super.itemExtent,
    super.prototypeItem,
    super.addAutomaticKeepAlives,
    super.addRepaintBoundaries,
    super.addSemanticIndexes,
    super.cacheExtent,
    super.semanticChildCount,
    super.dragStartBehavior,
    super.keyboardDismissBehavior,
    super.restorationId,
    super.clipBehavior,
    required NullableIndexedWidgetBuilder super.itemBuilder,
    ChildIndexGetter? findChildIndexCallback,
    super.itemCount,
  }) : super.builder(findChildIndexCallback: findChildIndexCallback);

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const NoScrollbarBehavior(),
      child: super.build(context),
    );
  }
}

/// Custom SingleChildScrollView that automatically hides scrollbars
class NoScrollbarSingleChildScrollView extends SingleChildScrollView {
  const NoScrollbarSingleChildScrollView({
    super.key,
    super.scrollDirection,
    super.reverse,
    super.padding,
    super.primary,
    super.physics,
    super.controller,
    super.child,
    super.dragStartBehavior,
    super.clipBehavior,
    super.restorationId,
    super.keyboardDismissBehavior,
  });

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const NoScrollbarBehavior(),
      child: super.build(context),
    );
  }
} 