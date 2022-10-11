import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:fyto/res/custom_color.dart';
import 'package:fyto/screens/login_screen.dart';
import 'package:fyto/screens/user_info.dart';
import 'package:fyto/utils/database.dart';
import 'package:fyto/utils/fireauth.dart';

class MapsScreen extends StatefulWidget {
  @override State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {

  late final _mapController;

  @override
    void initState() {
      super.initState();
      
      _mapController = MapController(
                            initMapWithUserPosition: false,
                            initPosition: GeoPoint(latitude: 47.4358055, longitude: 8.4737324),
                            // areaLimit: BoundingBox( east: 10.4922941, north: 47.8084648, south: 45.817995, west: 5.9559113,),
                       );
    }

    @override
      void dispose() {
        super.dispose();
        _mapController.dispose();
      }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.firebaseNavy,

      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          _mapController.addMarker(GeoPoint(latitude: 18.5204, longitude: 73.8567));
        }
      ),

      appBar: AppBar(
        title: const Text("Fyto Map"),
        actions: [
          IconButton(
            onPressed: () {
              if(FireAuth.checkLoggedin(context: context)) {
                User user = FireAuth.getCurrentUser()!;
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (builder) => UserInfoScreen(user: user)),
                );
              }
              else {
                ScaffoldMessenger.of(context).showSnackBar(
                  FireAuth.customSnackbar(content: "No user logged in!"),
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (builder) => LoginScreen()),
                );
              }
            }, 
            icon: const Icon(Icons.account_circle)
          ),
        ],
      ),

      drawer: Drawer(
        backgroundColor: CustomColors.firebaseNavy,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueAccent
              ),
              child: Text(
                "Fyto geo tagger",
                style: TextStyle(color: Colors.white),
              )
            ),
            ListTile(
              title: const Text(
                "Plants Info",
                style: TextStyle(color: Colors.white),
              ),
              leading: const Icon(Icons.info_rounded, color: Colors.white70,),
              onTap: () {
                Navigator.pop(context); // To close the drawer
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("TODO")));
              },
            ),
            ListTile(
              title: const Text(
                "Awoo",
                style: TextStyle(color: Colors.white),
              ),
              leading: const Icon(Icons.info_rounded, color: Colors.white70,),
              onTap: () async {
                PlantDatabase.initDatabase();
                await PlantDatabase.addDummyData();
                final plant = await PlantDatabase.getDummyData();
                if(plant != null)
                  _mapController.addMarker(GeoPoint(latitude: plant.lat, longitude: plant.lng));
              },
            )
          ],
        )
      ),
  
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height/3,
                child: OSMFlutter(
                  controller: _mapController,
                  markerOption: MarkerOption(
                    defaultMarker: const MarkerIcon(
                      icon: Icon(
                        Icons.map_rounded, 
                        color: Colors.greenAccent,
                        size: 20,
                      ),
                    )
                  ),
                )
              ),
            ),
            Column(
              children: PlantDatabase.getPlantsInfo(),
            )
          ],
        )
      ),
    );
  }
}
