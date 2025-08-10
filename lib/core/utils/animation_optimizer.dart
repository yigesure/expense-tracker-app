import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'logger.dart';

/// 动画性能优化工具
class AnimationOptimizer {
  static const Duration _defaultDuration = Duration(milliseconds: 300);
  static const Curve _defaultCurve = Curves.easeInOut;
  
  /// 检查设备是否支持高性能动画
  static bool get isHighPerformanceDevice {
    // 基于帧率判断设备性能
    return SchedulerBinding.instance.framesPerSecond >= 60;
  }
  
  /// 获取优化后的动画时长
  static Duration getOptimizedDuration([Duration? duration]) {
    final baseDuration = duration ?? _defaultDuration;
    
    // 低性能设备缩短动画时长
    if (!isHighPerformanceDevice) {
      return Duration(milliseconds: (baseDuration.inMilliseconds * 0.7).round());
    }
    
    return baseDuration;
  }
  
  /// 获取优化后的动画曲线
  static Curve getOptimizedCurve([Curve? curve]) {
    final baseCurve = curve ?? _defaultCurve;
    
    // 低性能设备使用更简单的曲线
    if (!isHighPerformanceDevice) {
      if (baseCurve == Curves.elasticOut || baseCurve == Curves.bounceOut) {
        return Curves.easeOut;
      }
      if (baseCurve == Curves.elasticIn || baseCurve == Curves.bounceIn) {
        return Curves.easeIn;
      }
    }
    
    return baseCurve;
  }
}

/// 优化的页面过渡动画
class OptimizedPageTransition extends PageRouteBuilder {
  final Widget child;
  final TransitionType type;
  final Duration? duration;
  final Curve? curve;

  OptimizedPageTransition({
    required this.child,
    this.type = TransitionType.slideFromRight,
    this.duration,
    this.curve,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: AnimationOptimizer.getOptimizedDuration(duration),
          reverseTransitionDuration: AnimationOptimizer.getOptimizedDuration(duration),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _buildTransition(
              context,
              animation,
              secondaryAnimation,
              child,
              type,
              AnimationOptimizer.getOptimizedCurve(curve),
            );
          },
        );

  static Widget _buildTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    TransitionType type,
    Curve curve,
  ) {
    final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);

    switch (type) {
      case TransitionType.slideFromRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );
      
      case TransitionType.slideFromLeft:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );
      
      case TransitionType.slideFromBottom:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );
      
      case TransitionType.fade:
        return FadeTransition(
          opacity: curvedAnimation,
          child: child,
        );
      
      case TransitionType.scale:
        return ScaleTransition(
          scale: curvedAnimation,
          child: child,
        );
      
      case TransitionType.fadeScale:
        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
            child: child,
          ),
        );
    }
  }
}

/// 过渡动画类型
enum TransitionType {
  slideFromRight,
  slideFromLeft,
  slideFromBottom,
  fade,
  scale,
  fadeScale,
}

/// 优化的列表项动画
class OptimizedListItemAnimation extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration? delay;
  final Duration? duration;
  final Curve? curve;

  const OptimizedListItemAnimation({
    super.key,
    required this.child,
    required this.index,
    this.delay,
    this.duration,
    this.curve,
  });

  @override
  State<OptimizedListItemAnimation> createState() => _OptimizedListItemAnimationState();
}

class _OptimizedListItemAnimationState extends State<OptimizedListItemAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: AnimationOptimizer.getOptimizedDuration(widget.duration),
      vsync: this,
    );

    final curve = AnimationOptimizer.getOptimizedCurve(widget.curve);
    final curvedAnimation = CurvedAnimation(parent: _controller, curve: curve);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(curvedAnimation);

    // 延迟启动动画
    final delay = widget.delay ?? Duration(milliseconds: widget.index * 50);
    Future.delayed(delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

/// 优化的按钮点击动画
class OptimizedTapAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Duration? duration;
  final double scaleValue;

  const OptimizedTapAnimation({
    super.key,
    required this.child,
    this.onTap,
    this.duration,
    this.scaleValue = 0.95,
  });

  @override
  State<OptimizedTapAnimation> createState() => _OptimizedTapAnimationState();
}

class _OptimizedTapAnimationState extends State<OptimizedTapAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: AnimationOptimizer.getOptimizedDuration(
        widget.duration ?? const Duration(milliseconds: 100),
      ),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleValue,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AnimationOptimizer.getOptimizedCurve(Curves.easeInOut),
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

/// 优化的加载动画
class OptimizedLoadingAnimation extends StatefulWidget {
  final double size;
  final Color? color;
  final Duration? duration;

  const OptimizedLoadingAnimation({
    super.key,
    this.size = 24.0,
    this.color,
    this.duration,
  });

  @override
  State<OptimizedLoadingAnimation> createState() => _OptimizedLoadingAnimationState();
}

class _OptimizedLoadingAnimationState extends State<OptimizedLoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: AnimationOptimizer.getOptimizedDuration(
        widget.duration ?? const Duration(milliseconds: 1000),
      ),
      vsync: this,
    );

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 低性能设备使用简单的进度指示器
    if (!AnimationOptimizer.isHighPerformanceDevice) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: CircularProgressIndicator(
          color: widget.color,
          strokeWidth: 2.0,
        ),
      );
    }

    return RotationTransition(
      turns: _controller,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CircularProgressIndicator(
          color: widget.color,
          strokeWidth: 2.0,
        ),
      ),
    );
  }
}

/// 动画性能监控
class AnimationPerformanceMonitor {
  static int _frameDropCount = 0;
  static DateTime? _lastFrameTime;
  static const Duration _frameThreshold = Duration(milliseconds: 16); // 60fps

  /// 开始监控帧率
  static void startMonitoring() {
    SchedulerBinding.instance.addPersistentFrameCallback(_onFrame);
    AppLogger.info('AnimationPerformanceMonitor', 'Started monitoring animation performance');
  }

  /// 停止监控
  static void stopMonitoring() {
    SchedulerBinding.instance.removePersistentFrameCallback(_onFrame);
    AppLogger.info('AnimationPerformanceMonitor', 'Stopped monitoring animation performance');
  }

  static void _onFrame(Duration timestamp) {
    final now = DateTime.now();
    
    if (_lastFrameTime != null) {
      final frameDuration = now.difference(_lastFrameTime!);
      if (frameDuration > _frameThreshold) {
        _frameDropCount++;
        if (_frameDropCount % 10 == 0) {
          AppLogger.warning(
            'AnimationPerformanceMonitor',
            'Frame drops detected: $_frameDropCount total, last frame: ${frameDuration.inMilliseconds}ms',
          );
        }
      }
    }
    
    _lastFrameTime = now;
  }

  /// 获取性能统计
  static Map<String, dynamic> getPerformanceStats() {
    return {
      'frameDropCount': _frameDropCount,
      'isHighPerformanceDevice': AnimationOptimizer.isHighPerformanceDevice,
      'framesPerSecond': SchedulerBinding.instance.framesPerSecond,
    };
  }

  /// 重置统计
  static void resetStats() {
    _frameDropCount = 0;
    _lastFrameTime = null;
    AppLogger.info('AnimationPerformanceMonitor', 'Performance stats reset');
  }
}