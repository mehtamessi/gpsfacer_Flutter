import 'package:flutter/material.dart';

import 'dart:async';

import 'package:flutter_geofence/geofence.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gpsfacer_mukesh/Constants.dart';
import 'package:gpsfacer_mukesh/FacePage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FaceRecog Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainScreen(),
    );
  }
}


class MainScreen extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MainScreen> {
bool statusCall=false;
  @override
  void initState() {
    setState(() {
      Geofence.requestPermissions();
    });
    super.initState();
    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('FaceScanner app'),
        ),
        body:
        new Container(
        margin: const EdgeInsets.only(top: 30.0,left: 30,right: 30,bottom: 10),
        child: ListView(children: <Widget>[
         Text('face detection within 10 meter radius',
           textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.blue,
              fontSize: 18,
            ),),

          SizedBox(height: 30),

          RaisedButton(
            padding: EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
                side: BorderSide(color: Colors.lightBlueAccent)),
            color: Colors.lightBlueAccent,
            textColor: Colors.white,
            child: Text("Face Detection".toUpperCase(),
                style: TextStyle(fontSize: 14)),

            onPressed: () {
              //Geofence.requestPermissions();
              setState(() {
                addRegion();
              });

            },
          ),

          SizedBox(height: 30),

          RaisedButton(
            padding: EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
                side: BorderSide(color: Colors.lightBlueAccent)),
            color: Colors.lightBlueAccent,
            textColor: Colors.white,
            child: Text("Request GPS Permissions".toUpperCase(),
                style: TextStyle(fontSize: 14)),

            onPressed: () {
              //Geofence.requestPermissions();
              setState(() {
                Geofence.requestPermissions();
              });
            },
          ),
        ],
        ),)
      ),
    );
  }

  void getCurrentLocation()  {

    Geofence.getCurrentLocation().then((coordinate) {
      showToast("Your latest latitude: ${coordinate.latitude} and longitude: ${coordinate.longitude}");
          Constants.LocationUpdated=coordinate;

      if(!statusCall&&Constants.LocationUpdated!=null) {
        Navigator.of(context).push(new MaterialPageRoute(builder:
            (BuildContext context) => new FacePage()));
      }else{
        _showMaterialDialog();
      }
    });
setState(() {
  if(Constants.LocationUpdated!=null) {

    Geofence.startListeningForLocationChanges();
    Geofence.backgroundLocationUpdated.stream.listen((event) {
      //scheduleNotification("You moved significantly", "a significant location change just happened.");
      showToast(
          "You moved significantly, a significant location change just happened.");
      setState(() {
        statusCall = false;
      });
    });

  }
});

  }
  void addRegion() {

    Geolocation location = Geolocation(latitude: 24.1380443, longitude: 74.0313776, radius: 10.0, id: "Kerkplein13");
    Geofence.addGeolocation(location, GeolocationEvent.entry).then((onValue) {
      if(Constants.LocationUpdated!=null) {

          Geofence.startListeningForLocationChanges();
          Geofence.backgroundLocationUpdated.stream.listen((event) {
            //scheduleNotification("You moved significantly", "a significant location change just happened.");
            showToast("You moved significantly, a significant location change just happened.");
            setState(() {
              statusCall = false;
            });
          });

      }

    }).catchError((onError) {
      print("great failure");
    });
    setState(() {
      getCurrentLocation();
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {

    if (!mounted) return;
    Geofence.initialize();
    Geofence.startListening(GeolocationEvent.entry, (entry) {
      showToast("Entry of a georegion - Welcome to: ${entry.id}");
    });

    Geofence.startListening(GeolocationEvent.exit, (entry) {
      showToast("Exit of a georegion - Byebye to: ${entry.id}");
    });
  }

  void showToast(String message){
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey.shade300,
        textColor: Colors.black87,
        fontSize: 14.0
    );
  }

_showMaterialDialog() {
  showDialog(
      context: context,
      builder: (_) => new AlertDialog(
        title: new Text("Alert!"),
        content: new Text("You are out of 10 meter boundry."),
        actions: <Widget>[
          FlatButton(
            child: Text('Close me!'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      ));
}

}