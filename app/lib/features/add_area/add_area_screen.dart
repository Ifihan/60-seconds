import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/accent_button.dart';
import '../spin/spin_viewmodel.dart';
import '../areas/areas_viewmodel.dart';

class AddAreaScreen extends ConsumerStatefulWidget {
  const AddAreaScreen({super.key});

  @override
  ConsumerState<AddAreaScreen> createState() => _AddAreaScreenState();
}

class _AddAreaScreenState extends ConsumerState<AddAreaScreen> {
  final _nameCtrl = TextEditingController();
  final _topicsCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _topicsCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Area name is required.');
      return;
    }
    final topics = _topicsCtrl.text
        .split('\n')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    setState(() { _loading = true; _error = null; });
    try {
      final repo = ref.read(areaRepoProvider);
      await repo.createArea(name, topics);
      ref.invalidate(allAreasProvider);
      if (mounted) context.pop();
    } catch (e) {
      setState(() => _error = 'Failed to create area. Try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(Icons.chevron_left, color: AppColors.textMuted, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Text('NEW AREA', style: AppTypography.label(color: AppColors.textPrimary)),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AREA NAME', style: AppTypography.label()),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameCtrl,
                      style: AppTypography.body(),
                      decoration: const InputDecoration(hintText: 'e.g. Computer Science'),
                    ),
                    const SizedBox(height: 20),
                    Text('TOPICS', style: AppTypography.label()),
                    const SizedBox(height: 4),
                    Text('One per line', style: AppTypography.body(fontSize: 12, color: AppColors.textMuted)),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(border: Border.all(color: AppColors.border)),
                        padding: const EdgeInsets.all(12),
                        child: TextField(
                          controller: _topicsCtrl,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          style: AppTypography.mono(fontSize: 13),
                          decoration: InputDecoration.collapsed(
                            hintText: 'TCP/IP and how the internet routes data\nMemory management: stack vs heap\n...',
                            hintStyle: AppTypography.mono(fontSize: 13, color: AppColors.textMuted),
                          ),
                        ),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Text(_error!, style: AppTypography.body(fontSize: 13, color: AppColors.error)),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: AccentButton(label: 'CREATE AREA →', onTap: _submit, loading: _loading),
            ),
          ],
        ),
      ),
    );
  }
}
