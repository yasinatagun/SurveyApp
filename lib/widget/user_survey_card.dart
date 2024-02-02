import 'package:flutter/material.dart';

class UserSurveyCard extends StatelessWidget {
  const UserSurveyCard(
      {super.key, required this.surveyData, required this.surveyIndex});
  final int surveyIndex;
  final Map<String, dynamic> surveyData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Card(
        elevation: 0,
        color: Colors.amber.shade900,
        child: SizedBox(
          width: double.infinity,
          height: 100,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Survey ${surveyIndex + 1}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  "Answers ${surveyIndex + 1}: ${surveyData['survey$surveyIndex'] ?? 'Not Done'}",
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
