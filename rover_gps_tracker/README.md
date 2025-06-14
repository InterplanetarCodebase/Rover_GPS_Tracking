# Rover GPS Tracker (Flutter App)

This is the Android mobile application component of the Rover GPS Tracking Solution. Developed with Flutter, this app is responsible for acquiring the device's GPS coordinates and continuously transmitting them to a designated server.

---

### Features:

* **Real-time GPS Display:** Shows current Latitude and Longitude on the UI.
* **Continuous Data Transmission:** Sends GPS updates every **0.5 seconds** to a specified IP address on **port 5000**.
* **Start/Stop Tracking:** Manual controls to initiate and halt the tracking process.
* **Background Tracking:** Configured to continue tracking and sending data even when the app is in the background (requires specific Android permissions).
* **User Feedback:** Provides status messages for location acquisition and data transmission.

---

### Development Setup (for Contributors):

1.  **Clone the Monorepo:** If you haven't already, clone the main `RoverTrackingSolution` repository.
    ```bash
    git clone [https://github.com/YOUR_GITHUB_USERNAME/RoverTrackingSolution.git](https://github.com/YOUR_GITHUB_USERNAME/RoverTrackingSolution.git)
    cd RoverTrackingSolution/rover_gps_tracker
    ```
2.  **Install Flutter:** Ensure you have Flutter installed and configured on your machine.
    * [Flutter Installation Guide](https://flutter.dev/docs/get-started/install)
3.  **Install Dependencies:** Navigate to this `rover_gps_tracker` directory and fetch the Dart packages.
    ```bash
    flutter pub get
    ```
4.  **Android NDK Configuration:** This project requires Android NDK version `27.0.12077973`. If you encounter NDK-related build errors, update your `android/app/build.gradle.kts` file:
    ```kotlin
    // android/app/build.gradle.kts
    android {
        // ...
        ndkVersion = "27.0.12077973" // Ensure this line is present
        // ...
    }
    ```
5.  **Android Permissions (`AndroidManifest.xml`):**
    Ensure `android/app/src/main/AndroidManifest.xml` contains all necessary permissions for location and foreground services:
    ```xml
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/>
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION"/>
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>

    <application android:usesCleartextTraffic="true">
        <service
            android:name="com.lyokone.location.FlutterLocationService"
            android:foregroundServiceType="location"
            android:enabled="true"
            android:exported="false" />
        <!-- ... other application content ... -->
    </application>
    ```
6.  **Connect Android Device:**
    * Enable Developer Options on your Android phone (tap Build Number 7 times in About Phone settings).
    * Enable USB Debugging in Developer Options.
    * Connect your phone to your PC via USB. Allow USB debugging when prompted.
    * (If `adb` issues: `sudo apt install adb`, then ensure `udev` rules are set up as per Linux setup guides for Android development.)
7.  **Run the App:**
    ```bash
    flutter run
    ```

---

### Configuration and Usage:

1.  **Laptop IP Address:**
    The app needs your laptop's IP address to send data.
    * On Linux, open a terminal and run `ip a`. Look for the `inet` address under your active network interface (e.g., `wlp2s0` for Wi-Fi), it will typically be `192.168.X.X`.
    * Update the `_ipController.text` in `lib/main.dart` with your laptop's IP:
        ```dart
        _ipController.text = 'YOUR_LAPTOP_IP_HERE'; // e.g., '192.168.0.140'
        ```
2.  **Network Connection:** Ensure both your Android phone and your laptop are connected to the **same Wi-Fi network**.
3.  **Server Running:** Make sure the Python `receiver_server_project` is running on your laptop.
4.  **Android Permissions (Runtime):**
    * When you first run the app, grant it location permission.
    * For **continuous tracking**, you MUST go to your phone's **System Settings** for the app:
        * **Settings -> Apps -> Rover GPS Tracker -> Permissions -> Location -> Select "Allow all the time."**
        * **Settings -> Apps -> Rover GPS Tracker -> Battery -> Select "Unrestricted" or "Don't optimize."**
5.  **Start Tracking:** Open the app and tap the "Start Tracking" button. Coordinates will begin flowing to your server every 0.5 seconds.