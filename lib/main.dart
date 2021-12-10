import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Login With MS-Office'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _counter = "";



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                child: Text("Login"),
                onPressed: ()async{
                  try{

                    var result = await FlutterWebAuth.authenticate(
                        url: "https://staging-tossauth.teo-intl.com/connect/authorize?client_id=1CB07952-B8EC-4433-9CC0-BD062F2F519A&scope=TOSSAPI%20offline_access&response_type=code&redirect_uri=oauth%3A%2F%2Ftoss&nonce=81387052-6182-486a-9e75-b9b9985a4d63",
                        callbackUrlScheme: "oauth");

                    String? code= Uri.parse(result).queryParameters['code'];
                    Map<String, dynamic> jsonMap = {
                      'client_id': '1CB07952-B8EC-4433-9CC0-BD062F2F519A',
                      "client_secret":"TOSS_Android_App_Secret",
                      "grant_type":"authorization_code",
                      "scope":"openid profile TOSSAPI offline_access",
                      "redirect_uri":"oauth://toss",
                      "code": code
                    };

                    final res = await http.post(
                      Uri.parse("https://staging-tossauth.teo-intl.com/Connect/token"),
                      headers:<String, String>{"Content-Type":"application/x-www-form-urlencoded"},
                      body:jsonMap,
                    );

                    if(res.statusCode==200){
                      code = jsonDecode(res.body)['access_token'];
                      Map<String, dynamic> patload = Jwt.parseJwt(code!);
                      setState(() {
                        _counter = "Name: "+patload['name']+'\n'+"Designation: "+patload['empDesignation']+ "\nEmail:"+ patload['email'];
                      });

                    }else {
                      setState(() {
                      _counter = "Error "+res.statusCode.toString();
                    });
                    }
                  }
                  catch(e){
                    setState(() {
                      _counter = e.toString();
                    });
                  }
                },
              ),
              Center(
                child: Text(
                  '$_counter',
                 // style: Theme.of(context).textTheme.headline6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}