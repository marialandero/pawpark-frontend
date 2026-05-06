import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pawpark_frontend/providers/post_provider.dart';
import 'package:pawpark_frontend/providers/quedada_provider.dart';
import 'package:pawpark_frontend/providers/usuario_provider.dart';
import 'package:pawpark_frontend/screens/feed/crear_post_screen.dart';
import 'package:pawpark_frontend/screens/feed/feed_screen.dart';
import 'package:pawpark_frontend/screens/feed/search_screen.dart';
import 'package:pawpark_frontend/screens/mapas/mapa_prueba.dart';
import 'package:pawpark_frontend/screens/mapas/mapas_screen.dart';
import 'package:pawpark_frontend/screens/perfil/form_editar_perfil_screen.dart';
import 'package:pawpark_frontend/screens/perfil/form_crear_mascota_screen.dart';
import 'package:pawpark_frontend/screens/perfil/perfil_mascota_screen.dart';
import 'package:pawpark_frontend/screens/perfil/perfil_screen.dart';
import 'package:pawpark_frontend/screens/quedadas/detalle_quedada_screen.dart';
import 'package:pawpark_frontend/screens/quedadas/form_crear_quedada_screen.dart';
import 'package:pawpark_frontend/screens/quedadas/quedadas_screen.dart';
import 'package:pawpark_frontend/theme/theme.dart';
import 'package:pawpark_frontend/utils/util.dart';
import 'auth/auth_wrapper.dart';
import 'screens/login/login_screen.dart';
import 'screens/login/register_screen.dart' hide LoginScreen;
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    await Firebase.initializeApp();
  }
  await initializeDateFormatting('es', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UsuarioProvider()),
        ChangeNotifierProvider(create: (_) => QuedadaProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider())
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
      // home: MapaPrueba(),
      routes: {
        "/login": (context) => LoginScreen(),
        "/register": (context) => RegisterScreen(),
        "/perfil": (context) => PerfilScreen(),
        "/form-mascota": (context) => FormMascotaScreen(),
        "/editar-perfil": (context) => FormEditarPerfilScreen(),
        "/perfil-mascota": (context) => PerfilMascotaScreen(),
        "/map": (context) => MapasScreen(),
        "/feed": (context) => FeedScreen(),
        "/quedadas": (context) => QuedadasScreen(),
        "/form-quedada": (context) => FormQuedadaScreen(),
        "/detalle-quedada": (context) => DetalleQuedadaScreen(),
        "/crear-post": (context) => CrearPostScreen(),
        "/search": (context) => SearchScreen()
      },
    );
  }
}
