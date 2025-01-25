import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:msb_app/models/ui/carousel_slides.dart';

class MsbCarousel extends StatefulWidget {
  final List<MsbCarouselSlide> slides;
  final double height;
  final ValueChanged<int>? onPageChanged;
  final Widget Function(int currentIndex, MsbCarouselSlide slide)? customIndicator;

  const MsbCarousel({
    Key? key,
    required this.slides,
    this.height = 250.0,
    this.onPageChanged,
    this.customIndicator,
  }) : super(key: key);

  @override
  State<MsbCarousel> createState() => _MsbCarouselState();
}

class _MsbCarouselState extends State<MsbCarousel> {
  int _currentIndex = 0;

  Widget _defaultIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: widget.slides.asMap().entries.map((entry) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _currentIndex = entry.key;
            });
            widget.onPageChanged?.call(entry.key);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: _currentIndex == entry.key ? 20.0 : 8.0,
            height: 8.0,
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: _currentIndex == entry.key ? Colors.grey : Colors.grey.shade400,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCarouselItem(MsbCarouselSlide slide) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Image.asset(
        slide.imagePath,
        fit: BoxFit.fitWidth,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: widget.slides.length,
          itemBuilder: (context, index, realIndex) {
            final slide = widget.slides[index];
            return _buildCarouselItem(slide);
          },
          options: CarouselOptions(
            autoPlay: true,
            height: widget.height,
            viewportFraction: 1.0,
            enlargeCenterPage: true,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
              widget.onPageChanged?.call(index);
            },
          ),
        ),
        widget.customIndicator?.call(_currentIndex, widget.slides[_currentIndex]) ?? _defaultIndicator(),
      ],
    );
  }
}
