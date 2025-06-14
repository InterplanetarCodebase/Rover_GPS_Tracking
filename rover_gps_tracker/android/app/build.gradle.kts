import java.util.Properties // Add this import
import java.io.FileInputStream // Add this import

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties() // Use the imported Properties
keystoreProperties.load(FileInputStream(keystorePropertiesFile)) // Use the imported FileInputStream


android {
    namespace = "com.example.rover_gps_tracker"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.rover_gps_tracker"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            // Retrieve keystore and key details from key.properties
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
        }
        // Removed explicit create("debug") as Gradle provides a default one
        // create("debug") {
        //     // This refers to Android Studio's default debug keystore
        //     // Usually found at ~/.android/debug.keystore
        //     storeFile = file(System.getProperty("user.home") + "/.android/debug.keystore")
        //     storePassword = "android" // Default password for debug keystore
        //     keyAlias = "androiddebugkey" // Default alias
        //     keyPassword = "android" // Default password for debug key
        // }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")

            // Optional: Enable minification and resource shrinking for smaller APK size
            // They require a ProGuard/R8 rules file (proguard-rules.pro)
            // minifyEnabled = true
            // shrinkResources = true
            // proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
        debug {
            // Changed to use getByName for consistency, explicitly referring to the debug signing config
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
