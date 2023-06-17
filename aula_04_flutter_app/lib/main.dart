import 'package:aula_04_flutter_app/meu_aplicativo.dart';
import 'package:aula_04_flutter_app/repositories/favoritas_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => FavoritasRepository(),
      child: const MyApp(),
    ),
  );
}
