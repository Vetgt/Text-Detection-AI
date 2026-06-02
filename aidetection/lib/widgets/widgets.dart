import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../theme/app_theme.dart';
import '../models/prediction_result.dart';

// ── Dark card container ─────────────────────────────────────
class DarkCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? borderColor;

  const DarkCard({
    super.key,
    required this.child,
    this.padding,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bg2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor ?? AppTheme.line,
          width: 1,
        ),
      ),
      child: child,
    );
  }
}

// ── Section label (monospace, muted) ───────────────────────
class MonoLabel extends StatelessWidget {
  final String text;
  const MonoLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.dmMono(
        fontSize: 10,
        letterSpacing: 0.1,
        color: AppTheme.textMuted,
      ),
    );
  }
}

// ── Server status badge ─────────────────────────────────────
class ServerBadge extends StatelessWidget {
  final bool online;
  const ServerBadge({super.key, required this.online});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (online ? AppTheme.humanColor : AppTheme.aiColor).withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: (online ? AppTheme.humanColor : AppTheme.aiColor).withOpacity(0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PulseDot(color: online ? AppTheme.humanColor : AppTheme.aiColor),
          const SizedBox(width: 6),
          Text(
            online ? 'API Online' : 'API Offline',
            style: GoogleFonts.dmMono(
              fontSize: 11,
              color: online ? AppTheme.humanColor : AppTheme.aiColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  final Color color;
  const _PulseDot({required this.color});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _anim = Tween(begin: 1.0, end: 0.3).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Opacity(
        opacity: _anim.value,
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

// ── Verdict card ────────────────────────────────────────────
class VerdictCard extends StatelessWidget {
  final PredictionResult result;
  const VerdictCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final isAI = result.isAI;
    final color = isAI ? AppTheme.aiColor : AppTheme.humanColor;
    final lightColor = isAI ? AppTheme.aiLight : AppTheme.humanLight;
    final icon = isAI ? '⚡' : '✦';

    return DarkCard(
      borderColor: color.withOpacity(0.25),
      child: Stack(
        children: [
          // Left accent bar
          Positioned(
            left: -20, top: -20, bottom: -20,
            child: Container(
              width: 3,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(20),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(icon, style: const TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 16),
                // Label + verdict
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MonoLabel('Verdict'),
                      const SizedBox(height: 4),
                      Text(
                        isAI ? 'AI Generated' : 'Human Written',
                        style: GoogleFonts.instrumentSerif(
                          fontSize: 26,
                          fontStyle: FontStyle.italic,
                          color: lightColor,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                // Confidence %
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${result.confidencePct}%',
                      style: GoogleFonts.dmMono(
                        fontSize: 34,
                        fontWeight: FontWeight.w500,
                        color: color,
                        letterSpacing: -1,
                      ),
                    ),
                    Text(
                      'confidence',
                      style: GoogleFonts.dmMono(
                        fontSize: 10,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, duration: 400.ms, curve: Curves.easeOut);
  }
}

// ── Probability meter ───────────────────────────────────────
class ProbabilityMeter extends StatelessWidget {
  final PredictionResult result;
  const ProbabilityMeter({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final aiPct = result.isAI
        ? result.confidence
        : 1 - result.confidence;
    final humanPct = 1 - aiPct;

    return DarkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MonoLabel('Probability Distribution'),
          const SizedBox(height: 16),
          // AI bar
          _Bar(
            label: 'AI',
            percent: aiPct,
            color: AppTheme.aiColor,
          ),
          const SizedBox(height: 10),
          // Human bar
          _Bar(
            label: 'Human',
            percent: humanPct,
            color: AppTheme.humanColor,
          ),
        ],
      ),
    )
        .animate(delay: 100.ms)
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, duration: 400.ms, curve: Curves.easeOut);
  }
}

class _Bar extends StatelessWidget {
  final String label;
  final double percent;
  final Color color;

  const _Bar({
    required this.label,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.dmMono(fontSize: 11, color: color),
            ),
            Text(
              '${(percent * 100).round()}%',
              style: GoogleFonts.dmMono(fontSize: 11, color: color),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearPercentIndicator(
          percent: percent.clamp(0.0, 1.0),
          lineHeight: 8,
          backgroundColor: AppTheme.bg4,
          progressColor: color,
          barRadius: const Radius.circular(100),
          padding: EdgeInsets.zero,
          animation: true,
          animationDuration: 800,
          curve: Curves.easeOut,
        ),
      ],
    );
  }
}

// ── Error banner ────────────────────────────────────────────
class ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const ErrorBanner({
    super.key,
    required this.message,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.aiColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.aiColor.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              color: AppTheme.aiColor, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.syne(
                fontSize: 13,
                color: AppTheme.aiLight,
              ),
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: Icon(Icons.close, color: AppTheme.textMuted, size: 16),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}
