import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:symmetry_showcase/config/theme/app_themes.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/bloc/article/upload/upload_article_bloc.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/pages/home/daily_news.dart';
import 'package:symmetry_showcase/firebase_options.dart';
import 'package:symmetry_showcase/injection_container.dart' as di;
import 'package:symmetry_showcase/injection_container.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Configurar el status bar transparente para Android
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Habilitar edge-to-edge para que el contenido se extienda detrás del status bar
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RemoteArticlesBloc>(
          create: (context) => sl<RemoteArticlesBloc>()..add(const GetArticles()),
        ),
        BlocProvider<UploadArticleBloc>(
          create: (context) => sl<UploadArticleBloc>(),
        ),
      ],
      child: MaterialApp(
        theme: theme(),
        home: const DailyNews(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
