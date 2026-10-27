import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_constants.dart';
import 'assistant_controller.dart';

class AssistantView extends StatefulWidget {
  const AssistantView({super.key});

  @override
  State<AssistantView> createState() => _AssistantViewState();
}

class _AssistantViewState extends State<AssistantView> {
  final _input = TextEditingController();
  AssistantController get controller => Get.find<AssistantController>();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            AppConstants.assistantDisclaimer,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Wrap(
          spacing: 8,
          children: [
            ActionChip(
              label: const Text('Última semana'),
              onPressed: () => controller.send(
                '¿Cómo han variado mis mediciones durante la última semana?',
              ),
            ),
            ActionChip(
              label: const Text('Este mes'),
              onPressed: () =>
                  controller.send('¿Cuántas mediciones registré este mes?'),
            ),
          ],
        ),
        Expanded(
          child: Obx(() {
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: controller.messages.length,
              itemBuilder: (context, i) {
                final m = controller.messages[i];
                return Align(
                  alignment: m.isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: m.isUser
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(m.text),
                  ),
                );
              },
            );
          }),
        ),
        Obx(() {
          if (controller.errorMessage.value != null) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                controller.errorMessage.value!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _input,
                  decoration: const InputDecoration(
                    hintText: 'Pregunte sobre sus registros...',
                  ),
                ),
              ),
              Obx(() {
                return IconButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                          controller.send(_input.text);
                          _input.clear();
                        },
                  icon: controller.isLoading.value
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
