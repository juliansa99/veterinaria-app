import 'package:flutter/material.dart';
import 'package:veterinaria_app/app/fechas.dart';
import 'package:veterinaria_app/app/theme/app_theme.dart';
import 'package:veterinaria_app/features/auth/servicio_autenticacion.dart';
import 'package:veterinaria_app/features/auth/widgets/auth_button.dart';
import 'package:veterinaria_app/features/cliente/data/repositorio_turnos.dart';
import 'package:veterinaria_app/features/cliente/models/veterinario.dart';
import 'package:veterinaria_app/features/cliente/pages/confirmacion_turno_page.dart';

class PaginaReservarTurnoHorario extends StatefulWidget {
  const PaginaReservarTurnoHorario({super.key, required this.veterinario});

  final Veterinario veterinario;

  @override
  State<PaginaReservarTurnoHorario> createState() =>
      _EstadoPaginaReservarTurnoHorario();
}

class _EstadoPaginaReservarTurnoHorario
    extends State<PaginaReservarTurnoHorario> {
  static const int _diasHaciaAdelante = 30;
  static const int _maximoDiasMostrados = 10;

  Map<String, HorarioAtencion>? _disponibilidad;
  List<DateTime> _diasDisponibles = const [];
  DateTime? _fecha;
  Stream<Set<String>>? _ocupados;
  String? _horarioElegido;
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  /// Lee la disponibilidad del veterinario y arma la lista de próximos días
  /// en los que atiende y todavía tiene horarios.
  Future<void> _cargar() async {
    try {
      final disponibilidad =
          await RepositorioTurnos.disponibilidadDe(widget.veterinario.uid);
      final hoy = DateTime.now();
      final dias = <DateTime>[];
      for (var i = 0;
          i <= _diasHaciaAdelante && dias.length < _maximoDiasMostrados;
          i++) {
        final dia = DateTime(hoy.year, hoy.month, hoy.day + i);
        if (RepositorioTurnos.horariosDelDia(disponibilidad, dia).isNotEmpty) {
          dias.add(dia);
        }
      }
      if (!mounted) return;
      setState(() {
        _disponibilidad = disponibilidad;
        _diasDisponibles = dias;
        if (dias.isNotEmpty) _elegirDia(dias.first);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = ServicioAutenticacion.mensajeDeError(error));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _elegirDia(DateTime dia) {
    _fecha = dia;
    _horarioElegido = null;
    _ocupados =
        RepositorioTurnos.horariosOcupados(widget.veterinario.uid, dia);
  }

  void _confirmarTurno() {
    final partes = _horarioElegido!.split(':');
    final fecha = _fecha!;
    final fechaHora = DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
      int.parse(partes.first),
      int.parse(partes.last),
    );
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => PaginaConfirmacionTurno(
          veterinario: widget.veterinario,
          fechaHora: fechaHora,
        ),
      ),
    );
  }

  Widget _contenido(TextTheme tema) {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Text(_error!, style: tema.bodyMedium, textAlign: TextAlign.center),
      );
    }
    if (_fecha == null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          '${widget.veterinario.nombre} todavía no tiene horarios disponibles.',
          style: tema.bodyMedium,
          textAlign: TextAlign.center,
        ),
      );
    }

    final fecha = _fecha!;
    return StreamBuilder<Set<String>>(
      stream: _ocupados,
      builder: (context, estado) {
        final ocupados = estado.data ?? const <String>{};
        final libres = RepositorioTurnos.horariosDelDia(_disponibilidad, fecha)
            .where((hora) => !ocupados.contains(hora))
            .toList();
        // Si alguien tomó el horario elegido mientras tanto, se deselecciona.
        final elegido = libres.contains(_horarioElegido) ? _horarioElegido : null;

        return ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            Text(widget.veterinario.nombre, style: tema.bodyLarge),
            const SizedBox(height: 4),
            Text(fechaLarga(fecha), style: tema.titleLarge),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final dia in _diasDisponibles)
                  ChoiceChip(
                    label: Text(fechaCorta(dia)),
                    selected: mismoDia(dia, fecha),
                    selectedColor: ColoresAplicacion.principal,
                    labelStyle: TextStyle(
                      color: mismoDia(dia, fecha)
                          ? Colors.white
                          : ColoresAplicacion.textoPrincipal,
                    ),
                    onSelected: (_) => setState(() => _elegirDia(dia)),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            if (libres.isEmpty)
              Text(
                'No quedan horarios libres para este día.',
                style: tema.bodyMedium,
              ),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final horario in libres)
                  ChoiceChip(
                    label: Text(horario),
                    selected: elegido == horario,
                    selectedColor: ColoresAplicacion.principal,
                    labelStyle: TextStyle(
                      color: elegido == horario
                          ? Colors.white
                          : ColoresAplicacion.textoPrincipal,
                    ),
                    checkmarkColor: Colors.white,
                    onSelected: (_) {
                      setState(() => _horarioElegido = horario);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 32),
            Opacity(
              opacity: elegido == null ? 0.4 : 1,
              child: BotonAutenticacion(
                etiqueta: 'Confirmar turno',
                onPressed: () {
                  if (elegido != null) {
                    _horarioElegido = elegido;
                    _confirmarTurno();
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservar Turno'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: _contenido(tema),
          ),
        ),
      ),
    );
  }
}
