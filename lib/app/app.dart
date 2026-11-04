import 'package:flutter/material.dart';
import 'package:veterinaria_app/app/theme/app_theme.dart';
import 'package:veterinaria_app/features/auth/pages/login_page.dart';
import 'package:veterinaria_app/features/auth/servicio_autenticacion.dart';
import 'package:veterinaria_app/features/cliente/pages/home_cliente_page.dart';

class AplicacionVeterinaria extends StatelessWidget {
  const AplicacionVeterinaria({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Veterinaria',
      debugShowCheckedModeBanner: false,
      theme: TemaAplicacion.claro,
      home: const _PantallaInicial(),
    );
  }
}

/// Decide la primera pantalla: login, o el home si hay una sesión de
/// cliente válida (el rol se verifica contra Firestore).
class _PantallaInicial extends StatelessWidget {
  const _PantallaInicial();

  @override
  Widget build(BuildContext context) {
    if (ServicioAutenticacion.usuarioActual == null) {
      return const PaginaLogin();
    }
    return FutureBuilder<bool>(
      future: ServicioAutenticacion.sesionEsCliente(),
      builder: (context, estado) {
        if (estado.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return estado.data == true
            ? const PaginaHomeCliente()
            : const PaginaLogin();
      },
    );
  }
}
