class Veterinario {
  const Veterinario({
    required this.nombre,
    required this.especialidad,
    this.uid = '',
  });

  final String nombre;
  final String especialidad;

  /// UID del veterinario en Firebase Authentication (vacío en datos de ejemplo).
  final String uid;
}
