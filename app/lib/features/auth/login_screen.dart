import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/accent_button.dart';
import 'auth_notifier.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final String? returnTo;
  const LoginScreen({super.key, this.returnTo});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    await ref.read(authProvider.notifier).login(
          _emailCtrl.text.trim(),
          _passCtrl.text,
        );
    if (!mounted) return;
    final auth = ref.read(authProvider);
    if (auth.isAuthenticated) {
      context.go(widget.returnTo ?? '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () =>
                    context.canPop() ? context.pop() : context.go('/'),
                child: const Icon(
                  Icons.close,
                  color: AppColors.textMuted,
                  size: 22,
                ),
              ),
              const SizedBox(height: 24),
              Text('SIGN IN', style: AppTypography.label(color: AppColors.accent)),
              const SizedBox(height: 12),
              Text('Welcome\nback.', style: AppTypography.display(fontSize: 40)),
              const SizedBox(height: 40),
              Text('EMAIL', style: AppTypography.label()),
              const SizedBox(height: 8),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: AppTypography.mono(fontSize: 15),
                decoration: const InputDecoration(hintText: 'you@domain.com'),
              ),
              const SizedBox(height: 16),
              Text('PASSWORD', style: AppTypography.label()),
              const SizedBox(height: 8),
              TextField(
                controller: _passCtrl,
                obscureText: true,
                style: AppTypography.mono(fontSize: 15),
                onSubmitted: (_) => _submit(),
                decoration: const InputDecoration(hintText: '••••••••'),
              ),
              if (auth.error != null) ...[
                const SizedBox(height: 12),
                Text(auth.error!, style: AppTypography.body(fontSize: 13, color: AppColors.error)),
              ],
              const Spacer(),
              AccentButton(
                label: 'SIGN IN →',
                onTap: _submit,
                loading: auth.loading,
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () => context.pushReplacement('/signup${widget.returnTo != null ? "?returnTo=${widget.returnTo}" : ""}'),
                  child: Text('CREATE ACCOUNT', style: AppTypography.label()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
