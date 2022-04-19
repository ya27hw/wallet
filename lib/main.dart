import 'package:eth_wallet/db/init_db.dart';
import 'package:eth_wallet/util/classes.dart';
import 'package:eth_wallet/util/tools.dart';
import 'package:flutter/material.dart';
import 'package:eth_wallet/routes/library.dart' as route;
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  // ---------- Hive ----------
  await Hive.initFlutter();

  Hive
    ..registerAdapter(NetworkAdapter())
    ..registerAdapter(TokenAdapter())
    ..registerAdapter(TransactionTypeAdapter())
    ..registerAdapter(TransactionDataAdapter());

  final myBox = await Hive.openBox('myBox');
  final tokenBox = await Hive.openBox("tokenBox");

  final tokenAmountBox = await Hive.openBox("tokenAmountBox");
  final activityBox = await Hive.openBox("activityBox");

  // TESTING PURPOSES
  // await myBox.clear();
   tokenBox.clear();

  // ---------- Load Networks to DB ----------

  // Check if myBox is empty
  if (myBox.isEmpty) {
    // Load Networks to DB
    await initDB();
  }

  // TESTING PURPOSES : Set defaultNetwork
  myBox.put("defaultNetwork", "ropsten");

  // ---------- Initial route ----------
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
            textTheme: GoogleFonts.poppinsTextTheme(
              ThemeData.dark().textTheme,
            ),
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
