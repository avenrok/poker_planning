import 'package:flutter/material.dart';
import 'package:poker_planning/data/menu_model.dart';
import 'package:poker_planning/view/login.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => MenuModel(),
      child: const LoginView()
      )
    );
}

// void main() {
//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (context) => CartModel()),
//         Provider(create: (context) => SomeOtherClass()),
//       ],
//       child: const MyApp(),
//     ),
//   );
// }
