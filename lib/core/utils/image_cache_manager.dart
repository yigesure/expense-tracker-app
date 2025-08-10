import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'logger.dart';

/// 图片和图标缓存管理器
class ImageCacheManager {
  static final Map<String, ui.Image> _imageCache = {};
  static final Map<String, Uint8List> _assetCache = {};
  static const int _maxCacheSize = 50;
  static const Duration _cacheExpiry = Duration(hours: 1);
  static final Map<String, DateTime> _cacheTimestamps = {};

  /// 预加载常用图标
  static Future<void> preloadCommonIcons() async {
    try {
      AppLogger.info('ImageCacheManager', 'Preloading common icons');
      
      final commonIcons = [
        'assets/icons/income.png',
        'assets/icons/expense.png',
        'assets/icons/transfer.png',
        'assets/icons/food.png',
        'assets/icons/transport.png',
        'assets/icons/shopping.png',
        'assets/icons/entertainment.png',
        'assets/icons/health.png',
        'assets/icons/education.png',
        'assets/icons/other.png',
      ];

      for (final iconPath in commonIcons) {
        await _loadAssetToCache(iconPath);
      }
      
      AppLogger.info('ImageCacheManager', 'Preloaded ${commonIcons.length} icons');
    } catch (e, stackTrace) {
      AppLogger.error('ImageCacheManager', 'Error preloading icons: $e', stackTrace);
    }
  }

  /// 从缓存获取资源
  static Future<Uint8List?> getAsset(String assetPath) async {
    try {
      // 检查缓存是否过期
      if (_isCacheExpired(assetPath)) {
        _removeFromCache(assetPath);
      }

      // 从缓存返回
      if (_assetCache.containsKey(assetPath)) {
        AppLogger.debug('ImageCacheManager', 'Asset loaded from cache: $assetPath');
        return _assetCache[assetPath];
      }

      // 加载到缓存
      return await _loadAssetToCache(assetPath);
    } catch (e, stackTrace) {
      AppLogger.error('ImageCacheManager', 'Error getting asset $assetPath: $e', stackTrace);
      return null;
    }
  }

  /// 加载资源到缓存
  static Future<Uint8List?> _loadAssetToCache(String assetPath) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();
      
      // 检查缓存大小限制
      if (_assetCache.length >= _maxCacheSize) {
        _evictOldestCache();
      }
      
      _assetCache[assetPath] = bytes;
      _cacheTimestamps[assetPath] = DateTime.now();
      
      AppLogger.debug('ImageCacheManager', 'Asset loaded to cache: $assetPath');
      return bytes;
    } catch (e) {
      AppLogger.error('ImageCacheManager', 'Error loading asset $assetPath: $e');
      return null;
    }
  }

  /// 获取UI图像
  static Future<ui.Image?> getImage(String assetPath) async {
    try {
      // 检查缓存是否过期
      if (_isCacheExpired(assetPath)) {
        _removeFromCache(assetPath);
      }

      // 从缓存返回
      if (_imageCache.containsKey(assetPath)) {
        AppLogger.debug('ImageCacheManager', 'Image loaded from cache: $assetPath');
        return _imageCache[assetPath];
      }

      // 加载到缓存
      return await _loadImageToCache(assetPath);
    } catch (e, stackTrace) {
      AppLogger.error('ImageCacheManager', 'Error getting image $assetPath: $e', stackTrace);
      return null;
    }
  }

  /// 加载图像到缓存
  static Future<ui.Image?> _loadImageToCache(String assetPath) async {
    try {
      final Uint8List? bytes = await getAsset(assetPath);
      if (bytes == null) return null;

      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image image = frameInfo.image;
      
      // 检查缓存大小限制
      if (_imageCache.length >= _maxCacheSize) {
        _evictOldestImageCache();
      }
      
      _imageCache[assetPath] = image;
      _cacheTimestamps[assetPath] = DateTime.now();
      
      AppLogger.debug('ImageCacheManager', 'Image loaded to cache: $assetPath');
      return image;
    } catch (e) {
      AppLogger.error('ImageCacheManager', 'Error loading image $assetPath: $e');
      return null;
    }
  }

  /// 检查缓存是否过期
  static bool _isCacheExpired(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return true;
    return DateTime.now().difference(timestamp) > _cacheExpiry;
  }

  /// 从缓存中移除
  static void _removeFromCache(String key) {
    _assetCache.remove(key);
    _imageCache[key]?.dispose();
    _imageCache.remove(key);
    _cacheTimestamps.remove(key);
  }

  /// 清理最旧的资源缓存
  static void _evictOldestCache() {
    if (_cacheTimestamps.isEmpty) return;
    
    final oldestKey = _cacheTimestamps.entries
        .reduce((a, b) => a.value.isBefore(b.value) ? a : b)
        .key;
    
    _removeFromCache(oldestKey);
    AppLogger.debug('ImageCacheManager', 'Evicted oldest cache: $oldestKey');
  }

  /// 清理最旧的图像缓存
  static void _evictOldestImageCache() {
    if (_imageCache.isEmpty) return;
    
    final oldestKey = _cacheTimestamps.entries
        .where((entry) => _imageCache.containsKey(entry.key))
        .reduce((a, b) => a.value.isBefore(b.value) ? a : b)
        .key;
    
    _imageCache[oldestKey]?.dispose();
    _imageCache.remove(oldestKey);
    AppLogger.debug('ImageCacheManager', 'Evicted oldest image cache: $oldestKey');
  }

  /// 清理所有缓存
  static void clearCache() {
    AppLogger.info('ImageCacheManager', 'Clearing all cache');
    
    // 释放图像资源
    for (final image in _imageCache.values) {
      image.dispose();
    }
    
    _assetCache.clear();
    _imageCache.clear();
    _cacheTimestamps.clear();
  }

  /// 获取缓存统计信息
  static Map<String, dynamic> getCacheStats() {
    return {
      'assetCacheSize': _assetCache.length,
      'imageCacheSize': _imageCache.length,
      'totalCacheSize': _assetCache.length + _imageCache.length,
      'maxCacheSize': _maxCacheSize,
      'cacheExpiry': _cacheExpiry.inMinutes,
    };
  }

  /// 预热缓存
  static Future<void> warmUpCache() async {
    await preloadCommonIcons();
    AppLogger.info('ImageCacheManager', 'Cache warmed up successfully');
  }
}

/// 缓存优化的图片组件
class CachedImage extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? color;

  const CachedImage({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: ImageCacheManager.getAsset(assetPath),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return Image.memory(
            snapshot.data!,
            width: width,
            height: height,
            fit: fit,
            color: color,
            errorBuilder: (context, error, stackTrace) {
              AppLogger.error('CachedImage', 'Error displaying image $assetPath: $error');
              return _buildErrorWidget();
            },
          );
        } else if (snapshot.hasError) {
          AppLogger.error('CachedImage', 'Error loading image $assetPath: ${snapshot.error}');
          return _buildErrorWidget();
        } else {
          return _buildLoadingWidget();
        }
      },
    );
  }

  Widget _buildLoadingWidget() {
    return SizedBox(
      width: width ?? 24,
      height: height ?? 24,
      child: const Center(
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return SizedBox(
      width: width ?? 24,
      height: height ?? 24,
      child: const Icon(
        Icons.error_outline,
        color: Colors.grey,
      ),
    );
  }
}