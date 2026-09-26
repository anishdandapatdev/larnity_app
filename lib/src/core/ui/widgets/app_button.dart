import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String? label;
  final TextStyle? labelStyle;
  final VoidCallback? onPressed;
  final Widget? prefix;
  final Widget? suffix;
  final Widget? icon;
  final Widget? child;
  final double? radius;
  final Color? bgColor;
  final Color? borderColor;
  final double? borderWidth;
  final double? height;
  final double? width;
  final bool isExpanded;
  final EdgeInsets? padding;
  final bool isLoading;
  final Widget? loadingWidget;

  const AppButton({
    super.key,
    this.label,
    this.labelStyle,
    this.onPressed,
    this.prefix,
    this.suffix,
    this.icon,
    this.child,
    this.borderColor,
    this.borderWidth,
    this.radius,
    this.bgColor,
    this.height,
    this.width,
    this.isExpanded = true,
    this.padding,
    this.isLoading = false,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(
          side: borderColor != null
              ? BorderSide(color: borderColor!, width: borderWidth ?? 1.0)
              : BorderSide.none,
          borderRadius: BorderRadius.circular(radius ?? 8),
        ),
        minimumSize: Size(
          width ?? (isExpanded ? double.infinity : 0),
          height ?? 48,
        ),
        padding: padding ?? EdgeInsets.symmetric(horizontal: 16),
      ),
      child: isLoading
          ? loadingWidget ?? const CircularProgressIndicator()
          : child ??
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (prefix != null) ...[prefix!, const SizedBox(width: 8)],
                    if (icon != null) ...[icon!, const SizedBox(width: 8)],
                    if (label != null)
                      Flexible(
                        child: Text(
                          label!,
                          style: labelStyle,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (suffix != null) ...[const SizedBox(width: 8), suffix!],
                  ],
                ),
    );
  }
}
