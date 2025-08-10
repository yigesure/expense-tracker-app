import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../utils/logger.dart';

/// 手势反馈Widget
/// 提供丰富的手势交互和触觉反馈
class GestureFeedbackWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final Function(DragUpdateDetails)? onPanUpdate;
  final Function(DragEndDetails)? onPanEnd;
  final bool enableHapticFeedback;
  final bool enableScaleAnimation;
  final bool enableRippleEffect;
  final Duration animationDuration;
  final double scaleValue;

  const GestureFeedbackWidget({
    super.key,
    required this.child,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onPanUpdate,
    this.onPanEnd,
    this.enableHapticFeedback = true,
    this.enableScaleAnimation = true,
    this.enableRippleEffect = true,
    this.animationDuration = const Duration(milliseconds: 150),
    this.scaleValue = 0.95,
  });

  @override
  State<GestureFeedbackWidget> createState() => _GestureFeedbackWidgetState();
}

class _GestureFeedbackWidgetState extends State<GestureFeedbackWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;
  static final AppLogger _logger = AppLogger('GestureFeedbackWidget');

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleValue,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.enableScaleAnimation) {
      setState(() {
        _isPressed = true;
      });
      _animationController.forward();
    }
    
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.enableScaleAnimation) {
      setState(() {
        _isPressed = false;
      });
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.enableScaleAnimation) {
      setState(() {
        _isPressed = false;
      });
      _animationController.reverse();
    }
  }

  void _handleTap() {
    _logger.info('手势点击');
    if (widget.enableHapticFeedback) {
      HapticFeedback.selectionClick();
    }
    widget.onTap?.call();
  }

  void _handleDoubleTap() {
    _logger.info('手势双击');
    if (widget.enableHapticFeedback) {
      HapticFeedback.mediumImpact();
    }
    widget.onDoubleTap?.call();
  }

  void _handleLongPress() {
    _logger.info('手势长按');
    if (widget.enableHapticFeedback) {
      HapticFeedback.heavyImpact();
    }
    widget.onLongPress?.call();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = widget.child;

    if (widget.enableScaleAnimation) {
      child = AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      );
    }

    if (widget.enableRippleEffect && widget.onTap != null) {
      child = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleTap,
          onDoubleTap: widget.onDoubleTap != null ? _handleDoubleTap : null,
          onLongPress: widget.onLongPress != null ? _handleLongPress : null,
          borderRadius: BorderRadius.circular(12),
          child: child,
        ),
      );
    } else {
      child = GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onTap != null ? _handleTap : null,
        onDoubleTap: widget.onDoubleTap != null ? _handleDoubleTap : null,
        onLongPress: widget.onLongPress != null ? _handleLongPress : null,
        onPanUpdate: widget.onPanUpdate,
        onPanEnd: widget.onPanEnd,
        child: child,
      );
    }

    return child;
  }
}

/// 长按菜单Widget
class LongPressMenuWidget extends StatelessWidget {
  final Widget child;
  final List<LongPressMenuItem> menuItems;
  final bool enableHapticFeedback;

  const LongPressMenuWidget({
    super.key,
    required this.child,
    required this.menuItems,
    this.enableHapticFeedback = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showContextMenu(context),
      child: child,
    );
  }

  void _showContextMenu(BuildContext context) {
    if (enableHapticFeedback) {
      HapticFeedback.heavyImpact();
    }

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + size.height,
        position.dx + size.width,
        position.dy + size.height + 200,
      ),
      items: menuItems.map((item) {
        return PopupMenuItem(
          value: item.value,
          child: Row(
            children: [
              if (item.icon != null) ...[
                Icon(item.icon, size: 20, color: item.color),
                const SizedBox(width: 12),
              ],
              Text(
                item.title,
                style: TextStyle(color: item.color),
              ),
            ],
          ),
        );
      }).toList(),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ).then((value) {
      if (value != null) {
        final item = menuItems.firstWhere((item) => item.value == value);
        item.onTap?.call();
      }
    });
  }
}

