import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';

class TestHelper {
  static Future<void> initializeHive() async {
    // 为测试创建临时目录
    final testDir = Directory('./test/hive_test');
    if (testDir.existsSync()) {
      testDir.deleteSync(recursive: true);
    }
    testDir.createSync(recursive: true);
    
    // 初始化Hive
    Hive.init(testDir.path);
  }

  static Future<void> cleanupHive() async {
    try {
      await Hive.close();
      final testDir = Directory('./test/hive_test');
      if (testDir.existsSync()) {
        testDir.deleteSync(recursive: true);
      }
    } catch (e) {
      // 忽略清理错误
    }
  }
}