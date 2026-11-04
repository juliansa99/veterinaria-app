import 'package:flutter/material.dart';
import 'package:veterinaria_app/app/fechas.dart';
import 'package:veterinaria_app/app/theme/app_theme.dart';
import 'package:veterinaria_app/features/cliente/models/registro_clinico.dart';

class TarjetaRegistroClinico extends StatelessWidget {
  const TarjetaRegistroClinico({super.key, required this.registro});

  final RegistroClinico registro;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    final secciones = {
      'Estado': registro.estadoGeneral,
      'Diagnóstico': registro.diagnostico,
      'Tratamientos': registro.tratamientos,
      'Estudios': registro.estudios,
      'Medicamentos': registro.medicamentos,
      'Observaciones': registro.observaciones,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColoresAplicacion.superficie,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColoresAplicacion.borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${registro.mascotaNombre} · ${fechaCorta(registro.fechaTurno)} '
            '${horaTexto(registro.fechaTurno)}',
            style: tema.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: ColoresAplicacion.textoPrincipal,
            ),
          ),
          if (registro.veterinarioNombre.isNotEmpty)
            Text(registro.veterinarioNombre, style: tema.bodyMedium),
          for (final seccion in secciones.entries)
            if (seccion.value.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                seccion.key,
                style: tema.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: ColoresAplicacion.principal,
                ),
              ),
              Text(seccion.value, style: tema.bodyMedium),
            ],
        ],
      ),
    );
  }
}