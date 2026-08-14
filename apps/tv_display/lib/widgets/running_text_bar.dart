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
    final activeMessages = widget.messages.where((m) => m.isActive).toList();
    if (activeMessages.isEmpty) {
      _timer?.cancel();
    } else if (_timer == null || !_timer!.isActive) {
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

  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
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

  Widget _buildRunningState(
    ThemeData theme,
    ColorScheme colorScheme,
    List<RunningTextMessage> activeMessages,
  ) {
    final combinedText =
        activeMessages.map((m) => '[${m.category}] ${m.content}').join('   •   ');

    return Card(
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.2)),
      ),
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: SizedBox(
          height: 40,
          child: Row(
            children: [
              // Fully rounded Pill (BorderRadius.circular(50)) for INFORMASI
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                height: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(50),
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
                  padding: const EdgeInsets.symmetric(horizontal: 20),
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
        ),
      ),
    );
  }
}
