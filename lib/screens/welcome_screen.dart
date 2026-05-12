import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/theme.dart';
import '../data/settings_provider.dart';
import '../widgets/momentum_logo.dart';
import '../widgets/press_button.dart';

/// Écran de bienvenue au premier lancement.
/// Demande juste le prénom de l'utilisateur, sans flair commercial.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Petit délai pour que la transition se termine avant d'ouvrir le clavier.
    Future.delayed(const Duration(milliseconds: 450), () {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  bool get _canContinue => _ctrl.text.trim().isNotEmpty;

  void _submit() {
    if (!_canContinue) return;
    context.read<SettingsProvider>().setUserName(_ctrl.text);
    // Pas de Navigator.pop : le Gate détecte que userName est rempli et
    // remplace cet écran par RootScreen automatiquement.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),

              // Logo + wordmark
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const MomentumLogo(size: 28),
                  const SizedBox(width: 10),
                  Text(
                    'Momentum',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),

              const SizedBox(height: 56),

              // Greeting éditorial
              Text(
                'Bienvenue.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 34,
                    ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Avant de commencer,\nappelle-toi comment ?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.5,
                  color: AppColors.inkSoft,
                  height: 1.5,
                  letterSpacing: -0.15,
                ),
              ),

              const SizedBox(height: 36),

              // Input
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.hairline),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                child: TextField(
                  controller: _ctrl,
                  focusNode: _focus,
                  textInputAction: TextInputAction.done,
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _submit(),
                  cursorColor: AppColors.accent,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                    letterSpacing: -0.5,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ton prénom',
                    hintStyle: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: AppColors.muted.withOpacity(0.7),
                      letterSpacing: -0.5,
                    ),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 14),
                    isDense: true,
                  ),
                ),
              ),

              const Spacer(flex: 3),

              // CTA
              PressButton(
                onTap: _canContinue ? _submit : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _canContinue
                        ? AppColors.ink
                        : AppColors.hairline,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Text(
                    'Continuer',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.16,
                      color: _canContinue
                          ? AppColors.surface
                          : AppColors.muted,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'Tu pourras le changer plus tard dans les Réglages.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.muted,
                    letterSpacing: -0.12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
