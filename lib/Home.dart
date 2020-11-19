import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:convert';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _listaTarefas = [];
  Map<String, dynamic> _ultimaTarefaRemovida = Map();
  TextEditingController _controllerTarefa = TextEditingController();

  Future<File> _getFile() async {
    final diretorio = await getApplicationDocumentsDirectory();
    return File("${diretorio.path}/dados.json");
  }

  _salvarTarefa(){
    String textoDigitado = _controllerTarefa.text;

    Map<String, dynamic> tarefa = Map();
    tarefa["titulo"] = textoDigitado;
    tarefa["realizada"] = false;

    setState(() {
      _listaTarefas.add(tarefa);
    });
    _salvarArquivo();
    _controllerTarefa.text = "";
  }

  _salvarArquivo() async {
    final arquivo = await _getFile();

    String dados = json.encode(_listaTarefas);
    arquivo.writeAsString(dados);
  }

  _lerArquivo() async {
    try {
      final arquivo = await _getFile();
      return arquivo.readAsString();
    } catch (e) {
      print("caminho items: merda");
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _lerArquivo().then( (dados) {
      setState(() {
        _listaTarefas = json.decode(dados);
      });
    } );
  }

  Widget criarItemLista(context, index){
    final item = _listaTarefas[index]["titulo"];

    return Dismissible(
        key: Key(DateTime.now().millisecondsSinceEpoch.toString() /* para gerar numero diferente*/),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          //Recuperar ultimo item excluido
          _ultimaTarefaRemovida = _listaTarefas[index];

          //Remove item da lista
          _listaTarefas.removeAt(index);
          _salvarArquivo();

          //snackbar
          final snackbar = SnackBar(
            //backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
              content: Text("Tarefa removida!"),
            action: SnackBarAction(
                label: "Desfazer",
                onPressed: (){
                  //Inserir novamente item removido na lista
                  setState(() {
                    _listaTarefas.insert(index, _ultimaTarefaRemovida);
                  });
                  _salvarArquivo();
                }
            ),
          );
          Scaffold.of(context).showSnackBar(snackbar);
        },
        background: Container(
          color: Colors.red,
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.delete,
                color: Colors.white,
              )
            ],
          ),
        ),
        child: CheckboxListTile(
            title: Text(_listaTarefas[index]["titulo"]),
            value: _listaTarefas[index]["realizada"],
            onChanged: (valorAlterado) {
              setState(() {
                _listaTarefas[index]["realizada"] = valorAlterado;
              });
              _salvarArquivo();
            }
        )
    );
  }


  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Lista de Tarefas"),
        backgroundColor: Colors.purple,
      ),


      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: Colors.purple,
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Adicionar Tarefa"),
                    content: TextField(
                      controller: _controllerTarefa,
                      decoration: InputDecoration(
                          labelText: "Digite a sua Tarefa"
                      ),
                      onChanged: (text) {},
                    ),
                    actions: [
                      FlatButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Cancelar")),
                      FlatButton(
                          onPressed: () {
                            _salvarTarefa();
                            Navigator.pop(context);
                          },
                          child: Text("Salvar"))
                    ],
                  );
                });
          }),



      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
                  itemCount: _listaTarefas.length,
                  itemBuilder: criarItemLista,
              )
          )
        ],
      )

    );
  }
}
