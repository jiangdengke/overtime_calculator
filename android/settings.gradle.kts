pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        // 优先使用国内镜像，降低下载阻塞风险
        maven(url = uri("https://maven.aliyun.com/repository/gradle-plugin"))
        maven(url = uri("https://maven.aliyun.com/repository/google"))
        maven(url = uri("https://maven.aliyun.com/repository/public"))
        maven(url = uri("https://repo.huaweicloud.com/repository/maven"))
        maven(url = uri("https://mirrors.cloud.tencent.com/nexus/repository/maven-public"))
        // 官方源作为回退
        google()
        mavenCentral()
        gradlePluginPortal()
    }

    // 通过解析策略将常见插件映射为具体模块坐标，走上面的镜像仓库
    resolutionStrategy {
        eachPlugin {
            when (requested.id.id) {
                // Kotlin 插件统一走 kotlin-gradle-plugin（版本可与 plugins 块保持一致）
                "org.jetbrains.kotlin.android",
                "org.jetbrains.kotlin.jvm",
                "org.jetbrains.kotlin.multiplatform",
                "org.jetbrains.kotlin.kapt" -> {
                    useModule("org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.0")
                }
                // Android Gradle Plugin
                "com.android.application" -> {
                    useModule("com.android.tools.build:gradle:8.7.3")
                }
            }
        }
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.7.3" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

include(":app")

// 读取 local.properties 以获取 Flutter SDK 路径（供本地 engine maven 仓库使用）
val localProps = java.util.Properties()
val localPropsFile = file("local.properties")
if (localPropsFile.exists()) {
    localPropsFile.inputStream().use { localProps.load(it) }
}
val flutterSdkFromLocal: String? = localProps.getProperty("flutter.sdk")

// 统一依赖解析仓库（优先国内镜像）
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        // Flutter 本地 engine maven 仓库（提供 io.flutter:* 工件）
        if (flutterSdkFromLocal != null) {
            maven(url = uri("$flutterSdkFromLocal/bin/cache/artifacts/engine/android"))
        }
        // Flutter 官方与国内镜像仓库（download.flutter.io）
        maven(url = uri("https://storage.flutter-io.cn/download.flutter.io"))
        maven(url = uri("https://storage.googleapis.com/download.flutter.io"))
        maven(url = uri("https://maven.aliyun.com/repository/google"))
        maven(url = uri("https://maven.aliyun.com/repository/public"))
        maven(url = uri("https://repo.huaweicloud.com/repository/maven"))
        maven(url = uri("https://mirrors.cloud.tencent.com/nexus/repository/maven-public"))
        google()
        mavenCentral()
    }
}
