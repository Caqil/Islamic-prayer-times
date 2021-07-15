import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:provider/provider.dart';

import 'provider/settings_provider.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Completer<GoogleMapController> _controller = Completer();
  final searchBarContoller = FloatingSearchBarController();
  FocusNode _focusNode = FocusNode();
  bool isInEditMode = false;
  BuildContext searchContext;
  var _searchController = TextEditingController();
  List<Marker> _markers = <Marker>[];
  CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(0.0, 0.0),
    zoom: 14.4746,
  );
  String address;
  bool addressFound = true;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        isInEditMode = _focusNode.hasFocus;
      });
    });

    var state = Provider.of<SettingsProvider>(context, listen: false);
    _searchController.text = state.address;
    address = _searchController.text;
    _kGooglePlex = CameraPosition(
      target: LatLng(state.latitude, state.longitude),
      zoom: 14.4746,
    );
    if (state.latitude == 0.0 && state.longitude == 0.0) {
      getCurrentPosition();
    } else {
      _markers.add(Marker(
        markerId: MarkerId('SomeId'),
        position: LatLng(state.latitude, state.longitude),
      ));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  getCurrentPosition() async {
    Position _position = await _determinePosition();

    List<Placemark> placemarks =
        await placemarkFromCoordinates(_position.latitude, _position.longitude);

    _searchController.text = placemarks.first.subLocality +
        " " +
        placemarks.first.subAdministrativeArea;

    address = _searchController.text;

    setState(() {
      _kGooglePlex = CameraPosition(
        target: LatLng(_position.latitude, _position.longitude),
        zoom: 14.4746,
      );
    });

    _markers.add(Marker(
      markerId: MarkerId('SomeId'),
      position: LatLng(_position.latitude, _position.longitude),
      onDragEnd: (value) => {},
    ));

    _goToTheLake();
  }

  getAddressFromMap(double latitude, double longitude) async {
    Position _position = Position(latitude: latitude, longitude: longitude);

/*    setState(() {
      searchBarContoller.query = "euijbce wje";
    });*/

    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);

    _searchController.text = placemarks.first.subLocality +
        " " +
        placemarks.first.subAdministrativeArea;

    address = _searchController.text;
    //
    // address = placemarks.first.subLocality +
    //     " " +
    //     placemarks.first.subAdministrativeArea +
    //     " " +
    //     placemarks.first.administrativeArea;

    print("address: " + placemarks.first.toString());

    setState(() {
      _kGooglePlex = CameraPosition(
        target: LatLng(_position.latitude, _position.longitude),
        zoom: 14.4746,
      );
    });

    _markers.add(Marker(
      markerId: MarkerId('SomeId'),
      position: LatLng(_position.latitude, _position.longitude),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            markers: Set<Marker>.of(_markers),
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            onTap: (LatLng latLng) {
              getAddressFromMap(latLng.latitude, latLng.longitude);
            },
          ),
          SafeArea(
            child: Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Expanded(
                    child: TextField(
                      focusNode: _focusNode,
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (term) {
                        getLocationFrom(term);
                      },
                      decoration: InputDecoration(
                          border: InputBorder.none, hintText: "Search..."),
                    ),
                  ),
                  Visibility(
                    visible: isInEditMode,
                    child: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        _searchController.clear();
                      },
                    ),
                  ),
                  Visibility(
                    visible: !isInEditMode,
                    child: IconButton(
                      icon: Icon(Icons.location_on),
                      onPressed: () {
                        getCurrentPosition();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // buildFloatingSearchBar(),
        ],
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        child: FloatingActionButton.extended(
          onPressed: () {
            if (address.trim().isNotEmpty) {
              saveAddress();
            }
          },
          label: Text('Save'),
          icon: Icon(Icons.check),
        ),
      ),
    );
  }

  Widget buildFloatingSearchBar() {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return FloatingSearchBar(
      hint: 'Search...',
      title: Text(address == null ? "" : address),
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 800),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      maxWidth: isPortrait ? 600 : 500,
      onSubmitted: (val) {
        FloatingSearchBar.of(searchContext).close();
        searchBarContoller.close();
        // getLocationFrom(val);
        // Navigator.pop(context);
      },
      debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: (query) {
        FloatingSearchBar.of(context).close();
        // Call your model, bloc, controller here.
      },
      // controller: searchBarContoller,
      // Specify a custom transition to be used for
      // animating between opened and closed stated.
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
            icon: const Icon(Icons.place),
            onPressed: () {
              getCurrentPosition();
            },
          ),
        ),
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),
      ],
      builder: (ctx, transition) {
        searchContext = ctx;
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Material(
            color: Colors.white,
            elevation: 4.0,
            child: Container(
              child: Text(
                "shjefnvkjkd",
                style: TextStyle(fontSize: 30),
              ),
            ),
            // child: Column(
            //   mainAxisSize: MainAxisSize.min,
            //   children: Colors.accents.map((color) {
            //     return Container(height: 112, color: color);
            //   }).toList(),
            // ),
          ),
        );
      },
    );
  }

  getLocationFrom(String val) async {
    try {
      List<Location> locations = await locationFromAddress(val);
      print("locations:" + locations.toString());
      Position _position = Position(
          latitude: locations[0].latitude, longitude: locations[0].longitude);

      List<Placemark> placemarks = await placemarkFromCoordinates(
          _position.latitude, _position.longitude);

      _searchController.text = placemarks.first.subLocality +
          " " +
          placemarks.first.subAdministrativeArea;

      address = _searchController.text;

      setState(() {
        _kGooglePlex = CameraPosition(
          target: LatLng(_position.latitude, _position.longitude),
          zoom: 14.4746,
        );
      });

      _markers.add(Marker(
        markerId: MarkerId('SomeId'),
        position: LatLng(_position.latitude, _position.longitude),
        // infoWindow: InfoWindow(title: 'Your location'),
        onDragEnd: (value) => {},
      ));

      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(_kGooglePlex));
      addressFound = true;
    } catch (Exception) {
      addressFound = false;
      print("Exception: ${Exception.toString()}");
    }
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kGooglePlex));
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permantly denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  void saveAddress() {
    var state = Provider.of<SettingsProvider>(context, listen: false);

    state.setLatitude(_kGooglePlex.target.latitude);
    state.setLongitude(_kGooglePlex.target.longitude);
    print("addd: " + address);
    state.setAddress(address);

    Navigator.pop(context);
  }
}
