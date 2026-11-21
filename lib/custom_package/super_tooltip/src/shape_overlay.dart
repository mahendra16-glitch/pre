import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'enums.dart';

class ShapeOverlay extends ShapeBorder {
  const ShapeOverlay({
    this.clipRect,
    this.clipAreaShape,
    this.clipAreaCornerRadius,
    this.barrierColor,
    this.overlayDimensions,
  });

  final Rect? clipRect;
  final ClipAreaShape? clipAreaShape;
  final double? clipAreaCornerRadius;
  final Color? barrierColor;
  final EdgeInsetsGeometry? overlayDimensions;

  @override
  EdgeInsetsGeometry get dimensions => overlayDimensions ?? EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addOval(clipRect ?? Rect.zero);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    var outer = Path()..addRect(rect);

    if (clipRect == null) return outer;

    Path exclusion;
    final safeClipRect = clipRect!;
    final safeCornerRadius = clipAreaCornerRadius ?? 0.0;

    if (clipAreaShape == ClipAreaShape.oval) {
      exclusion = Path()..addOval(safeClipRect);
    } else {
      exclusion = Path()
        ..moveTo(safeClipRect.left + safeCornerRadius, safeClipRect.top)
        ..lineTo(safeClipRect.right - safeCornerRadius, safeClipRect.top)
        ..arcToPoint(
          Offset(safeClipRect.right, safeClipRect.top + safeCornerRadius),
          radius: Radius.circular(safeCornerRadius),
        )
        ..lineTo(safeClipRect.right, safeClipRect.bottom - safeCornerRadius)
        ..arcToPoint(
          Offset(safeClipRect.right - safeCornerRadius, safeClipRect.bottom),
          radius: Radius.circular(safeCornerRadius),
        )
        ..lineTo(safeClipRect.left + safeCornerRadius, safeClipRect.bottom)
        ..arcToPoint(
          Offset(safeClipRect.left, safeClipRect.bottom - safeCornerRadius),
          radius: Radius.circular(safeCornerRadius),
        )
        ..lineTo(safeClipRect.left, safeClipRect.top + safeCornerRadius)
        ..arcToPoint(
          Offset(safeClipRect.left + safeCornerRadius, safeClipRect.top),
          radius: Radius.circular(safeCornerRadius),
        )
        ..close();
    }

    return Path.combine(ui.PathOperation.difference, outer, exclusion);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) =>
      canvas.drawPath(
        getOuterPath(rect),
        Paint()..color = barrierColor ?? Colors.transparent,
      );

  @override
  ShapeBorder scale(double t) {
    return ShapeOverlay(
      clipRect: clipRect,
      clipAreaShape: clipAreaShape,
      clipAreaCornerRadius: clipAreaCornerRadius,
      barrierColor: barrierColor,
      overlayDimensions: overlayDimensions,
    );
  }
}
