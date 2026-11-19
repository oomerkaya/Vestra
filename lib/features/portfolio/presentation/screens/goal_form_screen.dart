import 'dart:async';

import 'package:capira/core/domain/display_currency.dart';
import 'package:capira/core/error/result.dart';
import 'package:capira/core/l10n/l10n.dart';
import 'package:capira/core/theme/app_tokens.dart';
import 'package:capira/core/utils/decimal_input.dart';
import 'package:capira/core/widgets/choice_tiles.dart';
import 'package:capira/core/widgets/confirm_dialog.dart';
import 'package:capira/core/widgets/messages.dart';
import 'package:capira/features/market/domain/entities/quote.dart';
import 'package:capira/features/market/presentation/instrument_labels.dart';
import 'package:capira/features/portfolio/domain/entities/goal.dart';
import 'package:capira/features/portfolio/portfolio_providers.dart';
import 'package:capira/features/portfolio/presentation/portfolio_labels.dart';
import 'package:capira/features/portfolio/presentation/widgets/instrument_picker_sheet.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Create ([goalId] `null`) or edit a savings goal.
class GoalFormScreen extends ConsumerStatefulWidget {
  const GoalFormScreen({this.goalId, super.key});

  final int? goalId;

  @override
  ConsumerState<GoalFormScreen> createState() => _GoalFormScreenState();
}

class _GoalFormScreenState extends ConsumerState<GoalFormScreen> {
  final _title = TextEditingController();
  final _target = TextEditingController();
  GoalKind _kind = GoalKind.portfolioValue;
  DisplayCurrency _currency = DisplayCurrency.tryLira;
  QuoteCategory _category = QuoteCategory.metals;
  PickedInstrument? _picked;
  GoalProblem? _problem;
  bool _loaded = false;

  @override
  void dispose() {
    _title.dispose();
    _target.dispose();
    super.dispose();
  }

  /// Fills the form once from the stored goal when editing.
  void _loadOnce(List<Goal> goals) {
    if (_loaded) return;
    final id = widget.goalId;
    if (id == null) {
      _loaded = true;
      return;
    }
    final goal = goals.where((g) => g.id == id).firstOrNull;
    if (goal == null) return;
    _loaded = true;
    _title.text = goal.title;
    _target.text = formatDecimalInput(goal.target);
    _kind = goal.kind;
    _currency = goal.currency ?? DisplayCurrency.tryLira;
    final i = goal.instrument;
    if (i != null) {
      _category = QuoteCategory.of(i.type);
      _picked = (instrument: i, name: i.code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    _loadOnce(ref.watch(goalsProvider).value ?? const []);
    final editing = widget.goalId != null;
    final picked = _picked;

    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? l10n.goalsEditTitle : l10n.goalsNewTitle),
        actions: [
          if (editing)
            IconButton(
              tooltip: l10n.goalsDelete,
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () => unawaited(_delete()),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.sm,
          AppSpacing.screen,
          AppSpacing.xxl,
        ),
        children: [
          TextField(
            controller: _title,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: l10n.goalsFieldTitle,
              hintText: l10n.goalsFieldTitleHint,
              errorText: _problem == GoalProblem.emptyTitle
                  ? l10n.goalsErrorTitle
                  : null,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          ChoiceTiles<GoalKind>(
            selected: _kind,
            onChanged: (k) => setState(() => _kind = k),
            options: [
              ChoiceTile(
                value: GoalKind.portfolioValue,
                label: l10n.goalsKindValue,
                icon: Icons.account_balance_wallet_outlined,
              ),
              ChoiceTile(
                value: GoalKind.assetQuantity,
                label: l10n.goalsKindQuantity,
                icon: Icons.inventory_2_outlined,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          if (_kind == GoalKind.portfolioValue) ...[
            SegmentedButton<DisplayCurrency>(
              showSelectedIcon: false,
              segments: [
                for (final c in DisplayCurrency.values)
                  ButtonSegment(value: c, label: Text(c.symbol)),
              ],
              selected: {_currency},
              onSelectionChanged: (s) => setState(() => _currency = s.single),
            ),
            const SizedBox(height: AppSpacing.lg),
          ] else ...[
            ChoiceTiles<QuoteCategory>(
              selected: _category,
              onChanged: (c) => setState(() {
                if (c != _category) _picked = null;
                _category = c;
              }),
              options: [
                for (final c in QuoteCategory.values)
                  ChoiceTile(
                    value: c,
                    label: categoryLabel(l10n, c),
                    icon: categoryIcon(c),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: () => unawaited(_pick()),
              icon: const Icon(Icons.search_rounded),
              label: Text(
                picked == null
                    ? l10n.goalsPickInstrument
                    : instrumentShortName(l10n, picked.instrument),
              ),
            ),
            if (_problem == GoalProblem.missingInstrument)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  l10n.goalsErrorInstrument,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
          ],
          TextField(
            controller: _target,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: _kind == GoalKind.portfolioValue
                  ? l10n.goalsFieldAmount
                  : l10n.goalsFieldQuantity,
              suffixText: _kind == GoalKind.portfolioValue
                  ? _currency.symbol
                  : picked == null
                  ? null
                  : quantityUnit(l10n, picked.instrument),
              errorText: _problem == GoalProblem.nonPositiveTarget
                  ? l10n.goalsErrorTarget
                  : null,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(
            onPressed: () => unawaited(_save()),
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );
  }

  Future<void> _pick() async {
    final picked = await InstrumentPickerSheet.show(context, _category);
    if (picked == null || !mounted) return;
    setState(() {
      _picked = picked;
      if (_title.text.trim().isEmpty) {
        _title.text = context.l10n.goalsDefaultTitle(
          instrumentShortName(context.l10n, picked.instrument),
        );
      }
    });
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final draft = GoalDraft(
      title: _title.text,
      kind: _kind,
      target: parseDecimalInput(_target.text) ?? Decimal.zero,
      currency: _currency,
      instrument: _picked?.instrument,
    );
    final result = await ref
        .read(saveGoalProvider)
        .call(draft, id: widget.goalId);
    if (!mounted) return;
    switch (result) {
      case Success():
        router.pop();
        messenger.showMessage(l10n.goalsSaved);
      case Err(:final failure):
        setState(
          () => _problem = failure is GoalValidationFailure
              ? failure.problem
              : null,
        );
        if (failure is! GoalValidationFailure) {
          messenger.showMessage(l10n.goalsSaveFailed);
        }
    }
  }

  Future<void> _delete() async {
    final id = widget.goalId;
    if (id == null) return;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final confirmed = await confirmDestructive(
      context,
      title: l10n.goalsDeleteTitle,
      message: l10n.goalsDeleteMessage(_title.text),
    );
    if (!confirmed) return;
    await ref.read(deleteGoalProvider).call(id);
    router.pop();
    messenger.showMessage(l10n.goalsDeleted);
  }
}
