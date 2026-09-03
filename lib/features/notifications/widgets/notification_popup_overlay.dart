import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../models/notification_model.dart';
import '../providers/notification_provider.dart';
import '../screens/notification_center_screen.dart';
import 'notification_popup_card.dart';

/// Wraps the entire app to display popup toast notifications at the top
/// whenever a new notification is added via [NotificationProvider].
///
/// Usage in app.dart:
/// ```dart
/// MaterialApp.router(
///   builder: (context, child) {
///     return NotificationPopupOverlay(child: child!);
///   },
/// )
/// ```
class NotificationPopupOverlay extends StatefulWidget {
  final Widget child;

  const NotificationPopupOverlay({super.key, required this.child});

  @override
  State<NotificationPopupOverlay> createState() =>
      _NotificationPopupOverlayState();
}

class _NotificationPopupOverlayState extends State<NotificationPopupOverlay> {
  final List<_PopupEntry> _activePopups = [];
  NotificationModel? _lastSeenPopup;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkForNewPopup();
  }

  void _checkForNewPopup() {
    final provider = context.read<NotificationProvider>();
    final latest = provider.latestPopup;
    if (latest != null && latest != _lastSeenPopup) {
      _lastSeenPopup = latest;
      provider.clearLatestPopup();
      _showPopup(latest);
    }
  }

  void _showPopup(NotificationModel notification) {
    // Limit to 2 visible popups — remove the oldest if needed.
    if (_activePopups.length >= 2) {
      _dismissPopup(_activePopups.first.id);
    }

    final entry = _PopupEntry(
      id: notification.id,
      notification: notification,
    );

    setState(() {
      _activePopups.add(entry);
    });

    // Auto-dismiss after 4 seconds
    entry.dismissTimer = Timer(const Duration(seconds: 4), () {
      _dismissPopup(entry.id);
    });
  }

  void _dismissPopup(String id) {
    final idx = _activePopups.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    _activePopups[idx].dismissTimer?.cancel();
    setState(() {
      _activePopups.removeAt(idx);
    });
  }

  void _onPopupTap(String id) {
    _dismissPopup(id);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const NotificationCenterScreen(),
      ),
    );
  }

  @override
  void dispose() {
    for (final entry in _activePopups) {
      entry.dismissTimer?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for changes to trigger popup check
    context.watch<NotificationProvider>();

    // Check after build frame to catch new notifications
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _checkForNewPopup();
    });

    return Stack(
      children: [
        // The actual app content
        widget.child,
        // Popup toasts at the top — wrapped in Material to avoid yellow
        // underlines (no DefaultTextStyle ancestor outside Scaffold).
        if (_activePopups.isNotEmpty)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8.h,
            left: 0,
            right: 0,
            child: Material(
              type: MaterialType.transparency,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _activePopups.map((entry) {
                  return _AnimatedPopup(
                    key: ValueKey(entry.id),
                    entry: entry,
                    onDismiss: () => _dismissPopup(entry.id),
                    onTap: () => _onPopupTap(entry.id),
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _PopupEntry {
  final String id;
  final NotificationModel notification;
  Timer? dismissTimer;

  _PopupEntry({required this.id, required this.notification});
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated popup wrapper — slide down + fade in, swipe up to dismiss
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedPopup extends StatefulWidget {
  final _PopupEntry entry;
  final VoidCallback onDismiss;
  final VoidCallback onTap;

  const _AnimatedPopup({
    super.key,
    required this.entry,
    required this.onDismiss,
    required this.onTap,
  });

  @override
  State<_AnimatedPopup> createState() => _AnimatedPopupState();
}

class _AnimatedPopupState extends State<_AnimatedPopup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Dismissible(
          key: ValueKey('popup_dismiss_${widget.entry.id}'),
          direction: DismissDirection.up,
          onDismissed: (_) => widget.onDismiss(),
          child: Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: NotificationPopupCard(
              notification: widget.entry.notification,
              onTap: widget.onTap,
              onDismiss: widget.onDismiss,
            ),
          ),
        ),
      ),
    );
  }
}
