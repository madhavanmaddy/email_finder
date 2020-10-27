import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart' as url;
import 'package:fluttertoast/fluttertoast.dart' as toast;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Email Finder',
      home: MyHomePage(),
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String domain;
  http.Response res;
  Map data;
  Map metaData;
  List emailsDetails;
  List emails = [];
  int results;
  String test;
  processText() {
    FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    setState(() {
      data = jsonDecode(res.body);
      metaData = Map.from(data['meta']);
      results = metaData['results'];
      emailsDetails = List.castFrom(data['data']['emails']);
      emails = [];
      if (emailsDetails.isEmpty) {
        toast.Fluttertoast.showToast(
            msg: "Couldn't find Emails on that domain :(");
      } else {
        for (int i = 0; i < 10; i++) {
          emails.add(emailsDetails[i]['value']);
        }
        print(emails);
      }
    });
  }

  sendMail(String email) async {
    bool test;
    test = await url.canLaunch("mailto:$email");
    if (test) {
      url.launch("mailto:$email");
    } else {
      toast.Fluttertoast.showToast(msg: "Couldn/'t Send Mail\nTry Again");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Email Finder'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        physics: BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: (_domain) {
                setState(() {
                  domain = _domain;
                });
              },
              decoration: InputDecoration(
                  fillColor: Colors.deepOrange,
                  icon: Icon(Icons.search),
                  hintText: 'Domain'),
            ),
            RaisedButton(
                color: Colors.deepOrange,
                child: Text(
                  'Search Emails',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  FocusScopeNode currentFocus = FocusScope.of(context);

                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                  if (domain == null) {
                    toast.Fluttertoast.showToast(
                        msg: 'Enter a Domain to Search');
                  } else {
                    if (domain == null || domain.isEmpty) {
                      toast.Fluttertoast.showToast(
                          msg: "Enter a Domain to Search");
                    }
                    domain = domain.toLowerCase();
                    res = await http.get(
                        'https://api.hunter.io/v2/domain-search?domain=$domain&api_key=b5add8f0a662fb1e7971c15cc316db9a7ef8d20a');
                    if (res == null) {
                      toast.Fluttertoast.showToast(
                          msg: "Couldn\'t Fetch Information!!");
                    } else {
                      processText();
                    }
                  }
                }),
            SizedBox(
              height: 30,
            ),
            emails.isNotEmpty
                ? ListView.builder(
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: emails.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Icon(
                          Icons.mail,
                          color: Colors.deepOrange,
                        ),
                        title: Text(emails[index]),
                        onTap: () {
                          sendMail(emails[index]);
                        },
                      );
                    })
                : Container(),
          ],
        ),
      ),
      resizeToAvoidBottomInset: false,
      bottomSheet: Container(
        color: Colors.deepOrange,
        height: 20,
        child: Center(
            child: Text(
          'Powered by hunter.io',
          style: TextStyle(color: Colors.white),
        )),
      ),
    );
  }
}
