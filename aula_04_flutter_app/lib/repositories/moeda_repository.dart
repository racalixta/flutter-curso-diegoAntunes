import 'dart:async';
import 'dart:convert';

import 'package:aula_04_flutter_app/database/db.dart';
import 'package:aula_04_flutter_app/models/moeda.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;

class MoedaRepository extends ChangeNotifier {
  List<Moeda> _tabela = [];
  List<Moeda> get tabela => _tabela;
  late Timer intervalo;

  MoedaRepository() {
    _initRepository();
  }

  _initRepository() async {
    await _setupMoedasTable();
    await _setupDadosTableMoeda();
    await _readMoedasTable();
    _refreshPrecos();
  }

  _refreshPrecos() async {
    intervalo =
        Timer.periodic(const Duration(minutes: 5), (_) => checkPrecos());
  }

  checkPrecos() async {
    String uri = 'https://api.coinbase.com/v2/assets/search?base=BRL';
    final response = await http.get(Uri.parse(uri));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> moedas = json['data'];
      Database db = await DB.instance.database;
      Batch batch = db.batch();

      for (var atual in _tabela) {
        for (var novo in moedas) {
          if (atual.baseId == novo['base_id']) {
            final moeda = novo['prices'];
            final preco = moeda['latest_price'];
            final timestamp = DateTime.parse(preco['timestamp']);

            batch.update(
              'moedas',
              {
                'preco': moeda['latest'],
                'timestamp': timestamp.millisecondsSinceEpoch,
                'mudancaHora': preco['percent_change']['hour'].toString(),
                'mudancaDia': preco['percent_change']['day'].toString(),
                'mudancaSemana': preco['percent_change']['week'].toString(),
                'mudancaMes': preco['percent_change']['month'].toString(),
                'mudancaAno': preco['percent_change']['year'].toString(),
                'mudancaPeriodoTotal':
                    preco['percent_change']['all'].toString(),
              },
              where: 'baseId = ?',
              whereArgs: [atual.baseId],
            );
          }
        }
      }

      await batch.commit(noResult: true);
      await _readMoedasTable();
    }
  }

  _readMoedasTable() async {
    Database db = await DB.instance.database;
    List resultados = await db.query('moedas');
    _tabela = resultados.map((row) {
      return Moeda(
        baseId: row['baseId'],
        sigla: row['sigla'],
        nome: row['nome'],
        icone: row['icone'],
        preco: double.parse(row['preco']),
        timestamp: DateTime.fromMillisecondsSinceEpoch(row['timestamp']),
        mudancaHora: double.parse(row['mudancaHora']),
        mudancaDia: double.parse(row['mudancaDia']),
        mudancaSemana: double.parse(row['mudancaSemana']),
        mudancaMes: double.parse(row['mudancaMes']),
        mudancaAno: double.parse(row['mudancaAno']),
        mudancaPeriodoTotal: double.parse(row['mudancaPeriodoTotal']),
      );
    }).toList();

    notifyListeners();
  }

  moedasTableIsEmpty() async {
    Database db = await DB.instance.database;
    List resultados = await db.query('moedas');
    return resultados.isEmpty;
  }

  _setupDadosTableMoeda() async {
    final verify = await moedasTableIsEmpty();
    if (verify) {
      String uri = 'https://api.coinbase.com/v2/assets/search?base=BRL';

      final response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> moedas = json['data'];

        Database db = await DB.instance.database;
        Batch batch = db.batch();

        for (var moeda in moedas) {
          final preco = moeda['latest_price'];
          final timestamp = DateTime.parse(preco['timestamp']);

          batch.insert('moedas', {
            'baseId': moeda['id'],
            'sigla': moeda['symbol'],
            'nome': moeda['name'],
            'icone': moeda['image_url'],
            'preco': moeda['latest'],
            'timestamp': timestamp.millisecondsSinceEpoch,
            'mudancaHora': preco['percent_change']['hour'].toString(),
            'mudancaDia': preco['percent_change']['day'].toString(),
            'mudancaSemana': preco['percent_change']['week'].toString(),
            'mudancaMes': preco['percent_change']['month'].toString(),
            'mudancaAno': preco['percent_change']['year'].toString(),
            'mudancaPeriodoTotal': preco['percent_change']['all'].toString(),
          });
        }

        await batch.commit(noResult: true);
      }
    }
  }

  _setupMoedasTable() async {
    String table = '''
      CREATE TABLE IF NOT EXISTS moedas (
        baseId TEXT PRIMARY KEY,
        sigla TEXT,
        nome TEXT,
        icone TEXT,
        preco TEXT,
        timestamp INTEGER,
        mudancaHora TEXT,
        mudancaDia TEXT,
        mudancaSemana TEXT,
        mudancaMes TEXT,
        mudancaAno TEXT,
        mudancaPeriodoTotal TEXT
      );
    ''';

    print('setup 1 <--------------------');
    Database db = await DB.instance.database;
    print('setup 2 <--------------------');
    await db.execute(table);
    print('setup 3 <--------------------');
  }
}
