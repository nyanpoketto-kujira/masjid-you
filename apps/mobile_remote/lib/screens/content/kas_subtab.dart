import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_models/shared_models.dart';
import '../../widgets/editor_empty_state.dart';
import '../../widgets/kas_stat_card.dart';

/// Editor Kas (Fase 3, ADR-025): kartu ringkasan tetap di atas; tambah
/// lewat Extended FAB yang membuka form dalam dialog full-screen; baris
/// transaksi menampilkan kata Masuk/Keluar selain warna; hapus rutin
/// diurungkan lewat SnackBar (ditangani pemanggil).
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

  void _openAddDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return _AddKasDialog(
          amountController: amountController,
          descriptionController: descriptionController,
          kasType: kasType,
          onTypeChanged: onTypeChanged,
          onAddTransaction: onAddTransaction,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final summary = KasSummary.fromTransactions(transactions);

    final moneyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormat = DateFormat('d MMM yyyy, HH:mm');

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Transaksi'),
      ),
      body: Padding(
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
            Expanded(
              child: transactions.isEmpty
                  ? EditorEmptyState(
                      icon: Icons.account_balance_wallet,
                      title: 'Belum ada transaksi kas',
                      message: 'Catat pemasukan dan pengeluaran kas '
                          'masjid di sini.',
                      actionLabel: 'Tambah Transaksi',
                      onAction: () => _openAddDialog(context),
                    )
                  : ListView.builder(
                      key: const PageStorageKey('kas_list_view'),
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final tx = transactions[index];
                        final isMasuk = tx.type == KasType.masuk;
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isMasuk
                                  ? Colors.green.withValues(alpha: 0.15)
                                  : Colors.red.withValues(alpha: 0.15),
                              child: Icon(
                                isMasuk
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: isMasuk ? Colors.green : Colors.red,
                              ),
                            ),
                            title: Text(tx.description),
                            subtitle: Text(
                              '${isMasuk ? 'Masuk' : 'Keluar'} • '
                              '${dateFormat.format(tx.date)}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${isMasuk ? '+' : '-'} '
                                  '${moneyFormat.format(tx.amount)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isMasuk ? Colors.green : Colors.red,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  tooltip: 'Hapus transaksi',
                                  onPressed: () =>
                                      onRemoveTransaction(tx.id),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Form tambah transaksi dalam dialog full-screen: tipe (Masuk/Keluar),
/// nominal, keterangan + tombol Simpan eksplisit di AppBar (non-aktif bila
/// nominal tidak valid atau keterangan kosong). Tipe dipilih secara lokal
/// di dialog; nilai akhirnya diteruskan ke pemanggil saat Simpan ditekan.
class _AddKasDialog extends StatefulWidget {
  const _AddKasDialog({
    required this.amountController,
    required this.descriptionController,
    required this.kasType,
    required this.onTypeChanged,
    required this.onAddTransaction,
  });

  final TextEditingController amountController;
  final TextEditingController descriptionController;
  final KasType kasType;
  final ValueChanged<KasType> onTypeChanged;
  final VoidCallback onAddTransaction;

  @override
  State<_AddKasDialog> createState() => _AddKasDialogState();
}

class _AddKasDialogState extends State<_AddKasDialog> {
  late KasType _type;

  @override
  void initState() {
    super.initState();
    _type = widget.kasType;
  }

  bool _canSave(String amountText, String descriptionText) {
    final amount = int.tryParse(amountText.trim());
    return amount != null && amount > 0 && descriptionText.trim().isNotEmpty;
  }

  void _save() {
    widget.onTypeChanged(_type);
    widget.onAddTransaction();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Tutup',
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Tambah Transaksi'),
          actions: [
            ListenableBuilder(
              listenable: Listenable.merge([
                widget.amountController,
                widget.descriptionController,
              ]),
              builder: (context, _) {
                final canSave = _canSave(
                  widget.amountController.text,
                  widget.descriptionController.text,
                );
                return TextButton(
                  onPressed: canSave ? _save : null,
                  child: const Text('Simpan'),
                );
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    selected: {_type},
                    onSelectionChanged: (set) {
                      setState(() => _type = set.first);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: widget.amountController,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Nominal (Rp)',
                  prefixText: 'Rp ',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: widget.descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Keterangan / Sumber / Peruntukan',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
