import 'package:flutter/material.dart';

import 'enums.dart';
import 'utils.dart';

class TooltipPositionDelegate extends SingleChildLayoutDelegate {
  TooltipPositionDelegate({
    this.snapsFarAwayVertically = false,
    this.snapsFarAwayHorizontally = false,
    required this.preferredDirection,
    this.constraints,
    this.margin = 0.0,
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.target,
    this.overlay,
  });

  final bool snapsFarAwayVertically;
  final bool snapsFarAwayHorizontally;
  final double margin;
  final Offset target;
  final RenderBox? overlay;
  final BoxConstraints? constraints;

  final TooltipDirection preferredDirection;
  final double? top, bottom, left, right;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    var newConstraints = constraints;

    switch (preferredDirection) {
      case TooltipDirection.up:
      case TooltipDirection.down:
        newConstraints = SuperUtils.verticalConstraints(
          constraints: newConstraints,
          margin: margin,
          bottom: bottom,
          isUp: preferredDirection == TooltipDirection.up,
          target: target,
          top: top,
          left: left,
          right: right,
        );
        break;
      case TooltipDirection.right:
      case TooltipDirection.left:
        newConstraints = SuperUtils.horizontalConstraints(
          constraints: newConstraints,
          margin: margin,
          bottom: bottom,
          isRight: preferredDirection == TooltipDirection.right,
          target: target,
          top: top,
          left: left,
          right: right,
        );
        break;
    }

    return newConstraints.copyWith(
      minHeight: newConstraints.minHeight > newConstraints.maxHeight
          ? newConstraints.maxHeight
          : newConstraints.minHeight,
      minWidth: newConstraints.minWidth > newConstraints.maxWidth
          ? newConstraints.maxWidth
          : newConstraints.minWidth,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    switch (preferredDirection) {
      case TooltipDirection.up:
      case TooltipDirection.down:
        final double topOffset = preferredDirection == TooltipDirection.up
            ? top ?? target.dy - childSize.height
            : target.dy;

        return Offset(
          SuperUtils.leftMostXtoTarget(
            childSize: childSize,
            left: left,
            margin: margin,
            right: right,
            size: size,
            target: target,
          ),
          topOffset,
        );

      case TooltipDirection.right:
      case TooltipDirection.left:
        final double leftOffset = preferredDirection == TooltipDirection.left
            ? left ?? target.dx - childSize.width
            : target.dx;
        return Offset(
          leftOffset,
          SuperUtils.topMostYtoTarget(
            bottom: bottom,
            childSize: childSize,
            margin: margin,
            size: size,
            target: target,
            top: top,
          ),
        );
      default:
        throw ArgumentError('$preferredDirection');
    }
  }

  @override
  bool shouldRelayout(covariant TooltipPositionDelegate oldDelegate) => true;
}
