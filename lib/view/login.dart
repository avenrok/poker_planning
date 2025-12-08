import 'package:flutter/material.dart';
import 'package:poker_planning/l10n/app_localizations.dart';
import 'package:poker_planning/theme/styles.dart';
import 'package:poker_planning/view/menu.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AppLocalizations.of(context)!.loginTitle,
              style: AppTextStyles.headline,),
            SizedBox(height: 10,),
            TextFormField(
              decoration: InputDecoration(),
            ),
            SizedBox(height: 10,),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MenuView()));
              }, 
              child: Text(AppLocalizations.of(context)!.loginButton)
              ),
             SizedBox(height: 10,),
              ],
            ),
      ),
    );
  }
}