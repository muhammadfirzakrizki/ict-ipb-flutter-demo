import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localization.dart';
import '../../../../core/router/app_routes.dart';
import '../../../auth/application/auth_controller.dart';

class DashboardMenu extends ConsumerWidget {
  const DashboardMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      onSelected: (value) {
        if (value == 'logout') {
          ref.read(authControllerProvider.notifier).logout();
        } else if (value == 'info') {
          context.push(AppRoutes.profile);
        } else if (value == 'settings') {
          context.push(AppRoutes.settings);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'info',
          child: ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(context.tr('profile')),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          child: ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: Text(context.tr('settings_menu')),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              context.tr('logout'),
              style: const TextStyle(color: Colors.red),
            ),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}
