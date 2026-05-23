import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../backend/backend.dart';
import 'collections_controller.dart';

Future<void> showCollectionFormDialog(
  BuildContext context,
  WidgetRef ref, {
  Collection? collection,
}) async {
  final nameController = TextEditingController(text: collection?.name);
  final descriptionController =
      TextEditingController(text: collection?.description);
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(collection == null ? 'New collection' : 'Edit collection'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
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
          child: const Text('Save'),
        ),
      ],
    ),
  );
  nameController.dispose();
  descriptionController.dispose();
}
