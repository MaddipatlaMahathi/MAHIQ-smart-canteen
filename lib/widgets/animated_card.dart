import 'package:flutter/material.dart';

class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;

  const AnimatedCard({
    Key? key,
    required this.child,
    this.onTap,
    this.margin = const EdgeInsets.only(bottom: 16),
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null) _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.onTap != null) _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      child: MouseRegion(
        onEnter: (_) {
          if (widget.onTap != null) {
            setState(() => _isHovered = true);
          }
        },
        onExit: (_) {
          if (widget.onTap != null) {
            setState(() => _isHovered = false);
          }
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: widget.padding,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: Theme.of(context).cardTheme.shape != null
                        ? (Theme.of(context).cardTheme.shape as RoundedRectangleBorder).borderRadius
                        : BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: _isHovered ? Colors.black26 : Colors.black12,
                        blurRadius: _isHovered ? 12 : 6,
                        offset: _isHovered ? const Offset(0, 6) : const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: Theme.of(context).cardTheme.shape != null
                        ? (Theme.of(context).cardTheme.shape as RoundedRectangleBorder).borderRadius
                        : BorderRadius.circular(16),
                    child: child,
                  ),
                ),
              );
            },
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
