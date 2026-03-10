import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localization.dart';
import '../services/firebase_auth_error_mapper.dart';
import '../widgets/app_animations.dart';
import '../widgets/fullscreen_loading_overlay.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isSaving = false;

  Future<void> _editProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _isSaving) return;

    final controller = TextEditingController(text: user.displayName ?? '');
    final newName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.tr('edit_profile')),
          content: TextField(
            controller: controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: context.tr('display_name'),
              hintText: context.tr('enter_new_name'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.tr('cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: Text(context.tr('save')),
            ),
          ],
        );
      },
    );

    if (newName == null) return;
    if (newName.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.tr('name_required'))));
      return;
    }

    setState(() => _isSaving = true);
    try {
      await user.updateDisplayName(newName);
      await user.reload();
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.tr('profile_updated'))));
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr(FirebaseAuthErrorMapper.fromException(e))),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('profile_update_error'))),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? '-';
    final displayName = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!
        : email.split('@').first;
    final initials = displayName.isNotEmpty
        ? displayName.substring(0, 1).toUpperCase()
        : 'U';

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('profile_title').toUpperCase()),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: context.tr('edit'),
            onPressed: _isSaving ? null : _editProfile,
            icon: const Icon(Icons.edit_outlined),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(20),
            children: [
              FadeSlideIn(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 380),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: colorScheme.primary.withValues(alpha: 0.15),
                        child: Text(
                          initials,
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        displayName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withValues(
                            alpha: 0.75,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _ProfileTile(
                icon: Icons.badge_outlined,
                title: context.tr('user_id'),
                value: user?.uid ?? '-',
              ),
              _ProfileTile(
                icon: Icons.verified_user_outlined,
                title: context.tr('email_verified'),
                value: (user?.emailVerified ?? false)
                    ? context.tr('yes')
                    : context.tr('no'),
              ),
              _ProfileTile(
                icon: Icons.calendar_month_outlined,
                title: context.tr('created'),
                value: _formatDate(user?.metadata.creationTime),
              ),
              _ProfileTile(
                icon: Icons.access_time_outlined,
                title: context.tr('last_sign_in'),
                value: _formatDate(user?.metadata.lastSignInTime),
              ),
            ],
          ),
          FullScreenLoadingOverlay(visible: _isSaving),
        ],
      ),
    );
  }

  static String _formatDate(DateTime? date) {
    if (date == null) return '-';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, color: colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
