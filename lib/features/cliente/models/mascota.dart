class Mascota {
  const Mascota({
    this.id,
    required this.nombre,
    required this.especie,
    required this.raza,
    required this.edad,
    this.observaciones = '',
  });

  /// Id del documento en Firestore (null mientras la mascota no se guardó).
  final String? id;
  final String nombre;
  final String especie;
  final String raza;
  final int edad;
  final String observaciones;

  factory Mascota.desdeMapa(String id, Map<String, dynamic> datos) {
    return Mascota(
      id: id,
      nombre: (datos['nombre'] as String?) ?? '',
      especie: (datos['especie'] as String?) ?? '',
      raza: (datos['raza'] as String?) ?? '',
      edad: (datos['edad'] as num?)?.toInt() ?? 0,
      observaciones: (datos['observaciones'] as String?) ?? '',
    );
  }
}
