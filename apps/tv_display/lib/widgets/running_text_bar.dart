import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

class RunningTextBar extends StatefulWidget {
  final List<RunningTextMessage> messages;

  const RunningTextBar({
    super.key,
    required this.messages,
  });

  @override
  State<RunningTextBar> createState() => _RunningTextBarState();
}

class _RunningTextBarState extends State<RunningTextBar> {
  late ScrollController _scrollController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  @override
  void didUpdateWidget(RunningTextBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldActiveMessages = oldWidget.messages.where((m) => m.isActive).toList();
    final newActiveMessages = widget.messages.where((m) => m.isActive).toList();

    // Check if active messages list changed (added/removed/toggled)
    final activeCountChanged = oldActiveMessages.length != newActiveMessages.length;

    // Check if any active message content changed
    final contentChanged = newActiveMessages.length == oldActiveMessages.length &&
        newActiveMessages.asMap().entries.any((entry) {
          final i = entry.key;
          final newMsg = entry.value;
          final oldMsg = oldActiveMessages[i];
          return newMsg.id == oldMsg.id &&
                 (newMsg.content != oldMsg.content || newMsg.category != oldMsg.category);
        });

    if (newActiveMessages.isEmpty) {
      _timer?.cancel();
    } else if (activeCountChanged || contentChanged || _timer == null || !_timer!.isActive) {
      // Restart marquee when messages change or content updates
      _startAutoScroll();
    }
  }

  void _startAutoScroll() {
    _timer?.cancel();
    final activeMessages = widget.messages.where((m) => m.isActive).toList();
    if (activeMessages.isEmpty) return;

    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!_scrollController.hasClients) return;
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;
      if (currentScroll >= maxScroll) {
        _scrollController.jumpTo(0);
      } else {
        _scrollController.jumpTo(currentScroll + 2.0);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final activeMessages = widget.messages.where((m) => m.isActive).toList();

    if (activeMessages.isEmpty) {
      return _buildEmptyState(theme, colorScheme);
    }

    return _buildRunningState(theme, colorScheme, activeMessages);
  }

  /// Bar running text full-width, menempel dasar layar (tanpa margin/radius).
  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      color: colorScheme.primary,
      height: 44,
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(
            Icons.campaign_rounded,
            color: colorScheme.onPrimary,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            'INFORMASI',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '•',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onPrimary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Tidak ada informasi',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Bar running text full-width: badge INFORMASI flush menyatu dengan bar
  /// (tanpa celah), teks berjalan di kanannya.
  Widget _buildRunningState(
    ThemeData theme,
    ColorScheme colorScheme,
    List<RunningTextMessage> activeMessages,
  ) {
    final combinedText =
        activeMessages.map((m) => '[${m.category}] ${m.content}').join('   •   ');

    return Container(
      color: colorScheme.surfaceContainerHighest,
      height: 44,
      child: Row(
        children: [
          // Badge INFORMASI — flush menyatu (stadium hanya di sisi kanan
          // agar menempel ke bar tanpa celah).
          Container(
            height: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: ShapeDecoration(
              color: colorScheme.primary,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.horizontal(
                  right: Radius.circular(22),
                ),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.campaign_rounded,
                  color: colorScheme.onPrimary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'INFORMASI',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Center(
                  child: Text(
                    combinedText,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 400), // Space before loop
              ],
            ),
          ),
        ],
      ),
    );
  }
}
