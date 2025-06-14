# Rover GPS Tracking Solution

This repository contains the source code for a comprehensive solution designed for tracking the GPS coordinates of a mobile device (Android phone) and sending them continuously (every 0.5 seconds) to a central server (your laptop). This setup is ideal for applications like rover competitions, where real-time location data is essential.

The solution consists of two main components:

1.  **`rover_gps_tracker`**: A Flutter Android application that runs on the mobile device to acquire and transmit GPS data.
2.  **`receiver_server`**: A Python Flask server that runs on a laptop/PC to receive and process the incoming GPS coordinates.

---

### For End Users / Quick Deployment:

**Important Note:** The source code provided in this repository is intended for **development, collaboration, and learning purposes only**. If you are an end-user and wish to use the app without building from source, please download the compiled Android APK directly from the Google Drive link below:

**[Download Rover GPS Tracker APK from Google Drive](https://drive.google.com/file/d/1OKRCWpzat0TcAbh7MitbSIVkACTFZH1q/view?usp=sharing)**

**Usage Instructions for the App on Android:**

1.  **Install the APK:** Download the APK from the link above and install it on your Android phone. You may need to enable "Install unknown apps" in your phone's security settings.
2.  **Grant Location Permission:** When you launch the app, it will ask for location permission. **It is critical to go into your phone's settings for this app and set Location permission to "Allow all the time"** (or similar phrasing depending on your Android version). This is essential for continuous background tracking.
    * **How to:** Go to Phone Settings -> Apps -> Rover GPS Tracker -> Permissions -> Location -> Select "Allow all the time".
3.  **Set Battery Usage to Unrestricted:** To prevent Android from optimizing battery and delaying location updates, set the app's battery usage to unrestricted.
    * **How to:** Go to Phone Settings -> Apps -> Rover GPS Tracker -> Battery -> Select "Unrestricted" or "Don't optimize."

4.  **Run the Receiver Server:** Ensure the Python `receiver_server` is running on your PC/laptop. Follow the instructions in `receiver_server/README.md` for setup and execution. **Make sure your phone and laptop are on the same Wi-Fi network.**

5.  **Find and Insert the IP of the laptop in the App:** 

    The Flutter app needs your laptop's IP address to send data.

    1.  Open a terminal on your Linux laptop.
    2.  Run the command: `ip a`
    3.  Look for your active network interface (e.g., `wlp2s0` for Wi-Fi) and find the `inet` address. This is your local IP (e.g., `192.168.0.140`).
    4.  Ensure your phone and laptop are on the same Wi-Fi network.

6.  **Start Tracking:** Open the app and tap "Start Tracking." The app will continuously send GPS coordinates to your server.

---

### For Developers / Project Overview:

For developers interested in contributing or understanding the codebase, please refer to the individual `README.md` files within the `rover_gps_tracker` and `receiver_server` directories for detailed setup and development instructions for each component.