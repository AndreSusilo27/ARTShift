import 'package:flutter/material.dart';

/// === Custom Button ===
class CustomButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onPressed;
  final double? width;
  final double? height;
  final Color? color;
  final double borderRadius;

  const CustomButton({
    required this.text,
    required this.onPressed,
    this.icon,
    this.width,
    this.height = 50, // Default tinggi 50
    this.color = Colors.blue, // Default warna biru
    this.borderRadius = 8, // Default border radius 8
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity, // Default penuh jika tidak diatur
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: EdgeInsets.symmetric(vertical: 14),
          elevation: 5,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white),
              SizedBox(width: 8), // Jarak antara ikon dan teks
            ],
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// === Custom Floating Back Button ===
class CustomFloatingBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final double size;
  final Color backgroundColor;
  final Color iconColor;

  const CustomFloatingBackButton({
    super.key,
    this.onPressed,
    this.icon = Icons.arrow_back, // Default ikon kembali
    this.size = 50, // Default ukuran FloatingActionButton
    this.backgroundColor = Colors.blueGrey, // Default warna tombol
    this.iconColor = Colors.white, // Default warna ikon
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
