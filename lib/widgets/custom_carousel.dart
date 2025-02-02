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
    'assets/images/slideshow/Karyawan.jpg',
    'assets/images/slideshow/Admin.jpg',
    'assets/images/slideshow/Orang Banyak.jpg',
    'assets/images/slideshow/Meeting.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double carouselHeight = screenHeight * 0.65;

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
                      const Color.fromARGB(0, 0, 0, 0),
                      const Color.fromARGB(85, 0, 0, 0),
                      const Color.fromARGB(135, 0, 0, 0),
                    ],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.overlay,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: carouselHeight,
                  ),
                ),
              );
            }).toList(),
            options: CarouselOptions(
              height: carouselHeight,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              enlargeCenterPage: true,
              viewportFraction: 0.90,
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
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
