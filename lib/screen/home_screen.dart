// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:survey_app/data/colors.dart';
import 'package:survey_app/data/survey_questions.dart';
import 'package:survey_app/screen/login_screen.dart';
import 'package:survey_app/screen/survey_screen.dart';
import 'package:survey_app/screen/user_survey_results.dart';
import 'package:survey_app/util/services/shared_preferences_service.dart';
import 'package:survey_app/util/utils.dart';
import 'package:survey_app/widget/survey_menu_item.dart';
import 'package:survey_app/util/locator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var myService = getIt<Utils>();
  var sharedPreferencesService = getIt<SharedPreferencesService>();
  bool isLoading = true;
  List<String> userEmails = [];
  String fileExtension = "";
  var isSignatureUploaded = false;
  var isPhotoUploaded = false;
  var map = <String, dynamic>{};
  var uncompletedSurveyCount = 3;
  final picker = ImagePicker();
  String imageUrl = "";
  bool isAdmin = false;
  bool isImageNull = true;
  File? image;

  @override
  void initState() {
    super.initState();
    dbInit();
    getProfilePictureUrl();
    initDoneSurveys();
    checkIsAdmin();
    updateUserEmails();
  }

  void updateUserEmails() async {
    userEmails = await fetchUserEmails();
    setState(() {});
  }

  Future<void> checkIsAdmin() async {
    myService.auth = FirebaseAuth.instance.currentUser;
    if (myService.auth != null) {
      final docRef = myService.database.collection("admins").doc("admins");
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        List<dynamic> adminList = docSnapshot.data()?['adminList'] ?? [];
        if (adminList.contains(myService.auth!.email)) {
          log("User is an admin.");
          isAdmin = true;
        } else {
          log("User is not an admin.");
          isAdmin = false;
        }
      } else {
        log("Admins document does not exist.");
      }
    } else {
      log("No user logged in.");
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<String> uploadImageToFirebase(File imageFile) async {
    try {
      final fileExtension = imageFile.path.split('.').last;
      Reference storageReference = FirebaseStorage.instance.ref().child(
          "${myService.auth!.email}/profile_photos/profile_picture.$fileExtension");

      UploadTask uploadTask = storageReference.putFile(imageFile);

      uploadTask.whenComplete(() async {
        String newImageUrl = await storageReference.getDownloadURL();
        log("Image uploaded to Firebase: $newImageUrl");

        // Save the file extension in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_picture_extension', fileExtension);
        await sharedPreferencesService.setString('profile_picture_extension', fileExtension);
        return newImageUrl;
      });
      return "nok";
    } catch (e) {
      log("Error uploading image to Firebase: $e");
      return "error";
    }
  }

  Future<List<String>> fetchUserEmails() async {
    QuerySnapshot querySnapshot =
        await myService.database.collection("users").get();
    List<String> userEmails = [];

    for (var doc in querySnapshot.docs) {
      String email = doc['email'];
      userEmails.add(email);
    }

    return userEmails;
  }

  void initDoneSurveys() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    survey0Done = prefs.getBool("survey0done") ?? false;
    survey1Done = prefs.getBool("survey1done") ?? false;
    survey2Done = prefs.getBool("survey2done") ?? false;
    uncompletedSurveyCounter();
  }

  Future<void> dbInit() async {
    final docRef =
        myService.database.collection("users").doc(myService.auth!.email);
    try {
      DocumentSnapshot doc = await docRef.get();
      final data = doc.data() as Map<String, dynamic>;
      setState(() {
        map = data;
      });
    } catch (e) {
      debugPrint("Error getting document: $e");
    }
  }

  Future getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        image = File(pickedFile.path);
        uploadImageToFirebase(image!);
      }
    });
  }

  Future getImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        image = File(pickedFile.path);
        uploadImageToFirebase(image!);
      }
    });
  }

  Future showOptions() async {
    showCupertinoModalPopup(
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: const Text('Photo Gallery'),
            onPressed: () {
              // close the options modal
              Navigator.of(context).pop();
              // get image from gallery
              getImageFromGallery();
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Camera'),
            onPressed: () {
              // close the options modal
              Navigator.of(context).pop();
              // get image from camera
              getImageFromCamera();
            },
          ),
        ],
      ),
      context: context,
    );
  }

  Future<void> updateProfilePictureUrlInFirestore(
      String profile_picture_url) async {
    try {
      String userEmail = myService.auth?.email ?? "unknown user email";
      await myService.database.collection("users").doc(userEmail).update({
        "profile_picture_url": profile_picture_url,
      });
      debugPrint("Profile Picture URL added to Firestore successfully");
    } catch (e) {
      debugPrint("Error updating Firestore: $e");
    }
  }

  Future<void> getProfilePictureUrl() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String fileExtension =
          prefs.getString('profile_picture_extension') ?? 'jpg';

      Reference storageReference = FirebaseStorage.instance.ref().child(
          "${myService.auth!.email}/profile_photos/profile_picture.$fileExtension");

      String url = await storageReference.getDownloadURL();
      setState(
        () {
          imageUrl = url;
          isImageNull = false;
        },
      );
    } catch (e) {
      log("Error getting image URL: $e");

      setState(
        () {
          imageUrl = "path/to/default/image.jpg";
          isImageNull = false;
        },
      );
    }
  }

  void goSurvey(int surveyIndex, bool isDone) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SurveyScreen(surveyIndex: surveyIndex, isDone: isDone),
      ),
    );
  }



  void uncompletedSurveyCounter() {
    uncompletedSurveyCount = 0;
    if (!survey0Done) {
      uncompletedSurveyCount++;
    }
    if (!survey1Done) {
      uncompletedSurveyCount++;
    }
    if (!survey2Done) {
      uncompletedSurveyCount++;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: colorDeepBlue,
        actions: [
          IconButton(
            onPressed: () {
              setState(
                () {
                  FirebaseAuth.instance.signOut();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  ).then(
                    (value) => Navigator.pop(context),
                  );
                },
              );
            },
            icon: const Icon(Icons.logout),
          )
        ],
        title: const Text("Survey App"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isAdmin
              ? isAdminPage()
              : isNotAdminPage(),
    );
  }

  Center isNotAdminPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              showOptions();
            },
            child: InkWell(
              child: ClipOval(
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: isImageNull
                      ? Image.asset(
                          "assets/images/profile_picture.png",
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
          ),
          Text(
            "Welcome ${map['name']}",
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 16,
          ),
          Text("There are $uncompletedSurveyCount survey waiting you"),
          const SizedBox(
            height: 16,
          ),
          SurveyMenuItem(
              surveyName: "Satisfaction Test",
              onPressed: () {
                goSurvey(0, survey0Done);
              },
              isDone: survey0Done),
          SurveyMenuItem(
              surveyName: "360 Performance Test",
              onPressed: () {
                goSurvey(1, survey1Done);
              },
              isDone: survey1Done),
          SurveyMenuItem(
              surveyName: "Worker Test",
              onPressed: () {
                goSurvey(2, survey2Done);
              },
              isDone: survey2Done),
        ],
      ),
    );
  }

  Center isAdminPage() {
    return Center(
      child: userEmails.isEmpty
          ? const CircularProgressIndicator()
          : ListView.builder(
              itemCount: userEmails.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UserSurveyResults(email: userEmails[index]),
                        ),
                      );
                    },
                    child: Text(
                      userEmails[index],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
