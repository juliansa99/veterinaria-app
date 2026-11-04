import 'package:flutter/material.dart';
import 'package:veterinaria_app/features/auth/pages/login_page.dart';
import 'package:veterinaria_app/features/auth/servicio_autenticacion.dart';
import 'package:veterinaria_app/features/cliente/data/repositorio_turnos.dart';
import 'package:veterinaria_app/features/cliente/models/turno.dart';
import 'package:veterinaria_app/features/cliente/pages/mis_mascotas_page.dart';
import 'package:veterinaria_app/features/cliente/pages/mis_turnos_page.dart';
import 'package:veterinaria_app/features/cliente/pages/reservar_turno_veterinario_page.dart';
import 'package:veterinaria_app/features/cliente/widgets/boton_acceso_rapido.dart';
import 'package:veterinaria_app/features/cliente/widgets/tarjeta_turno.dart';

class PaginaHomeCliente extends StatefulWidget {
  const PaginaHomeCliente({super.key});

  @override
  State<PaginaHomeCliente> createState() => _EstadoPaginaHomeCliente();
}

class _EstadoPaginaHomeCliente extends State<PaginaHomeCliente> {
  late final Stream<List<Turno>> _turnos = RepositorioTurnos.misTurnos();

  void _abrirPagina(BuildContext context, Widget pagina) {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (context) => pagina));
  }

  Future<void> _cerrarSesion(BuildContext context) async {
    await ServicioAutenticacion.cerrarSesion();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (context) => const PaginaLogin()),
      (ruta) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () => _cerrarSesion(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              children: [
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: BotonAccesoRapido(
                          etiqueta: 'Mis Mascotas',
                          icono: Icons.pets,
                          onPressed: () =>
                              _abrirPagina(context, const PaginaMisMascotas()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: BotonAccesoRapido(
                          etiqueta: 'Reservar Turno',
                          icono: Icons.event_available_outlined,
                          onPressed: () => _abrirPagina(
                            context,
                            const PaginaReservarTurnoVeterinario(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: BotonAccesoRapido(
                          etiqueta: 'Mis Turnos',
                          icono: Icons.calendar_month_outlined,
                          onPressed: () =>
                              _abrirPagina(context, const PaginaMisTurnos()),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Text('Próximos turnos', style: tema.titleLarge),
                const SizedBox(height: 12),
                StreamBuilder<List<Turno>>(
                  stream: _turnos,
                  builder: (context, estado) {
                    if (!estado.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final proximos = estado.data!
                        .where((turno) => turno.esProximo)
                        .toList()
                      ..sort((a, b) => a.fecha!.compareTo(b.fecha!));
                    if (proximos.isEmpty) {
                      return Text(
                        'No tenés turnos próximos',
                        style: tema.bodyMedium,
                      );
                    }
                    return Column(
                      children: [
                        for (final turno in proximos.take(3)) ...[
                          TarjetaTurno(turno: turno),
                          const SizedBox(height: 12),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
