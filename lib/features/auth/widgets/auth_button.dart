import 'package:flutter/material.dart';

class BotonAutenticacion extends StatelessWidget {
  const BotonAutenticacion({
    super.key,
    required this.etiqueta,
    required this.onPressed,
    this.cargando = false,
  });

  final String etiqueta;
  final VoidCallback onPressed;
  final bool cargando;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: cargando ? null : onPressed,
        child: cargando
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(etiqueta),
      ),
    );
  }
}
