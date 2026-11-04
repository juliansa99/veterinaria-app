import 'package:flutter/material.dart';
import 'package:veterinaria_app/app/fechas.dart';
import 'package:veterinaria_app/app/theme/app_theme.dart';
import 'package:veterinaria_app/features/auth/servicio_autenticacion.dart';
import 'package:veterinaria_app/features/auth/widgets/auth_button.dart';
import 'package:veterinaria_app/features/cliente/data/repositorio_mascotas.dart';
import 'package:veterinaria_app/features/cliente/data/repositorio_turnos.dart';
import 'package:veterinaria_app/features/cliente/models/mascota.dart';
import 'package:veterinaria_app/features/cliente/models/veterinario.dart';

class PaginaConfirmacionTurno extends StatefulWidget {
  const PaginaConfirmacionTurno({
    super.key,
    required this.veterinario,
    required this.fechaHora,
  });

  final Veterinario veterinario;
  final DateTime fechaHora;

  @override
  State<PaginaConfirmacionTurno> createState() =>
      _EstadoPaginaConfirmacionTurno();
}

class _EstadoPaginaConfirmacionTurno extends State<PaginaConfirmacionTurno> {
  late final Stream<List<Mascota>> _mascotas =
      RepositorioMascotas.mascotasDelCliente();

  String? _mascotaId;
  bool _reservando = false;

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Future<void> _confirmar(Mascota mascota) async {
    setState(() => _reservando = true);
    try {
      await RepositorioTurnos.reservar(
        veterinario: widget.veterinario,
        mascota: mascota,
        fechaHora: widget.fechaHora,
      );
      if (!mounted) return;
      final mensajes = ScaffoldMessenger.of(context);
      Navigator.of(context).popUntil((ruta) => ruta.isFirst);
      mensajes
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Turno reservado')));
    } on HorarioOcupadoExcepcion {
      if (!mounted) return;
      _mostrarMensaje(
        'Ese horario acaba de ser reservado por otra persona. Elegí otro.',
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      _mostrarMensaje(ServicioAutenticacion.mensajeDeError(error));
    } finally {
      if (mounted) setState(() => _reservando = false);
    }
  }

  void _cancelar(BuildContext context) {
    Navigator.of(context).popUntil((ruta) => ruta.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar turno'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: StreamBuilder<List<Mascota>>(
              stream: _mascotas,
              builder: (context, estado) {
                if (!estado.hasData && !estado.hasError) {
                  return const Center(child: CircularProgressIndicator());
                }
                final mascotas = estado.data ?? const <Mascota>[];
                Mascota? elegida;
                for (final m in mascotas) {
                  if (m.id == _mascotaId) elegida = m;
                }
                elegida ??= mascotas.isEmpty ? null : mascotas.first;

                return ListView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: ColoresAplicacion.superficie,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: ColoresAplicacion.borde),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Mascota', style: tema.bodyMedium),
                            const SizedBox(height: 6),
                            if (mascotas.isEmpty)
                              Text(
                                'Primero registrá una mascota en "Mis Mascotas".',
                                style: tema.bodyLarge,
                              )
                            else
                              DropdownButton<String>(
                                isExpanded: true,
                                value: elegida!.id,
                                items: [
                                  for (final mascota in mascotas)
                                    DropdownMenuItem<String>(
                                      value: mascota.id,
                                      child: Text(mascota.nombre),
                                    ),
                                ],
                                onChanged: _reservando
                                    ? null
                                    : (valor) =>
                                        setState(() => _mascotaId = valor),
                              ),
                            const SizedBox(height: 8),
                            Text(
                              'Veterinario: ${widget.veterinario.nombre}',
                              style: tema.bodyLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Fecha: ${fechaLarga(widget.fechaHora)}',
                              style: tema.bodyLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Horario: ${horaTexto(widget.fechaHora)}',
                              style: tema.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Opacity(
                      opacity: elegida == null ? 0.4 : 1,
                      child: BotonAutenticacion(
                        etiqueta: 'Confirmar',
                        cargando: _reservando,
                        onPressed: () {
                          if (elegida != null) _confirmar(elegida);
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed:
                            _reservando ? null : () => _cancelar(context),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(54),
                          foregroundColor: ColoresAplicacion.principal,
                          side: const BorderSide(
                            color: ColoresAplicacion.principal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
