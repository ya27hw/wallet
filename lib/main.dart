import 'package:eth_wallet/backend/hive.dart';
import 'package:eth_wallet/util/tools.dart';
import 'package:flutter/material.dart';
import 'package:eth_wallet/routes/library.dart' as route;
import 'package:eth_wallet/login/library.dart' as login;
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

late HiveDB boxxx;

Future<void> main() async {
  // ---------- Hive ----------
  await Hive.initFlutter();
  boxxx = HiveDB();
  await boxxx.createBox("myBox");

  // ---------- Intial route ----------
  bool exists = await checkIfFileExists("wallet.json");

  // ---------- Flutter ----------
  runApp(MyApp(exists: exists));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, required this.exists}) : super(key: key);
  final bool exists;

  @override
  Widget build(BuildContext context) => MaterialApp(
        initialRoute: exists ? route.verify : route.splashLogin,
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
