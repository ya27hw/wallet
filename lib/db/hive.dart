import 'package:hive/hive.dart';

class HiveDB {
  late Box _myBox;

  // Constructor

  // This is used to create a new box in the hive database
  Future<void> createBox(String boxName) async {
    _myBox = await Hive.openBox(boxName);
  }

  // Add data to the box
  void addData(String key, dynamic value) {
    _myBox.put(key, value);
  }

  // Get data from the box
  dynamic getData(String key) {
    return _myBox.get(key);
  }

  // Remove data from the box
  void removeData(String key) {
    _myBox.delete(key);
  }

  // Print all data in the box
  void printAll() {
    _myBox.toMap().forEach((key, value) {
      print("$key: $value");
    });
  }
}
