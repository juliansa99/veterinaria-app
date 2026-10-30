import 'package:flutter/material.dart';
import 'package:veterinaria_app/features/auth/servicio_autenticacion.dart';
import 'package:veterinaria_app/features/auth/widgets/auth_button.dart';
import 'package:veterinaria_app/features/auth/widgets/auth_text_field.dart';
import 'package:veterinaria_app/features/cliente/data/repositorio_mascotas.dart';
import 'package:veterinaria_app/features/cliente/mascota_validators.dart';
import 'package:veterinaria_app/features/cliente/models/mascota.dart';

class PaginaAltaMascota extends StatefulWidget {
  const PaginaAltaMascota({super.key});

  @override
  State<PaginaAltaMascota> createState() => _EstadoPaginaAltaMascota();
}

class _EstadoPaginaAltaMascota extends State<PaginaAltaMascota> {
  final _claveFormulario = GlobalKey<FormState>();
  final _controladorNombre = TextEditingController();
  final _controladorEspecie = TextEditingController();
  final _controladorRaza = TextEditingController();
  final _controladorEdad = TextEditingController();
  final _controladorObservaciones = TextEditingController();

  AutovalidateMode _modoAutovalidacion = AutovalidateMode.disabled;
  bool _guardando = false;

  @override
  void dispose() {
    _controladorNombre.dispose();
    _controladorEspecie.dispose();
    _controladorRaza.dispose();
    _controladorEdad.dispose();
    _controladorObservaciones.dispose();
    super.dispose();
  }

  Future<void> _enviarFormulario() async {
    if (!_claveFormulario.currentState!.validate()) {
      setState(() {
        _modoAutovalidacion = AutovalidateMode.onUserInteraction;
      });
      return;
    }

    final mascota = Mascota(
      nombre: _controladorNombre.text.trim(),
      especie: _controladorEspecie.text.trim(),
      raza: _controladorRaza.text.trim(),
      edad: int.parse(_controladorEdad.text.trim()),
      observaciones: _controladorObservaciones.text.trim(),
    );

    setState(() => _guardando = true);
    try {
      await RepositorioMascotas.agregar(mascota);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(ServicioAutenticacion.mensajeDeError(error))),
        );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final temaTexto = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alta mascota'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Form(
                key: _claveFormulario,
                autovalidateMode: _modoAutovalidacion,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Nueva mascota', style: temaTexto.titleLarge),
                    const SizedBox(height: 20),
                    CampoAutenticacion(
                      controller: _controladorNombre,
                      etiqueta: 'Nombre',
                      icono: Icons.pets,
                      textCapitalization: TextCapitalization.words,
                      validator: ValidadoresMascota.validarNombre,
                    ),
                    const SizedBox(height: 16),
                    CampoAutenticacion(
                      controller: _controladorEspecie,
                      etiqueta: 'Especie',
                      icono: Icons.category_outlined,
                      textCapitalization: TextCapitalization.sentences,
                      validator: ValidadoresMascota.validarEspecie,
                    ),
                    const SizedBox(height: 16),
                    CampoAutenticacion(
                      controller: _controladorRaza,
                      etiqueta: 'Raza',
                      icono: Icons.badge_outlined,
                      textCapitalization: TextCapitalization.sentences,
                      validator: ValidadoresMascota.validarRaza,
                    ),
                    const SizedBox(height: 16),
                    CampoAutenticacion(
                      controller: _controladorEdad,
                      etiqueta: 'Edad',
                      icono: Icons.cake_outlined,
                      keyboardType: TextInputType.number,
                      validator: ValidadoresMascota.validarEdad,
                    ),
                    const SizedBox(height: 16),
                    CampoAutenticacion(
                      controller: _controladorObservaciones,
                      etiqueta: 'Observaciones',
                      icono: Icons.notes_outlined,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _enviarFormulario(),
                    ),
                    const SizedBox(height: 24),
                    BotonAutenticacion(
                      etiqueta: 'Guardar',
                      cargando: _guardando,
                      onPressed: _enviarFormulario,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
