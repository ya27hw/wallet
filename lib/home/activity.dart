import 'package:eth_wallet/util/library.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class Activity extends StatefulWidget {
  const Activity({Key? key}) : super(key: key);

  @override
  _ActivityState createState() => _ActivityState();
}

class _ActivityState extends State<Activity> {
  late Box activityBox;

  @override
  void initState() {
    super.initState();
    activityBox = Hive.box("activityBox");
    // Iterate thru box
    for (var key in activityBox.keys) {
      TransactionData transactionData =
          activityBox.getAt(key) as TransactionData;
      print(transactionData.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryDarkColor(),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),

        backgroundColor: secondaryDarkColor(),
        centerTitle: true,
        title: const Text(
          'Activity',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView.builder(
        itemCount: activityBox.length,
        itemBuilder: (context, index) {
          TransactionData transactionData =
              activityBox.getAt(index) as TransactionData;
          return Helper().transactionCard(transactionData);
        },
      ),
    );
  }
}
