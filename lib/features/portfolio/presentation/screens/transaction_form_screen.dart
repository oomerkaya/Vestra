import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vestra/core/error/failure.dart';
import 'package:vestra/core/error/result.dart';
import 'package:vestra/core/l10n/l10n.dart';
import 'package:vestra/core/theme/app_tokens.dart';
import 'package:vestra/core/utils/decimal_input.dart';
import 'package:vestra/core/widgets/app_card.dart';
import 'package:vestra/core/widgets/choice_tiles.dart';
import 'package:vestra/core/widgets/confirm_dialog.dart';
import 'package:vestra/core/widgets/instrument_avatar.dart';
import 'package:vestra/core/widgets/messages.dart';
import 'package:vestra/features/market/domain/entities/quote.dart';
import 'package:vestra/features/market/market_providers.dart';
import 'package:vestra/features/market/presentation/instrument_labels.dart';
import 'package:vestra/features/portfolio/domain/entities/asset.dart';
import 'package:vestra/features/portfolio/domain/entities/asset_transaction.dart';
import 'package:vestra/features/portfolio/domain/entities/asset_type.dart';
import 'package:vestra/features/portfolio/portfolio_providers.dart';
import 'package:vestra/features/portfolio/presentation/portfolio_labels.dart';
import 'package:vestra/features/portfolio/presentation/widgets/instrument_picker_sheet.dart';

/// Add a buy/sell (optionally for a preset instrument) or edit an existing
/// transaction. Validation (quantity, price, oversell) lives in the use
/// cases; this screen only parses input and shows the result.
class TransactionFormScreen extends ConsumerStatefulWidget {
  const TransactionFormScreen.add({
    this.initial,
    this.initialKind = TransactionKind.buy,
    super.key,
  }) : asset = null,
       transaction = null;

  const TransactionFormScreen.edit({
    required Asset this.asset,
    required AssetTransaction this.transaction,
    super.key,
  }) : initial = null,
       initialKind = TransactionKind.buy;

  final PickedInstrument? initial;
  final TransactionKind initialKind;
  final Asset? asset;
  final AssetTransaction? transaction;

  bool get isEdit => transaction != null;

