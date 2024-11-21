import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPickerScreen extends StatefulWidget {
  @override
  _MapPickerScreenState createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng _initialLocation = LatLng(20.5937, -100.3899); // Cambia esto a una ubicación inicial relevante
  LatLng? _pickedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selecciona una ubicación'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              if (_pickedLocation != null) {
                Navigator.pop(context, _pickedLocation);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Selecciona una ubicación primero')),
                );
              }
            },
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _initialLocation,
          zoom: 14,
        ),
        onTap: (LatLng location) {
          setState(() {
            _pickedLocation = location;
          });
        },
        markers: _pickedLocation == null
            ? {}
            : {
                Marker(
                  markerId: MarkerId('selected_location'),
                  position: _pickedLocation!,
                ),
              },
      ),
    );
  }
}
