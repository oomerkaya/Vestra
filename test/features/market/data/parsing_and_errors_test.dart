import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestra/core/error/failure.dart';
import 'package:vestra/core/network/dio_failure_mapper.dart';
import 'package:vestra/features/market/data/dto/burkut_dtos.dart';
import 'package:vestra/features/market/data/dto/json_parsing.dart';

import '../../../helpers/fixtures.dart';

DioException _http(int status, {Object? data, Map<String, String>? headers}) {
  final options = RequestOptions(path: '/x');
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response<Object?>(
      requestOptions: options,
      statusCode: status,
      data: data,
      headers: Headers.fromMap({
        for (final e in (headers ?? {}).entries) e.key: [e.value],
      }),
    ),
  );
}

void main() {
  group('json parsing', () {
    test('parseDecimal handles num, string and comma decimals', () {
      expect(parseDecimal(42), d('42'));
      expect(parseDecimal(41.25), d('41.25'));
      expect(parseDecimal('3456,78'), d('3456.78'));
      expect(parseDecimal(''), isNull);
      expect(parseDecimal('abc'), isNull);
      expect(parseDecimal(null), isNull);
    });

    test('unwrapList accepts bare lists and {data: [...]}', () {
      expect(
        unwrapList([
          {'a': 1},
        ]),
        hasLength(1),
      );
      expect(
        unwrapList({
          'data': [
            {'a': 1},
            'junk',
          ],
        }),
        hasLength(1),
      );
      expect(unwrapList({'error': 'x'}), isEmpty);
    });

    test('parseDateTime handles ISO and unix seconds', () {
      expect(
        parseDateTime('2026-11-17T10:15:00Z'),
        DateTime.utc(2026, 11, 17, 10, 15),
      );
      expect(parseDateTime(0), DateTime.utc(1970));
    });
  });

  group('BurkutPriceDto (REST spec and SDK field names)', () {
    BurkutPriceDto? parse(Map<String, dynamic> json) =>
        BurkutPriceDto.fromJson({'symbol': 'x', ...json});

    test('price: buying, then price, then last_price', () {
      expect(parse({'buying': 1, 'price': 2, 'last_price': 3})!.price, d('1'));
      expect(parse({'price': 2, 'last_price': '3'})!.price, d('2'));
      expect(parse({'last_price': '312.50'})!.price, d('312.50'));
      expect(parse({'selling': 4}), isNull, reason: 'no usable price');
    });

    test('change: changePercent, dailyChangePct or change_rate', () {
      expect(
        parse({'price': 1, 'changePercent': 2.44})!.changePercent,
        d('2.44'),
      );
      expect(
        parse({'price': 1, 'dailyChangePct': 0.62})!.changePercent,
        d('0.62'),
      );
      expect(
        parse({'price': 1, 'change_rate': -0.35})!.changePercent,
        d('-0.35'),
      );
    });

    test('time: updatedAt or time', () {
      expect(
        parse({'price': 1, 'updatedAt': '2026-10-15T15:30:00Z'})!.updatedAt,
        DateTime.utc(2026, 10, 15, 15, 30),
      );
      expect(
        parse({'price': 1, 'time': '2026-10-15T15:30:00Z'})!.updatedAt,
        DateTime.utc(2026, 10, 15, 15, 30),
      );
    });

    test('symbol is upper-cased; missing symbol drops the item', () {
      expect(parse({'price': 1})!.symbol, 'X');
      expect(BurkutPriceDto.fromJson({'price': 1}), isNull);
    });

    test('isTry is derived from unit', () {
      expect(parse({'price': 1, 'unit': 'TL/Gr'})!.isTry, isTrue);
      expect(parse({'price': 1, 'unit': 'TL/Adet'})!.isTry, isTrue);
      expect(parse({'price': 1})!.isTry, isTrue);
      expect(parse({'price': 1, 'unit': 'USD/Ons'})!.isTry, isFalse);
    });
  });

  group('mapDioException', () {
    test('timeouts and connection errors are network failures', () {
      final e = DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.connectionError,
      );
      expect(mapDioException(e), isA<NetworkFailure>());
    });

    test('401/403 are auth failures (key rejected, not missing)', () {
      final failure = mapDioException(_http(401));
      expect(failure, isA<AuthFailure>());
      expect((failure as AuthFailure).missingKey, isFalse);
      expect(mapDioException(_http(403)), isA<AuthFailure>());
    });

    test('429 with monthly quota code is QuotaExceeded', () {
      expect(
        mapDioException(_http(429, data: {'error': 'MONTHLY_QUOTA_EXCEEDED'})),
        isA<QuotaExceededFailure>(),
      );
      expect(
        mapDioException(_http(429, data: {'message': 'Aylık kota tükendi'})),
        isA<QuotaExceededFailure>(),
      );
    });

    test('plain 429 is a rate limit with Retry-After', () {
      final failure = mapDioException(
        _http(429, headers: {'retry-after': '20'}),
      );
      expect(failure, isA<RateLimitFailure>());
      expect(
        (failure as RateLimitFailure).retryAfter,
        const Duration(seconds: 20),
      );
    });

    test('5xx is a server failure', () {
      final failure = mapDioException(_http(503));
      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).statusCode, 503);
    });
  });
}
