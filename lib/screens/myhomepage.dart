// ignore_for_file: unused_import

import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:naxtrustbets/components/customDrawers.dart';
import 'package:naxtrustbets/config/strings.dart';
import 'package:naxtrustbets/screens/predictionSlip.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title}) ;
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Map userBetsArray = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(widget.title),
          ),
        ),
      ),
      drawer: CustomDrawer(),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Icon(Icons.calendar_today),
                      Text('Top LIVE'),
                    ]),
                    Text('More')
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                StreamBuilder<List>(
                  stream: () async* {
                    while (true) {
                      await Future.delayed(Duration(seconds: 1));

                      List resultArray = json.decode(
                          (await http.get(Uri.parse(fixturesURL))).body);

                      yield resultArray;
                    }
                  }(),
                  builder: (ctx, snapshot) {
                    if (snapshot.hasError) print(snapshot.error);
                    if (snapshot.hasData) {
                      var resultWidget = <Widget>[];
                      var result = snapshot.data as List;

                      for (var element in result) {
                        try {
                          resultWidget.add(Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            shadowColor: Colors.grey[100],
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      element["league_logo"] == null
                                          ? Container()
                                          : Container(
                                              width: 50,
                                              height: 50,
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    element["league_logo"],
                                                progressIndicatorBuilder:
                                                    (context, url,
                                                            downloadProgress) =>
                                                        CircularProgressIndicator(
                                                            value:
                                                                downloadProgress
                                                                    .progress),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error),
                                              ),
                                            ),
                                      Flexible(
                                        child: Text(element['league_name']),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      element["home_team_logo"] == null
                                          ? Container()
                                          : Container(
                                              width: 50,
                                              height: 50,
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    element["home_team_logo"],
                                                progressIndicatorBuilder:
                                                    (context, url,
                                                            downloadProgress) =>
                                                        CircularProgressIndicator(
                                                            value:
                                                                downloadProgress
                                                                    .progress),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error),
                                              ),
                                            ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text('-'),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      element["away_team_logo"] == null
                                          ? Container()
                                          : Container(
                                              width: 50,
                                              height: 50,
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    element["away_team_logo"],
                                                progressIndicatorBuilder:
                                                    (context, url,
                                                            downloadProgress) =>
                                                        CircularProgressIndicator(
                                                            value:
                                                                downloadProgress
                                                                    .progress),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error),
                                              ),
                                            ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(element["event_home_team"]),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text('VS'),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(element["event_away_team"]),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(element["event_final_result"]),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                      '${element["event_date"]} ${element["event_time"]}'),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          userBetsArray[element["event_key"]] =
                                              {
                                            'decide': 'Win',
                                            'odd': element['odds']['odd_1'],
                                            'away': element['event_away_team'],
                                            'home': element['event_home_team'],
                                            'key': element["event_key"]
                                          };
                                          (await SharedPreferences
                                                  .getInstance())
                                              .setString('bet',
                                                  jsonEncode(userBetsArray));
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8)),
                                              border: Border.all(
                                                  color: Colors.grey)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Text(
                                                'W1 ${element['odds']['odd_1'] != null ? element['odds']['odd_1'] : 0.0}'),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          userBetsArray[element["event_key"]] =
                                              {
                                            'decide': 'Draw',
                                            'odd': element['odds']['odd_x'],
                                            'away': element['event_away_team'],
                                            'home': element['event_home_team'],
                                            'key': element["event_key"]
                                          };
                                          (await SharedPreferences
                                                  .getInstance())
                                              .setString('bet',
                                                  jsonEncode(userBetsArray));
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8)),
                                              border: Border.all(
                                                  color: Colors.grey)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Text(
                                                'X ${element['odds']['odd_x'] != null ? element['odds']['odd_x'] : 0.0}'),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          userBetsArray[element["event_key"]] =
                                              {
                                            'decide': 'Lose',
                                            'odd': element['odds']['odd_2'],
                                            'away': element['event_away_team'],
                                            'home': element['event_home_team'],
                                            'key': element["event_key"]
                                          };
                                          (await SharedPreferences
                                                  .getInstance())
                                              .setString('bet',
                                                  jsonEncode(userBetsArray));
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8)),
                                              border: Border.all(
                                                  color: Colors.grey)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Text(
                                                'W2 ${element['odds']['odd_2'] != null ? element['odds']['odd_2'] : 0.0}'),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ));
                          resultWidget.add(SizedBox(
                            height: 10,
                          ));
                        } catch (e) {}
                      }
                      return Column(children: resultWidget);
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
