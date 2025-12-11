plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.arif_mart.app"
    compileSdk = 36  // সর্বশেষ SDK এর জন্য

    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.arif_mart.app"
        minSdk = flutter.minSdkVersion           // ন্যূনতম সাপোর্টেড SDK
        targetSdk = 36        // Play Store requirement
        versionCode = 1
        versionName = "1.0.0"
    }

    signingConfigs {
        create("release") {
            keyAlias = "Arifmart"
            keyPassword = "Mart9216Aklima"
            storeFile = file("upload-keystore.jks")
            storePassword = "Arif9216Harun"
        }
    }

    buildTypes {
        getByName("debug") {
            isMinifyEnabled = false
            isShrinkResources = false
            isDebuggable = true
        }
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // জাভা 8+ desugaring
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // Play Core libraries (compatible version)
    implementation("com.google.android.play:app-update-ktx:2.1.0")
    implementation("com.google.android.play:review-ktx:2.0.2")
}