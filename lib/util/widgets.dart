import 'package:flutter/material.dart';

class Helper {

  Widget Button(double width, String msg, [BuildContext? ctx, Route? route]) {
    return ElevatedButton(
      child: Text(msg),
      style: ElevatedButton.styleFrom(
        textStyle: const TextStyle(fontSize: 17),
        padding: EdgeInsets.symmetric(horizontal: width * 0.20, vertical: 15),
        onPrimary: Colors.black,
        primary: const Color(0xFF41CD7D),
        onSurface: Colors.grey,
        // side: BorderSide(color: Colors.black, width: 1),
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
      ),
      onPressed:() {

        if (ctx != null && route != null) {
          Navigator.push(ctx, route);
        } 

      },
    );
  }

}