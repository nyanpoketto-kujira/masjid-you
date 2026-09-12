import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_models/shared_models.dart';
import '../../widgets/m3_pressable.dart';
import '../../widgets/kas_stat_card.dart';

class KasSubtab extends StatelessWidget {
  final List<KasTransaction> transactions;
  final TextEditingController amountController;
  final TextEditingController descriptionController;
  final KasType kasType;
  final Function(KasType) onTypeChanged;
  final VoidCallback onAddTransaction;
  final Function(String) onRemoveTransaction;

  const KasSubtab({
    super.key,
    required this.transactions,
    required this.amountController,
    required this.descriptionController,
    required this.kasType,
    required this.onTypeChanged,
    required this.onAddTransaction,
    required this.onRemoveTransaction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final summary = KasSummary.fromTransactions(transactions);

    final moneyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormat = DateFormat('d MMM yyyy, HH:mm');

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: KasStatCard(
                  title: 'SALDO KAS',
                  amount: moneyFormat.format(summary.saldo),
                  icon: Icons.account_balance_wallet,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: KasStatCard(
                  title: 'PEMASUKAN',
                  amount: moneyFormat.format(summary.totalMasuk),
                  icon: Icons.arrow_downward,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: KasStatCard(
                  title: 'PENGELUARAN',
                  amount: moneyFormat.format(summary.totalKeluar),
                  icon: Icons.arrow_upward,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tambah Transaksi Baru',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Tipe: '),
                      const SizedBox(width: 8),
                      SegmentedButton<KasType>(
                        segments: const [
                          ButtonSegment(
                            value: KasType.masuk,
                            label: Text('Masuk'),
                            icon: Icon(Icons.arrow_downward),
                          ),
                          ButtonSegment(
                            value: KasType.keluar,
                            label: Text('Keluar'),
                            icon: Icon(Icons.arrow_upward),
                          ),
                        ],
                        selected: {kasType},
                        onSelectionChanged: (set) => onTypeChanged(set.first),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Nominal (Rp)',
                      prefixText: 'Rp ',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Keterangan / Sumber / Peruntukan',
                    ),
                  ),
                  const SizedBox(height: 16),
                  M3Pressable(
                    child: FilledButton.icon(
                      onPressed: onAddTransaction,
                      icon: const Icon(Icons.add),
                      label: const Text('Simpan Transaksi'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              key: const PageStorageKey('kas_list_view'),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
                final isMasuk = tx.type == KasType.masuk;
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isMasuk ? Colors.green.withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.15),
                      child: Icon(
                        isMasuk ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isMasuk ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Text(tx.description),
                    subtitle: Text(dateFormat.format(tx.date)),
                    trailing: Text(
                      '${isMasuk ? '+' : '-'} ${moneyFormat.format(tx.amount)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isMasuk ? Colors.green : Colors.red,
                      ),
                    ),
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Hapus Transaksi?'),
                          content: Text('Apakah Anda yakin ingin menghapus transaksi "${tx.description}"?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Batal'),
                            ),
                            FilledButton(
                              onPressed: () {
                                onRemoveTransaction(tx.id);
                                Navigator.pop(ctx);
                              },
                              child: const Text('Hapus'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