  @override
  ConsumerState<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen> {
  static final RegExp _allowed = RegExp('[0-9.,]');

  final _quantity = TextEditingController();
  final _price = TextEditingController();
  final _note = TextEditingController();

  late QuoteCategory _category;
  PickedInstrument? _picked;
  late TransactionKind _kind;
  late DateTime _date;
  bool _priceAutoFilled = false;
  bool _busy = false;
  String? _instrumentError;
  String? _quantityError;
  String? _priceError;

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    final asset = widget.asset;
    if (tx != null && asset != null) {
      _picked = (
        instrument: (type: asset.type, code: asset.code),
        name: asset.name,
      );
      _category = QuoteCategory.of(asset.type);
      _kind = tx.kind;
      _date = tx.date;
      _quantity.text = formatDecimalInput(tx.quantity);
      final price = tx.unitPriceTry;
      if (price != null) _price.text = formatDecimalInput(price);
      _note.text = tx.note ?? '';
    } else {
      _picked = widget.initial;
      _category = widget.initial == null
          ? QuoteCategory.fx
          : QuoteCategory.of(widget.initial!.instrument.type);
      _kind = widget.initialKind;
      final now = DateTime.now();
      _date = DateTime(now.year, now.month, now.day);
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybePrefillPrice());
    }
  }

  @override
  void dispose() {
    _quantity.dispose();
    _price.dispose();
    _note.dispose();
    super.dispose();
  }

  bool get _isToday {
    final now = DateTime.now();
    return _date.year == now.year &&
        _date.month == now.month &&
        _date.day == now.day;
  }

  /// Fills the price with the cached quote when adding for today and the
  /// user hasn't typed a price (or the current one was auto-filled).
  void _maybePrefillPrice() {
    if (widget.isEdit || !mounted) return;
    final picked = _picked;
    if (!_isToday || picked == null) {
      if (_priceAutoFilled) {
        _price.clear();
        setState(() => _priceAutoFilled = false);
      }
      return;
    }
    if (_price.text.isNotEmpty && !_priceAutoFilled) return;
    final quotes = ref.read(quotesProvider).value ?? const <Quote>[];
    final quote = quotes
        .where((q) => q.instrument == picked.instrument)
        .firstOrNull;
    setState(() {
      if (quote == null) {
        if (_priceAutoFilled) _price.clear();
        _priceAutoFilled = false;
      } else {
        _price.text = formatDecimalInput(quote.priceTry);
        _priceAutoFilled = true;
      }
    });
  }

  Future<void> _pickInstrument() async {
    final picked = await InstrumentPickerSheet.show(context, _category);
    if (picked == null || !mounted) return;
    setState(() {
      _picked = picked;
      _instrumentError = null;
    });
    _maybePrefillPrice();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1990),
      lastDate: DateTime(now.year, now.month, now.day),
    );
    if (picked == null || !mounted) return;
    setState(() => _date = picked);
    _maybePrefillPrice();
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final picked = _picked;
    final quantity = parseDecimalInput(_quantity.text);
    final priceText = _price.text.trim();
    final price = priceText.isEmpty ? null : parseDecimalInput(priceText);
    setState(() {
      _instrumentError = picked == null ? l10n.txErrorInstrument : null;
      _quantityError = quantity == null ? l10n.txErrorQuantity : null;
      _priceError = priceText.isNotEmpty && price == null
          ? l10n.txErrorPriceFormat
          : null;
    });
    if (picked == null || quantity == null || _priceError != null) return;

    setState(() => _busy = true);
    final note = _note.text.trim().isEmpty ? null : _note.text.trim();
    final Result<Object?> result;
    final tx = widget.transaction;
    if (tx != null) {
      result = await ref
          .read(updateTransactionProvider)
          .call(
            tx.copyWith(
              kind: _kind,
              quantity: quantity,
              unitPriceTry: () => price,
              date: _date,
              note: () => note,
            ),
          );
    } else {
      result = await ref
          .read(addTransactionProvider)
          .call(
            AssetDraft(
              type: picked.instrument.type,
              code: picked.instrument.code,
              name: picked.name,
            ),
            TransactionDraft(
              kind: _kind,
              quantity: quantity,
              unitPriceTry: price,
              date: _date,
              note: note,
            ),
          );
    }
    if (!mounted) return;
    switch (result) {
      case Success():
        navigator.pop();
        messenger.showMessage(l10n.txSaved);
      case Err(:final failure):
        setState(() => _busy = false);
        _showFailure(failure);
    }
  }

  Future<void> _delete() async {
    final tx = widget.transaction;
    if (tx == null) return;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final confirmed = await confirmDestructive(
      context,
      title: l10n.txDeleteConfirmTitle,
      message: l10n.txDeleteConfirmMessage,
    );
    if (!confirmed || !mounted) return;
    final result = await ref.read(deleteTransactionProvider).call(tx);
    if (!mounted) return;
    switch (result) {
      case Success():
        navigator.pop();
        messenger.showMessage(l10n.txDeleted);
      case Err(:final failure):
        _showFailure(failure);
    }
  }

  void _showFailure(Failure failure) {
    final l10n = context.l10n;
    ScaffoldMessenger.of(
      context,
    ).showMessage(transactionFailureMessage(l10n, failure));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final title = widget.isEdit
        ? l10n.txTitleEdit
        : widget.initial == null
        ? l10n.txTitleAdd
        : _kind == TransactionKind.sell
        ? l10n.txTitleSell
        : l10n.txTitleBuy;
    final canChangeInstrument = !widget.isEdit && widget.initial == null;
    final picked = _picked;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (widget.isEdit)
            IconButton(
              tooltip: l10n.txDelete,
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: _busy ? null : () => unawaited(_delete()),
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
          if (canChangeInstrument) ...[
            _Label(l10n.txType),
            ChoiceTiles<QuoteCategory>(
              selected: _category,
              onChanged: (c) => setState(() {
                if (c != _category) {
                  _category = c;
                  _picked = null;
                  if (_priceAutoFilled) _price.clear();
                  _priceAutoFilled = false;
                }
              }),
              options: [
                ChoiceTile(
                  value: QuoteCategory.fx,
                  label: l10n.categoryFx,
                  icon: Icons.currency_exchange_rounded,
                ),
                ChoiceTile(
                  value: QuoteCategory.metals,
                  label: l10n.marketTabMetals,
                  icon: Icons.diamond_outlined,
                ),
                ChoiceTile(
                  value: QuoteCategory.stocks,
                  label: l10n.categoryStocks,
                  icon: Icons.candlestick_chart_outlined,
                ),
                ChoiceTile(
                  value: QuoteCategory.funds,
                  label: l10n.categoryFunds,
                  icon: Icons.pie_chart_outline_rounded,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
          _Label(l10n.txInstrument),
          AppCard(
            padding: EdgeInsets.zero,
            onTap: canChangeInstrument ? _pickInstrument : null,
            child: ListTile(
              leading: picked == null
                  ? const Icon(Icons.search_rounded)
                  : InstrumentAvatar(
                      type: picked.instrument.type,
                      label: instrumentShortLabel(picked.instrument),
                    ),
              title: Text(
                picked == null
                    ? l10n.txSelectInstrument
                    : instrumentName(
                        l10n,
                        picked.instrument,
                        providerName: picked.name,
                      ),
              ),
              subtitle: picked == null
                  ? null
                  : Text(
                      // Stocks and funds: full name; others: unit/code.
                      _hasLongName(picked)
                          ? picked.name
                          : instrumentSubtitle(l10n, picked.instrument),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
              trailing: canChangeInstrument
                  ? const Icon(Icons.chevron_right_rounded)
                  : null,
            ),
          ),
          if (_instrumentError != null)
            Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.xs,
                left: AppSpacing.lg,
              ),
              child: Text(
                _instrumentError!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.xl),
          ChoiceTiles<TransactionKind>(
            selected: _kind,
            onChanged: (k) => setState(() => _kind = k),
            options: [
              ChoiceTile(
                value: TransactionKind.buy,
                label: l10n.txKindBuy,
                icon: Icons.add_circle_outline_rounded,
              ),
              ChoiceTile(
                value: TransactionKind.sell,
                label: l10n.txKindSell,
                icon: Icons.remove_circle_outline_rounded,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          TextField(
            controller: _quantity,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            inputFormatters: [FilteringTextInputFormatter.allow(_allowed)],
            decoration: InputDecoration(
              labelText: l10n.txQuantity,
              errorText: _quantityError,
              suffixText: picked == null
                  ? null
                  : quantityUnit(l10n, picked.instrument),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _price,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            inputFormatters: [FilteringTextInputFormatter.allow(_allowed)],
            onChanged: (_) {
              if (_priceAutoFilled) setState(() => _priceAutoFilled = false);
            },
            decoration: InputDecoration(
              labelText: l10n.txUnitPrice,
              errorText: _priceError,
              helperText: _priceAutoFilled
                  ? l10n.txPriceFilled
                  : l10n.txUnitPriceHelp,
              prefixText: '₺ ',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            padding: EdgeInsets.zero,
            onTap: _busy ? null : () => unawaited(_pickDate()),
            child: ListTile(
              leading: const Icon(Icons.event_outlined),
              title: Text(l10n.txDate),
              trailing: Text(
                _formatDate(_date),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _note,
            maxLength: 200,
            decoration: InputDecoration(labelText: l10n.txNote),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: _busy ? null : () => unawaited(_save()),
            child: _busy
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.commonSave),
          ),
        ],
      ),
    );
  }

  /// Stocks and funds carry the provider's full name (shown as subtitle).
  static bool _hasLongName(PickedInstrument p) =>
      (p.instrument.type == AssetType.stock ||
          p.instrument.type == AssetType.fund) &&
      p.name != p.instrument.code;

  static String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.'
      '${d.month.toString().padLeft(2, '0')}.${d.year}';
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.sm),
    child: Text(text, style: Theme.of(context).textTheme.titleSmall),
  );
}
