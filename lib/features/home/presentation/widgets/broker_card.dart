import 'package:flutter/material.dart';
import 'package:src/core/theme/app_colors.dart';

class BrokerCard extends StatelessWidget {
  const BrokerCard({
    required this.host,
    required this.port,
    required this.topicPrefix,
    required this.isConnected,
    required this.isConnecting,
    required this.onReconnect,
    super.key,
  });

  final String host;
  final int port;
  final String topicPrefix;
  final bool isConnected;
  final bool isConnecting;
  final VoidCallback onReconnect;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  isConnected ? Icons.cloud_done_rounded : Icons.cloud_off,
                  color: isConnected
                      ? AppColors.success
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isConnected ? 'Broker connected' : 'Broker disconnected',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                TextButton.icon(
                  onPressed: isConnecting ? null : onReconnect,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(isConnecting ? 'Connecting...' : 'Reconnect'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Host: $host', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 6),
            Text('Port: $port', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 6),
            Text(
              'Topic prefix: $topicPrefix',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
