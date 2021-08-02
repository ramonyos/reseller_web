import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ccf_reseller_web_app/utils/colors.dart';
import 'dart:async';

import 'package:ccf_reseller_web_app/utils/const.dart';

class ChokCheyLocation extends StatefulWidget {
  @override
  _ChokCheyLocationState createState() => _ChokCheyLocationState();
}

class _ChokCheyLocationState extends State<ChokCheyLocation> {
  // static final CameraPosition _kGooglePlex = CameraPosition(
  //   target: LatLng(11.534141, 104.881723),
  //   zoom: 14.4746,
  // );

  // Completer<GoogleMapController> _controller = Completer();

  // BitmapDescriptor customIcon1;
  // createMarker(context) {
  //   if (customIcon1 == null) {
  //     ImageConfiguration configuration = createLocalImageConfiguration(context);
  //     BitmapDescriptor.fromAssetImage(
  //             configuration, 'assets/images/chokchey.png')
  //         .then(
  //       (icon) {
  //         setState(
  //           () {
  //             customIcon1 = icon;
  //           },
  //         );
  //       },
  //     );
  //   }
  // }

  // Set<Marker> markers;
  // @override
  // void didChangeDependencies() {
  //   createMarker(context);

  //   ImageConfiguration configuration =
  //       createLocalImageConfiguration(context, size: Size(100, 100));
  //   BitmapDescriptor.fromAssetImage(configuration, 'assets/images/chokchey.png')
  //       .then((icon) {
  //     markers = Set.from([
  //       Marker(
  //           markerId: MarkerId('12'),
  //           icon: icon,
  //           position: LatLng(11.534141, 104.881723),
  //           onTap: () {})
  //     ]);
  //     setState(() {
  //       customIcon1 = icon;
  //     });
  //   });

  //   super.didChangeDependencies();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        title: Text(
          AppLocalizations.of(context)!.location_chok_chey_finance,
          style: TextStyle(color: logolightGreen),
        ),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: logolightGreen,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
          // child: GoogleMap(
          //   myLocationEnabled: false,
          //   myLocationButtonEnabled: false,
          //   mapType: MapType.terrain,
          //   initialCameraPosition: _kGooglePlex,
          //   onMapCreated: (GoogleMapController controller) {
          //     _controller.complete(controller);
          //   },
          //   markers: markers,
          // ),
          ),
    );
  }
}
