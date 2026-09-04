import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app.dart';
import '../../../backend/backend.dart';
import 'collections_controller.dart';

Future<void> showCollectionFormDialog(
  BuildContext context,
  WidgetRef ref, {
  Collection? collection,
}) async {
  final settings =
      ref.read(appSettingsProvider).value ?? AppSettings.defaults;
  final isRu = settings.languageCode == 'ru';
  final nameController = TextEditingController(text: collection?.name);
  final descriptionController =
      TextEditingController(text: collection?.description);

  await showDialog<void>(
    context: context,
    builder: (context) {
      final scheme = Theme.of(context).colorScheme;
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
        actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                collection == null
                    ? Icons.create_new_folder_rounded
                    : Icons.edit_note_rounded,
                color: scheme.onPrimaryContainer,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                collection == null
                    ? (isRu ? 'Новая коллекция' : 'New collection')
                    : (isRu ? 'Редактировать' : 'Edit collection'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              autofocus: collection == null,
              decoration: InputDecoration(
                labelText: isRu ? 'Название' : 'Name',
                hintText: isRu ? 'Например, Избранные обои' : 'e.g. Best Wallpapers',
                prefixIcon: const Icon(Icons.bookmark_border_rounded),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: descriptionController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: isRu ? 'Описание (необязательно)' : 'Description (optional)',
                hintText: isRu ? 'О чем эта подборка' : 'What is this collection about',
                prefixIcon: const Icon(Icons.description_outlined),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isRu ? 'Отмена' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              if (collection == null) {
                await ref
                    .read(collectionsControllerProvider.notifier)
                    .create(name, descriptionController.text.trim());
              } else {
                await ref
                    .read(collectionsControllerProvider.notifier)
                    .updateCollection(
                      collection.id,
                      name: name,
                      description: descriptionController.text.trim(),
                      coverUrl: collection.coverUrl,
                    );
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(isRu ? 'Сохранить' : 'Save'),
          ),
        ],
      );
    },
  );
  nameController.dispose();
  descriptionController.dispose();
}
