import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  static const routeName = '/settings';

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

enum ThemeModeOption { light, dark, auto }

class _SettingsScreenState extends State<SettingsScreen> {
  bool _publicProfile = true;
  ThemeModeOption _themeMode = ThemeModeOption.dark;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        centerTitle: true,
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
        children: [
          const _SectionHeader('ACCOUNT'),
          _SettingsCard(
            children: [
              _SettingsRow(
                icon: Icons.email_outlined,
                title: 'Email',
                trailingText: 'alex@storyo.app',
                onTap: () {
                  // TODO: Navigate to Email screen
                },
              ),
              const _CardDivider(),
              _SettingsRow(
                icon: Icons.lock_outline_rounded,
                title: 'Password',
                onTap: () {
                  // TODO: Navigate to Password screen
                },
              ),
              const _CardDivider(),
              _SettingsRow(
                icon: Icons.share_outlined,
                title: 'Social Links',
                onTap: () {
                  // TODO: Navigate to Social Links screen
                },
              ),
            ],
          ),

          const SizedBox(height: 18),
          const _SectionHeader('PRIVACY'),
          _SettingsCard(
            children: [
              _SettingsRow(
                icon: Icons.remove_red_eye_outlined,
                title: 'Public Profile',
                subtitle: 'Allow others to see your library',
                trailing: Switch.adaptive(
                  value: _publicProfile,
                  onChanged: (v) => setState(() => _publicProfile = v),
                  activeColor: const Color(0xFF1E88FF),
                ),
                onTap: () => setState(() => _publicProfile = !_publicProfile),
              ),
              const _CardDivider(),
              _SettingsRow(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'Comment\nPermissions',
                trailingText: 'Everyone',
                onTap: () {
                  // TODO: Navigate to Comment Permissions screen
                },
              ),
            ],
          ),

          const SizedBox(height: 18),
          const _SectionHeader('PREFERENCES'),
          _SettingsCard(
            children: [
              _SettingsRow(
                icon: Icons.language_rounded,
                title: 'App Language',
                trailingText: 'English',
                onTap: () {
                  // TODO: Navigate to Language screen
                },
              ),
              const _CardDivider(),
              _SettingsRow(
                icon: Icons.tune_rounded,
                title: 'Content Filters',
                onTap: () {
                  // TODO: Navigate to Content Filters screen
                },
              ),
            ],
          ),

          const SizedBox(height: 18),
          const _SectionHeader('APPEARANCE'),
          _SettingsCard(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _IconBubble(icon: Icons.palette_outlined),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Theme Mode',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: _ThemeSegmented(
                  value: _themeMode,
                  onChanged: (v) => setState(() => _themeMode = v),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          _LogoutButton(
            onPressed: () {
              // TODO: Add logout logic
            },
          ),

          const SizedBox(height: 18),
          const Center(
            child: Text(
              'Storyo version 2.4.1(892)',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

/* -------------------- UI Components -------------------- */

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(18),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(children: children),
      ),
    );
  }
}

class _CardDivider extends StatelessWidget {
  const _CardDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.only(left: 64),
      color: Colors.white10,
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? trailingText;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailingText,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasSubtitle = subtitle != null && subtitle!.trim().isNotEmpty;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          crossAxisAlignment: hasSubtitle ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            _IconBubble(icon: icon),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: hasSubtitle ? 2 : 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.15,
                      ),
                    ),
                    if (hasSubtitle) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (trailing != null) trailing!,
            if (trailing == null) ...[
              if (trailingText != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    trailingText!,
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white38, size: 26),
            ]
          ],
        ),
      ),
    );
  }
}

class _IconBubble extends StatelessWidget {
  final IconData icon;
  const _IconBubble({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFF0F2A3D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: const Color(0xFF5AB3FF), size: 20),
    );
  }
}

class _ThemeSegmented extends StatelessWidget {
  final ThemeModeOption value;
  final ValueChanged<ThemeModeOption> onChanged;

  const _ThemeSegmented({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: CupertinoSlidingSegmentedControl<ThemeModeOption>(
        groupValue: value,
        thumbColor: const Color(0xFF1C1C1C),
        backgroundColor: Colors.transparent,
        onValueChanged: (v) {
          if (v != null) onChanged(v);
        },
        children: const {
          ThemeModeOption.light: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Text('Light', style: TextStyle(color: Colors.white70)),
          ),
          ThemeModeOption.dark: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Text('Dark', style: TextStyle(color: Color(0xFF4FA7FF), fontWeight: FontWeight.w700)),
          ),
          ThemeModeOption.auto: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Text('Auto', style: TextStyle(color: Colors.white70)),
          ),
        },
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _LogoutButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(18),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: const Text(
          'Log Out',
          style: TextStyle(
            color: Color(0xFFFF3B30),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}