import 'package:flutter/material.dart';
import 'enums.dart';

class SuperUtils {
  static EdgeInsets getTooltipMargin({
    CloseButtonType? closeButtonType,
    double? closeButtonSize,
    double? arrowTipDistance,
    double? arrowLength,
    TooltipDirection? preferredDirection,
    bool? showCloseButton,
  }) {
    final top = !(showCloseButton ?? false)
        ? 0.0
        : (closeButtonType == CloseButtonType.outside)
            ? (closeButtonSize ?? 0.0) + 12
            : 0.0;

    switch (preferredDirection) {
      case TooltipDirection.down:
        return EdgeInsets.only(
            top: (arrowTipDistance ?? 0.0) + (arrowLength ?? 0.0));

      case TooltipDirection.up:
        return EdgeInsets.only(
            bottom: (arrowTipDistance ?? 0.0) + (arrowLength ?? 0.0), top: top);

      case TooltipDirection.left:
        return EdgeInsets.only(
            right: (arrowTipDistance ?? 0.0) + (arrowLength ?? 0.0), top: top);

      case TooltipDirection.right:
        return EdgeInsets.only(
            left: (arrowTipDistance ?? 0.0) + (arrowLength ?? 0.0), top: top);

      default:
        throw ArgumentError(preferredDirection);
    }
  }

  static EdgeInsets getTooltipPadding({
    CloseButtonType? closeButtonType,
    double? closeButtonSize,
    bool? showCloseButton,
  }) {
    final top = !(showCloseButton ?? false)
        ? 0.0
        : (closeButtonType == CloseButtonType.inside)
            ? (closeButtonSize ?? 0.0)
            : 0.0;
    return EdgeInsets.only(top: top);
  }

  static double leftMostXtoTarget({
    double? left,
    double? right,
    double? margin,
    Size? size,
    Size? childSize,
    Offset? target,
  }) {
    double leftMostXtoTarget;

    leftMostXtoTarget = left ?? 0.0;

    return leftMostXtoTarget;
  }

  static double topMostYtoTarget({
    double? top,
    double? bottom,
    double? margin,
    Offset? target,
    Size? size,
    Size? childSize,
  }) {
    double topmostYtoTarget;

    topmostYtoTarget = top ?? 0.0;

    return topmostYtoTarget;
  }

  static BoxConstraints horizontalConstraints({
    BoxConstraints? constraints,
    double? top,
    double? bottom,
    double? right,
    double? left,
    double? margin,
    bool? isRight,
    Offset? target,
  }) {
    var maxHeight = constraints?.maxHeight ?? double.infinity;
    var minWidth = constraints?.minWidth ?? 0.0;
    var maxWidth = constraints?.maxWidth ?? double.infinity;

    if (bottom != null) {
      maxHeight = maxHeight - ((top ?? 0.0) + bottom);
    } else if ((bottom == null) || (top == null)) {
      final sideDelta = (top ?? 0.0) + (bottom ?? 0.0) + (margin ?? 0.0);

      if (maxHeight > maxHeight - sideDelta) {
        maxHeight = maxHeight - sideDelta;
      }
    } else {
      if (maxHeight > maxHeight - 2 * (margin ?? 0.0)) {
        maxHeight = maxHeight - 2 * (margin ?? 0.0);
      }
    }

    if (isRight ?? false) {
      minWidth = maxWidth = maxWidth - (right ?? 0.0) - (target?.dx ?? 0.0);
    } else {
      minWidth = maxWidth = (target?.dx ?? 0.0) - (left ?? 0.0);
    }

    return constraints?.copyWith(
          maxHeight: maxHeight,
          minWidth: minWidth,
          maxWidth: maxWidth,
        ) ??
        BoxConstraints(
          maxHeight: maxHeight,
          minWidth: minWidth,
          maxWidth: maxWidth,
        );
  }

  static BoxConstraints verticalConstraints({
    BoxConstraints? constraints,
    double? margin,
    bool? isUp,
    double? top,
    double? left,
    double? right,
    double? bottom,
    Offset? target,
  }) {
    var minHeight = constraints?.minHeight ?? 0.0;
    var maxHeight = constraints?.maxHeight ?? double.infinity;
    var maxWidth = constraints?.maxWidth ?? double.infinity;

    if (right != null) {
      maxWidth = maxWidth - ((left ?? 0.0) + right);
    } else if ((right == null) || (left == null)) {
      final sideDelta = (left ?? 0.0) + (right ?? 0.0) + (margin ?? 0.0);

      if (maxWidth > maxWidth - sideDelta) {
        maxWidth = maxWidth - sideDelta;
      }
    } else {
      if (maxWidth > maxWidth - 2 * (margin ?? 0.0)) {
        maxWidth = maxWidth - 2 * (margin ?? 0.0);
      }
    }

    if (isUp ?? false) {
      minHeight = maxHeight = (target?.dy ?? 0.0) - (top ?? 0.0);
    } else {
      minHeight = maxHeight = maxHeight - (bottom ?? 0.0) - (target?.dy ?? 0.0);
    }

    return constraints?.copyWith(
          minHeight: minHeight,
          maxHeight: maxHeight,
          maxWidth: maxWidth,
        ) ??
        BoxConstraints(
          minHeight: minHeight,
          maxHeight: maxHeight,
          maxWidth: maxWidth,
        );
  }
}
