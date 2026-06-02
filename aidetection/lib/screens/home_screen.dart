import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../services/prediction_provider.dart';
import '../widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      setState(() => _charCount = _ctrl.text.length);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _analyze() {
    if (_ctrl.text.trim().length < 10) return;
    FocusScope.of(context).unfocus();
    context.read<PredictionProvider>().predict(_ctrl.text);
    // Scroll down after a short delay to reveal results
    Future.delayed(const Duration(milliseconds: 600), () {
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    });
  }

  void _clear() {
    _ctrl.clear();
    context.read<PredictionProvider>().reset();
  }

  void _fillSample(String text) {
    _ctrl.text = text;
    _ctrl.selection = TextSelection.collapsed(offset: text.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Consumer<PredictionProvider>(
        builder: (context, provider, _) {
          return CustomScrollView(
            controller: _scroll,
            slivers: [
              // ── App Bar ──────────────────────────────────
              SliverAppBar(
                pinned: true,
                backgroundColor: AppTheme.bg.withOpacity(0.95),
                elevation: 0,
                expandedHeight: 0,
                toolbarHeight: 60,
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppTheme.line)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Text(
                        'Veritas',
                        style: GoogleFonts.instrumentSerif(
                          fontSize: 22,
                          fontStyle: FontStyle.italic,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppTheme.accent.withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          'v1.0',
                          style: GoogleFonts.dmMono(
                            fontSize: 10,
                            color: AppTheme.accent,
                            letterSpacing: 0.06,
                          ),
                        ),
                      ),
                      const Spacer(),
                      ServerBadge(online: provider.isServerOnline),
                      const SizedBox(width: 12),
                      // Download button
                      _DownloadButton(
                        loading: provider.isDownloading,
                        onTap: () => provider.downloadData(),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Content ──────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero
                      _Hero().animate().fadeIn(duration: 500.ms),

                      const SizedBox(height: 40),

                      // Sample buttons
                      _SampleButtons(
                        onSelect: _fillSample,
                      ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

                      const SizedBox(height: 20),

                      // Input card
                      _InputCard(
                        controller: _ctrl,
                        charCount: _charCount,
                        onAnalyze: _analyze,
                        onClear: _clear,
                        isLoading: provider.state == PredictionState.loading,
                      ).animate(delay: 150.ms).fadeIn(duration: 400.ms),

                      // Error
                      if (provider.state == PredictionState.error &&
                          provider.errorMessage != null) ...[
                        const SizedBox(height: 16),
                        ErrorBanner(
                          message: provider.errorMessage!,
                          onDismiss: provider.reset,
                        ),
                      ],

                      // Results
                      if (provider.state == PredictionState.success &&
                          provider.result != null) ...[
                        const SizedBox(height: 28),
                        _Results(result: provider.result!),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Hero section ─────────────────────────────────────────────
class _Hero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 32, height: 1, color: AppTheme.line2),
            const SizedBox(width: 8),
            Text(
              'LINGUISTIC INTELLIGENCE',
              style: GoogleFonts.dmMono(
                fontSize: 10,
                letterSpacing: 0.1,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(width: 8),
            Container(width: 32, height: 1, color: AppTheme.line2),
          ],
        ),
        const SizedBox(height: 20),
        RichText(
          text: TextSpan(
            style: GoogleFonts.instrumentSerif(
              fontSize: 40,
              height: 1.05,
              letterSpacing: -1.0,
              color: AppTheme.textPrimary,
            ),
            children: [
              const TextSpan(text: 'Is this '),
              TextSpan(
                text: 'written',
                style: GoogleFonts.instrumentSerif(
                  fontSize: 40,
                  height: 1.05,
                  fontStyle: FontStyle.italic,
                  color: AppTheme.accent,
                ),
              ),
              const TextSpan(text: '\nby a machine?'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Paste any text and Veritas will analyze its linguistic\npatterns using your fine-tuned transformer model.',
          style: GoogleFonts.syne(
            fontSize: 14,
            height: 1.65,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ── Sample buttons ────────────────────────────────────────────
class _SampleButtons extends StatelessWidget {
  final void Function(String) onSelect;

  const _SampleButtons({required this.onSelect});

  static const _samples = {
    'AI sample':
        'Furthermore, it is important to note that the implementation of artificial intelligence in modern workflows presents significant opportunities. In conclusion, organizations must carefully consider these factors to ensure optimal outcomes. Moreover, this comprehensive analysis demonstrates the multifaceted nature of technological integration in contemporary business environments.',
    'Human sample':
        "So I finally tried making sourdough last weekend. Honestly? Total disaster. The dough was sticky as hell and I didn't let it ferment long enough because I was impatient. It came out flat and dense but weirdly still tasted okay? Gonna try again this week.",
    'Mixed':
        'The research findings indicate that sleep deprivation significantly impacts cognitive performance. I remember reading this and thinking — wow, that explains so much about my college years. Furthermore, the data demonstrates a strong correlation between sleep quality and emotional regulation.',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MonoLabel('Try a sample —'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _samples.entries.map((e) {
            return _SampleChip(label: e.key, onTap: () => onSelect(e.value));
          }).toList(),
        ),
      ],
    );
  }
}

class _SampleChip extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _SampleChip({required this.label, required this.onTap});

  @override
  State<_SampleChip> createState() => _SampleChipState();
}

class _SampleChipState extends State<_SampleChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: _hovered ? AppTheme.accent.withOpacity(0.06) : AppTheme.bg3,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: _hovered
                  ? AppTheme.accent.withOpacity(0.4)
                  : AppTheme.line2,
            ),
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.dmMono(
              fontSize: 11,
              letterSpacing: 0.06,
              color: _hovered ? AppTheme.accent : AppTheme.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Input card ────────────────────────────────────────────────
class _InputCard extends StatelessWidget {
  final TextEditingController controller;
  final int charCount;
  final VoidCallback onAnalyze;
  final VoidCallback onClear;
  final bool isLoading;

  const _InputCard({
    required this.controller,
    required this.charCount,
    required this.onAnalyze,
    required this.onClear,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bg2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.line),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
            child: Row(
              children: [
                const MonoLabel('Input Text'),
                const Spacer(),
                Text(
                  '$charCount characters',
                  style: GoogleFonts.dmMono(
                    fontSize: 11,
                    color: charCount > 0 ? AppTheme.accent : AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppTheme.line),

          // Textarea
          TextField(
            controller: controller,
            maxLines: 8,
            style: GoogleFonts.syne(
              fontSize: 14,
              height: 1.7,
              color: AppTheme.textPrimary,
            ),
            decoration: InputDecoration(
              hintText:
                  'Paste or type your text here…\n(minimum 10 characters for analysis)',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              contentPadding: const EdgeInsets.all(20),
            ),
          ),

          Divider(height: 1, color: AppTheme.line),

          // Footer
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Longer texts yield more accurate results',
                    style: GoogleFonts.syne(
                      fontSize: 13,
                      color: AppTheme.textMuted,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (charCount > 0) ...[
                  GestureDetector(
                    onTap: onClear,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.line2),
                      ),
                      child: Text(
                        'Clear',
                        style: GoogleFonts.syne(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
                _AnalyzeButton(
                  enabled: charCount >= 10 && !isLoading,
                  loading: isLoading,
                  onTap: onAnalyze,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyzeButton extends StatefulWidget {
  final bool enabled;
  final bool loading;
  final VoidCallback onTap;

  const _AnalyzeButton({
    required this.enabled,
    required this.loading,
    required this.onTap,
  });

  @override
  State<_AnalyzeButton> createState() => _AnalyzeButtonState();
}

class _AnalyzeButtonState extends State<_AnalyzeButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        if (widget.enabled) widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed && widget.enabled ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedOpacity(
          opacity: widget.enabled ? 1.0 : 0.4,
          duration: const Duration(milliseconds: 200),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.accent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.loading)
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.bg,
                    ),
                  )
                else ...[
                  Text(
                    'Analyze',
                    style: GoogleFonts.syne(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.bg,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text('→', style: TextStyle(fontSize: 14, color: AppTheme.bg)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Results section ───────────────────────────────────────────
class _Results extends StatelessWidget {
  final result;
  const _Results({required this.result});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MonoLabel('Analysis Result'),
        const SizedBox(height: 16),
        VerdictCard(result: result),
        const SizedBox(height: 12),
        ProbabilityMeter(result: result),
      ],
    );
  }
}

// ── Download button ───────────────────────────────────────────
class _DownloadButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;

  const _DownloadButton({required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.line2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: loading
            ? SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.textMuted,
                ),
              )
            : Row(
                children: [
                  Icon(
                    Icons.download_rounded,
                    size: 15,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Dataset',
                    style: GoogleFonts.syne(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
