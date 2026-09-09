import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/platform_utils.dart' as pu;
import '../../data/remote/models/session_dto.dart';
import '../../data/remote/repositories/session_repository.dart';
import '../../shared/widgets/accent_button.dart';
import '../../shared/widgets/loop_header.dart';
import '../../shared/widgets/record_button.dart';
import '../../shared/widgets/timer_display.dart';
import '../auth/auth_notifier.dart';
import '../session/session_notifier.dart';

enum _Phase { idle, recording, done }

final sessionRepoProvider = Provider<SessionRepository>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});

class RecordScreen extends ConsumerStatefulWidget {
  const RecordScreen({super.key});

  @override
  ConsumerState<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends ConsumerState<RecordScreen>
    with SingleTickerProviderStateMixin {
  final _recorder = AudioRecorder();
  CameraController? _cameraController;
  _Phase _phase = _Phase.idle;
  pu.RecordMode _mode = pu.RecordMode.audio;
  int _remaining = 60;
  Timer? _timer;
  String? _fileName;
  String? _audioFilePath;
  DateTime? _recordedAt;
  String? _permissionError;
  bool _sessionLogged = false;
  String? _sessionId;
  bool _analyzing = false;
  String? _analyzeError;
  bool _skippedAnalyze = false;
  SessionDto? _analyzedSession;
  late AnimationController _dotPulse;

  @override
  void initState() {
    super.initState();
    _dotPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    _cameraController?.dispose();
    _dotPulse.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (_mode == pu.RecordMode.video) {
      await _startVideoRecording();
    } else {
      await _startAudioRecording();
    }
  }

  Future<void> _startAudioRecording() async {
    final micGranted = await Permission.microphone.request();
    if (!micGranted.isGranted) {
      setState(
          () => _permissionError = 'Microphone access is required to record.');
      return;
    }
    setState(() => _permissionError = null);

    final dir = await getTemporaryDirectory();
    final name = pu.recordingFileName(
        ref.read(sessionProvider).currentTopic ?? 'session', _mode);
    final path = '${dir.path}/$name';

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );

    _fileName = name;
    _audioFilePath = path;
    _beginTimer();
  }

  Future<void> _startVideoRecording() async {
    final statuses = await [Permission.camera, Permission.microphone].request();
    final granted = statuses.values.every((s) => s.isGranted);
    if (!granted) {
      setState(() => _permissionError =
          'Camera and microphone access are required to record video.');
      return;
    }
    setState(() => _permissionError = null);

    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      setState(() => _permissionError = 'No camera available on this device.');
      return;
    }

    final controller = CameraController(
      cameras.first,
      ResolutionPreset.medium,
      enableAudio: true,
    );
    await controller.initialize();
    await controller.prepareForVideoRecording();
    await controller.startVideoRecording();

    if (!mounted) {
      await controller.dispose();
      return;
    }

