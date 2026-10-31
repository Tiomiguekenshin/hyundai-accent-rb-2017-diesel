plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "com.autosense.launcher"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.autosense.launcher"
        // Android 7+; validar compatibilidad real en la K2001N antes de instalar.
        minSdk = 24
        targetSdk = 34
        versionCode = 1
        versionName = "0.1"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}

dependencies {
    // Sin librerías externas: solo framework de Android, para que corra ligero en 2 GB de RAM.
}
