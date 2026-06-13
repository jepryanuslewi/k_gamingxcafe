import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:k_gamingxcafe/services/nontifikasi_service.dart';

class NotifikasiOverlay extends StatefulWidget {
  final Widget child;
  const NotifikasiOverlay({super.key, required this.child});

  @override
  State<NotifikasiOverlay> createState() => _NotifikasiOverlayState();
}

class _NotifikasiOverlayState extends State<NotifikasiOverlay> {
  final List<OverlayEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    NontifikasiService().onNotification = _showNotif;
  }

  @override
  void dispose() {
    NontifikasiService().onNotification = null;

    for (final e in _entries) {
      e.remove();
    }
    _entries.clear();
    super.dispose();
  }

  void _showNotif(NotifPayload payload) {
    if (!mounted) return;

    final player = AudioPlayer();
    final source = AssetSource('sounds/notif.mp3');

    Future<void> loopSound() async {
      while (true) {
        try {
          await player.play(source);

          await player.onPlayerComplete.first;
        } catch (_) {
          break;
        }
      }
    }

    loopSound();

    final topOffset = 20.0 + (_entries.length * 100.0);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _NotifCardOverlay(
        payload: payload,
        topOffset: topOffset,
        onDismiss: () async {
          await player.stop();
          await player.dispose();
          entry.remove();
          _entries.remove(entry);

          NontifikasiService().scheduleRenotif(payload.jadwalId);
        },
      ),
    );

    _entries.add(entry);
    Overlay.of(context).insert(entry);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _NotifCardOverlay extends StatefulWidget {
  final NotifPayload payload;
  final double topOffset;
  final Future<void> Function() onDismiss;

  const _NotifCardOverlay({
    required this.payload,
    required this.topOffset,
    required this.onDismiss,
  });

  @override
  State<_NotifCardOverlay> createState() => _NotifCardOverlayState();
}

class _NotifCardOverlayState extends State<_NotifCardOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(_animCtrl);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _animatedDismiss() async {
    await _animCtrl.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    const Color accentColor = Colors.redAccent;
    const IconData icon = Icons.timer_off_rounded;
    const String title = '⛔ WAKTU HABIS!';
    final String sisaText =
        'Sesi ${widget.payload.customerName} telah berakhir.';

    return Positioned(
      top: widget.topOffset,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: _slideAnim,
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Container(
              width: 320,
              decoration: BoxDecoration(
                color: const Color(0xFF141C2F),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: accentColor, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.25),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Accent bar kiri
                  Container(
                    width: 6,
                    height: 80,
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        bottomLeft: Radius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Icon(icon, color: accentColor, size: 28),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            sisaText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF00E0C6,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF00E0C6,
                                    ).withOpacity(0.4),
                                    width: 0.5,
                                  ),
                                ),
                                child: Text(
                                  widget.payload.category,
                                  style: const TextStyle(
                                    color: Color(0xFF00E0C6),
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                widget.payload.packageOrUnit,
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _animatedDismiss,
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.close, color: Colors.white30, size: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
