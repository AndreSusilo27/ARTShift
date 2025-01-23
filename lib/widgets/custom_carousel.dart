import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CustomCarousel extends StatefulWidget {
  const CustomCarousel({super.key});

  @override
  State<CustomCarousel> createState() => _CustomCarouselState();
}

class _CustomCarouselState extends State<CustomCarousel> {
  int _currentIndex = 0;

  final List<String> imagePaths = [
    'assets/images/Employee.png',
    'assets/images/Admin.png',
    'assets/images/Shift.png',
    'assets/images/Meeting.png',
  ];

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double carouselHeight = screenHeight * 0.65; // 65% dari tinggi layar

    return Column(
      children: [
        SizedBox(
          height: carouselHeight,
          child: CarouselSlider(
            items: imagePaths.map((imagePath) {
              return ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0), // Transparan di atas
                      Colors.black.withOpacity(0.3), // Lebih gelap di tengah
                      Colors.black.withOpacity(0.6), // Semakin pekat di bawah
                    ],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.overlay, // Lebih smooth
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit
                        .cover, // Menyesuaikan gambar agar memenuhi slider
                    width: double.infinity, // Gunakan lebar maksimum
                    height: carouselHeight, // Menentukan tinggi agar konsisten
                  ),
                ),
              );
            }).toList(),
            options: CarouselOptions(
              height: carouselHeight,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              enlargeCenterPage: true,
              viewportFraction: 0.90, // Menggunakan seluruh lebar slider
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: imagePaths.asMap().entries.map((entry) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _currentIndex == entry.key ? 16 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: _currentIndex == entry.key ? Colors.blue : Colors.grey,
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
