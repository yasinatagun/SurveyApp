import 'dart:typed_data';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hand_signature/signature.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:survey_app/data/colors.dart';
import 'package:survey_app/data/survey_questions.dart';
import 'package:survey_app/screen/home_screen.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.surveyIndex});
  final int surveyIndex;
  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool isSignatureSaved = false;
  final HandSignatureControl handSignatureControl = HandSignatureControl(
    threshold: 3.0,
    smoothRatio: 0.65,
    velocityRange: 2.0,
  );
  void _clearSignature() {
    handSignatureControl.clear();
  }

  final user = FirebaseAuth.instance.currentUser;
  final db = FirebaseFirestore.instance;
  
  Future<void> uploadSignature() async {
    try {
      ByteData? byteData = await handSignatureControl.toImage();
      if (byteData == null) {
        debugPrint("No signature data available");
        return;
      }

      Uint8List imageData = byteData.buffer.asUint8List();

      String filePath =
          '${user?.email}/signatures//signatureSurvey${widget.surveyIndex}.png';

      Reference ref = FirebaseStorage.instance.ref().child(filePath);

      UploadTask uploadTask = ref.putData(imageData);

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      debugPrint('Download URL: $downloadUrl');

      await updateSignatureUrlInFirestore(downloadUrl);
    } catch (e) {
      debugPrint("Error uploading signature: $e");
    }
  }

  Future<void> updateSignatureUrlInFirestore(String signatureUrl) async {
    try {
      String userEmail = user?.email ??
          "unknown_user_email"; // Replace with current user email
      await db.collection("users").doc(userEmail).update({
        "signature_url": signatureUrl,
      });
      debugPrint("Signature URL added to Firestore successfully");
    } catch (e) {
      debugPrint("Error updating Firestore: $e");
    }
  }

  void saveDoneSurveys() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (isSignatureSaved) {
      switch (widget.surveyIndex) {
        case 0:
          survey0Done = true;
          prefs.setBool("survey0done", true);
          log("$survey0Done");
          break;
        case 1:
          survey1Done = true;
          prefs.setBool("survey1done", true);
          break;
        case 2:
          survey2Done = true;
          prefs.setBool("survey2done", true);
          break;
        default:
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorDeepBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Congratulations!",
              style: TextStyle(color: Colors.white, fontSize: 30),
            ),
            const Text(
              "You are adding value to our company.",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
              child: Container(
                width: double.infinity,
                height: 150,
                color: Colors.amber.shade900,
                child: HandSignature(
                    color: Colors.black,
                    width: 0.01,
                    control: handSignatureControl),
              ),
            ),
            const Text(
              "Please sign above to complete survey. \n Dont forget to save!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    _clearSignature();
                  },
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    uploadSignature().then((value) {
                      isSignatureSaved = true;
                    });
                  },
                  icon: const Icon(
                    Icons.save,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            ElevatedButton(
              onPressed: () async {
                if (isSignatureSaved) {
                  saveDoneSurveys();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomeScreen(),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade900,
                padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
              ),
              child: const Text(
                'Return Home',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
