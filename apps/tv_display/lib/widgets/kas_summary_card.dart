import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_models/shared_models.dart';

class KasSummaryCard extends StatelessWidget {
  final List<KasTransaction> transactions;

  const KasSummaryCard({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final summary = KasSummary.fromTransactions(transactions);

    final moneyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

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
                  Icon(Icons.account_balance_wallet_rounded,
                      size: 22, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Kas Masjid',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                moneyFormat.format(summary.saldo),
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 42,
                  height: 1.1,
                ),
              ),
              Text(
                'SALDO KAS',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              _KasAmountRow(
                icon: Icons.arrow_downward_rounded,
                label: 'Pemasukan',
                amount: moneyFormat.format(summary.totalMasuk),
                color: colorScheme.tertiary,
              ),
              const SizedBox(height: 6),
              _KasAmountRow(
                icon: Icons.arrow_upward_rounded,
                label: 'Pengeluaran',
                amount: moneyFormat.format(summary.totalKeluar),
                color: colorScheme.error,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KasAmountRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String amount;
  final Color color;

  const _KasAmountRow({
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          amount,
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
