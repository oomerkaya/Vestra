import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vestra/features/market/domain/entities/bist_indices.dart';

/// Guards the bundled index file: wrong edits are caught in CI.
void main() {
  final indices = BistIndices.fromJson(
    jsonDecode(File('assets/data/bist_indices.json').readAsStringSync())
        as Map<String, dynamic>,
  );

  test('asset has 30 and 100 unique symbols', () {
    expect(indices.bist30, hasLength(30));
    expect(indices.bist100, hasLength(100));
  });

  test('every BIST 30 stock is also in BIST 100', () {
    expect(indices.bist100.containsAll(indices.bist30), isTrue);
  });

  test('symbols look like BIST tickers', () {
    final ticker = RegExp(r'^[A-Z0-9]{3,6}$');
    expect(indices.bist100.every(ticker.hasMatch), isTrue);
  });

  test('isOutdated after validUntil', () {
    final until = indices.validUntil;
    expect(indices.isOutdated(until), isFalse);
    expect(indices.isOutdated(until.add(const Duration(days: 2))), isTrue);
  });
}
