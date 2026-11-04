import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:veterinaria_app/features/cliente/models/veterinario.dart';

/// Veterinarios reales: son los usuarios con `rol == 'veterinario'`.
class RepositorioVeterinarios {
  const RepositorioVeterinarios._();

  static Stream<List<Veterinario>> veterinarios() {
    return FirebaseFirestore.instance
        .collection('usuarios')
        .where('rol', isEqualTo: 'veterinario')
        .snapshots()
        .map((consulta) {
      final lista = [
        for (final documento in consulta.docs)
          Veterinario(
            uid: documento.id,
            nombre: (documento.data()['nombre'] as String?) ?? 'Veterinario',
            especialidad: 'Clínica general',
          ),
      ];
      lista.sort(
        (a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()),
      );
      return lista;
    });
  }
}
