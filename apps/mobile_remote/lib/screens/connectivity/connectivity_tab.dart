import 'package:flutter/material.dart';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';
import '../../widgets/m3_pressable.dart';

class ConnectivityTab extends StatelessWidget {
  final TextEditingController ipController;
  final bool isConnecting;
  final bool isConnected;
  final bool isScanning;
  final List<BleDiscoveredDevice> p2pDevices;
  final String p2pStatus;
  final VoidCallback onConnectWifi;
  final VoidCallback onStartScan;
  final VoidCallback onStopScan;
  final Function(BleDiscoveredDevice) onConnectP2p;

  const ConnectivityTab({
    super.key,
    required this.ipController,
    required this.isConnecting,
    required this.isConnected,
    required this.isScanning,
    required this.p2pDevices,
    required this.p2pStatus,
    required this.onConnectWifi,
    required this.onStartScan,
    required this.onStopScan,
    required this.onConnectP2p,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Card(
            color: isConnected
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isConnected ? Icons.cloud_done : Icons.cloud_off,
                        color: isConnected ? colorScheme.primary : colorScheme.error,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isConnected ? 'Koneksi Jaringan Aktif' : 'Belum Terhubung',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: ipController,
                          decoration: const InputDecoration(
                            labelText: 'IP Address TV Display',
                            prefixIcon: Icon(Icons.link),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      M3Pressable(
                        child: ElevatedButton.icon(
                          onPressed: isConnecting ? null : onConnectWifi,
                          icon: isConnecting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Icon(isConnected
                                  ? Icons.check_circle
                                  : Icons.connect_without_contact),
                          label: Text(isConnected ? 'Terhubung' : 'Sambungkan'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.wifi_tethering, color: colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'WiFi Direct (Tanpa Router)',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      M3Pressable(
                        child: FilledButton.tonalIcon(
                          onPressed: isScanning ? onStopScan : onStartScan,
                          icon: isScanning
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.radar),
                          label: Text(isScanning ? 'Stop' : 'Cari TV'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Hubungkan langsung Remote ke TV Display menggunakan WiFi Direct P2P / Bluetooth LE.',
                    style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  if (isScanning) ...[
                    const LinearProgressIndicator(),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    p2pStatus,
                    style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (p2pDevices.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(
                        child: Text(
                          isScanning ? 'Mencari perangkat TV...' : 'Tidak ada perangkat terdeteksi.',
                          style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: p2pDevices.length,
                      itemBuilder: (context, index) {
                        final device = p2pDevices[index];
                        final name = device.deviceName;
                        final address = device.deviceAddress;
                        return Card(
                          color: colorScheme.surfaceContainer,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(Icons.tv),
                            title: Text(name),
                            subtitle: Text(address),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => onConnectP2p(device),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
