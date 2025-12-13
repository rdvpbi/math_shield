plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.mathshield.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.mathshield.app"
        minSdk = 23
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Мультидекс для большого количества методов
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // Используем debug signing для простоты
            // Для публикации в Play Store нужен отдельный keystore
            signingConfig = signingConfigs.getByName("debug")
            
            // Оптимизация для релиза
            isMinifyEnabled = false  // true может вызвать проблемы с Flutter
            isShrinkResources = false
        }
        
        debug {
            isDebuggable = true
        }
    }
    
    // Для избежания конфликтов при сборке
    packagingOptions {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }
}

flutter {
    source = "../.."
}
