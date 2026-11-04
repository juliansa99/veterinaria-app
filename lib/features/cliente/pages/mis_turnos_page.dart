import 'package:flutter/material.dart';
import 'package:veterinaria_app/app/theme/app_theme.dart';
import 'package:veterinaria_app/features/auth/servicio_autenticacion.dart';
import 'package:veterinaria_app/features/cliente/data/repositorio_turnos.dart';
import 'package:veterinaria_app/features/cliente/models/turno.dart';
import 'package:veterinaria_app/features/cliente/widgets/tarjeta_turno.dart';
import 'package:veterinaria_app/features/cliente/pages/historial_clinico_page.dart';

class PaginaMisTurnos extends StatefulWidget {
  const PaginaMisTurnos({super.key});

  @override
  State<PaginaMisTurnos> createState() => _EstadoPaginaMisTurnos();
}

class _EstadoPaginaMisTurnos extends State<PaginaMisTurnos> {
  late final Stream<List<Turno>> _turnos = RepositorioTurnos.misTurnos();

  Future<void> _cancelar(Turno turno) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (contextoDialogo) => AlertDialog(
        title: const Text('¿Cancelar turno?'),
        content: Text(
          'Se cancelará el turno de ${turno.mascota} con '
          '${turno.veterinario} (${turno.fechaHora}).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(contextoDialogo).pop(false),
            child: const Text('Volver'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: ColoresAplicacion.error,
            ),
            onPressed: () => Navigator.of(contextoDialogo).pop(true),
            child: const Text('Cancelar turno'),
          ),
        ],
      ),
    );
    if (confirmado != true || !mounted) return;

    try {
      await RepositorioTurnos.cancelar(turno);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Turno cancelado')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(ServicioAutenticacion.mensajeDeError(error))),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
               appBar: AppBar(
          title: const Text('Mis Turnos'),
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: 'Historial clínico',
              icon: const Icon(Icons.medical_information_outlined),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const PaginaHistorialClinico(),
                ),
              ),
            ),
          ],
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Próximos'),
              Tab(text: 'Historial'),
            ],
          ),
        ),
        body: SafeArea(
          child: StreamBuilder<List<Turno>>(
            stream: _turnos,
            builder: (context, estado) {
              if (estado.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      ServicioAutenticacion.mensajeDeError(estado.error!),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              if (!estado.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final todos = estado.data!;
              final proximos = todos.where((t) => t.esProximo).toList()
                ..sort((a, b) => a.fecha!.compareTo(b.fecha!));
              final historial = todos.where((t) => !t.esProximo).toList()
                ..sort((a, b) => (b.fecha ?? DateTime(0))
                    .compareTo(a.fecha ?? DateTime(0)));

              return TabBarView(
                children: [
                  _ListaTurnos(
                    turnos: proximos,
                    vacio: 'No tenés turnos próximos.',
                    alCancelar: _cancelar,
                  ),
                  _ListaTurnos(
                    turnos: historial,
                    vacio: 'Todavía no hay turnos en tu historial.',
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ListaTurnos extends StatelessWidget {
  const _ListaTurnos({
    required this.turnos,
    required this.vacio,
    this.alCancelar,
  });

  final List<Turno> turnos;
  final String vacio;
  final void Function(Turno turno)? alCancelar;

  @override
  Widget build(BuildContext context) {
    if (turnos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            vacio,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          itemCount: turnos.length,
          separatorBuilder: (context, indice) => const SizedBox(height: 12),
          itemBuilder: (context, indice) {
            final turno = turnos[indice];
            return TarjetaTurno(
              turno: turno,
              onCancelar: alCancelar == null ? null : () => alCancelar!(turno),
            );
          },
        ),
      ),
    );
  }
}
