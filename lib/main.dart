import 'package:flutter/material.dart';
import 'package:poker_planning/view/authorization.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => null,
      child: const MainApp()
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


class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LoginView()
    );
  }
}
