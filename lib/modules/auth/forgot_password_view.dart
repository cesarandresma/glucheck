import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'auth_controller.dart';

class ForgotPasswordView extends GetView<AuthController> {
  ForgotPasswordView({super.key});

  final _email = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar contraseña')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text(
                'Ingrese su correo y le enviaremos un enlace para restablecer la contraseña.',
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
                      : () => controller.resetPassword(_email.text),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator()
                      : const Text('Enviar enlace'),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
