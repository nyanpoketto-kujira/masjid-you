import 'package:bluetooth_sync/bluetooth_sync.dart';
import 'package:flutter/material.dart';

import '../../widgets/m3_pressable.dart';

class ConnectionGatewayScreen extends StatelessWidget {
  final TextEditingController ipController;
  final bool isConnecting;
  final VoidCallback onConnectIp;

  final bool btIsScanning;
  final List<BluetoothDeviceInfo> btDevices;
  final String btStatus;
  final VoidCallback onBtStartScan;
  final VoidCallback onBtStopScan;
  final ValueChanged<BluetoothDeviceInfo> onBtConnect;

  const ConnectionGatewayScreen({
    super.key,
    required this.ipController,
    required this.isConnecting,
    required this.onConnectIp,
    required this.btIsScanning,
    required this.btDevices,
    required this.btStatus,
    required this.onBtStartScan,
    required this.onBtStopScan,
    required this.onBtConnect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 16),
            Icon(Icons.tv_rounded, size: 56, color: colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Selamat Datang di Remote Masjid',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Sambungkan dulu ke TV Masjid untuk membuka menu utama '
              '(Pengaturan, Konten, dan Tes).',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.bluetooth_searching,
                            color: colorScheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Koneksi Bluetooth',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        M3Pressable(
                          child: FilledButton.tonalIcon(
                            onPressed:
                                btIsScanning ? onBtStopScan : onBtStartScan,
                            icon: btIsScanning
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Icon(Icons.radar),
                            label: Text(btIsScanning ? 'Stop' : 'Cari TV'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Gunakan Bluetooth Classic untuk pairing langsung dan '
                      'masukkan PIN challenge dari TV.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      btStatus,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (btDevices.isEmpty)
                      Text(
                        btIsScanning
                            ? 'Mencari perangkat TV...'
                            : 'Belum ada perangkat ditemukan.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      )
                    else
                      for (final device in btDevices)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Card(
                            color: colorScheme.surfaceContainerHigh,
                            child: ListTile(
                              leading: const Icon(Icons.tv),
                              title: Text(device.name),
                              subtitle: Text(device.address),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => onBtConnect(device),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.wifi_rounded, color: colorScheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Koneksi IP Address',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Masukkan IP TV jika TV dan HP berada di jaringan '
                      'Wi-Fi/LAN yang sama.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: ipController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'IP Address TV',
                        hintText: '192.168.1.10:8080',
                        prefixIcon: Icon(Icons.link),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: M3Pressable(
                        child: FilledButton.icon(
                          onPressed: isConnecting ? null : onConnectIp,
                          icon: isConnecting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                              : const Icon(Icons.connect_without_contact),
                          label: Text(
                            isConnecting ? 'Menyambungkan...' : 'Hubungkan',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
