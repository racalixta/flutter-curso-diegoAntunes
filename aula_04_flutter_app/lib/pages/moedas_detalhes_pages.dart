import 'package:aula_04_flutter_app/models/moeda.dart';
import 'package:flutter/material.dart';

class MoedasDetalhesPage extends StatefulWidget {
  Moeda moeda;

  MoedasDetalhesPage({super.key, required this.moeda});

  @override
  State<MoedasDetalhesPage> createState() => _MoedasDetalhesPageState();
}

class _MoedasDetalhesPageState extends State<MoedasDetalhesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.moeda.nome),
      ),
      body: Column(
        children: [
          Row(
            children: [
              const Spacer(),
              SizedBox(
                width: 50,
                child: Image.asset(widget.moeda.icone),
              )
            ],
          )
        ],
      ),
    );
  }
}
