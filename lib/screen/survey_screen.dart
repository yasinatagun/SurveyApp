import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:survey_app/data/colors.dart';
import 'package:survey_app/data/survey_questions.dart';
import 'package:survey_app/screen/login_screen.dart';
import 'package:survey_app/screen/result_screen.dart';
import 'package:survey_app/util/locator.dart';
import 'package:survey_app/util/utils.dart';

class SurveyScreen extends StatefulWidget {
  const SurveyScreen(
      {super.key, required this.surveyIndex, required this.isDone});
  final int surveyIndex;
  final bool isDone;
  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  var survIndex = 0;
  var selectedOption = 0;
  var myService = getIt<Utils>();
  var selectedAnswers = <int>[];
  var surveyQuestionsCopied = [];
  var questionIndex = 0;
  final user = FirebaseAuth.instance.currentUser;
  final db = FirebaseFirestore.instance;
  var answersList = <int>[];
  Map<String, dynamic> surveyData = {};

  @override
  void initState() {
    super.initState();    
    if (widget.surveyIndex == 0) {
      surveyQuestionsCopied = List.from(survey0QuestionsList);
    } else if (widget.surveyIndex == 1) {
      surveyQuestionsCopied = List.from(survey1QuestionsList);
    } else {
      surveyQuestionsCopied = List.from(survey2QuestionsList);
    }
    fetchSurveyData().then((value) {
      if (surveyData['survey${widget.surveyIndex}'] != null) {
        answersList = List.from(surveyData['survey${widget.surveyIndex}']);
        log("ANSWER LIST : ${answersList.toString()}");
      }
    });
  }

  Future<void> fetchSurveyData() async {
    try {
      DocumentSnapshot docSnapshot =
          await db.collection("users").doc("${myService.auth!.email}").get();
          
      if (docSnapshot.exists) {
        log("Giriyormu set state");
        setState(() {
          surveyData = docSnapshot.data() as Map<String, dynamic>;
          log("surrrr ${surveyData.toString()}");
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

  void nextQuestion() {
    questionIndex++;
    selectedOption = 0;
  }

  Future<void> uploadAnswersToFirebase(List<dynamic> selectedAnswers) async {
    try {
      String userEmail = user?.email ??
          "unknown_user_email"; // Replace with current user email
      await db.collection("users").doc(userEmail).update({
        "survey${widget.surveyIndex}": selectedAnswers,
      });
      debugPrint("Success");
    } catch (e) {
      debugPrint("Error updating Firestore: $e");
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
                  ).then((value) => Navigator.pop(context));
                },
              );
            },
            icon: const Icon(Icons.logout),
          )
        ],
        title: const Text("Survey Started"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 20, 40, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Question ${questionIndex + 1}",
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.amber.shade900),
                ),
                Text(
                  surveyQuestionsCopied[questionIndex].questionText,
                  style: const TextStyle(
                    fontSize: 22,
                  ),
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 40,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      ListTile(
                        title: Text(
                          surveyQuestionsCopied[questionIndex].answers[0],
                          style: const TextStyle(fontSize: 18),
                        ),
                        leading: SizedBox(
                          width: 20,
                          height: 20,
                          child: Radio(
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            activeColor: Colors.amber,
                            value: (answersList.isNotEmpty
                                ? answersList[questionIndex]
                                : 0),
                            groupValue: selectedOption,
                            onChanged: (value) {
                              setState(() {
                                selectedOption = value!;
                              });
                            },
                          ),
                        ),
                      ),
                      ListTile(
                        title: Text(
                          surveyQuestionsCopied[questionIndex].answers[1],
                          style: const TextStyle(fontSize: 18),
                        ),
                        leading: SizedBox(
                          width: 20,
                          height: 20,
                          child: Radio(
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            value: 1 -
                                (answersList.isNotEmpty
                                    ? answersList[questionIndex]
                                    : 0),
                            activeColor: Colors.amber,
                            groupValue: selectedOption,
                            onChanged: (value) {
                              setState(() {
                                selectedOption = value!;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(
                        () {
                          if (questionIndex <
                              surveyQuestionsCopied.length - 1) {
                            selectedAnswers.add(selectedOption);
                            log(selectedAnswers.toString());
                            nextQuestion();
                          } else {
                            log(selectedAnswers.toString());
                                    selectedAnswers.add(selectedOption);

                            uploadAnswersToFirebase(selectedAnswers);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ResultScreen(
                                    surveyIndex: widget.surveyIndex,
                                  ),
                                )).then((value) => Navigator.pop(context));
                          }
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorDeepBlue,
                      padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                    ),
                    child: Text(
                      (questionIndex < surveyQuestionsCopied.length - 1)
                          ? 'Next Question'
                          : 'Finish Survey',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
