import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:veterinaria_app/features/cliente/models/mascota.dart';
import 'package:veterinaria_app/features/cliente/models/turno.dart';
import 'package:veterinaria_app/features/cliente/models/veterinario.dart';

/// Se lanza cuando el horario elegido ya fue reservado por otra persona.
class HorarioOcupadoExcepcion implements Exception {
  const HorarioOcupadoExcepcion();
}

/// Horario de atención de un día, con horas "HH:mm".
class HorarioAtencion {
  const HorarioAtencion({
    required this.activo,
    required this.desde,
    required this.hasta,
  });

  final bool activo;
  final String desde;
  final String hasta;
}

/// Disponibilidad, reserva y cancelación de turnos.
///
/// Estructura en Firestore:
/// - `disponibilidad/{vetUid}`: horarios de atención que define el veterinario.
/// - `ocupados/{vetUid}_{aaaaMMdd}_{HHmm}`: un documento por horario tomado.
///   Su ID es determinístico, así que dos clientes no pueden reservar el mismo
///   horario (la segunda escritura falla).
/// - `turnos/{id}`: el turno, con los datos del cliente, mascota y veterinario.
class RepositorioTurnos {
  const RepositorioTurnos._();

  static const int duracionMin = 60;
  static const List<String> _clavesDias = [
    'lun', 'mar', 'mie', 'jue', 'vie', 'sab', 'dom',
  ];

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static String _dos(int n) => n.toString().padLeft(2, '0');

  /// "20261029" para el día dado.
  static String claveDia(DateTime fecha) =>
      '${fecha.year}${_dos(fecha.month)}${_dos(fecha.day)}';

  static int _minutos(String hhmm) {
    final partes = hhmm.split(':');
    return (int.tryParse(partes.first) ?? 0) * 60 +
        (int.tryParse(partes.last) ?? 0);
  }

  // ------------------------------------------------------------------
  // Disponibilidad
  // ------------------------------------------------------------------

  /// Disponibilidad del veterinario, o `null` si todavía no definió una.
  static Future<Map<String, HorarioAtencion>?> disponibilidadDe(
    String veterinarioUid,
  ) async {
    final documento =
        await _db.collection('disponibilidad').doc(veterinarioUid).get();
    final datos = documento.data();
    if (datos == null) return null;

    final dias = (datos['dias'] as Map?) ?? const {};
    final resultado = <String, HorarioAtencion>{};
    for (final entrada in dias.entries) {
      final valor = entrada.value;
      if (valor is! Map) continue;
      resultado[entrada.key as String] = HorarioAtencion(
        activo: valor['activo'] == true,
        desde: (valor['desde'] as String?) ?? '09:00',
        hasta: (valor['hasta'] as String?) ?? '18:00',
      );
    }
    return resultado;
  }

  /// ¿El veterinario atiende ese día de la semana?
  static bool atiendeEl(
    Map<String, HorarioAtencion>? disponibilidad,
    DateTime fecha,
  ) {
    final horario = disponibilidad?[_clavesDias[fecha.weekday - 1]];
    return horario != null && horario.activo;
  }

  /// Horarios de inicio ("HH:mm") de turnos de 60 minutos para ese día.
  /// Si el día es hoy, se descartan los que ya pasaron.
  static List<String> horariosDelDia(
    Map<String, HorarioAtencion>? disponibilidad,
    DateTime fecha,
  ) {
    final horario = disponibilidad?[_clavesDias[fecha.weekday - 1]];
    if (horario == null || !horario.activo) return const [];

    final ahora = DateTime.now();
    final resultado = <String>[];
    for (var m = _minutos(horario.desde);
        m + duracionMin <= _minutos(horario.hasta);
        m += duracionMin) {
      final inicio = DateTime(fecha.year, fecha.month, fecha.day, 0, m);
      if (inicio.isAfter(ahora)) {
        resultado.add('${_dos(m ~/ 60)}:${_dos(m % 60)}');
      }
    }
    return resultado;
  }

