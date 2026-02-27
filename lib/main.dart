import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pawpark_frontend/screens/add_mascota_screen.dart';
import 'package:pawpark_frontend/screens/perfil_screen.dart';
import 'package:pawpark_frontend/theme/theme.dart';
import 'package:pawpark_frontend/utils/util.dart';
import 'auth/auth_wrapper.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart' hide LoginScreen;
import 'firebase_options.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<String>(create: (_) => "PawPark initial state")
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    TextTheme textTheme = createTextTheme(context, "Roboto", "Didact Gothic");
    MaterialTheme myTheme = MaterialTheme(textTheme);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PawPark App',
      theme: myTheme.light(),
      darkTheme: myTheme.dark(),
      themeMode: ThemeMode.system,
      home: AuthWrapper(),
      routes: {
        "/login": (context) => LoginScreen(),
        "/register": (context) => RegisterScreen(),
        "/perfil": (context) => PerfilScreen(),
        "/add-mascota": (context) => AddMascotaScreen()
      },
    );
  }
}
