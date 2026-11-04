import 'package:cloud_firestore/cloud_firestore.dart';

/// Ficha clínica de un turno (documento `historial/{turnoId}`).
class RegistroClinico {
  const RegistroClinico({
    required this.turnoId,
    required this.mascotaNombre,
    required this.veterinarioNombre,
    required this.fechaTurno,
    this.estadoGeneral = '',
    this.diagnostico = '',
    this.tratamientos = '',
    this.estudios = '',
    this.medicamentos = '',
    this.observaciones = '',
  });

  final String turnoId;
  final String mascotaNombre;
  final String veterinarioNombre;
  final DateTime fechaTurno;
  final String estadoGeneral;
  final String diagnostico;
  final String tratamientos;
  final String estudios;
  final String medicamentos;
  final String observaciones;

  factory RegistroClinico.desdeMapa(String id, Map<String, dynamic> datos) {
    String texto(String clave) => (datos[clave] as String?) ?? '';
    return RegistroClinico(
      turnoId: id,
      mascotaNombre: texto('mascotaNombre'),
      veterinarioNombre: texto('veterinarioNombre'),
      fechaTurno:
          (datos['fechaTurno'] as Timestamp?)?.toDate() ?? DateTime.now(),
      estadoGeneral: texto('estadoGeneral'),
      diagnostico: texto('diagnostico'),
      tratamientos: texto('tratamientos'),
      estudios: texto('estudios'),
      medicamentos: texto('medicamentos'),
      observaciones: texto('observaciones'),
    );
  }
}