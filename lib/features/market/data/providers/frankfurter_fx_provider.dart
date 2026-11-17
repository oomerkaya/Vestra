import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:vestra/core/domain/instrument.dart';
import 'package:vestra/core/error/result.dart';
import 'package:vestra/core/network/dio_failure_mapper.dart';
import 'package:vestra/features/market/data/datasources/frankfurter_remote_data_source.dart';
import 'package:vestra/features/market/domain/entities/quote.dart';
import 'package:vestra/features/market/domain/providers/price_providers.dart';

/// Free FX fallback (ECB daily reference rates). Used when there is no
/// Bürküt key, the quota is used up, or Bürküt FX fails.
class FrankfurterFxProvider implements FxRateProvider {
  FrankfurterFxProvider(this._remote, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  /// Currencies ECB publishes that Turkish users commonly hold.
  static const List<String> currencies = [
    'USD',
    'EUR',
    'GBP',
    'CHF',
    'JPY',
    'CAD',
    'AUD',
    'DKK',
    'SEK',
    'NOK',
  ];

  static const int priceScale = 6;

  final FrankfurterRemoteDataSource _remote;
  final DateTime Function() _clock;

  @override
  Future<Result<List<Quote>>> fetchRates() async {
    try {
      final result = await _remote.latestPerTry(currencies);
      final now = _clock();
      return Success([
        for (final MapEntry(key: code, value: perTry) in result.perTry.entries)
          if (perTry > Decimal.zero)
            Quote(
              instrument: (type: AssetType.currency, code: code),
              // API gives units per 1 TRY; invert to TRY per unit.
              priceTry: (Decimal.one / perTry).toDecimal(
                scaleOnInfinitePrecision: priceScale,
              ),
              source: QuoteSource.frankfurter,
              fetchedAt: now,
              asOf: result.date,
            ),
      ]);
    } on DioException catch (e) {
      return Err(mapDioException(e));
    }
  }
}
