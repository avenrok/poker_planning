import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyles {
  static const TextStyle headline = TextStyle(
    fontFamily: 'FiraSans',
    fontSize: 20,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary
  );

  static const TextStyle bodyText = TextStyle(
    fontFamily: 'FiraSans',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary
  );

  static const TextStyle hintText = TextStyle(
    fontFamily: 'FiraSans',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint
  );

  static const TextStyle alertText = TextStyle(
    fontFamily: 'FiraSans',
    fontSize: 12,
    fontWeight: FontWeight.w200,
    fontStyle: FontStyle.normal,
    color: AppColors.textHint
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontFamily: 'FiraSans',
    fontSize: 24,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.normal,
    color: Colors.white,
  );

}