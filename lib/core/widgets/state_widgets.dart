import 'package:flutter/material.dart';
import '../utils/animation_optimizer.dart';
import '../accessibility/accessibility_helper.dart';
import 'material3_components.dart';

/// 状态管理Widget集合
class StateWidgets {
  StateWidgets._();

  /// 异步构建器 - 统一处理加载、错误、成功状态
  static Widget asyncBuilder<T>({
    required Future<T> future,
    required Widget Function(BuildContext context, T data) builder,
    Widget? loadingWidget,
    Widget Function(BuildContext context, Object error)? errorBuilder,
    String? loadingMessage,
    String? emptyMessage,
    bool Function(T data)? isEmpty,
  }) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        // 加载状态
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingWidget ?? 
              M3Components.loadingIndicator(message: loadingMessage);
        }
        
        // 错误状态
        if (snapshot.hasError) {
          if (errorBuilder != null) {
            return errorBuilder(context, snapshot.error!);
          }
          return M3Components.errorState(
            title: '加载失败',
            subtitle: snapshot.error.toString(),
            onRetry: () {
              // 触发重建以重新执行future
              (context as Element).markNeedsBuild();
            },
          );
        }
        
        // 成功状态
        if (snapshot.hasData) {
          final data = snapshot.data!;
          
          // 检查空状态
          if (isEmpty?.call(data) == true) {
            return M3Components.emptyState(
              icon: Icons.inbox_outlined,
              title: '暂无数据',
              subtitle: emptyMessage,
            );
          }
          
          return builder(context, data);
        }
        
        // 默认空状态
        return M3Components.emptyState(
          icon: Icons.inbox_outlined,
          title: '暂无数据',
          subtitle: emptyMessage,
        );
      },
    );
  }

  /// 流构建器 - 统一处理流数据状态
  static Widget streamBuilder<T>({
    required Stream<T> stream,
    required Widget Function(BuildContext context, T data) builder,
    Widget? loadingWidget,
    Widget Function(BuildContext context, Object error)? errorBuilder,
    String? loadingMessage,
    String? emptyMessage,
    bool Function(T data)? isEmpty,
    T? initialData,
  }) {
    return StreamBuilder<T>(
      stream: stream,
      initialData: initialData,
      builder: (context, snapshot) {
        // 加载状态
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return loadingWidget ?? 
              M3Components.loadingIndicator(message: loadingMessage);
        }
        
        // 错误状态
        if (snapshot.hasError) {
          if (errorBuilder != null) {
            return errorBuilder(context, snapshot.error!);
          }
          return M3Components.errorState(
            title: '加载失败',
            subtitle: snapshot.error.toString(),
          );
        }
        
        // 成功状态
        if (snapshot.hasData) {
          final data = snapshot.data!;
          
          // 检查空状态
          if (isEmpty?.call(data) == true) {
            return M3Components.emptyState(
              icon: Icons.inbox_outlined,
              title: '暂无数据',
              subtitle: emptyMessage,
            );
          }
          
          return builder(context, data);
        }
        
        // 默认空状态
        return M3Components.emptyState(
          icon: Icons.inbox_outlined,
          title: '暂无数据',
          subtitle: emptyMessage,
        );
      },
    );
  }

  /// 条件构建器 - 根据条件显示不同内容
  static Widget conditionalBuilder({
    required bool condition,
    required Widget Function(BuildContext context) builder,
    Widget Function(BuildContext context)? fallback,
  }) {
    return Builder(
      builder: (context) {
        if (condition) {
          return builder(context);
        }
        return fallback?.call(context) ?? const SizedBox.shrink();
      },
    );
  }

  /// 动画列表项 - 带入场动画的列表项
  static Widget animatedListItem({
    required Widget child,
    required int index,
    Duration? delay,
    Duration? duration,
    Curve? curve,
  }) {
    return OptimizedListItemAnimation(
      index: index,
      delay: delay,
      duration: duration,
      curve: curve,
      child: child,
    );
  }

  /// 可展开的内容区域
  static Widget expandableContent({
    required Widget header,
    required Widget content,
    bool initiallyExpanded = false,
    Duration? duration,
    Curve? curve,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return _ExpandableContent(
      header: header,
      content: content,
      initiallyExpanded: initiallyExpanded,
      duration: duration,
      curve: curve,
      contentPadding: contentPadding,
    );
  }

  /// 滑动删除项
  static Widget dismissibleItem({
    required String itemKey,
    required Widget child,
    required DismissDirection direction,
    required Future<bool> Function(DismissDirection direction) confirmDismiss,
    Widget Function(BuildContext context, DismissDirection direction)? background,
    Widget Function(BuildContext context, DismissDirection direction)? secondaryBackground,
  }) {
    return Dismissible(
      key: Key(itemKey),
      direction: direction,
      confirmDismiss: confirmDismiss,
      background: background?.call(
        NavigationService.navigatorKey.currentContext!,
        direction,
      ) ?? Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      secondaryBackground: secondaryBackground?.call(
        NavigationService.navigatorKey.currentContext!,
        direction,
      ),
      child: child,
    );
  }

  /// 刷新指示器
  static Widget refreshIndicator({
    required Widget child,
    required Future<void> Function() onRefresh,
    String? semanticLabel,
  }) {
    return AccessibilityHelper.semanticLabel(
      label: semanticLabel ?? '下拉刷新',
      hint: '向下滑动以刷新内容',
      child: RefreshIndicator(
        onRefresh: onRefresh,
        child: child,
      ),
    );
  }

  /// 无限滚动列表
  static Widget infiniteScrollList({
    required int itemCount,
    required Widget Function(BuildContext context, int index) itemBuilder,
    required Future<void> Function() onLoadMore,
    bool hasMore = true,
    Widget? loadingWidget,
    ScrollController? controller,
    EdgeInsetsGeometry? padding,
  }) {
    return _InfiniteScrollList(
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      onLoadMore: onLoadMore,
      hasMore: hasMore,
      loadingWidget: loadingWidget,
      controller: controller,
      padding: padding,
    );
  }

  /// 搜索结果列表
  static Widget searchResultList<T>({
    required List<T> items,
    required Widget Function(BuildContext context, T item, int index) itemBuilder,
    required String Function(T item) searchFilter,
    String searchQuery = '',
    Widget? emptyWidget,
    Widget? noResultsWidget,
    EdgeInsetsGeometry? padding,
  }) {
    final filteredItems = searchQuery.isEmpty
        ? items
        : items.where((item) => 
            searchFilter(item).toLowerCase().contains(searchQuery.toLowerCase())
          ).toList();

    if (items.isEmpty) {
      return emptyWidget ?? M3Components.emptyState(
        icon: Icons.inbox_outlined,
        title: '暂无数据',
      );
    }

    if (filteredItems.isEmpty && searchQuery.isNotEmpty) {
      return noResultsWidget ?? M3Components.emptyState(
        icon: Icons.search_off,
        title: '未找到相关结果',
        subtitle: '尝试使用其他关键词搜索',
      );
    }

    return ListView.builder(
      padding: padding,
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        return animatedListItem(
          index: index,
          child: itemBuilder(context, filteredItems[index], index),
        );
      },
    );
  }

  /// 分页列表
  static Widget paginatedList<T>({
    required List<T> items,
    required Widget Function(BuildContext context, T item, int index) itemBuilder,
    int itemsPerPage = 20,
    Widget? loadingWidget,
    Widget? emptyWidget,
    EdgeInsetsGeometry? padding,
  }) {
    return _PaginatedList<T>(
      items: items,
      itemBuilder: itemBuilder,
      itemsPerPage: itemsPerPage,
      loadingWidget: loadingWidget,
      emptyWidget: emptyWidget,
      padding: padding,
    );
  }
}

