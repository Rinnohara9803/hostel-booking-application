import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hostel_booking_application/utilities/themes.dart';

class HostelMapPage extends StatefulWidget {
  const HostelMapPage({Key? key}) : super(key: key);
  static const routeName = '/hostelMapPage';

  @override
  State<HostelMapPage> createState() => _HostelMapPageState();
}

class _HostelMapPageState extends State<HostelMapPage> {
  late GoogleMapController _googleMapController;

  Marker getMarker(double latitude, double longitude) {
    return Marker(
      markerId: const MarkerId('rino'),
      infoWindow: const InfoWindow(
        title: 'Hostel Location',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueBlue,
      ),
      position: LatLng(
        latitude,
        longitude,
      ),
    );
  }

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context)!.settings.arguments as LatLng;
    final lat = routeArgs.latitude;
    final long = routeArgs.longitude;
    return SafeArea(
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          child: Icon(
            Icons.center_focus_strong,
            color: ThemeClass.primaryColor,
          ),
          onPressed: () {
            _googleMapController.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: LatLng(
                    lat,
                    long,
                  ),
                  zoom: 12.5,
                  tilt: 0,
                ),
              ),
            );
          },
        ),
        body: Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              markers: {
                Marker(
                  markerId: const MarkerId('rino'),
                  infoWindow: const InfoWindow(
                    title: 'Hostel Location',
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueBlue,
                  ),
                  position: LatLng(
                    lat,
                    long,
                  ),
                ),
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  lat,
                  long,
                ),
                zoom: 12.5,
                tilt: 0,
              ),
              onMapCreated: (controller) => _googleMapController = controller,
            ),
            Positioned(
              right: 10,
              top: 10,
              child: IconButton(
                color: ThemeClass.primaryColor,
                onPressed: () {
                  _googleMapController.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: LatLng(
                          lat,
                          long,
                        ),
                        zoom: 15.5,
                        tilt: 50,
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.location_on_outlined,
                  size: 35,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
