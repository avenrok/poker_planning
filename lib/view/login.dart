import 'package:flutter/material.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
          children: [
            Text("Вход"),
            SizedBox.shrink(),
            TextFormField(
              decoration: InputDecoration(),
            ),
            SizedBox.shrink(),
            ElevatedButton(onPressed: null, 
              child: null),
            SizedBox.shrink()
          ],
        );
  }
}