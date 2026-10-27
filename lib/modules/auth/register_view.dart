import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'auth_controller.dart';

class RegisterView extends GetView<AuthController> {
  RegisterView({super.key});

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Nombre'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _email,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _password,
                decoration: const InputDecoration(
                  labelText: 'Contraseña (mín. 6)',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              Obx(() {
                if (controller.errorMessage.value != null) {
                  return Text(
                    controller.errorMessage.value!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              const SizedBox(height: 16),
              Obx(() {
                return FilledButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.register(
                          name: _name.text,
                          email: _email.text,
                          password: _password.text,
                        ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Registrarme'),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
