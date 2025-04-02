 import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  LatLng userLocation = LatLng(28.5355, 77.3910); // Default location (Noida)
  late final MapController mapController;
  StreamSubscription<Position>? positionStream;

  final List<LatLng> routePoints = [
    LatLng(28.5682, 77.3245),
    LatLng(28.5733, 77.3341),
    LatLng(28.5800, 77.3442),
    LatLng(28.5911, 77.3553),
    LatLng(28.6000, 77.3651),
    LatLng(28.6099, 77.3750),
  ];



  @override
  void initState() {
    super.initState();
    mapController = MapController();
    requestPermission();
    startTracking();
  }

  // Request Location Permission
  Future<void> requestPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      print("Location permission denied");
    }
  }

  // Start Live Tracking
  void startTracking() {
    positionStream = Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        userLocation = LatLng(position.latitude, position.longitude);
        mapController.move(userLocation, mapController.camera.zoom);
      });

      if (!isOnRoute(userLocation, routePoints)) {
        print("⚠️ You are off the route! Please re-route.");
      }
    });
  }

  // Function to Check if User is on the Route
  bool isOnRoute(LatLng userLocation, List<LatLng> routePoints) {
    for (LatLng point in routePoints) {
      double distance = Geolocator.distanceBetween(
          userLocation.latitude, userLocation.longitude,
          point.latitude, point.longitude
      );

      if (distance < 20) { // Allow small deviation (20 meters)
        return true;
      }
    }
    return false;
  }

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Live Tracking")),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: userLocation,
          initialZoom: 15.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',userAgentPackageName: "com.example.flutter_map",
          ),
          // User's current location marker
          MarkerLayer(
            markers: [
              Marker(
                point: userLocation,
                width: 40,
                height: 40,
                child: Icon(Icons.location_pin, color: Colors.red, size: 40),
              ),
            ],
          ),
          // Route Polyline
          PolylineLayer(
            polylines: [
              Polyline(
                points: routePoints,
                strokeWidth: 5,
                color: Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }
}