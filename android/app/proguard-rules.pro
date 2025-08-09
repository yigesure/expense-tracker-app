# Flutter相关规则
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Dart相关规则
-dontwarn io.flutter.embedding.**

# 保持注解
-keepattributes *Annotation*

# 保持行号信息，方便调试
-keepattributes SourceFile,LineNumberTable

# 保持泛型信息
-keepattributes Signature

# 保持异常信息
-keepattributes Exceptions

# Hive数据库相关
-keep class hive.** { *; }
-keep class **$HiveFieldAdapter { *; }

# JSON序列化相关
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# 保持枚举类
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}