import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../app/theme.dart';
import '../data/sessions_provider.dart';
import '../data/task.dart';
import '../data/task_provider.dart';
import '../services/focus_notification.dart';
import '../utils/time_format.dart';
import '../widgets/press_button.dart';

/// Focus Mode — plein écran sombre, distraction-free.
/// • Timer MM:SS pausable
/// • Anneaux qui respirent (animation 6s)
/// • Music widget : "Pluie en forêt" (audioplayers, loop sur l'asset audio fourni)
/// • Bouton « Terminer la session » qui logue la durée et revient à l'accueil
/// • Notification ongoing sur l'écran de verrouillage avec boutons Pause / Terminer
class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key, required this.task});

  final Task task;

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> with TickerProviderStateMixin {
  Timer? _ticker;
  int _seconds = 0;
  bool _paused = false;
  late final DateTime _sessionStartedAt;
  StreamSubscription<FocusNotifAction>? _notifSub;

  late final AnimationController _breath;
  late final AudioPlayer _player;
  bool _musicPlaying = true;
  bool _muted = false;

  static const _audioAsset = 'audio/drawingsample1.mp3';

  @override
  void initState() {
    super.initState();
    _sessionStartedAt = DateTime.now();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    _breath = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _player = AudioPlayer();
    _player.setReleaseMode(ReleaseMode.loop);
    _startMusic();

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_paused) return;
      setState(() => _seconds += 1);
      // Met à jour la notif chaque seconde (silencieuse via onlyAlertOnce).
      _refreshNotif();
    });

    // Demande la perm de notif (Android 13+) puis pose la notif initiale.
    Future.microtask(() async {
      await FocusNotificationService.requestPermission();
      await _refreshNotif();
    });

    // Écoute les actions de la notif (taps sur Pause / Terminer).
    _notifSub = FocusNotificationService.actions.listen(_handleNotifAction);
  }

  Future<void> _refreshNotif() => FocusNotificationService.show(
        taskTitle: widget.task.title,
        elapsedSec: _seconds,
        paused: _paused,
      );

  Future<void> _handleNotifAction(FocusNotifAction action) async {
    switch (action) {
      case FocusNotifAction.pauseOrResume:
        await _togglePause();
        break;
      case FocusNotifAction.stop:
        if (mounted) _pauseAndExit(); // tap Terminer sur notif = pause, pas done
        break;
    }
  }

  Future<void> _togglePause() async {
    setState(() => _paused = !_paused);
    if (_paused) {
      // Pause aussi la musique pour cohérence
      await _player.pause();
      setState(() => _musicPlaying = false);
    } else {
      await _player.resume();
      setState(() => _musicPlaying = true);
    }
    await _refreshNotif();
  }

  Future<void> _startMusic() async {
    try {
      await _player.play(AssetSource(_audioAsset));
    } catch (_) {
      // Si l'audio n'est pas disponible, on garde simplement l'UI sans bloquer.
    }
  }

  Future<void> _toggleMusic() async {
    setState(() => _musicPlaying = !_musicPlaying);
    if (_musicPlaying) {
      await _player.resume();
    } else {
      await _player.pause();
    }
  }

  Future<void> _toggleMute() async {
    setState(() => _muted = !_muted);
    await _player.setVolume(_muted ? 0 : 1);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _notifSub?.cancel();
    _breath.dispose();
    _player.dispose();
    FocusNotificationService.dismiss();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    super.dispose();
  }

  /// Log la session, n'affecte pas le statut. La tâche reste active.
  Future<void> _pauseAndExit() async {
    if (_seconds > 0) {
      await context
          .read<SessionsProvider>()
          .log(
            taskId: widget.task.id,
            startedAt: _sessionStartedAt,
            durationSeconds: _seconds,
          );
      await context.read<TaskProvider>().logSession(widget.task.id, _seconds);
    }
    if (mounted) Navigator.of(context).pop();
  }

  /// Log la session ET marque la tâche comme terminée.
  Future<void> _finishDone() async {
    if (_seconds > 0) {
      await context
          .read<SessionsProvider>()
          .log(
            taskId: widget.task.id,
            startedAt: _sessionStartedAt,
            durationSeconds: _seconds,
          );
      await context.read<TaskProvider>().logSession(widget.task.id, _seconds);
    }
    await context
        .read<TaskProvider>()
        .setStatus(widget.task.id, TaskStatus.done);
    if (mounted) Navigator.of(context).pop();
  }

  /// Annule sans rien logger.
  void _cancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.focusBg,
      body: Stack(
        children: [
          // Halo central animé
          AnimatedBuilder(
            animation: _breath,
            builder: (_, __) {
              final t = Curves.easeInOut.transform(_breath.value);
              final scale = 1.0 + 0.08 * t;
              return Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Transform.translate(
                    offset: const Offset(0, -40),
                    child: Container(
                      width: 460 * scale,
                      height: 460 * scale,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.focusGlow,
                            AppColors.focusBg.withOpacity(0),
                          ],
                          stops: const [0, 0.65],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PressButton(
                        semanticLabel: 'Annuler la session',
                        onTap: _cancel,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0x0FFFFFFF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 20,
                            color: AppColors.focusInkSoft,
                          ),
                        ),
                      ),
                      Text(
                        _paused
                            ? 'SESSION EN PAUSE'
                            : 'SESSION DE CONCENTRATION',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.6,
                          color: AppColors.focusMuted,
                        ),
                      ),
                      // Bouton Pause/Reprendre intégré dans la top bar
                      PressButton(
                        semanticLabel: _paused ? 'Reprendre' : 'Pause',
                        onTap: _togglePause,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0x0FFFFFFF),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _paused
                                ? Icons.play_arrow_rounded
                                : Icons.pause_rounded,
                            size: 20,
                            color: AppColors.focusInk,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Center
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'EN COURS SUR',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.6,
                            color: AppColors.focusMuted,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 280),
                          child: Text(
                            widget.task.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                              letterSpacing: -0.21,
                              color: AppColors.focusInk,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Anneaux + timer
                        SizedBox(
                          width: 320,
                          height: 320,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              _BreathingRing(
                                size: 280,
                                color: AppColors.focusRing,
                                controller: _breath,
                              ),
                              _BreathingRing(
                                size: 320,
                                color: AppColors.focusRingFaint,
                                controller: _breath,
                                phaseShift: 0.5,
                              ),
                              Container(
                                width: 320,
                                height: 320,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.focusTimerGlow,
                                      blurRadius: 60,
                                      spreadRadius: -20,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  formatMMSS(_seconds),
                                  style: TextStyle(
                                    fontSize: 76,
                                    fontWeight: FontWeight.w300,
                                    letterSpacing: -3,
                                    color: _paused
                                        ? AppColors.focusTimer.withOpacity(0.55)
                                        : AppColors.focusTimer,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures()
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        _MusicWidget(
                          playing: _musicPlaying,
                          muted: _muted,
                          onTogglePlay: _toggleMusic,
                          onToggleMute: _toggleMute,
                        ),
                      ],
                    ),
                  ),
                ),

                // Actions de fin de session : Pause + C'est plié !
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    children: [
                      // C'est plié ! (action primaire, accent vert glow)
                      PressButton(
                        onTap: _finishDone,
                        child: Container(
                          width: double.infinity,
                          height: 60,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.focusAccent,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.focusTimerGlow,
                                blurRadius: 40,
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_rounded,
                                  color: AppColors.focusBg, size: 22),
                              SizedBox(width: 8),
                              Text(
                                "C'est plié !",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.17,
                                  color: AppColors.focusBg,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Pause, je reprendrai (action secondaire, ghost)
                      PressButton(
                        onTap: _pauseAndExit,
                        child: Container(
                          width: double.infinity,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0x0DFFFFFF),
                            border: Border.all(color: AppColors.focusRing),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'Pause, je reprendrai',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.15,
                              color: AppColors.focusInkSoft,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BreathingRing extends StatelessWidget {
  const _BreathingRing({
    required this.size,
    required this.color,
    required this.controller,
    this.phaseShift = 0,
  });

  final double size;
  final Color color;
  final AnimationController controller;
  final double phaseShift;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final v = ((controller.value + phaseShift) % 1);
        final t = Curves.easeInOut.transform(v < 0.5 ? v * 2 : (1 - v) * 2);
        final scale = 1.0 + 0.06 * t;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 1),
            ),
          ),
        );
      },
    );
  }
}

