import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vestra/core/l10n/l10n.dart';
import 'package:vestra/core/theme/app_tokens.dart';
import 'package:vestra/core/widgets/app_card.dart';
import 'package:vestra/core/widgets/choice_tiles.dart';
import 'package:vestra/core/widgets/section_header.dart';
import 'package:vestra/features/portfolio/presentation/widgets/backup_section.dart';
import 'package:vestra/features/settings/presentation/theme_mode_provider.dart';
import 'package:vestra/features/settings/presentation/widgets/data_source_section.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          0,
          AppSpacing.screen,
          AppSpacing.xxl,
        ),
        children: [
          SectionHeader(l10n.settingsSectionAppearance),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.settingsTheme, style: textTheme.titleSmall),
                const SizedBox(height: AppSpacing.md),
                const _ThemeSelector(),
              ],
            ),
          ),
          SectionHeader(l10n.settingsSectionData),
          const DataSourceSection(),
          SectionHeader(l10n.settingsSectionBackup),
          const BackupSection(),
          SectionHeader(l10n.settingsSectionAbout),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.shield_outlined),
                  title: Text(l10n.settingsDisclaimerTitle),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Text(
                      l10n.settingsDisclaimer,
                      style: textTheme.bodySmall?.copyWith(height: 1.45),
                    ),
                  ),
                ),
                const Divider(indent: AppSpacing.lg, endIndent: AppSpacing.lg),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(l10n.settingsLicenses),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: l10n.appTitle,
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

class _ThemeSelector extends ConsumerWidget {
  const _ThemeSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return ChoiceTiles<ThemeMode>(
      selected: ref.watch(themeModeProvider),
      onChanged: (mode) =>
          unawaited(ref.read(themeModeProvider.notifier).setMode(mode)),
      options: [
        ChoiceTile(
          value: ThemeMode.system,
          label: l10n.themeSystem,
          icon: Icons.brightness_auto_outlined,
        ),
        ChoiceTile(
          value: ThemeMode.light,
          label: l10n.themeLight,
          icon: Icons.light_mode_outlined,
        ),
        ChoiceTile(
          value: ThemeMode.dark,
          label: l10n.themeDark,
          icon: Icons.dark_mode_outlined,
        ),
      ],
    );
  }
}