    _cameraController = controller;
    _fileName = pu.recordingFileName(
        ref.read(sessionProvider).currentTopic ?? 'session', _mode);
    _beginTimer();
  }

  void _beginTimer() {
    _recordedAt = DateTime.now();
    _remaining = 60;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining <= 0) {
        _stopRecording();
      } else {
        setState(() => _remaining--);
      }
    });

    setState(() => _phase = _Phase.recording);
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();

    String? saved;
    if (_mode == pu.RecordMode.video && _cameraController != null) {
      final file = await _cameraController!.stopVideoRecording();
      saved = file.path;
      await _cameraController!.dispose();
      _cameraController = null;
    } else {
      saved = await _recorder.stop();
    }
    if (saved != null) {
      await pu.saveRecording(saved, _mode);
    }

    final auth = ref.read(authProvider);
    final session = ref.read(sessionProvider);
    var logged = false;
    String? sessionId;
    if (auth.isAuthenticated && session.selectedArea != null) {
      try {
        final created = await ref.read(sessionRepoProvider).logSession(
              areaId: session.selectedArea!.id,
              topic: session.currentTopic ?? '',
              mode: _mode == pu.RecordMode.audio ? 'AUDIO' : 'VIDEO',
              completedAt: _recordedAt ?? DateTime.now(),
            );
        logged = true;
        sessionId = created.id;
      } catch (_) {
        // logged stays false — the done screen reflects this honestly
        // rather than claiming a save that didn't happen.
      }
    }

    setState(() {
      _phase = _Phase.done;
      _remaining = 0;
      _sessionLogged = logged;
      _sessionId = sessionId;
    });
  }

  Future<void> _handleAnalyze() async {
    final sessionId = _sessionId;
    final audioPath = _audioFilePath;
    if (sessionId == null || audioPath == null) return;
    setState(() {
      _analyzing = true;
      _analyzeError = null;
    });
    try {
      final result = await ref.read(sessionRepoProvider).analyzeSession(
            sessionId: sessionId,
            audioFilePath: audioPath,
          );
      if (!mounted) return;
      setState(() => _analyzedSession = result);
    } catch (_) {
      if (!mounted) return;
      setState(() => _analyzeError = 'Analysis failed. You can retry.');
    } finally {
      if (mounted) setState(() => _analyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final topic = session.currentTopic ?? '';
    final area = session.selectedArea;

    if (_phase == _Phase.recording) return _buildRecording(topic);

    if (_phase == _Phase.done) return _buildDone(topic, area?.name ?? '');

    return _buildIdle(topic, area);
  }

  Widget _buildIdle(String topic, dynamic area) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LoopHeader(step: 3, label: 'REC'),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (area != null)
                    Text('${area.abbreviation} · ${area.name.toUpperCase()}',
                        style: AppTypography.label()),
                  const SizedBox(height: 6),
                  Text(topic, style: AppTypography.headline(fontSize: 22)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: TimerDisplay(seconds: _remaining),
            ),
            const SizedBox(height: 24),
            // AUDIO / VIDEO toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _ModeTab(
                    label: 'AUDIO',
                    active: _mode == pu.RecordMode.audio,
                    onTap: () => setState(() {
                      _mode = pu.RecordMode.audio;
                      _permissionError = null;
                    }),
                  ),
                  const SizedBox(width: 8),
                  _ModeTab(
                    label: 'VIDEO',
                    active: _mode == pu.RecordMode.video,
                    onTap: () => setState(() {
                      _mode = pu.RecordMode.video;
                      _permissionError = null;
                    }),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Center(
              child: RecordButton(
                state: RecordButtonState.idle,
                onTap: _startRecording,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Tap to record · one take, sixty seconds',
                style: AppTypography.mono(
                    fontSize: 12, color: AppColors.textMuted),
              ),
            ),
            if (_permissionError != null) ...[
              const SizedBox(height: 8),
              Center(
                child: Text(
                  _permissionError!,
                  style:
                      AppTypography.body(fontSize: 12, color: AppColors.error),
                ),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildRecording(String topic) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    children: [
                      FadeTransition(
                        opacity: _dotPulse,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'RECORDING · ${_mode == pu.RecordMode.audio ? "AUDIO" : "VIDEO"}',
                        style: AppTypography.label(color: AppColors.accent),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Center(
                  child: Text(topic,
                      style: AppTypography.body(
                          fontSize: 13, color: AppColors.textMuted)),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TimerDisplay(
                    seconds: _remaining,
                    fontSize: MediaQuery.of(context).size.width * 0.22,
                  ),
                ),
                const Spacer(),
                Center(
                  child: RecordButton(
                    state: RecordButtonState.recording,
                    onTap: _stopRecording,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text('Tap to stop',
                      style: AppTypography.mono(
                          fontSize: 12, color: AppColors.textMuted)),
                ),
                const SizedBox(height: 32),
              ],
            ),
            if (_mode == pu.RecordMode.video &&
                _cameraController != null &&
                _cameraController!.value.isInitialized)
              Positioned(
                left: 20,
                bottom: 20,
                child: ClipRect(
                  child: SizedBox(
                    width: 120,
                    height: 160,
                    child: CameraPreview(_cameraController!),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDone(String topic, String areaName) {
    final isAuth = ref.read(authProvider).isAuthenticated;
    final date = _recordedAt != null
        ? '${_monthName(_recordedAt!.month)} ${_recordedAt!.day}, ${_recordedAt!.year} · ${_recordedAt!.hour.toString().padLeft(2, '0')}:${_recordedAt!.minute.toString().padLeft(2, '0')}'
        : '';

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LoopHeader(step: 4, label: 'DONE'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(
                        Icons.check,
                        color: (!isAuth || _sessionLogged)
                            ? AppColors.accent
                            : AppColors.textMuted,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        (!isAuth || _sessionLogged)
                            ? 'SESSION SAVED'
                            : 'SAVED LOCALLY',
                        style: AppTypography.label(
                          color: (!isAuth || _sessionLogged)
                              ? AppColors.accent
                              : AppColors.textMuted,
                        ),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    Text(topic, style: AppTypography.display(fontSize: 36)),
                    const SizedBox(height: 20),
                    const Divider(color: AppColors.border),
                    _MetaRow('Area', areaName),
                    const Divider(color: AppColors.border),
                    _MetaRow('Recorded', date),
                    const Divider(color: AppColors.border),
                    _MetaRow('Format',
                        '${_mode == pu.RecordMode.audio ? "Audio" : "Video"} · 01:00'),
                    const Divider(color: AppColors.border),
                    if (_fileName != null) _MetaRow('File', _fileName!),
                    if (_fileName != null)
                      const Divider(color: AppColors.border),
                    const SizedBox(height: 12),
                    Text(
                      !isAuth
                          ? 'Saved to your device. Nothing uploaded.'
                          : _sessionLogged
                              ? 'Saved to device. Session logged.'
                              : 'Saved to device, but the session could not be synced to your account.',
                      style: AppTypography.mono(
                          fontSize: 12, color: AppColors.textMuted),
                    ),
                    if (isAuth && _sessionLogged) ...[
                      const SizedBox(height: 24),
                      _buildAnalyzeSection(),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                children: [
                  AccentButton(
                    label: 'START AGAIN →',
                    onTap: () {
                      setState(() {
                        _phase = _Phase.idle;
                        _remaining = 60;
                        _fileName = null;
                        _audioFilePath = null;
                        _recordedAt = null;
                        _sessionLogged = false;
                        _sessionId = null;
                        _analyzing = false;
                        _analyzeError = null;
                        _skippedAnalyze = false;
                        _analyzedSession = null;
                        _permissionError = null;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        ref.read(sessionProvider.notifier).resetSession();
                        context.go('/');
                      },
                      child: Text('NEW SPIN →',
                          style: AppTypography.label(
                              color: AppColors.textMuted)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: GestureDetector(
                      onTap: () => context.push('/history'),
                      child: Text('VIEW HISTORY',
                          style: AppTypography.label(
                              color: AppColors.textMuted)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyzeSection() {
    if (_mode != pu.RecordMode.audio) {
      return Text(
        'Speech analysis is available for audio recordings.',
        style: AppTypography.mono(fontSize: 12, color: AppColors.textMuted),
      );
    }

    if (_analyzedSession != null) {
      return _AnalysisResult(session: _analyzedSession!);
    }

    if (_skippedAnalyze) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AccentButton(
          label: _analyzing ? 'Analyzing…' : 'ANALYZE →',
          onTap: _handleAnalyze,
          loading: _analyzing,
        ),
        if (_analyzing) ...[
          const SizedBox(height: 8),
          Text('This can take up to 15s.',
              style: AppTypography.mono(
                  fontSize: 12, color: AppColors.textMuted)),
        ],
        if (_analyzeError != null) ...[
          const SizedBox(height: 8),
          Text(_analyzeError!,
              style: AppTypography.body(fontSize: 12, color: AppColors.error)),
        ],
        if (!_analyzing) ...[
          const SizedBox(height: 12),
          Center(
            child: GestureDetector(
              onTap: () => setState(() => _skippedAnalyze = true),
              child: Text('Skip',
                  style: AppTypography.label(color: AppColors.textMuted)),
            ),
          ),
        ],
      ],
    );
  }

  String _monthName(int m) => const [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ][m];
}

class _ModeTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _ModeTab(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          color: active ? AppColors.accent : AppColors.surface,
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTypography.label(
                color: active ? AppColors.background : AppColors.textMuted),
          ),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;
  const _MetaRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Text(label,
              style:
                  AppTypography.body(fontSize: 13, color: AppColors.textMuted)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: AppTypography.mono(fontSize: 13),
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalysisResult extends StatelessWidget {
  final SessionDto session;
  const _AnalysisResult({required this.session});

  @override
  Widget build(BuildContext context) {
    final stats = <String, String>{
      'Filler words': '${session.fillerWordCount ?? "-"}',
      'Pace': '${session.wordsPerMinute ?? "-"} wpm',
      'Coherence': '${session.coherenceScore ?? "-"}/10',
      'Grammar': '${session.grammarScore ?? "-"}/10',
      'Content accuracy': '${session.contentAccuracyScore ?? "-"}/10',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: AppColors.border),
        const SizedBox(height: 16),
        Wrap(
          spacing: 24,
          runSpacing: 16,
          children: stats.entries
              .map((e) => SizedBox(
                    width: 140,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.value, style: AppTypography.display(fontSize: 22)),
                        const SizedBox(height: 4),
                        Text(e.key,
                            style: AppTypography.mono(
                                fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ),
                  ))
              .toList(),
        ),
        if (session.feedbackSummary != null) ...[
          const SizedBox(height: 20),
          Text(session.feedbackSummary!,
              style: AppTypography.body(fontSize: 14)),
        ],
        if (session.transcript != null) ...[
          const SizedBox(height: 16),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(bottom: 12),
              title: Text('TRANSCRIPT', style: AppTypography.label()),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    session.transcript!,
                    style: AppTypography.body(
                        fontSize: 13, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
