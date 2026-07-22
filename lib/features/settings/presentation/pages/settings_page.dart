import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/export_service.dart';
import '../../domain/currency.dart';
import '../cubit/settings_cubit.dart';
import '../widgets/edit_profile_sheet.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          const _ProfileHeader(),
          const SizedBox(height: 16),
          _SectionTitle('Appearance'),
          const _ThemeSelector(),
          const _CurrencyTile(),
          const SizedBox(height: 8),
          _SectionTitle('Notifications'),
          const _NotificationToggles(),
          const SizedBox(height: 8),
          _SectionTitle('Security'),
          const _BiometricToggle(),
          const SizedBox(height: 8),
          _SectionTitle('Data'),
          const _ExportTile(),
          const SizedBox(height: 8),
          _SectionTitle('About'),
          const _AboutTile(),
          const SizedBox(height: 24),
          _LogoutButton(),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.select<AuthBloc, dynamic>((b) => b.state.user);
    final name = user?.name ?? 'Guest';
    final email = user?.email ?? '';
    final initial =
        name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
            foregroundColor: theme.colorScheme.primary,
            child: Text(initial,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                if (email.isNotEmpty)
                  Text(email,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit profile',
            onPressed: () async {
              final bloc = context.read<AuthBloc>();
              final newName = await EditProfileSheet.show(context, name);
              if (newName != null && newName.isNotEmpty) {
                bloc.add(AuthProfileUpdated(newName));
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector();

  @override
  Widget build(BuildContext context) {
    final mode = context.select<SettingsCubit, ThemeMode>(
        (c) => c.state.themeMode);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Expanded(child: Text('Theme')),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode),
                  tooltip: 'Light'),
              ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.brightness_auto),
                  tooltip: 'System'),
              ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode),
                  tooltip: 'Dark'),
            ],
            selected: {mode},
            showSelectedIcon: false,
            onSelectionChanged: (s) =>
                context.read<SettingsCubit>().setThemeMode(s.first),
          ),
        ],
      ),
    );
  }
}

class _CurrencyTile extends StatelessWidget {
  const _CurrencyTile();

  @override
  Widget build(BuildContext context) {
    final currency =
        context.select<SettingsCubit, Currency>((c) => c.state.currency);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.currency_exchange),
      title: const Text('Currency'),
      subtitle: Text('${currency.name} (${currency.symbol})'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _pick(context),
    );
  }

  Future<void> _pick(BuildContext context) async {
    final cubit = context.read<SettingsCubit>();
    final selected = await showModalBottomSheet<Currency>(
      context: context,
      showDragHandle: true,
      builder: (_) => ListView(
        shrinkWrap: true,
        children: [
          for (final c in kSupportedCurrencies)
            ListTile(
              leading: SizedBox(
                width: 32,
                child: Text(c.symbol,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              title: Text(c.name),
              trailing: Text(c.code),
              onTap: () => Navigator.pop(context, c),
            ),
        ],
      ),
    );
    if (selected != null) cubit.setCurrency(selected);
  }
}

class _NotificationToggles extends StatelessWidget {
  const _NotificationToggles();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SettingsCubit>();
    final state = context.watch<SettingsCubit>().state;
    return Column(
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Budget threshold alerts'),
          value: state.notifyBudgetAlerts,
          onChanged: cubit.setNotifyBudgetAlerts,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Subscription renewal reminders'),
          value: state.notifyRenewals,
          onChanged: cubit.setNotifyRenewals,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Daily spending summary'),
          value: state.notifyDailySummary,
          onChanged: cubit.setNotifyDailySummary,
        ),
      ],
    );
  }
}

class _BiometricToggle extends StatelessWidget {
  const _BiometricToggle();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SettingsCubit>();
    final enabled =
        context.select<SettingsCubit, bool>((c) => c.state.biometricEnabled);
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      secondary: const Icon(Icons.fingerprint),
      title: const Text('Biometric unlock'),
      subtitle: const Text('Require fingerprint / face to open the app'),
      value: enabled,
      onChanged: cubit.setBiometric,
    );
  }
}

class _ExportTile extends StatelessWidget {
  const _ExportTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.ios_share),
      title: const Text('Export all data'),
      subtitle: const Text('Share your transactions, budgets & subscriptions'),
      onTap: () async {
        final messenger = ScaffoldMessenger.of(context);
        try {
          await sl<ExportDataService>()
              .exportAndShare(exportedAt: DateTime.now().toIso8601String());
        } catch (_) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Could not export data.')),
          );
        }
      },
    );
  }
}

class _AboutTile extends StatelessWidget {
  const _AboutTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.info_outline),
      title: const Text('About & Privacy Policy'),
      onTap: () async {
        final info = await PackageInfo.fromPlatform();
        if (!context.mounted) return;
        showAboutDialog(
          context: context,
          applicationName: 'Personal Finance Manager',
          applicationVersion: 'v${info.version}+${info.buildNumber}',
          applicationLegalese: '© 2026 Personal Finance Manager',
          children: const [
            SizedBox(height: 12),
            Text(
              'Your data stays on your device. We do not sell or share your '
              'financial information. Local storage is used for transactions, '
              'budgets, and subscriptions.',
            ),
          ],
        );
      },
    );
  }
}

class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        context.read<AuthBloc>().add(const AuthLogoutRequested());
        context.go(AppRoutes.login);
      },
      icon: const Icon(Icons.logout),
      label: const Text('Log out'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        foregroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
