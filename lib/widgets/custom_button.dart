import 'package:flutter/material.dart';

/// === Custom Button ===
class CustomButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final String? imageAsset;
  final VoidCallback onPressed;
  final double? width;
  final double height;
  final Color color;
  final Color textColor;
  final double borderRadius;
  final TextStyle? textStyle;
  final double? elevation;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.imageAsset,
    this.width,
    this.height = 50,
    this.color = Colors.blue,
    this.textColor = Colors.white,
    this.borderRadius = 13,
    this.textStyle,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: elevation,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imageAsset != null) ...[
              Image.asset(
                imageAsset!,
                height: 24,
                width: 24,
              ),
              const SizedBox(width: 10),
            ] else if (icon != null) ...[
              Icon(icon, color: textColor),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: textStyle ??
                  TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

//Custom Floating Back Button
class CustomFloatingBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final double size;
  final Color backgroundColor;
  final Color iconColor;

  const CustomFloatingBackButton({
    super.key,
    this.onPressed,
    this.icon = Icons.arrow_back,
    this.size = 50,
    this.backgroundColor = Colors.blue,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: FloatingActionButton(
        onPressed: onPressed ?? () => Navigator.pop(context),
        backgroundColor: backgroundColor,
        child: Icon(icon, color: iconColor),
      ),
    );
  }
}