  /// Horarios ("HH:mm") ya reservados de un veterinario en un día,
  /// actualizados en tiempo real.
  static Stream<Set<String>> horariosOcupados(
    String veterinarioUid,
    DateTime fecha,
  ) {
    return _db
        .collection('ocupados')
        .where('veterinarioUid', isEqualTo: veterinarioUid)
        .where('dia', isEqualTo: claveDia(fecha))
        .snapshots()
        .map((consulta) => {
              for (final documento in consulta.docs)
                (documento.data()['hora'] as String?) ?? '',
            });
  }

  // ------------------------------------------------------------------
  // Reserva
  // ------------------------------------------------------------------

  /// Reserva el turno en una transacción: si el horario ya está ocupado
  /// lanza [HorarioOcupadoExcepcion]; si no, crea el turno y marca el
  /// horario como ocupado en la misma operación.
  static Future<void> reservar({
    required Veterinario veterinario,
    required Mascota mascota,
    required DateTime fechaHora,
  }) async {
    final usuario = FirebaseAuth.instance.currentUser;
    if (usuario == null) throw StateError('No hay una sesión iniciada');
    if (mascota.id == null) throw StateError('La mascota no está guardada');

    final dia = claveDia(fechaHora);
    final hora = '${_dos(fechaHora.hour)}:${_dos(fechaHora.minute)}';
    final clave = '${dia}_${_dos(fechaHora.hour)}${_dos(fechaHora.minute)}';

    final ocupadoRef = _db.collection('ocupados').doc('${veterinario.uid}_$clave');
    final turnoRef = _db.collection('turnos').doc();

    await _db.runTransaction((transaccion) async {
      final ocupado = await transaccion.get(ocupadoRef);
      if (ocupado.exists) throw const HorarioOcupadoExcepcion();

      transaccion.set(turnoRef, {
        'clienteUid': usuario.uid,
        'clienteNombre': usuario.displayName ?? usuario.email ?? '',
        'mascotaId': mascota.id,
        'mascotaNombre': mascota.nombre,
        'veterinarioUid': veterinario.uid,
        'veterinarioNombre': veterinario.nombre,
        'fechaHora': Timestamp.fromDate(fechaHora),
        'dia': dia,
        'hora': hora,
        'clave': clave,
        'estado': Turno.estadoReservado,
        'creadoEn': FieldValue.serverTimestamp(),
      });
      transaccion.set(ocupadoRef, {
        'veterinarioUid': veterinario.uid,
        'dia': dia,
        'hora': hora,
        'clave': clave,
        'fechaHora': Timestamp.fromDate(fechaHora),
        'turnoId': turnoRef.id,
      });
    });
  }

  // ------------------------------------------------------------------
  // Mis turnos
  // ------------------------------------------------------------------

  /// Todos los turnos del cliente con sesión iniciada, en tiempo real.
  static Stream<List<Turno>> misTurnos() {
    final usuario = FirebaseAuth.instance.currentUser;
    if (usuario == null) return Stream.value(const <Turno>[]);

    return _db
        .collection('turnos')
        .where('clienteUid', isEqualTo: usuario.uid)
        .snapshots()
        .map((consulta) => [
              for (final documento in consulta.docs)
                Turno.desdeMapa(documento.id, documento.data()),
            ]);
  }

  /// Cancela el turno y libera el horario (en una sola operación).
  static Future<void> cancelar(Turno turno) async {
    final lote = _db.batch();
    lote.update(_db.collection('turnos').doc(turno.id), {
      'estado': Turno.estadoCancelado,
      'canceladoPor': 'cliente',
      'canceladoEn': FieldValue.serverTimestamp(),
    });
    lote.delete(
      _db.collection('ocupados').doc('${turno.veterinarioUid}_${turno.clave}'),
    );
    await lote.commit();
  }
}