/// 可展开内容实现
class _ExpandableContent extends StatefulWidget {
  final Widget header;
  final Widget content;
  final bool initiallyExpanded;
  final Duration? duration;
  final Curve? curve;
  final EdgeInsetsGeometry? contentPadding;

  const _ExpandableContent({
    required this.header,
    required this.content,
    this.initiallyExpanded = false,
    this.duration,
    this.curve,
    this.contentPadding,
  });

  @override
  State<_ExpandableContent> createState() => _ExpandableContentState();
}

class _ExpandableContentState extends State<_ExpandableContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    
    _controller = AnimationController(
      duration: AnimationOptimizer.getOptimizedDuration(
        widget.duration ?? const Duration(milliseconds: 300),
      ),
      vsync: this,
    );

    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: AnimationOptimizer.getOptimizedCurve(
        widget.curve ?? Curves.easeInOut,
      ),
    );

    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AccessibilityHelper.accessibleButton(
          label: _isExpanded ? '收起内容' : '展开内容',
          onPressed: _toggle,
          child: widget.header,
        ),
        SizeTransition(
          sizeFactor: _expandAnimation,
          child: Padding(
            padding: widget.contentPadding ?? EdgeInsets.zero,
            child: widget.content,
          ),
        ),
      ],
    );
  }
}

