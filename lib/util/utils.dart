import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Utils {
  var auth = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore database = FirebaseFirestore.instance;

  void doSomething() {
    log("Doing something");
  }


}
