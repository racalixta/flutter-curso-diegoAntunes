class Pessoa {
  // Propriedade privada
  late String _privado;

  get privado => this._privado;
  set privado(n) => this._privado = n;

  // Três formas:

  // 1 + A
  // String? nome;
  // String? sobrenome;

  // 2 + A
  // late String nome;
  // late String sobrenome;

  // A
  // Pessoa() {
  //   this.nome = "João";
  //   this.sobrenome = "Silva";
  // }

  // 3 + B
  String nome;
  String sobrenome;

  get nomeCompleto => "${this.nome} ${this.sobrenome}";

  // B
  Pessoa({required this.nome, required this.sobrenome});
}
