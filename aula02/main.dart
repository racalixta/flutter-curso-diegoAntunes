import 'pessoa.dart';

main() {
  Pessoa joao = Pessoa(
    nome: "João",
    sobrenome: "Santos",
  );

  print("O nome é ${joao.nome} e o sobrenome ${joao.sobrenome}");
  print("\n O nome completo é: ${joao.nomeCompleto}");
}
