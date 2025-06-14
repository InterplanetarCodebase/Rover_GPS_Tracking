// main.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // For making HTTP requests
import 'dart:convert'; // For JSON encoding/decoding
import 'package:location/location.dart'; // For accessing device location
import 'dart:async'; // Required for StreamSubscription
import 'package:flutter/services.dart'; // Required for PlatformException

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rover GPS Tracker',
      theme: ThemeData(
        primarySwatch:
            Colors.teal, // A different primary color for the new functionality
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const GPSTrackerPage(),
    );
  }
}

class GPSTrackerPage extends StatefulWidget {
  const GPSTrackerPage({super.key});

  @override
  State<GPSTrackerPage> createState() => _GPSTrackerPageState();
}

class _GPSTrackerPageState extends State<GPSTrackerPage> {
  // TextEditingController for the IP address input field
  final TextEditingController _ipController = TextEditingController();

  // Message to display status to the user
  String _message = 'Tap "Start Tracking" to begin sending coordinates.';

  // State variables to hold current latitude and longitude
  String _currentLat = 'N/A';
  String _currentLon = 'N/A';

  // Instance of the location service
  Location location = Location();

  // StreamSubscription to listen for continuous location changes
  StreamSubscription<LocationData>? _locationSubscription;

  // Boolean to track if GPS tracking is currently active
  bool _isTracking = false;

  // Define the target IP address and port for the server
  // YOU MUST CONFIRM/REPLACE THIS WITH YOUR LAPTOP'S ACTUAL IP ADDRESS.
  // Use the IP address you found with `ip a` (e.g., 192.168.0.140)
  // The port should match the one your Python server is listening on (default 5000)
  final int _targetPort = 5000;

  @override
  void initState() {
    super.initState();
    _ipController.text =
        '192.168.0.140'; // <<< CONFIRM/REPLACE WITH YOUR LAPTOP'S ACTUAL IP
    _checkLocationPermissions(); // Immediately check permissions on app start
  }

