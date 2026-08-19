import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:material_new_shapes/material_new_shapes.dart';
import 'package:shared_models/shared_models.dart';

import '../theme/m3_shape_border.dart';

class BannerCarousel extends StatefulWidget {
  final List<MediaBanner> banners;

  const BannerCarousel({
    super.key,
    required this.banners,
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;

  List<MediaBanner> get _activeBanners =>
      widget.banners.where((b) => b.isActive).toList();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      final banners = _activeBanners;
      if (banners.isEmpty) return;
      final nextIndex = (_currentIndex + 1) % banners.length;
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(BannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldActiveBanners = oldWidget.banners.where((b) => b.isActive).toList();
    final newActiveBanners = widget.banners.where((b) => b.isActive).toList();
    
    // Restart timer if active banners list changed
    if (oldActiveBanners.length != newActiveBanners.length) {
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final banners = _activeBanners;

    if (banners.isEmpty) {
      return Card(
        color: colorScheme.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.mosque_rounded,
                  size: 88,
                  color: colorScheme.primary.withValues(alpha: 0.65),
                ),
                const SizedBox(height: 16),
                Text(
                  'Jagalah Shaf dan Shalatlah Tepat Waktu',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Reset index if it points beyond the (new) list length.
    if (_currentIndex >= banners.length) {
      _currentIndex = 0;
    }

    return Card(
      color: colorScheme.surfaceContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: banners.length,
        itemBuilder: (context, index) {
          final banner = banners[index];
          return _BannerPage(
            banner: banner,
            active: index == _currentIndex,
          );
        },
      ),
    );
  }
}

class _BannerPage extends StatefulWidget {
  final MediaBanner banner;
  final bool active;

  const _BannerPage({
    required this.banner,
    required this.active,
  });

  @override
  State<_BannerPage> createState() => _BannerPageState();
}

class _BannerPageState extends State<_BannerPage> {
  final _scrollController = ScrollController();
  Timer? _scrollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
  }

  @override
  void didUpdateWidget(covariant _BannerPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final contentChanged = oldWidget.banner.header != widget.banner.header ||
        oldWidget.banner.title != widget.banner.title ||
        oldWidget.banner.content != widget.banner.content ||
        oldWidget.banner.footer != widget.banner.footer;
    if (contentChanged) {
      _scrollTimer?.cancel();
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
      WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
    } else if (oldWidget.active != widget.active && widget.active) {
      // Page became visible again: reset and start the scroll fresh.
      _scrollTimer?.cancel();
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
      WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
    }
  }

  /// Slowly scrolls the content from top to bottom (when it overflows)
  /// during the ~9s the page is shown, without shrinking the font size.
  void _startAutoScroll() {
    _scrollTimer?.cancel();
    if (!mounted || !_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) return;

    const tickMs = 50;
    const durationMs = 9000;
    final step = maxScroll / (durationMs / tickMs);

    _scrollTimer = Timer.periodic(const Duration(milliseconds: tickMs), (timer) {
      if (!mounted || !_scrollController.hasClients) {
        timer.cancel();
        return;
      }
      final target = _scrollController.offset + step;
      if (target >= _scrollController.position.maxScrollExtent) {
        timer.cancel();
      } else {
        _scrollController.jumpTo(target);
      }
    });
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final banner = widget.banner;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Poster Image (if available)
          if (banner.base64Image != null && banner.base64Image!.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 140,
                height: double.infinity,
                color: colorScheme.surfaceContainerHigh,
                child: Image.memory(
                  base64Decode(banner.base64Image!),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Icon(Icons.broken_image, size: 40));
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Badge Pill (StadiumBorder)
                  if (banner.header.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                      decoration: ShapeDecoration(
                        color: colorScheme.tertiaryContainer,
                        shape: M3ShapeBorder(MaterialShapes.pill),
                      ),
                      child: Text(
                        banner.header,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onTertiaryContainer,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    banner.title,
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                    ),
                  ),
                  if (banner.content.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      banner.content,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 16,
                        height: 1.3,
                      ),
                    ),
                  ],
                  if (banner.footer.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      banner.footer,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
