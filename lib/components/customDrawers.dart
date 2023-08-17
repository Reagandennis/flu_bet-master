

import 'package:flutter/material.dart';
import 'package:naxtrustbets/screens/login.dart';
import 'package:naxtrustbets/screens/myhomepage.dart';
import 'package:naxtrustbets/screens/predictionSlip.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomDrawer extends StatefulWidget {

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(
              "Welcome",
              style: TextStyle(fontSize: 20),
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            trailing: Icon(Icons.home),
            title: Text('Home'),
            onTap: () async {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (ctx) => MyHomePage(title: 'NaxTrust bet')));
            },
          ),
          ListTile(
            trailing: Icon(Icons.sports),
            title: Text('Prediction Slip'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (ctx) => PredictionSlip()));
            },
          ),
          ListTile(
            title: Text('Log Out'),
            trailing: Icon(Icons.logout),
            onTap: () async {
              Navigator.pop(context);
              (await SharedPreferences.getInstance()).clear();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (ctx) => login()),
                  (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
