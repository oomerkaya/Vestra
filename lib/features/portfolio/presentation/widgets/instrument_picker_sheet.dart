import 'package:capira/core/domain/instrument.dart';
import 'package:capira/core/l10n/l10n.dart';
import 'package:capira/core/theme/app_tokens.dart';
import 'package:capira/core/theme/app_typography.dart';
import 'package:capira/core/utils/formatters.dart';
import 'package:capira/core/widgets/instrument_avatar.dart';
import 'package:capira/features/market/domain/entities/quote.dart';
import 'package:capira/features/market/domain/entities/stock_listing.dart';
import 'package:capira/features/market/market_providers.dart';
import 'package:capira/features/market/presentation/instrument_labels.dart';
import 'package:capira/features/portfolio/domain/instrument_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What the picker returns: the instrument and the name to store.
typedef PickedInstrument = ({Instrument instrument, String name});

/// Bottom sheet listing selectable instruments of one [category]. Stocks
/// are searched in the cached BIST list; a symbol can also be typed.
class InstrumentPickerSheet extends ConsumerStatefulWidget {
  const InstrumentPickerSheet({required this.category, super.key});

  final QuoteCategory category;

  static Future<PickedInstrument?> show(
    BuildContext context,
    QuoteCategory category,
  ) => showModalBottomSheet<PickedInstrument>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => FractionallySizedBox(
      heightFactor: 0.85,
      child: InstrumentPickerSheet(category: category),
    ),
  );

  @override
  ConsumerState<InstrumentPickerSheet> createState() =>
      _InstrumentPickerSheetState();
}

class _InstrumentPickerSheetState extends ConsumerState<InstrumentPickerSheet> {
  final _search = TextEditingController();
  String _query = '';

  static final RegExp _symbolPattern = RegExp(r'^[A-Z0-9]{2,8}$');

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isStocks = widget.category == QuoteCategory.stocks;
    final isFunds = widget.category == QuoteCategory.funds;
    final quotes = {
      for (final q in ref.watch(quotesProvider).value ?? const <Quote>[])
        q.instrument: q,
    };

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              0,
              AppSpacing.xl,
              AppSpacing.md,
            ),
            child: Text(
              l10n.pickerTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          if (isStocks || isFunds)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                0,
                AppSpacing.xl,
                AppSpacing.md,
              ),
              child: TextField(
                controller: _search,
                autofocus: true,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: isFunds
                      ? l10n.marketSearchFunds
                      : l10n.pickerSearchStocks,
                  prefixIcon: const Icon(Icons.search_rounded),
                ),
                onChanged: (v) =>
                    setState(() => _query = turkishUpperCase(v.trim())),
              ),
            ),
          Expanded(
            child: isStocks
                ? _stockList(context, quotes)
                : isFunds
                ? _fundList(context, quotes)
                : _catalogList(context, quotes),
          ),
        ],
      ),
    );
  }

  Widget _catalogList(BuildContext context, Map<Instrument, Quote> quotes) {
    final l10n = context.l10n;
    final instruments = widget.category == QuoteCategory.fx
        ? InstrumentCatalog.currencyInstruments
        : InstrumentCatalog.metals;
    return ListView.builder(
      itemCount: instruments.length,
      itemBuilder: (context, i) {
        final instrument = instruments[i];
        final name = instrumentName(l10n, instrument);
        return _PickerTile(
          instrument: instrument,
          title: name,
          subtitle: instrumentSubtitle(l10n, instrument),
          quote: quotes[instrument],
          onTap: () => Navigator.of(
            context,
          ).pop((instrument: instrument, name: name)),
        );
      },
    );
  }

  /// Funds come from the cached daily TEFAS snapshot.
  Widget _fundList(BuildContext context, Map<Instrument, Quote> quotes) {
    final l10n = context.l10n;
    final funds = [
      for (final q in quotes.values)
        if (q.instrument.type == AssetType.fund) q,
    ]..sort((a, b) => a.instrument.code.compareTo(b.instrument.code));
    final matches = _query.isEmpty
        ? funds
        : [
            for (final q in funds)
              if (q.instrument.code.startsWith(_query) ||
                  turkishUpperCase(q.name ?? '').contains(_query))
                q,
          ];
    if (funds.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Text(l10n.marketFundsNotLoaded),
      );
    }
    return ListView(
      children: [
        if (matches.isEmpty)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Center(child: Text(l10n.pickerNoResults)),
          ),
        for (final q in matches.take(100))
          _PickerTile(
            instrument: q.instrument,
            title: q.instrument.code,
            subtitle: q.name ?? q.instrument.code,
            quote: q,
            onTap: () =>
                Navigator.of(
                  context,
                ).pop((
                  instrument: q.instrument,
                  name: q.name ?? q.instrument.code,
                )),
          ),
      ],
    );
  }

  Widget _stockList(BuildContext context, Map<Instrument, Quote> quotes) {
    final l10n = context.l10n;
    final listings = ref.watch(stockListingsProvider);
    final all = listings.value ?? const <StockListing>[];
    final matches = _query.isEmpty
        ? all
        : [
            for (final s in all)
              if (s.symbol.startsWith(_query) ||
                  turkishUpperCase(s.name).contains(_query))
                s,
          ];
    final canUseTyped =
        _symbolPattern.hasMatch(_query) &&
        !matches.any((s) => s.symbol == _query);

    return ListView(
      children: [
        if (listings.isLoading)
          const Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (listings.hasError)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
            child: Text(
              l10n.pickerStockListUnavailable,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        if (canUseTyped)
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: Text(l10n.pickerUseSymbol(_query)),
            onTap: () => Navigator.of(context).pop((
              instrument: (type: AssetType.stock, code: _query),
              name: _query,
            )),
          ),
        if (!listings.isLoading && matches.isEmpty && !canUseTyped)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Center(child: Text(l10n.pickerNoResults)),
          ),
        for (final s in matches.take(100))
          _PickerTile(
            instrument: (type: AssetType.stock, code: s.symbol),
            title: s.symbol,
            subtitle: s.name,
            quote: quotes[(type: AssetType.stock, code: s.symbol)],
            onTap: () => Navigator.of(context).pop((
              instrument: (type: AssetType.stock, code: s.symbol),
              name: s.name,
            )),
          ),
      ],
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.instrument,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.quote,
  });

  final Instrument instrument;
  final String title;
  final String subtitle;
  final Quote? quote;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final q = quote;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      leading: InstrumentAvatar(
        type: instrument.type,
        label: instrumentShortLabel(instrument),
      ),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: q == null
          ? null
          : Text(
              Formatters.currencyTry(q.priceTry),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFeatures: AppTypography.tabular,
                fontWeight: FontWeight.w600,
              ),
            ),
      onTap: onTap,
    );
  }
}
