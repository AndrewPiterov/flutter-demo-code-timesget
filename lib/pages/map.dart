import 'dart:async';
import 'package:flutter/material.dart';
import "package:google_maps_flutter/google_maps_flutter.dart";
import 'package:latlong/latlong.dart' as latlong;
import 'package:timesget/components/app_bar.dart';
import 'package:timesget/config/app_config.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'package:timesget/styles/constants.dart';

class MapPage extends StatefulWidget {
  @override
  State<MapPage> createState() {
    return _MapPage();
  }
}

class _MapPage extends State<MapPage> {
  static LatLng get companyLat => LatLng(30.087202, 31.180082);

  List<Marker> markers = <Marker>[
    Marker(
      markerId: MarkerId('company_position'),
      position: companyLat,
      infoWindow:
          InfoWindow(title: AppConfig.appName, snippet: AppConfig.appName),
      onTap: () {},
    ),
  ];

  Completer<GoogleMapController> _controller = Completer();

  String error;

  bool hasPermission;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  LocationData currentLocation;
  var location = new Location();

  Future<CameraPosition> _getCurrentLocation() async {
    // Platform messages may fail, so we use a try/catch PlatformException.

    hasPermission = await location.hasPermission();

    if (hasPermission) {
      try {
        currentLocation = await location.getLocation();
        return CameraPosition(
          target: LatLng(currentLocation.latitude, currentLocation.longitude),
          zoom: _computeZoom(),
          bearing: 15.0,
          tilt: 45.0,
        );
      } on PlatformException catch (e) {
        if (e.code == 'PERMISSION_DENIED') {
          error = 'Permission denied';
        }
        currentLocation = null;
      }
    } else {
      // TODO:: await location.requestPermission();
    }

    return CameraPosition(
      target: LatLng(companyLat.latitude, companyLat.longitude),
      zoom: 16,
      bearing: 15.0,
      tilt: 45.0,
    );
  }

  double _computeZoom() {
    final latlong.Distance distance = new latlong.Distance();

    final m = distance(
        latlong.LatLng(currentLocation.latitude, currentLocation.longitude),
        latlong.LatLng(companyLat.latitude, companyLat.longitude));

    if (m < 1000) {
      return 16;
    }

    if (m < 5000) {
      return 15;
    }

    if (m < 10000) {
      return 14;
    }

    return 12;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getAppBar(context),
        body: FutureBuilder(
          future: _getCurrentLocation(),
          builder: (context, snap) {
            if (!snap.hasData) {
              return AppConstants.circleSpinner;
            }

            final position = snap.data;

            return GoogleMap(
              initialCameraPosition: position,
              mapType: MapType.normal,
              markers: Set<Marker>.of(markers),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              myLocationButtonEnabled: hasPermission,
              myLocationEnabled: hasPermission,
            );
          },
        ));
  }
}
