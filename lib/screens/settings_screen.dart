import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/controls_sheet.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _androidPackageId = 'softwaredevvvv.nurova';
  static const _privacyPolicyUrl =
      'https://github.com/SoftwareDevvvv/planet-space-app/blob/main/PRIVACY_POLICY.md';
  static const _openSourceUrl = 'https://github.com/SoftwareDevvvv/planet-space-app';
  static const _rateAppUrl =
      'https://play.google.com/store/apps/details?id=$_androidPackageId';
  static const _shareText =
      'Check out Nurova — an interactive solar system app: https://play.google.com/store/apps/details?id=$_androidPackageId';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05070E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF05070E),
        title: const Text('Settings'),
      ),
      body: Stack(
        children: [
          const _GridBackdrop(),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                _SettingsTile(
                  title: 'Privacy Policy',
                  subtitle: _privacyPolicyUrl.isEmpty
                      ? 'Add link later'
                      : 'View privacy policy',
                  icon: Icons.privacy_tip_outlined,
                  onTap: () => _openLink(context, _privacyPolicyUrl),
                ),
                _SettingsTile(
                  title: 'Open Source',
                  subtitle: _openSourceUrl.isEmpty
                      ? 'Add repo link later'
                      : 'View GitHub repo',
                  icon: FontAwesomeIcons.github,
                  onTap: () => _openLink(context, _openSourceUrl),
                ),
                _SettingsTile(
                  title: 'Share This App',
                  subtitle: 'Send the app to a friend',
                  icon: Icons.share_outlined,
                  onTap: () => Share.share(_shareText),
                ),
                _SettingsTile(
                  title: 'Rate This App',
                  subtitle: _rateAppUrl.isEmpty
                      ? 'Add store link later'
                      : 'Open store page',
                  icon: Icons.star_rate_outlined,
                  onTap: () => _openLink(context, _rateAppUrl),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openLink(BuildContext context, String url) async {
    if (url.isEmpty) {
      _showMessage(context, 'Link not set yet.');
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null) {
      _showMessage(context, 'Invalid link.');
      return;
    }
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      _showMessage(context, 'Unable to open link.');
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0F1B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white.withOpacity(0.85)),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.65),
              ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
        onTap: onTap,
      ),
    );
  }
}

class _GridBackdrop extends StatelessWidget {
  const _GridBackdrop();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _GridGlowPainter(),
        child: Container(),
      ),
    );
  }
}

class _GridGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1.0;
    const step = 38.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white.withOpacity(0.12), Colors.transparent],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.8, size.height * 0.2),
          radius: size.width * 0.6,
        ),
      );
    canvas.drawRect(Offset.zero & size, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
