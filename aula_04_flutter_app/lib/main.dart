import 'package:aula_04_flutter_app/configs/app_settings.dart';
import 'package:aula_04_flutter_app/configs/hive_config.dart';
import 'package:aula_04_flutter_app/meu_aplicativo.dart';
import 'package:aula_04_flutter_app/repositories/favoritas_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveConfig.start();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppSettings()),
        ChangeNotifierProvider(create: (context) => FavoritasRepository()),
      ],
      child: const MyApp(),
    ),
  );
}
