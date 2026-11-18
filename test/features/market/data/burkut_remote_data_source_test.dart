import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestra/features/market/data/datasources/burkut_remote_data_source.dart';

import '../../../helpers/fixtures.dart';

/// Answers every request with a fixed JSON body and headers, and records
/// what was sent. No real network access.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.body, {this.headers = const {}});

  final Object body;
  final Map<String, List<String>> headers;
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
        ...headers,
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  (BurkutRemoteDataSource, _FakeAdapter) build(
    Object body, {
    Map<String, List<String>> headers = const {},
  }) {
    final adapter = _FakeAdapter(body, headers: headers);
    final dio = Dio(BaseOptions(baseUrl: BurkutRemoteDataSource.baseUrl))
      ..httpClientAdapter = adapter;
    return (BurkutRemoteDataSource(dio), adapter);
  }

  test('sends the key in X-API-Key and reads X-Quota-Remaining', () async {
    final (source, adapter) = build(
      [
        {'symbol': 'USD', 'price': 38.42},
      ],
      headers: {
        'x-quota-remaining': ['687'],
      },
    );

    final response = await source.getForex('bk_live_fake');

    expect(adapter.lastRequest!.headers['X-API-Key'], 'bk_live_fake');
    expect(adapter.lastRequest!.path, '/forex');
    expect(response.quotaRemaining, 687);
    expect(response.items.single.price, d('38.42'));
  });

  test('accepts a {data: [...]} envelope and a missing quota header', () async {
    final (source, _) = build({
      'data': [
        {'symbol': 'ALTIN', 'buying': 3178.2},
      ],
    });

    final response = await source.getGold('bk_live_fake');

    expect(response.items.single.symbol, 'ALTIN');
    expect(response.quotaRemaining, isNull);
  });

  test('/stocks returns the whole market; only wanted symbols kept', () async {
    final (source, adapter) = build([
      {'symbol': 'THYAO', 'price': 304.5, 'changePercent': 2.44},
      {'symbol': 'GARAN', 'price': 118.2, 'changePercent': -0.67},
      {'symbol': 'ASELS', 'price': 65.9},
    ]);

    final response = await source.getStocks('bk_live_fake', [
      'thyao',
      'ASELS',
    ]);

    expect(response.items.map((i) => i.symbol), ['THYAO', 'ASELS']);
    expect(adapter.lastRequest!.queryParameters['symbols'], 'THYAO,ASELS');
  });
}