/// 长按菜单项
class LongPressMenuItem {
  final String value;
  final String title;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onTap;

  const LongPressMenuItem({
    required this.value,
    required this.title,
    this.icon,
    this.color,
    this.onTap,
  });
}

/// 滑动手势识别Widget
class SwipeGestureWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final VoidCallback? onSwipeUp;
  final VoidCallback? onSwipeDown;
  final double threshold;
  final bool enableHapticFeedback;

  const SwipeGestureWidget({
    super.key,
    required this.child,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onSwipeUp,
    this.onSwipeDown,
    this.threshold = 50.0,
    this.enableHapticFeedback = true,
  });

  @override
  State<SwipeGestureWidget> createState() => _SwipeGestureWidgetState();
}

class _SwipeGestureWidgetState extends State<SwipeGestureWidget> {
  Offset? _startPosition;
  static final AppLogger _logger = AppLogger('SwipeGestureWidget');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        _startPosition = details.localPosition;
      },
      onPanEnd: (details) {
        if (_startPosition == null) return;

        final endPosition = details.localPosition;
        final difference = endPosition - _startPosition!;

        if (difference.dx.abs() > difference.dy.abs()) {
          // 水平滑动
          if (difference.dx > widget.threshold) {
            _logger.info('手势右滑');
            if (widget.enableHapticFeedback) {
              HapticFeedback.lightImpact();
            }
            widget.onSwipeRight?.call();
          } else if (difference.dx < -widget.threshold) {
            _logger.info('手势左滑');
            if (widget.enableHapticFeedback) {
              HapticFeedback.lightImpact();
            }
            widget.onSwipeLeft?.call();
          }
        } else {
          // 垂直滑动
          if (difference.dy > widget.threshold) {
            _logger.info('手势下滑');
            if (widget.enableHapticFeedback) {
              HapticFeedback.lightImpact();
            }
            widget.onSwipeDown?.call();
          } else if (difference.dy < -widget.threshold) {
            _logger.info('手势上滑');
            if (widget.enableHapticFeedback) {
              HapticFeedback.lightImpact();
            }
            widget.onSwipeUp?.call();
          }
        }

        _startPosition = null;
      },
      child: widget.child,
    );
  }
}

/// 双指缩放手势Widget
class ScaleGestureWidget extends StatefulWidget {
  final Widget child;
  final Function(double scale)? onScaleUpdate;
  final VoidCallback? onScaleStart;
  final VoidCallback? onScaleEnd;
  final double minScale;
  final double maxScale;
  final bool enableHapticFeedback;

  const ScaleGestureWidget({
    super.key,
    required this.child,
    this.onScaleUpdate,
    this.onScaleStart,
    this.onScaleEnd,
    this.minScale = 0.5,
    this.maxScale = 3.0,
    this.enableHapticFeedback = true,
  });

  @override
  State<ScaleGestureWidget> createState() => _ScaleGestureWidgetState();
}

class _ScaleGestureWidgetState extends State<ScaleGestureWidget> {
  double _currentScale = 1.0;
  static final AppLogger _logger = AppLogger('ScaleGestureWidget');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (details) {
        _logger.info('缩放手势开始');
        if (widget.enableHapticFeedback) {
          HapticFeedback.lightImpact();
        }
        widget.onScaleStart?.call();
      },
      onScaleUpdate: (details) {
        setState(() {
          _currentScale = (details.scale).clamp(widget.minScale, widget.maxScale);
        });
        widget.onScaleUpdate?.call(_currentScale);
      },
      onScaleEnd: (details) {
        _logger.info('缩放手势结束', {'finalScale': _currentScale});
        if (widget.enableHapticFeedback) {
          HapticFeedback.lightImpact();
        }
        widget.onScaleEnd?.call();
      },
      child: Transform.scale(
        scale: _currentScale,
        child: widget.child,
      ),
    );
  }
}