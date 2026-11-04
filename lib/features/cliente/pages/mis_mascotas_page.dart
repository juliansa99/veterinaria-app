import 'package:flutter/material.dart';
import 'package:veterinaria_app/features/auth/servicio_autenticacion.dart';
import 'package:veterinaria_app/features/cliente/data/repositorio_mascotas.dart';
import 'package:veterinaria_app/features/cliente/models/mascota.dart';
import 'package:veterinaria_app/features/cliente/pages/alta_mascota_page.dart';
import 'package:veterinaria_app/features/cliente/widgets/tarjeta_mascota.dart';

class PaginaMisMascotas extends StatefulWidget {
  const PaginaMisMascotas({super.key});

  @override
  State<PaginaMisMascotas> createState() => _EstadoPaginaMisMascotas();
}

class _EstadoPaginaMisMascotas extends State<PaginaMisMascotas> {
  // Se crea una sola vez para no reabrir la consulta en cada rebuild.
  late final Stream<List<Mascota>> _mascotas =
      RepositorioMascotas.mascotasDelCliente();

  Future<void> _abrirAltaMascota() async {
    final guardada = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) => const PaginaAltaMascota(),
      ),
    );

    if (guardada == true && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Mascota guardada')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Mascotas'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirAltaMascota,
        tooltip: 'Agregar mascota',
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: StreamBuilder<List<Mascota>>(
              stream: _mascotas,
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
                final mascotas = estado.data!;
                if (mascotas.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Todavía no registraste mascotas.\n'
                      'Tocá + para agregar la primera.',
                      style: tema.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 88),
                  itemCount: mascotas.length,
                  separatorBuilder: (context, indice) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, indice) {
                    return TarjetaMascota(mascota: mascotas[indice]);
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
