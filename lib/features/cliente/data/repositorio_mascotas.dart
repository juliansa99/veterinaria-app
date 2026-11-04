import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:veterinaria_app/features/cliente/models/mascota.dart';

/// Acceso a la colección `mascotas` de Firestore.
///
/// Cada documento guarda `duenioUid` (el cliente que la registró). Las reglas
/// de Firestore garantizan que cada cliente solo ve y modifica las suyas, y
/// que los veterinarios pueden verlas todas como pacientes.
class RepositorioMascotas {
  const RepositorioMascotas._();

  static final CollectionReference<Map<String, dynamic>> _coleccion =
      FirebaseFirestore.instance.collection('mascotas');

  /// Mascotas del cliente con sesión iniciada, en tiempo real.
  static Stream<List<Mascota>> mascotasDelCliente() {
    final usuario = FirebaseAuth.instance.currentUser;
    if (usuario == null) return Stream.value(const <Mascota>[]);

    return _coleccion
        .where('duenioUid', isEqualTo: usuario.uid)
        .snapshots()
        .map((consulta) {
      final mascotas = [
        for (final documento in consulta.docs)
          Mascota.desdeMapa(documento.id, documento.data()),
      ];
      // Se ordena en la app para no requerir un índice compuesto.
      mascotas.sort(
        (a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()),
      );
      return mascotas;
    });
  }

  /// Guarda una mascota nueva a nombre del cliente con sesión iniciada.
  static Future<void> agregar(Mascota mascota) async {
    final usuario = FirebaseAuth.instance.currentUser;
    if (usuario == null) {
      throw StateError('No hay una sesión iniciada');
    }

    await _coleccion.add({
      'duenioUid': usuario.uid,
      'duenioNombre': usuario.displayName ?? usuario.email ?? '',
      'nombre': mascota.nombre,
      'especie': mascota.especie,
      'raza': mascota.raza,
      'edad': mascota.edad,
      'observaciones': mascota.observaciones,
      'creadoEn': FieldValue.serverTimestamp(),
    });
  }
}
