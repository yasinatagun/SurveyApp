import 'package:flutter/material.dart';
import 'package:survey_app/data/colors.dart';

class SurveyMenuItem extends StatelessWidget {
  const SurveyMenuItem(
      {super.key, required this.surveyName, required this.onPressed, required this.isDone});
  final String surveyName;
  final void Function()? onPressed;
  final bool isDone;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Card(
          elevation: 0,
          color: isDone ? colorDeepBlue : Colors.amber.shade900,
          child: SizedBox(
            width: double.infinity,
            height: 100,
            child: Center(
              child: Text(
                surveyName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
