import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/providers/user_provider.dart';
import 'package:mobile/core/auth/auth_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          Container(
            height: 160,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A00C8), Color(0xFF3A10E0), Color(0xFF5B2CF5)],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                          ),
                          child: const Icon(Icons.chevron_left, color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'My Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Jost',
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                      child: userAsync.when(
                        loading: () => const Center(
                          child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
                        ),
                        error: (err, _) => Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Failed to load profile.',
                                style: const TextStyle(color: Color(0xFF94A3B8)),
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: () => ref.invalidate(userProvider),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                        data: (user) => _ProfileContent(user: user, ref: ref),
                      ),
                    ),
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

class _ProfileContent extends StatelessWidget {
  final Map<String, dynamic> user;
  final WidgetRef ref;

  const _ProfileContent({required this.user, required this.ref});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F0FF),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      (user['name'] ?? '?').toString().isNotEmpty
                          ? (user['name'] as String)[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF7C3AED),
                        fontFamily: 'Jost',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user['name'] ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E1B4B),
                    fontFamily: 'Jost',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user['email'] ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF94A3B8),
                    fontFamily: 'Jost',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          const _SectionLabel(label: 'ACADEMIC'),
          const SizedBox(height: 8),
          _InfoCard(
            children: [
              _InfoRow(icon: Icons.school_outlined, label: 'Major', value: user['major'] ?? '—'),
              _InfoRow(icon: Icons.calendar_today_outlined, label: 'Graduating', value: '${user['grad_year'] ?? '—'}'),
            ],
          ),

          const SizedBox(height: 24),
          const _SectionLabel(label: 'LIVING'),
          const SizedBox(height: 8),
          _InfoCard(
            children: [
              _InfoRow(icon: Icons.home_outlined, label: 'Residence', value: user['dorm'] ?? '—'),
            ],
          ),

          const SizedBox(height: 24),
          const _SectionLabel(label: 'HOME'),
          const SizedBox(height: 8),
          _InfoCard(
            children: [
              _InfoRow(icon: Icons.public_outlined, label: 'Nationality', value: user['home_country'] ?? '—'),
              _InfoRow(icon: Icons.attach_money_outlined, label: 'Currency', value: user['home_currency'] ?? '—'),
            ],
          ),

          if (user['lifestyle'] != null) ...[
            const SizedBox(height: 24),
            const _SectionLabel(label: 'LIFESTYLE'),
            const SizedBox(height: 8),
            _LifestyleCard(lifestyle: user['lifestyle'] as Map<String, dynamic>),
          ],

          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () => _handleLogout(context),
              icon: const Icon(Icons.logout, size: 16, color: Color(0xFFEF4444)),
              label: const Text(
                'Log out',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFEF4444),
                  fontFamily: 'Jost',
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFECACA)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AuthService.logout();
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    }
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Color(0xFF94A3B8),
        letterSpacing: 1.0,
        fontFamily: 'Jost',
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF818CF8)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                fontFamily: 'Jost',
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E1B4B),
              fontFamily: 'Jost',
            ),
          ),
        ],
      ),
    );
  }
}

class _LifestyleCard extends StatelessWidget {
  final Map<String, dynamic> lifestyle;
  const _LifestyleCard({required this.lifestyle});

  String _label(String key, dynamic value) {
    switch (key) {
      case 'sleep':
        return value == 'early' ? 'Early bird' : 'Night owl';
      case 'noise':
        return value == 'quiet' ? 'Quiet' : 'Lively';
      case 'social':
        return value == 'introvert' ? 'Introvert' : 'Extrovert';
      case 'cooking':
        return value == true ? 'Cooks at home' : 'Rarely cooks';
      case 'diet':
        final dietStr = value as String?;
        if (dietStr == null || dietStr.isEmpty) return 'No preference';
        return '${dietStr[0].toUpperCase()}${dietStr.substring(1)}';
      case 'cleanliness':
        return '$value / 5';
      default:
        return value.toString();
    }
  }

  IconData _icon(String key) {
    switch (key) {
      case 'sleep':
        return Icons.bedtime_outlined;
      case 'noise':
        return Icons.volume_up_outlined;
      case 'social':
        return Icons.groups_outlined;
      case 'cooking':
        return Icons.restaurant_outlined;
      case 'diet':
        return Icons.set_meal_outlined;
      case 'cleanliness':
        return Icons.cleaning_services_outlined;
      default:
        return Icons.info_outline;
    }
  }

  String _fieldLabel(String key) {
    switch (key) {
      case 'sleep': return 'Sleep schedule';
      case 'noise': return 'Noise level';
      case 'social': return 'Social style';
      case 'cooking': return 'Cooking';
      case 'diet': return 'Diet';
      case 'cleanliness': return 'Cleanliness';
      default: return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    const order = ['sleep', 'cleanliness', 'noise', 'social', 'cooking', 'diet'];
    final rows = order.where((k) => lifestyle.containsKey(k)).map((k) {
      return _InfoRow(
        icon: _icon(k),
        label: _fieldLabel(k),
        value: _label(k, lifestyle[k]),
      );
    }).toList();

    return _InfoCard(children: rows);
  }
}