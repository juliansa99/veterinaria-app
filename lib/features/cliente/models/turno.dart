import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:veterinaria_app/app/fechas.dart';

/// Turno reservado por un cliente para una de sus mascotas.
class Turno {
  const Turno({
    this.id,
    required this.mascota,
    required this.veterinario,
    required this.fechaHora,
    this.fecha,
    this.estado = estadoReservado,
    this.veterinarioUid = '',
    this.clave = '',
  });

  static const String estadoReservado = 'reservado';
  static const String estadoCancelado = 'cancelado';

  /// Id del documento en `turnos` (null en datos de ejemplo).
  final String? id;
  final String mascota;
  final String veterinario;

  /// Texto listo para mostrar, por ejemplo "Mié 29/10 · 09:00".
  final String fechaHora;

  /// Fecha y hora reales del turno.
  final DateTime? fecha;
  final String estado;
  final String veterinarioUid;

  /// Clave del horario ("aaaaMMdd_HHmm"), usada para liberar el horario.
  final String clave;

  bool get estaCancelado => estado == estadoCancelado;

  /// Reservado y todavía no terminó (los turnos duran 60 minutos).
  bool get esProximo =>
      estado == estadoReservado &&
      fecha != null &&
      fecha!.add(const Duration(minutes: 60)).isAfter(DateTime.now());

  factory Turno.desdeMapa(String id, Map<String, dynamic> datos) {
    final fecha = (datos['fechaHora'] as Timestamp?)?.toDate();
    return Turno(
      id: id,
      mascota: (datos['mascotaNombre'] as String?) ?? '',
      veterinario: (datos['veterinarioNombre'] as String?) ?? '',
      fecha: fecha,
      fechaHora: fecha == null
          ? ''
          : '${fechaCorta(fecha)} · ${horaTexto(fecha)}',
      estado: (datos['estado'] as String?) ?? estadoReservado,
      veterinarioUid: (datos['veterinarioUid'] as String?) ?? '',
      clave: (datos['clave'] as String?) ?? '',
    );
  }
}
