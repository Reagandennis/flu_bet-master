import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:naxtrustbets/components/customDrawers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class PredictionSlip extends StatefulWidget {
  @override
  _PredictionSlipState createState() => _PredictionSlipState();
}

class _PredictionSlipState extends State<PredictionSlip> {
  var amountToStakeController = TextEditingController();
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: CustomDrawer(),
      body: SingleChildScrollView(
        child: StreamBuilder<Map>(stream: () async* {
          while (true) {
            await Future.delayed(Duration(seconds: 1));
            yield (jsonDecode(
                (await SharedPreferences.getInstance()).getString('bet') ??
                    '{}') as Map);
          }
        }(), builder: (context, snapshot) {
          if (snapshot.hasData) {
            var dataList = snapshot.data as Map;
            Iterable numberOfBets = dataList.values as Iterable;
            double totalOdds = 0.0;

            var betWidget = <Widget>[];

            for (var keys in dataList.keys) {
              betWidget.add(Container(
                width: double.infinity,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                '${dataList[keys]['home']} vs ${dataList[keys]['away']}'),
                            IconButton(
                                onPressed: () async {
                                  var pref =
                                      (await SharedPreferences.getInstance());
                                  var betList = jsonDecode(
                                      pref.getString('bet') as String) as Map;
                                  betList.remove(dataList[keys]['key']);
                                  await pref.setString(
                                      'bet', jsonEncode(betList));

                                  setState(() {});
                                },
                                icon: Icon(Icons.close))
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                                '${dataList[keys]['decide']} ${dataList[keys]['odd']}'),
                            IconButton(
                              onPressed: () async {},
                              icon: Icon(
                                Icons.close,
                                color: Color(0x00ffffff),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ));
            }
            for (var e in numberOfBets) {
              totalOdds += double.parse(e['odd']);
            }
            return Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: betWidget
                  ..addAll([
                    Text('Main account'),
                    SizedBox(
                      height: 15,
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Bets for period'),
                            Text('${numberOfBets.length}')
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Accumulator'),
                                Text(totalOdds.toString())
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            TextField(
                              controller: amountToStakeController,
                              decoration: InputDecoration(
                                  hintText: 'Enter amount to stake'),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                ),
                                onPressed: () async {
                                  if (amountToStakeController.text.trim() ==
                                      '') {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Please enter amount to stake')));
                                    return;
                                  }
                                  if (totalOdds == 0) {
                                   ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Predict and come back!')));
                                    return;
                                  }

                                  Widget cryptoButton = TextButton(
                                    child: Text("Crypto"),
                                    onPressed: () async {
                                      var instancePref =
                                          await SharedPreferences.getInstance();
                                      var response = jsonDecode((await post(
                                              Uri.parse(
                                                  'https://api.commerce.coinbase.com/charges/'),
                                              headers: {
                                                'Content-Type':
                                                    'application/json',
                                                'X-CC-Api-Key':
                                                    '76668e58-4186-46a5-8478-5b16cd96d3c6',
                                                'X-CC-Version': '2018-03-22',
                                              },
                                              body: jsonEncode({
                                                'name': 'Deposit',
                                                'description':
                                                    'Predict my odds with ${amountToStakeController.text.trim()}',
                                                'local_price': {
                                                  'amount':
                                                      amountToStakeController
                                                          .text
                                                          .trim(),
                                                  'currency': 'USD'
                                                },
                                                "metadata": {
                                                  'userId': instancePref
                                                      .getString('userId'),
                                                  'methodOfPayment':
                                                      'I want to bet on this data ${(await SharedPreferences.getInstance()).getString('bet')}, at ${new DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())},my id is ${(await SharedPreferences.getInstance()).getString('userId')}',
                                                  'sellingMethod': 'nottrade',
                                                  'phone': '',
                                                  'dollarRate': 1,
                                                  'currencyExchange': 'my odds',
                                                  'currency': 'usd',
                                                },
                                                'pricing_type': 'fixed_price'
                                              })))
                                          .body);

                                      Navigator.pop(context);

                                      setState(() {
                                        instancePref.remove('bet');
                                      });

                                      await launch(
                                          response['data']['hosted_url']);
                                    },
                                  );
                                  Widget fiatButton = TextButton(
                                    child: Text("Fiat"),
                                    onPressed: () async {
                                      var instancePref =
                                          await SharedPreferences.getInstance();
                                      var response = jsonDecode((await post(
                                              Uri.parse(
                                                  'https://naxtrust.com/ntc/trading/saveToDb'),
                                              body: jsonEncode({
                                                'amount':
                                                    amountToStakeController.text
                                                        .trim(),
                                                'description':
                                                    'Selling ${amountToStakeController.text.trim()}',
                                                'userId': instancePref
                                                    .getString('userId'),
                                                'phone': '',
                                                'methodOfPayment':
                                                    'I want to bet on this data ${instancePref.getString('bet')}, at ${new DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())},my id is ${instancePref.getString('userId')}',
                                                'sellingMethod': 'nottrade',
                                                'dollarRate': 1,
                                                'currencyExchange': 'my odds',
                                                'currency': 'usd',
                                              })))
                                          .body);

                                      if (response['success']) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                                content:
                                                    Text('Bet Successfull')));
                                        setState(() {
                                          instancePref.remove('bet');
                                        });
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Bet Failed, ${response['error']}')));
                                      }
                                      Navigator.pop(context);
                                    },
                                  );

                                  // set up the AlertDialog
                                  AlertDialog alert = AlertDialog(
                                    title: Text("Choose Method"),
                                    content: Text("Crypto or Fiat"),
                                    actions: [
                                      cryptoButton,
                                      fiatButton,
                                    ],
                                  );

                                  // show the dialog
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return alert;
                                    },
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Text('Predict Now'),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ]),
              ),
            );
          }
          return Center(child: CircularProgressIndicator());
        }),
      ),
      appBar: AppBar(
        title: SizedBox(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text('Prediction Slip'),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              size: 30,
            ),
            onPressed: () {},
          )
        ],
      ),
    );
  }
}
