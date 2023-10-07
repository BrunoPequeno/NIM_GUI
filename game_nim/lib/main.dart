import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.blue, 
        scaffoldBackgroundColor: Colors.white, 
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Jogo NIM'),
        ),
        body: NIM(),
      ),
    );
  }
}

class NIM extends StatefulWidget {
  @override
  _NIMState createState() => _NIMState();
}

class _NIMState extends State<NIM> {
  int numeroMaximoDePecas = 0;
  int numeroMaximoDePecasRetiradas = 0;
  int pecasRestantes = 0;
  int pecasRetiradas = 0;
  int pecasComputadorRetiradas = 0;

  String errorTextNumeroMaximo = '';
  String errorTextNumeroRetiradas = '';

  bool isGameStarted = false;
  bool jogadorComeca = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, 
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Defina as regras da partida:',
                textAlign: TextAlign.center,
              ),
              TextField(
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  setState(() {
                    numeroMaximoDePecas = int.tryParse(value) ?? 0;
                    if (numeroMaximoDePecas < 2) {
                      errorTextNumeroMaximo = 'Número mínimo de peças é 2';
                    } else {
                      errorTextNumeroMaximo = '';
                    }
                    pecasRestantes = numeroMaximoDePecas;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Número total de peças',
                  errorText: (isGameStarted || errorTextNumeroMaximo.isNotEmpty)
                      ? errorTextNumeroMaximo
                      : null,
                ),
              ),
              TextField(
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  setState(() {
                    numeroMaximoDePecasRetiradas = int.tryParse(value) ?? 0;
                    if (numeroMaximoDePecasRetiradas < 1) {
                      errorTextNumeroRetiradas =
                          'Número mínimo de peças a retirar é 1';
                    } else if (numeroMaximoDePecasRetiradas > pecasRestantes) {
                      errorTextNumeroRetiradas =
                          'Número inválido de peças a retirar';
                    } else {
                      errorTextNumeroRetiradas = '';
                    }
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Número limite de peças a retirar por jogada',
                  errorText: (isGameStarted || errorTextNumeroRetiradas.isNotEmpty)
                      ? errorTextNumeroRetiradas
                      : null,
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (errorTextNumeroMaximo.isEmpty &&
                      errorTextNumeroRetiradas.isEmpty &&
                      numeroMaximoDePecas > 0 &&
                      numeroMaximoDePecasRetiradas > 0) {
                    isGameStarted = true;
                    jogadorComeca = (numeroMaximoDePecas %
                            (numeroMaximoDePecasRetiradas + 1)) ==
                        0;
                    _showInformacoesDialog(context);
                  }
                },
                child: Text('Iniciar jogo'),
              ),
            ],
          ),
          Container(
            color: Colors.blue, 
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, 
              children: <Widget>[
                Text(
                  'Bruno Pequeno',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color.fromRGBO(255, 255, 255, 0.4),
                  ),
                ),
                SizedBox(width: 16.0), 
                Text(
                  '1431432312033',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color.fromRGBO(255, 255, 255, 0.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showInformacoesDialog(BuildContext context) {
    if (!jogadorComeca) {
      _computadorMove();
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Partida'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('Número restante de peças: $pecasRestantes'),
                  if (!jogadorComeca)
                    Text('O computador começou'),
                  SizedBox(height: 14.0),
                  Text('Quantas peças deseja retirar?'),
                  Text(''),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: List.generate(
                      pecasRestantes > numeroMaximoDePecasRetiradas
                          ? numeroMaximoDePecasRetiradas
                          : pecasRestantes,
                      (index) {
                        int pecasARetirar = index + 1;
                        return ElevatedButton(
                          onPressed: () {
                            setState(() {
                              pecasRetiradas = pecasARetirar;
                              pecasRestantes -= pecasARetirar;

                              if (pecasRestantes <= 0) {
                                _showDerrotaDialog(context);
                                return;
                              }

                              _computadorMove();

                              if (pecasRestantes <= 0) {
                                _showVitoriaDialog(context, false);
                              }
                            });

                            _showQuantidadePecasRetiradasDialog(context);
                          },
                          child: Text('$pecasARetirar'),
                        );
                      },
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Sair'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _computadorMove() {
    int diferenca = pecasRestantes % (numeroMaximoDePecasRetiradas + 1);
    int pecasARetirar = 0;
    if (diferenca == 0 || diferenca == 1) {
      pecasARetirar = max(1, numeroMaximoDePecasRetiradas);
    } else {
      pecasARetirar = diferenca - 1;
    }
    pecasRestantes -= pecasARetirar;
    pecasComputadorRetiradas = pecasARetirar;
  }

  void _showDerrotaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Você Perdeu!'),
          content: Text('Você retirou a última peça.'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => RestartGame()),
                );
              },
              child: Text('Jogar novamente'),
            ),
          ],
        );
      },
    );
  }

  void _showQuantidadePecasRetiradasDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Sua jogada'),
          content: Text('Você retirou $pecasRetiradas peça(s).'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (pecasRestantes > 0) {
                  _showMensagemDoComputador(context);
                }
              },
              child: Text('Continuar'),
            ),
          ],
        );
      },
    );
  }

  void _showMensagemDoComputador(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Vez do PC'),
          content:
              Text('Ele retirou $pecasComputadorRetiradas peça(s).'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (pecasRestantes <= 0) {
                  _showVitoriaDialog(context, true);
                }
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showVitoriaDialog(BuildContext context, bool computadorVenceu) {
    String titulo =
        computadorVenceu ? 'Você Perdeu!' : 'Parabéns! Você venceu!';
    String conteudo = computadorVenceu
        ? 'O computador retirou a última peça.'
        : 'Parabéns, você ganhou! 😁';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(titulo),
          content: Text(conteudo),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => RestartGame()),
                );
              },
              child: Text('Jogar novamente'),
            ),
          ],
        );
      },
    );
  }
}

class RestartGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Jogo NIM'),
        ),
        body: NIM(),
      ),
    );
  }
}