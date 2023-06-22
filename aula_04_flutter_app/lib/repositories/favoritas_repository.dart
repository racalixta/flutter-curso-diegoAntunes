import 'dart:collection';
// import 'package:aula_04_flutter_app/adapters/moeda_hive_adapter.dart';
import 'package:aula_04_flutter_app/database/db_firestore.dart';
import 'package:aula_04_flutter_app/models/moeda.dart';
import 'package:aula_04_flutter_app/repositories/moeda_repository.dart';
import 'package:aula_04_flutter_app/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';

class FavoritasRepository extends ChangeNotifier {
  final List<Moeda> _lista = [];
  // Isso fazia parte do Hive (esta sendo usado Firebase Firestore no lugar)
  // late LazyBox box;

  late FirebaseFirestore db;
  late AuthService auth;

  FavoritasRepository({required this.auth}) {
    _startRepository();
  }

  _startRepository() async {
    // Isso fazia parte do Hive
    // await _openBox();
    await _startFirestore();
    await _readFavoritas();
  }

  _startFirestore() {
    db = DBFirestore.get();
  }

  // Isso fazia parte do Hive
  // _openBox() async {
  //   Hive.registerAdapter(MoedaHiveAdapter());
  //   box = await Hive.openLazyBox<Moeda>('moedasss_favoritas');
  // }
  // _readFavoritas() {
  //   box.keys.forEach((moeda) async {
  //     Moeda m = await box.get(moeda);
  //     _lista.add(m);
  //     notifyListeners();
  //   });
  // }

  _readFavoritas() async {
    if (auth.usuario != null && _lista.isEmpty) {
      final snapshot =
          await db.collection('usuarios/${auth.usuario!.uid}/favoritas').get();

      snapshot.docs.forEach((doc) {
        Moeda moeda = MoedaRepository.tabela
            .firstWhere((moeda) => moeda.sigla == doc.get('sigla'));

        _lista.add(moeda);
        notifyListeners();
      });
    }
  }

  UnmodifiableListView<Moeda> get lista => UnmodifiableListView(_lista);

  saveAll(List<Moeda> moedas) {
    moedas.forEach((moeda) async {
      if (!_lista.any((atual) => atual.sigla == moeda.sigla)) {
        _lista.add(moeda);
        await db
            .collection('usuarios/${auth.usuario!.uid}/favoritas')
            .doc(moeda.sigla)
            .set({
          'moeda': moeda.nome,
          'sigla': moeda.sigla,
          'preco': moeda.preco,
        });

        // Isso fazia parte do Hive
        // box.put(moeda.sigla, moeda);
      }
    });
    notifyListeners();
  }

  remove(Moeda moeda) async {
    await db
        .collection('usuarios/${auth.usuario!.uid}/favoritas')
        .doc(moeda.sigla)
        .delete();
    _lista.remove(moeda);

    // isso fazia parte do Hive
    // box.delete(moeda.sigla);
    notifyListeners();
  }
}
