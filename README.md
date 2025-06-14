# Rover GPS Tracking Solution

This repository contains the source code for a comprehensive solution designed for tracking the GPS coordinates of a mobile device (Android phone) and sending them continuously to a central server (your laptop). This setup is ideal for applications like rover competitions, where real-time location data is essential.

The solution consists of two main components:

1.  **`rover_gps_tracker`**: A Flutter Android application that runs on the mobile device to acquire and transmit GPS data.
2.  **`receiver_server_project`**: A Python Flask server that runs on a laptop/PC to receive and process the incoming GPS coordinates.

---

### For End Users / Quick Deployment:

**Important Note:** The source code provided in this repository is intended for **development, collaboration, and learning purposes only**. If you are an end-user and wish to use the app without building from source, please download the compiled Android APK directly from the Google Drive link below:

**[Download Rover GPS Tracker APK from Google Drive](YOUR_GOOGLE_DRIVE_APK_HERE)**
*(Replace `YOUR_GOOGLE_DRIVE_APK_HERE` with the actual shareable link to your `app-release.apk` file once you've uploaded it.)*

**Usage Instructions for the App on Android:**

1.  **Install the APK:** Download the APK from the link above and install it on your Android phone. You may need to enable "Install unknown apps" in your phone's security settings.
2.  **Run the Receiver Server:** Ensure the Python `receiver_server_project` is running on your PC/laptop. Follow the instructions in `receiver_server_project/README.md` for setup and execution. Make sure your phone and laptop are on the same Wi-Fi network and the IP address in the app is correctly set to your laptop's IP (port 5000).
3.  **Grant Location Permission:** When you launch the app, it will ask for location permission. **It is critical to go into your phone's settings for this app and set Location permission to "Allow all the time"** (or similar phrasing depending on your Android version). This is essential for continuous background tracking.
    * **How to:** Go to Phone Settings -> Apps -> Rover GPS Tracker -> Permissions -> Location -> Select "Allow all the time".
4.  **Set Battery Usage to Unrestricted:** To prevent Android from optimizing battery and delaying location updates, set the app's battery usage to unrestricted.
    * **How to:** Go to Phone Settings -> Apps -> Rover GPS Tracker -> Battery -> Select "Unrestricted" or "Don't optimize."
5.  **Start Tracking:** Open the app and tap "Start Tracking." The app will continuously send GPS coordinates to your server.

---

### For Developers / Project Overview:

For developers interested in contributing or understanding the codebase, please refer to the individual `README.md` files within the `rover_gps_tracker` and `receiver_server_project` directories for detailed setup and development instructions for each component.