plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.aamir.sovely"          // ✅ your unique ID
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
        applicationId = "com.aamir.sovely"  // ✅ must match namespace
        minSdk = flutter.minSdkVersion                          // ✅ explicit — supports 97% of devices
        targetSdk = flutter.targetSdkVersion
        versionCode = 1                      // ✅ increment each release
        versionName = "1.0.0"               // ✅ your app version
    }

    buildTypes {
        release {
            isMinifyEnabled = true           // ✅ shrinks app size
            isShrinkResources = true         // ✅ removes unused resources
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("debug") // ⚠️ replace with real keystore before publishing
        }
    }
}

flutter {
    source = "../.."
}
