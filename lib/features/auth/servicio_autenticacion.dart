import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Se lanza cuando la cuenta existe pero su rol no corresponde a esta app.
class AccesoDenegadoExcepcion implements Exception {
  const AccesoDenegadoExcepcion();
}

/// Autenticación de la app de clientes.
///
/// Toda cuenta creada desde esta app queda con `rol: 'cliente'`. El rol de
/// veterinario no puede asignarse desde acá: las reglas de Firestore solo
/// permiten crear `usuarios/{uid}` con `rol == 'cliente'`.
class ServicioAutenticacion {
  const ServicioAutenticacion._();

  static const String rolCliente = 'cliente';

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static User? get usuarioActual => _auth.currentUser;

  /// Devuelve el rol guardado en `usuarios/{uid}` o `null` si no existe.
  static Future<String?> _leerRol(String uid) async {
    final documento = await _db.collection('usuarios').doc(uid).get();
    return documento.data()?['rol'] as String?;
  }

  /// Comprueba que la sesión actual pertenece a un cliente.
  /// Si no es así, cierra la sesión. Ante un error de red devuelve `false`
  /// sin cerrar la sesión.
  static Future<bool> sesionEsCliente() async {
    final usuario = _auth.currentUser;
    if (usuario == null) return false;
    try {
      final rol = await _leerRol(usuario.uid);
      if (rol == rolCliente) return true;
      await _auth.signOut();
      return false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> iniciarSesion({
    required String email,
    required String contrasena,
  }) async {
    final credencial = await _auth.signInWithEmailAndPassword(
      email: email,
      password: contrasena,
    );
    final rol = await _leerRol(credencial.user!.uid);
    if (rol != rolCliente) {
      await _auth.signOut();
      throw const AccesoDenegadoExcepcion();
    }
  }

  static Future<void> registrar({
    required String nombre,
    required String email,
    required String contrasena,
  }) async {
    final credencial = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: contrasena,
    );
    final usuario = credencial.user!;
    try {
      await usuario.updateDisplayName(nombre);
      await _db.collection('usuarios').doc(usuario.uid).set({
        'nombre': nombre,
        'email': email,
        'rol': rolCliente,
        'creadoEn': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Si no se pudo guardar el perfil, no dejamos una cuenta a medias.
      await usuario.delete();
      rethrow;
    }
  }

  static Future<void> recuperarContrasena(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  static Future<void> cerrarSesion() => _auth.signOut();

  static String mensajeDeError(Object error) {
    if (error is AccesoDenegadoExcepcion) {
      return 'Esta cuenta no tiene acceso a la app de clientes';
    }
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'El email no es válido';
        case 'user-disabled':
          return 'Esta cuenta está deshabilitada';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Email o contraseña incorrectos';
        case 'email-already-in-use':
          return 'Ya existe una cuenta con ese email';
        case 'weak-password':
          return 'La contraseña es muy débil (mínimo 6 caracteres)';
        case 'too-many-requests':
          return 'Demasiados intentos. Probá de nuevo en unos minutos';
        case 'network-request-failed':
          return 'Sin conexión a internet';
      }
    }
    if (error is FirebaseException && error.code == 'permission-denied') {
      return 'No tenés permisos para realizar esta acción';
    }
    return 'Ocurrió un error. Intentá de nuevo';
  }
}
