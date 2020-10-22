import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  processText() {
    setState(() {
      data = jsonDecode(res.body);
    });
    print(data['data']['emails']);
    for(int i=1;i<data.length;i++){
      print(data['data']['emails'][i]['value']);
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
                  hintText: 'Domain Name'),
            ),
            RaisedButton(
                color: Colors.deepOrange,
                child: Text(
                  'Search Emails',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  res = await http.get(
                      'https://api.hunter.io/v2/domain-search?domain=$domain&api_key=b5add8f0a662fb1e7971c15cc316db9a7ef8d20a');
                  processText();
                }),
            SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}
