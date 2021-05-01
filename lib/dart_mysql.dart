import 'package:mysql1/mysql1.dart';

Future<MySqlConnection> getConnection() async {
  var settings = ConnectionSettings(
      host: 'localhost',
      port: 3306,
      user: 'root',
      password: 'root',
      db: 'dart_mysql');
  return await MySqlConnection.connect(settings);
}

Future<void> cadastrarAluno() async {
  var conn = await getConnection();
  // Cadastrar aluno na tabela alunos
  var cadastroAluno = await conn
      .query('insert aluno(cd_aluno, nome) values(null, ?)', ['Robson Dias']);

  var alunoId = cadastroAluno.insertId;
  var turmaId = await getTurma('Turma 02');
  // Cadastrar o aluno na tabela turma_aluno
  var cadastroTurmaAluno = await conn.query(
      'insert turma_aluno(turma_id, aluno_id) values(?, ?)',
      [turmaId, alunoId]);

  print(' ID do aluno cadastrado: $alunoId');
  print(
      'Cadastro do Aluno na turma feito com sucesso: ${cadastroTurmaAluno.affectedRows}');

  await conn.close();
}

Future<int> getTurma(nomeTurma) async {
  var conn = await getConnection();
  var resultado =
      await conn.query('select id from turma where nome = ?', [nomeTurma]);
  return resultado.first[0];
}

Future<void> cadastrarTurma() async {
  var conn = await getConnection();

  var result =
      await conn.query('insert turma(id, nome) values(null, ?)', ['Turma 01']);
  print(' ID do aluno cadastrado: ${result.insertId}');
  await conn.close();
}

Future<String> atualizarAluno(int id, String nome) async {
  var conn = await getConnection();
  var resultado = await conn
      .query('update aluno set nome = ?  where cd_aluno = ?', [nome, id]);
  if (resultado.affectedRows > 0) {
    await conn.close();
    return 'Aluno Alterado com Sucesso';
  } else {
    await conn.close();
    return 'Alteração Não realizada';
  }
}

Future<void> run() async {
  print('Cadastrando o Usuário');
  await cadastrarAluno();
  // await cadastrarTurma(); - Cadastrei somente uma vez

  var mensagem = await atualizarAluno(2, 'Qualquer coisa');
  print(mensagem);

  // Uma Query Interessante
  var conn = await getConnection();
  var listagem = await conn.query('''
    select t.nome, a.cd_aluno, a.nome from turma t
    inner join turma_aluno ta on ta.turma_id = t.id
    inner join aluno a on ta.aluno_id = a.cd_aluno''');

  listagem.forEach((r) {
    print('Aluno: ${r[2]} está na Turma ${r[0]}');
  });
  await conn.close();
}
