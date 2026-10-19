import 'package:flutter/material.dart';

/// Icon with proper semantic label for screen readers
class AccessibleIcon extends StatelessWidget {
  final IconData icon;
  final String semanticLabel;
  final double? size;
  final Color? color;

  const AccessibleIcon({
    super.key,
    required this.icon,
    required this.semanticLabel,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: ExcludeSemantics(
        child: Icon(
          icon,
          size: size,
          color: color,
        ),
      ),
    );
  }
}

/// IconButton with proper semantic label and tap target size
class AccessibleIconButton extends StatelessWidget {
  final IconData icon;
  final String semanticLabel;
  final String? tooltip;
  final VoidCallback onPressed;
  final double? iconSize;
  final Color? color;

  const AccessibleIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    this.tooltip,
    this.iconSize,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: true,
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        tooltip: tooltip ?? semanticLabel,
        iconSize: iconSize,
        color: color,
        // Ensure minimum tap target
        constraints: const BoxConstraints(
          minWidth: 48,
          minHeight: 48,
        ),
      ),
    );
  }
}