  // Asynchronous function to check and request location permissions
  Future<void> _checkLocationPermissions() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // 1. Check if location service is enabled on the device
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      // If not enabled, request the user to enable it
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        setState(() {
          _message =
              "Location service disabled. Please enable it in device settings.";
        });
        return; // Exit if service remains disabled
      }
    }

    // 2. Check and request app permissions for location access (foreground)
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      // If foreground permission is denied, request it
      permissionGranted = await location.requestPermission();
    }

    // After attempting to request, check the final foreground permission status
    if (permissionGranted == PermissionStatus.granted) {
      setState(() {
        _message = 'Foreground location permission granted. Ready to track.';
      });
    } else if (permissionGranted == PermissionStatus.denied ||
        permissionGranted == PermissionStatus.deniedForever) {
      setState(() {
        _message =
            "Foreground location permission denied. Cannot track GPS data. Please grant permission in app settings.";
      });
    }
    // If the permission is 'always' (Android 10+), it will also be considered 'granted' for foreground purposes by the plugin.
    // The specific background permission check happens when enableBackgroundMode is called.
  }

  // Function to start continuous GPS tracking and sending
  void _startTracking() async {
    // Ensure permissions are still good before starting
    await _checkLocationPermissions();

    // Check the current message to see if permissions are definitely ready
    if (_message.contains("denied") || _message.contains("disabled")) {
      // Removed 'restricted' here
      // Don't start tracking if permissions or service are not ready
      return;
    }

    // Configure location update settings
    location.changeSettings(
      accuracy: LocationAccuracy.high, // Use high accuracy for better precision
      interval: 500, // Update interval: 0.5 seconds (500 milliseconds)
      distanceFilter: 0, // Get updates even for small movements
    );

    // Request to enable background location updates (for Android 8.0/API 26+)
    // This helps the app continue tracking even when minimized
    try {
      await location.enableBackgroundMode(enable: true);
    } on PlatformException catch (e) {
      // Specific error handling for background permission denial
      if (e.code == 'PERMISSION_DENIED') {
        setState(() {
          _message =
              "Background location permission denied. For continuous tracking, go to App Info -> Permissions -> Location, and set to 'Allow all the time'.";
          _isTracking =
              false; // Cannot track in background without this permission
        });
        print("Background location permission denied: ${e.message}");
        return; // Stop here if background permission is denied
      } else {
        // Re-throw other platform exceptions
        rethrow;
      }
    }

    setState(() {
      _isTracking = true;
      _message = "Tracking started. Waiting for first coordinates...";
    });

    // Start listening for location changes continuously
    _locationSubscription = location.onLocationChanged.listen((
      LocationData currentLocation,
    ) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          // Update UI with current coordinates
          _currentLat = currentLocation.latitude!.toStringAsFixed(6);
          _currentLon = currentLocation.longitude!.toStringAsFixed(6);
          _message = "Tracking: Lat $_currentLat, Lon $_currentLon";
        });
        // Send the obtained location data to the server
        _sendLocationData(currentLocation);
      } else {
        setState(() {
          _message = "Tracking... waiting for valid coordinates.";
        });
      }
    });
  }

  // Function to stop GPS tracking
  void _stopTracking() {
    _locationSubscription
        ?.cancel(); // Cancel the location stream to stop updates
    setState(() {
      _isTracking = false;
      _message = "Tracking stopped.";
      // Reset coordinates display if desired, or keep last known
      // _currentLat = 'N/A';
      // _currentLon = 'N/A';
    });
    // Disable background location updates when stopping
    location.enableBackgroundMode(enable: false);
  }

  // Asynchronous function to send location data via HTTP POST
  Future<void> _sendLocationData(LocationData locationData) async {
    final String targetIp = _ipController.text;

    // Validate IP address before sending
    if (targetIp.isEmpty) {
      print('Error: Target IP address is empty. Cannot send coordinates.');
      // You might want to show a SnackBar or AlertDialog here
      return;
    }

    // Construct the URI for the POST request to the /send-coordinates endpoint
    final uri = Uri.parse('http://$targetIp:$_targetPort/send-coordinates');

    try {
      final response = await http
          .post(
            uri,
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              'latitude': locationData.latitude, // Use direct double values
              'longitude': locationData.longitude, // Use direct double values
              'timestamp': DateTime.now()
                  .toIso8601String(), // Include a timestamp
            }),
          )
          .timeout(
            const Duration(seconds: 5),
          ); // 5-second timeout for the network request

      if (response.statusCode == 200) {
        // print('Coordinates sent successfully.'); // Log for debugging, but don't update _message every 0.5s
      } else {
        print(
          'Failed to send coordinates. Status: ${response.statusCode}. Response: ${response.body}',
        );
        setState(() {
          _message = 'Send failed! Status: ${response.statusCode}';
        });
      }
    } on http.ClientException catch (e) {
      print('HTTP Client Exception sending coordinates: ${e.message}');
      setState(() {
        _message = 'Network error sending! Check IP/Server.';
      });
    } on Exception catch (e) {
      print(
        'An unexpected error occurred sending coordinates: ${e.toString()}',
      );
      setState(() {
        _message = 'Error sending: ${e.toString()}';
      });
    }
  }

  // Dispose method: Clean up resources when the widget is removed
  @override
  void dispose() {
    _locationSubscription
        ?.cancel(); // Cancel the location stream to prevent memory leaks
    _ipController.dispose(); // Dispose the IP controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rover GPS Tracker'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Display Current Coordinates
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  color: Theme.of(
                    context,
                  ).primaryColor.withOpacity(0.1), // Dynamic background color
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Text(
                          'Current GPS Coordinates:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'Latitude: $_currentLat',
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Longitude: $_currentLon',
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // IP Address Input Field
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _ipController,
                      decoration: InputDecoration(
                        labelText: 'Target IP Address',
                        hintText: 'e.g., 192.168.0.140',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.computer),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Start/Stop Tracking Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isTracking
                            ? null
                            : _startTracking, // Disable if tracking
                        icon: const Icon(Icons.play_arrow, size: 24),
                        label: const Text(
                          'Start Tracking',
                          style: TextStyle(fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 8,
                          shadowColor: Colors.greenAccent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isTracking
                            ? _stopTracking
                            : null, // Enable only if tracking
                        icon: const Icon(Icons.stop, size: 24),
                        label: const Text(
                          'Stop Tracking',
                          style: TextStyle(fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 8,
                          shadowColor: Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Message Display
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: Colors.blueGrey[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blueGrey[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Ensure your laptop\'s IP address is correct and '
                  'the Python server is running (no changes needed for server).',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.orange,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