class _MusicWidget extends StatelessWidget {
  const _MusicWidget({
    required this.playing,
    required this.muted,
    required this.onTogglePlay,
    required this.onToggleMute,
  });

  final bool playing;
  final bool muted;
  final VoidCallback onTogglePlay;
  final VoidCallback onToggleMute;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 14, 10),
      decoration: BoxDecoration(
        color: const Color(0x0DFFFFFF),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.focusRing),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.music_note_rounded,
              color: AppColors.focusAccent, size: 16),
          const SizedBox(width: 10),
          const Text(
            'Pluie en forêt',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.focusInk,
              letterSpacing: -0.13,
            ),
          ),
          const SizedBox(width: 12),
          _Waveform(playing: playing, color: AppColors.focusAccent),
          const SizedBox(width: 12),
          PressButton(
            semanticLabel: playing ? 'Pause' : 'Lecture',
            onTap: onTogglePlay,
            child: Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: Color(0x14FFFFFF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                size: 16,
                color: AppColors.focusInk,
              ),
            ),
          ),
          const SizedBox(width: 4),
          PressButton(
            semanticLabel: muted ? 'Activer le son' : 'Couper le son',
            onTap: onToggleMute,
            child: Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              child: Icon(
                muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                size: 16,
                color: muted ? AppColors.focusMuted : AppColors.focusInk,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Waveform extends StatefulWidget {
  const _Waveform({required this.playing, required this.color});
  final bool playing;
  final Color color;

  @override
  State<_Waveform> createState() => _WaveformState();
}

class _WaveformState extends State<_Waveform>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 14,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(5, (i) {
              double h;
              if (widget.playing) {
                final phase = (_ctrl.value + i * 0.12) % 1;
                final s = (phase < 0.5 ? phase * 2 : (1 - phase) * 2);
                h = 4 + 8 * Curves.easeInOut.transform(s);
              } else {
                h = 3;
              }
              return Container(
                width: 2,
                height: h,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(widget.playing ? 1 : 0.4),
                  borderRadius: BorderRadius.circular(1),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
