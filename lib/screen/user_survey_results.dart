import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:survey_app/widget/user_survey_card.dart';

class UserSurveyResults extends StatefulWidget {
  const UserSurveyResults({super.key, required this.email});
  final String email;
  @override
  State<UserSurveyResults> createState() => _UserSurveyResultsState();
}

class _UserSurveyResultsState extends State<UserSurveyResults> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic> surveyData = {};

  @override
  void initState() {
    super.initState();
    fetchSurveyData();
  }

  Future<void> fetchSurveyData() async {
    try {
      DocumentSnapshot docSnapshot =
          await db.collection("users").doc(widget.email).get();
      if (docSnapshot.exists) {
        setState(() {
          surveyData = docSnapshot.data() as Map<String, dynamic>;
        });
      } else {
        // Handle the case where the document does not exist
        log("Document does not exist");
      }
    } catch (e) {
      // Handle any errors
      log("Error fetching survey data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Survey Results"),
      ),
      body: surveyData.isEmpty
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show loading indicator while data is being fetched
          : Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Hello admin, you are looking for\n${widget.email} users information", textAlign: TextAlign.center,),
                    const SizedBox(height: 20,),
                    UserSurveyCard(
                      surveyData: surveyData,
                      surveyIndex: 0,
                    ),
                    UserSurveyCard(
                      surveyData: surveyData,
                      surveyIndex: 1,
                    ),
                    UserSurveyCard(
                      surveyData: surveyData,
                      surveyIndex: 2,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
