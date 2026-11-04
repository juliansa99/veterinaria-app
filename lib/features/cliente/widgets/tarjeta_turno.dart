import 'package:flutter/material.dart';
import 'package:veterinaria_app/app/theme/app_theme.dart';
import 'package:veterinaria_app/features/cliente/models/turno.dart';

class TarjetaTurno extends StatelessWidget {
  const TarjetaTurno({super.key, required this.turno, this.onCancelar});

  final Turno turno;

  /// Si se indica, la tarjeta muestra el botón "Cancelar".
  final VoidCallback? onCancelar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: ColoresAplicacion.superficie,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColoresAplicacion.borde),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: ColoresAplicacion.secundarioSuave,
              child: Icon(Icons.pets, color: ColoresAplicacion.principal),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    turno.mascota,
                    style: tema.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: ColoresAplicacion.textoPrincipal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(turno.veterinario, style: tema.bodyMedium),
                  Text(turno.fechaHora, style: tema.bodyMedium),
                  if (turno.estaCancelado)
                    Text(
                      'Cancelado',
                      style: tema.bodyMedium?.copyWith(
                        color: ColoresAplicacion.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
            if (onCancelar != null)
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: ColoresAplicacion.error,
                ),
                onPressed: onCancelar,
                child: const Text('Cancelar'),
              ),
          ],
        ),
      ),
    );
  }
}
