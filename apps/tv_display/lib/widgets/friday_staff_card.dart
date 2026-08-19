import 'package:flutter/material.dart';

/// Kartu penampil Petugas Hari Jumat (Khatib & Muadzin) di dashboard TV.
///
/// Desain serasi dengan [KasSummaryCard] agar area kanan dashboard tetap
/// konsisten saat bergantian tampil di hari Jumat.
class FridayStaffCard extends StatelessWidget {
  final String khatib;
  final String muadzin;

  const FridayStaffCard({
    super.key,
    required this.khatib,
    required this.muadzin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      color: colorScheme.surfaceContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.menu_book_rounded,
                      size: 22, color: colorScheme.tertiary),
                  const SizedBox(width: 8),
                  Text(
                    'Petugas Jumat',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _StaffRow(
                icon: Icons.person_rounded,
                label: 'Khatib',
                name: khatib,
              ),
              const SizedBox(height: 8),
              _StaffRow(
                icon: Icons.campaign_rounded,
                label: 'Muadzin',
                name: muadzin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StaffRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String name;

  const _StaffRow({
    required this.icon,
    required this.label,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: theme.textTheme.titleSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: 16,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          name,
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ],
    );
  }
}
