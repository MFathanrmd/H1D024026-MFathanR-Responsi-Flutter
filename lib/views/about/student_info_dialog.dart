import 'package:flutter/material.dart';

/// Dialog profil mahasiswa untuk identitas pengerjaan tugas responsi.
class StudentInfoDialog extends StatelessWidget {
  const StudentInfoDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const StudentInfoDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.badge_rounded,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Informasi Praktikan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Nama', 'Muhammad Fathan Ramdani'),
          const SizedBox(height: 10),
          _buildInfoRow('NIM', 'H1D024026'),
          const SizedBox(height: 10),
          _buildInfoRow('Shift', 'Shift Awal: G  •  Shift Akhir: C'),
          const SizedBox(height: 10),
          _buildInfoRow('Mata Kuliah', 'Praktikum Pemrograman Mobile'),
          const SizedBox(height: 10),
          _buildInfoRow('Tugas', 'Responsi 2 - Aplikasi Cuaca (MVVM)'),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Aplikasi prakiraan cuaca Open-Meteo dengan arsitektur MVVM, Provider, dan Local Storage SharedPreferences.',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tutup'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
