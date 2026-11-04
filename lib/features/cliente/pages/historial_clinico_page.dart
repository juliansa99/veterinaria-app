import 'package:flutter/material.dart';
import 'package:veterinaria_app/features/auth/servicio_autenticacion.dart';
import 'package:veterinaria_app/features/cliente/data/repositorio_historial.dart';
import 'package:veterinaria_app/features/cliente/models/registro_clinico.dart';
import 'package:veterinaria_app/features/cliente/widgets/tarjeta_registro_clinico.dart';

class PaginaHistorialClinico extends StatelessWidget {
  const PaginaHistorialClinico({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial clínico'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: StreamBuilder<List<RegistroClinico>>(
              stream: RepositorioHistorial.misRegistros(),
              builder: (context, estado) {
                if (estado.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      ServicioAutenticacion.mensajeDeError(estado.error!),
                      style: tema.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                if (!estado.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final registros = estado.data!;
                if (registros.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Todavía no hay registros clínicos de tus mascotas.',
                      style: tema.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  itemCount: registros.length,
                  separatorBuilder: (context, indice) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, indice) =>
                      TarjetaRegistroClinico(registro: registros[indice]),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}