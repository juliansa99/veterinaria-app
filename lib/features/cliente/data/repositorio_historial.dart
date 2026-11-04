import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:veterinaria_app/features/cliente/models/registro_clinico.dart';

class RepositorioHistorial {
  const RepositorioHistorial._();

  /// Fichas clínicas de las mascotas del cliente con sesión iniciada.
  /// El `where` por clienteUid es obligatorio: las reglas lo exigen.
  static Stream<List<RegistroClinico>> misRegistros() {
    final usuario = FirebaseAuth.instance.currentUser;
    if (usuario == null) return Stream.value(const <RegistroClinico>[]);

    return FirebaseFirestore.instance
        .collection('historial')
        .where('clienteUid', isEqualTo: usuario.uid)
        .snapshots()
        .map((consulta) {
      final lista = [
        for (final documento in consulta.docs)
          RegistroClinico.desdeMapa(documento.id, documento.data()),
      ];
      lista.sort((a, b) => b.fechaTurno.compareTo(a.fechaTurno));
      return lista;
    });
  }
}