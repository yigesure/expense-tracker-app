import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/logger.dart';

/// 滑动操作Widget
/// 支持左滑删除、右滑编辑等手势操作
class SwipeActionWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onArchive;
  final bool enableEdit;
  final bool enableDelete;
  final bool enableArchive;
  final double actionWidth;

  const SwipeActionWidget({
    super.key,
    required this.child,
    this.onEdit,
    this.onDelete,
    this.onArchive,
    this.enableEdit = true,
    this.enableDelete = true,
    this.enableArchive = false,
    this.actionWidth = 80.0,
  });

  @override
  State<SwipeActionWidget> createState() => _SwipeActionWidgetState();
}

class _SwipeActionWidgetState extends State<SwipeActionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  double _dragExtent = 0.0;
  bool _dragUnderway = false;
  static final AppLogger _logger = AppLogger('SwipeActionWidget');

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    _dragUnderway = true;
    if (_animationController.isAnimating) {
      _animationController.stop();
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_dragUnderway) return;

    final delta = details.primaryDelta ?? 0.0;
    final oldDragExtent = _dragExtent;
    
    // 限制滑动范围
    final maxExtent = _getMaxDragExtent();
    _dragExtent = (_dragExtent + delta).clamp(-maxExtent, maxExtent);

    if (oldDragExtent != _dragExtent) {
      setState(() {});
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_dragUnderway) return;
    _dragUnderway = false;

    final velocity = details.primaryVelocity ?? 0.0;
    final maxExtent = _getMaxDragExtent();
    
    // 根据滑动距离和速度决定最终状态
    if (_dragExtent.abs() > maxExtent * 0.4 || velocity.abs() > 300) {
      // 展开操作按钮
      _animationController.forward().then((_) {
        if (mounted) {
          setState(() {
            _dragExtent = _dragExtent > 0 ? maxExtent : -maxExtent;
          });
        }
      });
    } else {
      // 回弹到原位
      _animationController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _dragExtent = 0.0;
          });
        }
      });
    }
  }

  double _getMaxDragExtent() {
    int actionCount = 0;
    if (widget.enableEdit && widget.onEdit != null) actionCount++;
    if (widget.enableDelete && widget.onDelete != null) actionCount++;
    if (widget.enableArchive && widget.onArchive != null) actionCount++;
    
    return actionCount * widget.actionWidth;
  }

  void _performAction(VoidCallback? action, String actionName) {
    _logger.info('执行滑动操作', {'action': actionName});
    
    // 先回弹动画
    _animationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _dragExtent = 0.0;
        });
        // 执行操作
        action?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: Stack(
        children: [
          // 背景操作按钮
          _buildActionBackground(),
          // 主内容
          Transform.translate(
            offset: Offset(_dragExtent, 0),
            child: widget.child,
          ),
        ],
      ),
    );
  }

  Widget _buildActionBackground() {
    final actions = <Widget>[];
    
    if (_dragExtent > 0) {
      // 右滑显示左侧操作
      if (widget.enableEdit && widget.onEdit != null) {
        actions.add(_buildActionButton(
          icon: Icons.edit,
          color: AppColors.softBlue,
          onTap: () => _performAction(widget.onEdit, 'edit'),
        ));
      }
      if (widget.enableArchive && widget.onArchive != null) {
        actions.add(_buildActionButton(
          icon: Icons.archive,
          color: AppColors.warning,
          onTap: () => _performAction(widget.onArchive, 'archive'),
        ));
      }
    } else if (_dragExtent < 0) {
      // 左滑显示右侧操作
      if (widget.enableDelete && widget.onDelete != null) {
        actions.add(_buildActionButton(
          icon: Icons.delete,
          color: AppColors.error,
          onTap: () => _performAction(widget.onDelete, 'delete'),
        ));
      }
    }

    return Positioned.fill(
      child: Row(
        children: [
          if (_dragExtent > 0) ...actions,
          const Spacer(),
          if (_dragExtent < 0) ...actions,
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: widget.actionWidth,
        color: color,
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}