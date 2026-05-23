import 'package:flutter/material.dart';

import '../../../../backend/backend.dart';

class ProviderCard extends StatelessWidget {
  const ProviderCard({
    required this.config,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final ContentProviderConfig config;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Switch(value: config.enabled, onChanged: onToggle),
        title: Text(config.name),
        subtitle: Text(
            '${config.apiType} · ${config.baseUrl}\nPriority ${config.priority}'),
        isThreeLine: true,
        trailing: Wrap(
          spacing: 4,
          children: [
            IconButton(
              tooltip: 'Edit',
              onPressed: onEdit,
              icon: const Icon(Icons.edit_rounded),
            ),
            IconButton(
              tooltip: 'Delete',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
