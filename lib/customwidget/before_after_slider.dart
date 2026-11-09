import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BeforeAfterSlider extends StatefulWidget {
  final Widget beforeImage;
  final Widget afterImage;
  final double thumbRadius;
  final Color thumbColor;
  final Color backgroundColor;

  const BeforeAfterSlider({
    Key? key,
    required this.beforeImage,
    required this.afterImage,
    this.thumbRadius = 16.0,
    this.thumbColor = Colors.white,
    this.backgroundColor = Colors.transparent,
  }) : super(key: key);

  @override
  _BeforeAfterSliderState createState() => _BeforeAfterSliderState();
}

class _BeforeAfterSliderState extends State<BeforeAfterSlider> {
  double _sliderPosition = 0.5; // Starts at the middle

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final maxHeight = constraints.maxHeight;
        
        return Stack(
          children: [
            // Bottom image (After)
            SizedBox(
              width: maxWidth,
              height: maxHeight,
              child: widget.afterImage,
            ),
            
            // Top image (Before) wrapped in ClipRect
            ClipRect(
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: _sliderPosition,
                child: Container(
                  width: maxWidth,
                  height: maxHeight,
                  color: widget.backgroundColor,
                  child: widget.beforeImage,
                ),
              ),
            ),
            
            // The vertical line and draggable thumb
            Positioned(
              left: maxWidth * _sliderPosition - widget.thumbRadius,
              top: 0,
              bottom: 0,
              child: GestureDetector(
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    _sliderPosition += details.delta.dx / maxWidth;
                    _sliderPosition = _sliderPosition.clamp(0.0, 1.0);
                  });
                },
                child: SizedBox(
                  width: widget.thumbRadius * 2,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // White vertical line
                      Container(
                        width: 2.0,
                        color: Colors.white,
                      ),
                      // Thumb circle with icon
                      Container(
                        width: widget.thumbRadius * 2,
                        height: widget.thumbRadius * 2,
                        decoration: BoxDecoration(
                          color: widget.thumbColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                            )
                          ],
                        ),
                        child: Icon(
                          Icons.code, // Looking somewhat like < > arrows
                          color: Colors.grey.shade600,
                          size: widget.thumbRadius,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // "Before" badge
            Positioned(
              top: 16,
              left: 16,
              child: _buildBadge('Before'.tr),
            ),
            
            // "After" badge
            Positioned(
              top: 16,
              right: 16,
              child: _buildBadge('After'.tr),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF282F3E).withOpacity(0.85),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
