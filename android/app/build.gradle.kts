plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

apply(plugin = "org.jetbrains.kotlin.android")

android {
    namespace = "com.example.cfpv"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    buildDir = File(rootProject.projectDir, "../build/app")

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.cfpv"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