/// 无限滚动列表实现
class _InfiniteScrollList extends StatefulWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final Future<void> Function() onLoadMore;
  final bool hasMore;
  final Widget? loadingWidget;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;

  const _InfiniteScrollList({
    required this.itemCount,
    required this.itemBuilder,
    required this.onLoadMore,
    this.hasMore = true,
    this.loadingWidget,
    this.controller,
    this.padding,
  });

  @override
  State<_InfiniteScrollList> createState() => _InfiniteScrollListState();
}

class _InfiniteScrollListState extends State<_InfiniteScrollList> {
  late ScrollController _scrollController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_onScroll);
    }
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || !widget.hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onLoadMore();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      padding: widget.padding,
      itemCount: widget.itemCount + (widget.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == widget.itemCount) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: widget.loadingWidget ?? 
                M3Components.loadingIndicator(message: '加载更多...'),
          );
        }
        return widget.itemBuilder(context, index);
      },
    );
  }
}

/// 分页列表实现
class _PaginatedList<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final int itemsPerPage;
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final EdgeInsetsGeometry? padding;

  const _PaginatedList({
    required this.items,
    required this.itemBuilder,
    this.itemsPerPage = 20,
    this.loadingWidget,
    this.emptyWidget,
    this.padding,
  });

  @override
  State<_PaginatedList<T>> createState() => _PaginatedListState<T>();
}

class _PaginatedListState<T> extends State<_PaginatedList<T>> {
  int _currentPage = 0;
  bool _isLoading = false;

  List<T> get _visibleItems {
    final endIndex = (_currentPage + 1) * widget.itemsPerPage;
    return widget.items.take(endIndex).toList();
  }

  bool get _hasMore {
    return _visibleItems.length < widget.items.length;
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    // 模拟加载延迟
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _currentPage++;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return widget.emptyWidget ?? M3Components.emptyState(
        icon: Icons.inbox_outlined,
        title: '暂无数据',
      );
    }

    return StateWidgets.infiniteScrollList(
      itemCount: _visibleItems.length,
      itemBuilder: (context, index) {
        return StateWidgets.animatedListItem(
          index: index,
          child: widget.itemBuilder(context, _visibleItems[index], index),
        );
      },
      onLoadMore: _loadMore,
      hasMore: _hasMore,
      loadingWidget: widget.loadingWidget,
      padding: widget.padding,
    );
  }
}

/// 导航服务 - 用于全局导航
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static NavigatorState? get navigator => navigatorKey.currentState;
  static BuildContext? get context => navigatorKey.currentContext;

  static Future<T?> pushNamed<T>(String routeName, {Object? arguments}) {
    return navigator!.pushNamed<T>(routeName, arguments: arguments);
  }

  static Future<T?> push<T>(Route<T> route) {
    return navigator!.push<T>(route);
  }

  static void pop<T>([T? result]) {
    return navigator!.pop<T>(result);
  }

  static Future<T?> pushReplacement<T, TO>(Route<T> newRoute, {TO? result}) {
    return navigator!.pushReplacement<T, TO>(newRoute, result: result);
  }

  static Future<T?> pushAndRemoveUntil<T>(
    Route<T> newRoute,
    bool Function(Route<dynamic>) predicate,
  ) {
    return navigator!.pushAndRemoveUntil<T>(newRoute, predicate);
  }
}