import 'package:flutter/material.dart';
import 'package:talkflip/services/auth_service.dart';
import 'package:talkflip/features/home/screen/home_screen.dart';
import '../widgets/top_app_bar.dart';
import '../widgets/stats_card.dart';
import '../widgets/practice_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Top App Bar
            SliverToBoxAdapter(
              child: DashboardTopAppBar(
                user: _authService.currentUser,
                onMenuTap: _showMenuBottomSheet,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Your Stats Section
                    Text(
                      'Your Stats',
                      style:
                          Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Stats Cards Grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: [
                        StatsCard(
                          title: 'Practice Days',
                          value: '12',
                          icon: Icons.calendar_today_rounded,
                          color: Colors.blue,
                        ),
                        StatsCard(
                          title: 'Words Learned',
                          value: '48',
                          icon: Icons.school_rounded,
                          color: Colors.purple,
                        ),
                        StatsCard(
                          title: 'Avg. Score',
                          value: '85%',
                          icon: Icons.trending_up_rounded,
                          color: Colors.green,
                        ),
                        StatsCard(
                          title: 'Streak',
                          value: '7',
                          icon: Icons.local_fire_department_rounded,
                          color: Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Quick Practice Section
                    Text(
                      'Quick Practice',
                      style:
                          Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade900,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            // Practice Cards
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    PracticeCard(
                      title: 'Word Pronunciation',
                      description: 'Practice pronunciation of challenging words',
                      icon: Icons.mic_rounded,
                      color: Colors.blue,
                      badge: 'New',
                      onTap: () => _navigateToPronunciation(),
                    ),
                    const SizedBox(height: 12),
                    PracticeCard(
                      title: 'Sentence Practice',
                      description: 'Improve your fluency with full sentences',
                      icon: Icons.chat_rounded,
                      color: Colors.green,
                      onTap: () => _showComingSoonSnackbar(),
                    ),
                    const SizedBox(height: 12),
                    PracticeCard(
                      title: 'Accent Training',
                      description: 'Refine your accent and intonation',
                      icon: Icons.volume_up_rounded,
                      color: Colors.orange,
                      onTap: () => _showComingSoonSnackbar(),
                    ),
                    const SizedBox(height: 12),
                    PracticeCard(
                      title: 'Listening Comprehension',
                      description: 'Test your listening skills',
                      icon: Icons.headphones_rounded,
                      color: Colors.purple,
                      onTap: () => _showComingSoonSnackbar(),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPronunciation() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PronunciationScreen(),
      ),
    );
  }

  void _showComingSoonSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Coming soon! Stay tuned.'),
        backgroundColor: Colors.blue.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showMenuBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.person_rounded),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Profile feature coming soon'),
                    backgroundColor: Colors.blue.shade600,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_rounded),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Settings feature coming soon'),
                    backgroundColor: Colors.blue.shade600,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_rounded),
              title: const Text('Help & Support'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Support feature coming soon'),
                    backgroundColor: Colors.blue.shade600,
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                Navigator.pop(context);
                await _authService.signOut();
                if (mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/splash',
                    (route) => false,
                  );
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
