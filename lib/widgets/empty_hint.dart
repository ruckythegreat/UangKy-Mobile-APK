import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Empty state singkat: teks + opsional satu tombol aksi.
class EmptyHint extends StatelessWidget {
  const EmptyHint({super.key, required this.text, this.action, this.onAction});

  final String text;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.inkMuted)),
            if (action != null && onAction != null) ...[
              const SizedBox(height: 12),
              FilledButton(onPressed: onAction, child: Text(action!)),
            ],
          ],
        ),
      );
}
