import 'package:eth_wallet/backend/hive.dart';
import 'package:flutter/material.dart';
import 'package:eth_wallet/routes/library.dart' as route;
import 'package:eth_wallet/login/library.dart' as login;
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

late HiveDB boxxx;

Future<void> main() async {
  await Hive.initFlutter();
  boxxx = HiveDB();
  await boxxx.createBox("myBox");
  boxxx.addData("FUCK", "U");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        initialRoute: route.splashLogin,
        onGenerateRoute: route.controller,
        theme: ThemeData(
            colorScheme: ThemeData().colorScheme.copyWith(
                primary: const Color(0xFF41CD7D), brightness: Brightness.dark)),
        home: const MyHomePage(),
        debugShowCheckedModeBanner: false,
      );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp();
  }
}
