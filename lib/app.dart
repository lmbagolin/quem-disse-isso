import 'package:flutter/material.dart';

import 'core/tema.dart';
import 'ui/estado_app.dart';
import 'ui/telas/home_tela.dart';
import 'ui/widgets/tubo.dart';

class QuemDisseIssoApp extends StatefulWidget {
  const QuemDisseIssoApp({super.key, this.estado});

  final EstadoApp? estado;

  @override
  State<QuemDisseIssoApp> createState() => _QuemDisseIssoAppState();
}

class _QuemDisseIssoAppState extends State<QuemDisseIssoApp> {
  late final EstadoApp _estado = widget.estado ?? EstadoApp();

  @override
  void initState() {
    super.initState();
    _estado.iniciar();
  }

  @override
  void dispose() {
    _estado.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EscopoApp(
      estado: _estado,
      child: MaterialApp(
        title: 'Quem Disse Isso?',
        debugShowCheckedModeBanner: false,
        theme: construirTema(),
        // A textura cobre o app inteiro, por cima de qualquer tela.
        builder: (context, tela) => Tubo(child: tela ?? const SizedBox()),
        home: const HomeTela(),
      ),
    );
  }
}
