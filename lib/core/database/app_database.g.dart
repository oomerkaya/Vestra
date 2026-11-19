// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AssetsTable extends Assets with TableInfo<$AssetsTable, AssetRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, type, code, name, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assets';
  @override
  VerificationContext validateIntegrity(
    Insertable<AssetRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {type, code},
  ];
  @override
  AssetRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssetRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AssetsTable createAlias(String alias) {
    return $AssetsTable(attachedDatabase, alias);
  }
}

class AssetRow extends DataClass implements Insertable<AssetRow> {
  final int id;

  /// currency | gold | silver | stock
  final String type;

  /// e.g. USD, GRAM, CEYREK, SILVER_GRAM, THYAO
  final String code;
  final String name;
  final DateTime createdAt;
  const AssetRow({
    required this.id,
    required this.type,
    required this.code,
    required this.name,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AssetsCompanion toCompanion(bool nullToAbsent) {
    return AssetsCompanion(
      id: Value(id),
      type: Value(type),
      code: Value(code),
      name: Value(name),
      createdAt: Value(createdAt),
    );
  }

  factory AssetRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssetRow(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AssetRow copyWith({
    int? id,
    String? type,
    String? code,
    String? name,
    DateTime? createdAt,
  }) => AssetRow(
    id: id ?? this.id,
    type: type ?? this.type,
    code: code ?? this.code,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
  );
  AssetRow copyWithCompanion(AssetsCompanion data) {
    return AssetRow(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssetRow(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, code, name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssetRow &&
          other.id == this.id &&
          other.type == this.type &&
          other.code == this.code &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class AssetsCompanion extends UpdateCompanion<AssetRow> {
  final Value<int> id;
  final Value<String> type;
  final Value<String> code;
  final Value<String> name;
  final Value<DateTime> createdAt;
  const AssetsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AssetsCompanion.insert({
    this.id = const Value.absent(),
    required String type,
    required String code,
    required String name,
    this.createdAt = const Value.absent(),
  }) : type = Value(type),
       code = Value(code),
       name = Value(name);
  static Insertable<AssetRow> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<String>? code,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AssetsCompanion copyWith({
    Value<int>? id,
    Value<String>? type,
    Value<String>? code,
    Value<String>? name,
    Value<DateTime>? createdAt,
  }) {
    return AssetsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      code: code ?? this.code,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssetsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AssetTransactionsTable extends AssetTransactions
    with TableInfo<$AssetTransactionsTable, TransactionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssetTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _assetIdMeta = const VerificationMeta(
    'assetId',
  );
  @override
  late final GeneratedColumn<int> assetId = GeneratedColumn<int>(
    'asset_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES assets (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Decimal, String> quantity =
      GeneratedColumn<String>(
        'quantity',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Decimal>($AssetTransactionsTable.$converterquantity);
  @override
  late final GeneratedColumnWithTypeConverter<Decimal?, String> unitPriceTry =
      GeneratedColumn<String>(
        'unit_price_try',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Decimal?>(
        $AssetTransactionsTable.$converterunitPriceTryn,
      );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    assetId,
    kind,
    quantity,
    unitPriceTry,
    date,
    note,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'asset_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('asset_id')) {
      context.handle(
        _assetIdMeta,
        assetId.isAcceptableOrUnknown(data['asset_id']!, _assetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_assetIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      assetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}asset_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      quantity: $AssetTransactionsTable.$converterquantity.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}quantity'],
        )!,
      ),
      unitPriceTry: $AssetTransactionsTable.$converterunitPriceTryn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}unit_price_try'],
        ),
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AssetTransactionsTable createAlias(String alias) {
    return $AssetTransactionsTable(attachedDatabase, alias);
  }

  static TypeConverter<Decimal, String> $converterquantity =
      const DecimalConverter();
  static TypeConverter<Decimal, String> $converterunitPriceTry =
      const DecimalConverter();
  static TypeConverter<Decimal?, String?> $converterunitPriceTryn =
      NullAwareTypeConverter.wrap($converterunitPriceTry);
}

class TransactionRow extends DataClass implements Insertable<TransactionRow> {
  final int id;
  final int assetId;

  /// buy | sell
  final String kind;
  final Decimal quantity;

  /// Price per unit in TRY. Null when the user does not know the cost.
  final Decimal? unitPriceTry;
  final DateTime date;
  final String? note;
  final DateTime createdAt;
  const TransactionRow({
    required this.id,
    required this.assetId,
    required this.kind,
    required this.quantity,
    this.unitPriceTry,
    required this.date,
    this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['asset_id'] = Variable<int>(assetId);
    map['kind'] = Variable<String>(kind);
    {
      map['quantity'] = Variable<String>(
        $AssetTransactionsTable.$converterquantity.toSql(quantity),
      );
    }
    if (!nullToAbsent || unitPriceTry != null) {
      map['unit_price_try'] = Variable<String>(
        $AssetTransactionsTable.$converterunitPriceTryn.toSql(unitPriceTry),
      );
    }
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AssetTransactionsCompanion toCompanion(bool nullToAbsent) {
    return AssetTransactionsCompanion(
      id: Value(id),
      assetId: Value(assetId),
      kind: Value(kind),
      quantity: Value(quantity),
      unitPriceTry: unitPriceTry == null && nullToAbsent
          ? const Value.absent()
          : Value(unitPriceTry),
      date: Value(date),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory TransactionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionRow(
      id: serializer.fromJson<int>(json['id']),
      assetId: serializer.fromJson<int>(json['assetId']),
      kind: serializer.fromJson<String>(json['kind']),
      quantity: serializer.fromJson<Decimal>(json['quantity']),
      unitPriceTry: serializer.fromJson<Decimal?>(json['unitPriceTry']),
      date: serializer.fromJson<DateTime>(json['date']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'assetId': serializer.toJson<int>(assetId),
      'kind': serializer.toJson<String>(kind),
      'quantity': serializer.toJson<Decimal>(quantity),
      'unitPriceTry': serializer.toJson<Decimal?>(unitPriceTry),
      'date': serializer.toJson<DateTime>(date),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TransactionRow copyWith({
    int? id,
    int? assetId,
    String? kind,
    Decimal? quantity,
    Value<Decimal?> unitPriceTry = const Value.absent(),
    DateTime? date,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
  }) => TransactionRow(
    id: id ?? this.id,
    assetId: assetId ?? this.assetId,
    kind: kind ?? this.kind,
    quantity: quantity ?? this.quantity,
    unitPriceTry: unitPriceTry.present ? unitPriceTry.value : this.unitPriceTry,
    date: date ?? this.date,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  TransactionRow copyWithCompanion(AssetTransactionsCompanion data) {
    return TransactionRow(
      id: data.id.present ? data.id.value : this.id,
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
      kind: data.kind.present ? data.kind.value : this.kind,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPriceTry: data.unitPriceTry.present
          ? data.unitPriceTry.value
          : this.unitPriceTry,
      date: data.date.present ? data.date.value : this.date,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionRow(')
          ..write('id: $id, ')
          ..write('assetId: $assetId, ')
          ..write('kind: $kind, ')
          ..write('quantity: $quantity, ')
          ..write('unitPriceTry: $unitPriceTry, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    assetId,
    kind,
    quantity,
    unitPriceTry,
    date,
    note,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionRow &&
          other.id == this.id &&
          other.assetId == this.assetId &&
          other.kind == this.kind &&
          other.quantity == this.quantity &&
          other.unitPriceTry == this.unitPriceTry &&
          other.date == this.date &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class AssetTransactionsCompanion extends UpdateCompanion<TransactionRow> {
  final Value<int> id;
  final Value<int> assetId;
  final Value<String> kind;
  final Value<Decimal> quantity;
  final Value<Decimal?> unitPriceTry;
  final Value<DateTime> date;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  const AssetTransactionsCompanion({
    this.id = const Value.absent(),
    this.assetId = const Value.absent(),
    this.kind = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPriceTry = const Value.absent(),
    this.date = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AssetTransactionsCompanion.insert({
    this.id = const Value.absent(),
    required int assetId,
    required String kind,
    required Decimal quantity,
    this.unitPriceTry = const Value.absent(),
    required DateTime date,
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : assetId = Value(assetId),
       kind = Value(kind),
       quantity = Value(quantity),
       date = Value(date);
  static Insertable<TransactionRow> custom({
    Expression<int>? id,
    Expression<int>? assetId,
    Expression<String>? kind,
    Expression<String>? quantity,
    Expression<String>? unitPriceTry,
    Expression<DateTime>? date,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (assetId != null) 'asset_id': assetId,
      if (kind != null) 'kind': kind,
      if (quantity != null) 'quantity': quantity,
      if (unitPriceTry != null) 'unit_price_try': unitPriceTry,
      if (date != null) 'date': date,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AssetTransactionsCompanion copyWith({
    Value<int>? id,
    Value<int>? assetId,
    Value<String>? kind,
    Value<Decimal>? quantity,
    Value<Decimal?>? unitPriceTry,
    Value<DateTime>? date,
    Value<String?>? note,
    Value<DateTime>? createdAt,
  }) {
    return AssetTransactionsCompanion(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      kind: kind ?? this.kind,
      quantity: quantity ?? this.quantity,
      unitPriceTry: unitPriceTry ?? this.unitPriceTry,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (assetId.present) {
      map['asset_id'] = Variable<int>(assetId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<String>(
        $AssetTransactionsTable.$converterquantity.toSql(quantity.value),
      );
    }
    if (unitPriceTry.present) {
      map['unit_price_try'] = Variable<String>(
        $AssetTransactionsTable.$converterunitPriceTryn.toSql(
          unitPriceTry.value,
        ),
      );
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssetTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('assetId: $assetId, ')
          ..write('kind: $kind, ')
          ..write('quantity: $quantity, ')
          ..write('unitPriceTry: $unitPriceTry, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PriceCacheTable extends PriceCache
    with TableInfo<$PriceCacheTable, PriceCacheRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PriceCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Decimal, String> priceTry =
      GeneratedColumn<String>(
        'price_try',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Decimal>($PriceCacheTable.$converterpriceTry);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Decimal?, String> changePercent =
      GeneratedColumn<String>(
        'change_percent',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Decimal?>($PriceCacheTable.$converterchangePercentn);
  static const VerificationMeta _asOfMeta = const VerificationMeta('asOf');
  @override
  late final GeneratedColumn<DateTime> asOf = GeneratedColumn<DateTime>(
    'as_of',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    type,
    code,
    priceTry,
    source,
    fetchedAt,
    name,
    changePercent,
    asOf,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'price_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<PriceCacheRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('as_of')) {
      context.handle(
        _asOfMeta,
        asOf.isAcceptableOrUnknown(data['as_of']!, _asOfMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {type, code};
  @override
  PriceCacheRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PriceCacheRow(
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      priceTry: $PriceCacheTable.$converterpriceTry.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}price_try'],
        )!,
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      changePercent: $PriceCacheTable.$converterchangePercentn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}change_percent'],
        ),
      ),
      asOf: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}as_of'],
      ),
    );
  }

  @override
  $PriceCacheTable createAlias(String alias) {
    return $PriceCacheTable(attachedDatabase, alias);
  }

  static TypeConverter<Decimal, String> $converterpriceTry =
      const DecimalConverter();
  static TypeConverter<Decimal, String> $converterchangePercent =
      const DecimalConverter();
  static TypeConverter<Decimal?, String?> $converterchangePercentn =
      NullAwareTypeConverter.wrap($converterchangePercent);
}

class PriceCacheRow extends DataClass implements Insertable<PriceCacheRow> {
  final String type;
  final String code;
  final Decimal priceTry;
  final String source;
  final DateTime fetchedAt;

  /// Display name from the provider (v2).
  final String? name;

  /// Daily change in percent, e.g. `1.27` (v2).
  final Decimal? changePercent;

  /// Provider's own timestamp of the price, if given (v2).
  final DateTime? asOf;
  const PriceCacheRow({
    required this.type,
    required this.code,
    required this.priceTry,
    required this.source,
    required this.fetchedAt,
    this.name,
    this.changePercent,
    this.asOf,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['type'] = Variable<String>(type);
    map['code'] = Variable<String>(code);
    {
      map['price_try'] = Variable<String>(
        $PriceCacheTable.$converterpriceTry.toSql(priceTry),
      );
    }
    map['source'] = Variable<String>(source);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || changePercent != null) {
      map['change_percent'] = Variable<String>(
        $PriceCacheTable.$converterchangePercentn.toSql(changePercent),
      );
    }
    if (!nullToAbsent || asOf != null) {
      map['as_of'] = Variable<DateTime>(asOf);
    }
    return map;
  }

  PriceCacheCompanion toCompanion(bool nullToAbsent) {
    return PriceCacheCompanion(
      type: Value(type),
      code: Value(code),
      priceTry: Value(priceTry),
      source: Value(source),
      fetchedAt: Value(fetchedAt),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      changePercent: changePercent == null && nullToAbsent
          ? const Value.absent()
          : Value(changePercent),
      asOf: asOf == null && nullToAbsent ? const Value.absent() : Value(asOf),
    );
  }

  factory PriceCacheRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PriceCacheRow(
      type: serializer.fromJson<String>(json['type']),
      code: serializer.fromJson<String>(json['code']),
      priceTry: serializer.fromJson<Decimal>(json['priceTry']),
      source: serializer.fromJson<String>(json['source']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
      name: serializer.fromJson<String?>(json['name']),
      changePercent: serializer.fromJson<Decimal?>(json['changePercent']),
      asOf: serializer.fromJson<DateTime?>(json['asOf']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'type': serializer.toJson<String>(type),
      'code': serializer.toJson<String>(code),
      'priceTry': serializer.toJson<Decimal>(priceTry),
      'source': serializer.toJson<String>(source),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
      'name': serializer.toJson<String?>(name),
      'changePercent': serializer.toJson<Decimal?>(changePercent),
      'asOf': serializer.toJson<DateTime?>(asOf),
    };
  }

  PriceCacheRow copyWith({
    String? type,
    String? code,
    Decimal? priceTry,
    String? source,
    DateTime? fetchedAt,
    Value<String?> name = const Value.absent(),
    Value<Decimal?> changePercent = const Value.absent(),
    Value<DateTime?> asOf = const Value.absent(),
  }) => PriceCacheRow(
    type: type ?? this.type,
    code: code ?? this.code,
    priceTry: priceTry ?? this.priceTry,
    source: source ?? this.source,
    fetchedAt: fetchedAt ?? this.fetchedAt,
    name: name.present ? name.value : this.name,
    changePercent: changePercent.present
        ? changePercent.value
        : this.changePercent,
    asOf: asOf.present ? asOf.value : this.asOf,
  );
  PriceCacheRow copyWithCompanion(PriceCacheCompanion data) {
    return PriceCacheRow(
      type: data.type.present ? data.type.value : this.type,
      code: data.code.present ? data.code.value : this.code,
      priceTry: data.priceTry.present ? data.priceTry.value : this.priceTry,
      source: data.source.present ? data.source.value : this.source,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
      name: data.name.present ? data.name.value : this.name,
      changePercent: data.changePercent.present
          ? data.changePercent.value
          : this.changePercent,
      asOf: data.asOf.present ? data.asOf.value : this.asOf,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PriceCacheRow(')
          ..write('type: $type, ')
          ..write('code: $code, ')
          ..write('priceTry: $priceTry, ')
          ..write('source: $source, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('name: $name, ')
          ..write('changePercent: $changePercent, ')
          ..write('asOf: $asOf')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    type,
    code,
    priceTry,
    source,
    fetchedAt,
    name,
    changePercent,
    asOf,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PriceCacheRow &&
          other.type == this.type &&
          other.code == this.code &&
          other.priceTry == this.priceTry &&
          other.source == this.source &&
          other.fetchedAt == this.fetchedAt &&
          other.name == this.name &&
          other.changePercent == this.changePercent &&
          other.asOf == this.asOf);
}

class PriceCacheCompanion extends UpdateCompanion<PriceCacheRow> {
  final Value<String> type;
  final Value<String> code;
  final Value<Decimal> priceTry;
  final Value<String> source;
  final Value<DateTime> fetchedAt;
  final Value<String?> name;
  final Value<Decimal?> changePercent;
  final Value<DateTime?> asOf;
  final Value<int> rowid;
  const PriceCacheCompanion({
    this.type = const Value.absent(),
    this.code = const Value.absent(),
    this.priceTry = const Value.absent(),
    this.source = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.changePercent = const Value.absent(),
    this.asOf = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PriceCacheCompanion.insert({
    required String type,
    required String code,
    required Decimal priceTry,
    required String source,
    required DateTime fetchedAt,
    this.name = const Value.absent(),
    this.changePercent = const Value.absent(),
    this.asOf = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : type = Value(type),
       code = Value(code),
       priceTry = Value(priceTry),
       source = Value(source),
       fetchedAt = Value(fetchedAt);
  static Insertable<PriceCacheRow> custom({
    Expression<String>? type,
    Expression<String>? code,
    Expression<String>? priceTry,
    Expression<String>? source,
    Expression<DateTime>? fetchedAt,
    Expression<String>? name,
    Expression<String>? changePercent,
    Expression<DateTime>? asOf,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (type != null) 'type': type,
      if (code != null) 'code': code,
      if (priceTry != null) 'price_try': priceTry,
      if (source != null) 'source': source,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (name != null) 'name': name,
      if (changePercent != null) 'change_percent': changePercent,
      if (asOf != null) 'as_of': asOf,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PriceCacheCompanion copyWith({
    Value<String>? type,
    Value<String>? code,
    Value<Decimal>? priceTry,
    Value<String>? source,
    Value<DateTime>? fetchedAt,
    Value<String?>? name,
    Value<Decimal?>? changePercent,
    Value<DateTime?>? asOf,
    Value<int>? rowid,
  }) {
    return PriceCacheCompanion(
      type: type ?? this.type,
      code: code ?? this.code,
      priceTry: priceTry ?? this.priceTry,
      source: source ?? this.source,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      name: name ?? this.name,
      changePercent: changePercent ?? this.changePercent,
      asOf: asOf ?? this.asOf,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (priceTry.present) {
      map['price_try'] = Variable<String>(
        $PriceCacheTable.$converterpriceTry.toSql(priceTry.value),
      );
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (changePercent.present) {
      map['change_percent'] = Variable<String>(
        $PriceCacheTable.$converterchangePercentn.toSql(changePercent.value),
      );
    }
    if (asOf.present) {
      map['as_of'] = Variable<DateTime>(asOf.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PriceCacheCompanion(')
          ..write('type: $type, ')
          ..write('code: $code, ')
          ..write('priceTry: $priceTry, ')
          ..write('source: $source, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('name: $name, ')
          ..write('changePercent: $changePercent, ')
          ..write('asOf: $asOf, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  final String key;
  final String value;
  const SettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory SettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingRow copyWith({String? key, String? value}) =>
      SettingRow(key: key ?? this.key, value: value ?? this.value);
  SettingRow copyWithCompanion(AppSettingsCompanion data) {
    return SettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KapDisclosuresTable extends KapDisclosures
    with TableInfo<$KapDisclosuresTable, KapDisclosureRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KapDisclosuresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
    'symbol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _publishedAtMeta = const VerificationMeta(
    'publishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> publishedAt = GeneratedColumn<DateTime>(
    'published_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    symbol,
    title,
    summary,
    url,
    publishedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'kap_disclosures';
  @override
  VerificationContext validateIntegrity(
    Insertable<KapDisclosureRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('symbol')) {
      context.handle(
        _symbolMeta,
        symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta),
      );
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    }
    if (data.containsKey('published_at')) {
      context.handle(
        _publishedAtMeta,
        publishedAt.isAcceptableOrUnknown(
          data['published_at']!,
          _publishedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_publishedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KapDisclosureRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KapDisclosureRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      symbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symbol'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      ),
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      ),
      publishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}published_at'],
      )!,
    );
  }

  @override
  $KapDisclosuresTable createAlias(String alias) {
    return $KapDisclosuresTable(attachedDatabase, alias);
  }
}

class KapDisclosureRow extends DataClass
    implements Insertable<KapDisclosureRow> {
  /// Bürküt's id of the disclosure.
  final String id;
  final String symbol;
  final String title;
  final String? summary;

  /// Link to the original disclosure on kap.org.tr, if given.
  final String? url;
  final DateTime publishedAt;
  const KapDisclosureRow({
    required this.id,
    required this.symbol,
    required this.title,
    this.summary,
    this.url,
    required this.publishedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['symbol'] = Variable<String>(symbol);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || summary != null) {
      map['summary'] = Variable<String>(summary);
    }
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    map['published_at'] = Variable<DateTime>(publishedAt);
    return map;
  }

  KapDisclosuresCompanion toCompanion(bool nullToAbsent) {
    return KapDisclosuresCompanion(
      id: Value(id),
      symbol: Value(symbol),
      title: Value(title),
      summary: summary == null && nullToAbsent
          ? const Value.absent()
          : Value(summary),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
      publishedAt: Value(publishedAt),
    );
  }

  factory KapDisclosureRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KapDisclosureRow(
      id: serializer.fromJson<String>(json['id']),
      symbol: serializer.fromJson<String>(json['symbol']),
      title: serializer.fromJson<String>(json['title']),
      summary: serializer.fromJson<String?>(json['summary']),
      url: serializer.fromJson<String?>(json['url']),
      publishedAt: serializer.fromJson<DateTime>(json['publishedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'symbol': serializer.toJson<String>(symbol),
      'title': serializer.toJson<String>(title),
      'summary': serializer.toJson<String?>(summary),
      'url': serializer.toJson<String?>(url),
      'publishedAt': serializer.toJson<DateTime>(publishedAt),
    };
  }

  KapDisclosureRow copyWith({
    String? id,
    String? symbol,
    String? title,
    Value<String?> summary = const Value.absent(),
    Value<String?> url = const Value.absent(),
    DateTime? publishedAt,
  }) => KapDisclosureRow(
    id: id ?? this.id,
    symbol: symbol ?? this.symbol,
    title: title ?? this.title,
    summary: summary.present ? summary.value : this.summary,
    url: url.present ? url.value : this.url,
    publishedAt: publishedAt ?? this.publishedAt,
  );
  KapDisclosureRow copyWithCompanion(KapDisclosuresCompanion data) {
    return KapDisclosureRow(
      id: data.id.present ? data.id.value : this.id,
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      title: data.title.present ? data.title.value : this.title,
      summary: data.summary.present ? data.summary.value : this.summary,
      url: data.url.present ? data.url.value : this.url,
      publishedAt: data.publishedAt.present
          ? data.publishedAt.value
          : this.publishedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KapDisclosureRow(')
          ..write('id: $id, ')
          ..write('symbol: $symbol, ')
          ..write('title: $title, ')
          ..write('summary: $summary, ')
          ..write('url: $url, ')
          ..write('publishedAt: $publishedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, symbol, title, summary, url, publishedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KapDisclosureRow &&
          other.id == this.id &&
          other.symbol == this.symbol &&
          other.title == this.title &&
          other.summary == this.summary &&
          other.url == this.url &&
          other.publishedAt == this.publishedAt);
}

class KapDisclosuresCompanion extends UpdateCompanion<KapDisclosureRow> {
  final Value<String> id;
  final Value<String> symbol;
  final Value<String> title;
  final Value<String?> summary;
  final Value<String?> url;
  final Value<DateTime> publishedAt;
  final Value<int> rowid;
  const KapDisclosuresCompanion({
    this.id = const Value.absent(),
    this.symbol = const Value.absent(),
    this.title = const Value.absent(),
    this.summary = const Value.absent(),
    this.url = const Value.absent(),
    this.publishedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KapDisclosuresCompanion.insert({
    required String id,
    required String symbol,
    required String title,
    this.summary = const Value.absent(),
    this.url = const Value.absent(),
    required DateTime publishedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       symbol = Value(symbol),
       title = Value(title),
       publishedAt = Value(publishedAt);
  static Insertable<KapDisclosureRow> custom({
    Expression<String>? id,
    Expression<String>? symbol,
    Expression<String>? title,
    Expression<String>? summary,
    Expression<String>? url,
    Expression<DateTime>? publishedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (symbol != null) 'symbol': symbol,
      if (title != null) 'title': title,
      if (summary != null) 'summary': summary,
      if (url != null) 'url': url,
      if (publishedAt != null) 'published_at': publishedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KapDisclosuresCompanion copyWith({
    Value<String>? id,
    Value<String>? symbol,
    Value<String>? title,
    Value<String?>? summary,
    Value<String?>? url,
    Value<DateTime>? publishedAt,
    Value<int>? rowid,
  }) {
    return KapDisclosuresCompanion(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      url: url ?? this.url,
      publishedAt: publishedAt ?? this.publishedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (publishedAt.present) {
      map['published_at'] = Variable<DateTime>(publishedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KapDisclosuresCompanion(')
          ..write('id: $id, ')
          ..write('symbol: $symbol, ')
          ..write('title: $title, ')
          ..write('summary: $summary, ')
          ..write('url: $url, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PortfolioSnapshotsTable extends PortfolioSnapshots
    with TableInfo<$PortfolioSnapshotsTable, PortfolioSnapshotRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PortfolioSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Decimal, String> valueTry =
      GeneratedColumn<String>(
        'value_try',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Decimal>($PortfolioSnapshotsTable.$convertervalueTry);
  @override
  late final GeneratedColumnWithTypeConverter<Decimal?, String> costTry =
      GeneratedColumn<String>(
        'cost_try',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Decimal?>($PortfolioSnapshotsTable.$convertercostTryn);
  @override
  late final GeneratedColumnWithTypeConverter<Decimal?, String> usdTry =
      GeneratedColumn<String>(
        'usd_try',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Decimal?>($PortfolioSnapshotsTable.$converterusdTryn);
  @override
  late final GeneratedColumnWithTypeConverter<Decimal?, String> eurTry =
      GeneratedColumn<String>(
        'eur_try',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Decimal?>($PortfolioSnapshotsTable.$convertereurTryn);
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    day,
    valueTry,
    costTry,
    usdTry,
    eurTry,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'portfolio_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<PortfolioSnapshotRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {day};
  @override
  PortfolioSnapshotRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PortfolioSnapshotRow(
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      valueTry: $PortfolioSnapshotsTable.$convertervalueTry.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}value_try'],
        )!,
      ),
      costTry: $PortfolioSnapshotsTable.$convertercostTryn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}cost_try'],
        ),
      ),
      usdTry: $PortfolioSnapshotsTable.$converterusdTryn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}usd_try'],
        ),
      ),
      eurTry: $PortfolioSnapshotsTable.$convertereurTryn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}eur_try'],
        ),
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PortfolioSnapshotsTable createAlias(String alias) {
    return $PortfolioSnapshotsTable(attachedDatabase, alias);
  }

  static TypeConverter<Decimal, String> $convertervalueTry =
      const DecimalConverter();
  static TypeConverter<Decimal, String> $convertercostTry =
      const DecimalConverter();
  static TypeConverter<Decimal?, String?> $convertercostTryn =
      NullAwareTypeConverter.wrap($convertercostTry);
  static TypeConverter<Decimal, String> $converterusdTry =
      const DecimalConverter();
  static TypeConverter<Decimal?, String?> $converterusdTryn =
      NullAwareTypeConverter.wrap($converterusdTry);
  static TypeConverter<Decimal, String> $convertereurTry =
      const DecimalConverter();
  static TypeConverter<Decimal?, String?> $convertereurTryn =
      NullAwareTypeConverter.wrap($convertereurTry);
}

class PortfolioSnapshotRow extends DataClass
    implements Insertable<PortfolioSnapshotRow> {
  /// `YYYY-MM-DD` in Istanbul time.
  final String day;
  final Decimal valueTry;

  /// Cost of the priced holdings whose cost is known.
  final Decimal? costTry;

  /// TRY per USD / EUR that day, to draw the history in those currencies.
  final Decimal? usdTry;
  final Decimal? eurTry;
  final DateTime updatedAt;
  const PortfolioSnapshotRow({
    required this.day,
    required this.valueTry,
    this.costTry,
    this.usdTry,
    this.eurTry,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day'] = Variable<String>(day);
    {
      map['value_try'] = Variable<String>(
        $PortfolioSnapshotsTable.$convertervalueTry.toSql(valueTry),
      );
    }
    if (!nullToAbsent || costTry != null) {
      map['cost_try'] = Variable<String>(
        $PortfolioSnapshotsTable.$convertercostTryn.toSql(costTry),
      );
    }
    if (!nullToAbsent || usdTry != null) {
      map['usd_try'] = Variable<String>(
        $PortfolioSnapshotsTable.$converterusdTryn.toSql(usdTry),
      );
    }
    if (!nullToAbsent || eurTry != null) {
      map['eur_try'] = Variable<String>(
        $PortfolioSnapshotsTable.$convertereurTryn.toSql(eurTry),
      );
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PortfolioSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return PortfolioSnapshotsCompanion(
      day: Value(day),
      valueTry: Value(valueTry),
      costTry: costTry == null && nullToAbsent
          ? const Value.absent()
          : Value(costTry),
      usdTry: usdTry == null && nullToAbsent
          ? const Value.absent()
          : Value(usdTry),
      eurTry: eurTry == null && nullToAbsent
          ? const Value.absent()
          : Value(eurTry),
      updatedAt: Value(updatedAt),
    );
  }

  factory PortfolioSnapshotRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PortfolioSnapshotRow(
      day: serializer.fromJson<String>(json['day']),
      valueTry: serializer.fromJson<Decimal>(json['valueTry']),
      costTry: serializer.fromJson<Decimal?>(json['costTry']),
      usdTry: serializer.fromJson<Decimal?>(json['usdTry']),
      eurTry: serializer.fromJson<Decimal?>(json['eurTry']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'day': serializer.toJson<String>(day),
      'valueTry': serializer.toJson<Decimal>(valueTry),
      'costTry': serializer.toJson<Decimal?>(costTry),
      'usdTry': serializer.toJson<Decimal?>(usdTry),
      'eurTry': serializer.toJson<Decimal?>(eurTry),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PortfolioSnapshotRow copyWith({
    String? day,
    Decimal? valueTry,
    Value<Decimal?> costTry = const Value.absent(),
    Value<Decimal?> usdTry = const Value.absent(),
    Value<Decimal?> eurTry = const Value.absent(),
    DateTime? updatedAt,
  }) => PortfolioSnapshotRow(
    day: day ?? this.day,
    valueTry: valueTry ?? this.valueTry,
    costTry: costTry.present ? costTry.value : this.costTry,
    usdTry: usdTry.present ? usdTry.value : this.usdTry,
    eurTry: eurTry.present ? eurTry.value : this.eurTry,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PortfolioSnapshotRow copyWithCompanion(PortfolioSnapshotsCompanion data) {
    return PortfolioSnapshotRow(
      day: data.day.present ? data.day.value : this.day,
      valueTry: data.valueTry.present ? data.valueTry.value : this.valueTry,
      costTry: data.costTry.present ? data.costTry.value : this.costTry,
      usdTry: data.usdTry.present ? data.usdTry.value : this.usdTry,
      eurTry: data.eurTry.present ? data.eurTry.value : this.eurTry,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PortfolioSnapshotRow(')
          ..write('day: $day, ')
          ..write('valueTry: $valueTry, ')
          ..write('costTry: $costTry, ')
          ..write('usdTry: $usdTry, ')
          ..write('eurTry: $eurTry, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(day, valueTry, costTry, usdTry, eurTry, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PortfolioSnapshotRow &&
          other.day == this.day &&
          other.valueTry == this.valueTry &&
          other.costTry == this.costTry &&
          other.usdTry == this.usdTry &&
          other.eurTry == this.eurTry &&
          other.updatedAt == this.updatedAt);
}

class PortfolioSnapshotsCompanion
    extends UpdateCompanion<PortfolioSnapshotRow> {
  final Value<String> day;
  final Value<Decimal> valueTry;
  final Value<Decimal?> costTry;
  final Value<Decimal?> usdTry;
  final Value<Decimal?> eurTry;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PortfolioSnapshotsCompanion({
    this.day = const Value.absent(),
    this.valueTry = const Value.absent(),
    this.costTry = const Value.absent(),
    this.usdTry = const Value.absent(),
    this.eurTry = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PortfolioSnapshotsCompanion.insert({
    required String day,
    required Decimal valueTry,
    this.costTry = const Value.absent(),
    this.usdTry = const Value.absent(),
    this.eurTry = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : day = Value(day),
       valueTry = Value(valueTry),
       updatedAt = Value(updatedAt);
  static Insertable<PortfolioSnapshotRow> custom({
    Expression<String>? day,
    Expression<String>? valueTry,
    Expression<String>? costTry,
    Expression<String>? usdTry,
    Expression<String>? eurTry,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (day != null) 'day': day,
      if (valueTry != null) 'value_try': valueTry,
      if (costTry != null) 'cost_try': costTry,
      if (usdTry != null) 'usd_try': usdTry,
      if (eurTry != null) 'eur_try': eurTry,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PortfolioSnapshotsCompanion copyWith({
    Value<String>? day,
    Value<Decimal>? valueTry,
    Value<Decimal?>? costTry,
    Value<Decimal?>? usdTry,
    Value<Decimal?>? eurTry,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PortfolioSnapshotsCompanion(
      day: day ?? this.day,
      valueTry: valueTry ?? this.valueTry,
      costTry: costTry ?? this.costTry,
      usdTry: usdTry ?? this.usdTry,
      eurTry: eurTry ?? this.eurTry,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (valueTry.present) {
      map['value_try'] = Variable<String>(
        $PortfolioSnapshotsTable.$convertervalueTry.toSql(valueTry.value),
      );
    }
    if (costTry.present) {
      map['cost_try'] = Variable<String>(
        $PortfolioSnapshotsTable.$convertercostTryn.toSql(costTry.value),
      );
    }
    if (usdTry.present) {
      map['usd_try'] = Variable<String>(
        $PortfolioSnapshotsTable.$converterusdTryn.toSql(usdTry.value),
      );
    }
    if (eurTry.present) {
      map['eur_try'] = Variable<String>(
        $PortfolioSnapshotsTable.$convertereurTryn.toSql(eurTry.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PortfolioSnapshotsCompanion(')
          ..write('day: $day, ')
          ..write('valueTry: $valueTry, ')
          ..write('costTry: $costTry, ')
          ..write('usdTry: $usdTry, ')
          ..write('eurTry: $eurTry, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AssetSnapshotsTable extends AssetSnapshots
    with TableInfo<$AssetSnapshotsTable, AssetSnapshotRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssetSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Decimal, String> quantity =
      GeneratedColumn<String>(
        'quantity',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Decimal>($AssetSnapshotsTable.$converterquantity);
  @override
  late final GeneratedColumnWithTypeConverter<Decimal, String> priceTry =
      GeneratedColumn<String>(
        'price_try',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Decimal>($AssetSnapshotsTable.$converterpriceTry);
  @override
  List<GeneratedColumn> get $columns => [day, type, code, quantity, priceTry];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'asset_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<AssetSnapshotRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {day, type, code};
  @override
  AssetSnapshotRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssetSnapshotRow(
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      quantity: $AssetSnapshotsTable.$converterquantity.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}quantity'],
        )!,
      ),
      priceTry: $AssetSnapshotsTable.$converterpriceTry.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}price_try'],
        )!,
      ),
    );
  }

  @override
  $AssetSnapshotsTable createAlias(String alias) {
    return $AssetSnapshotsTable(attachedDatabase, alias);
  }

  static TypeConverter<Decimal, String> $converterquantity =
      const DecimalConverter();
  static TypeConverter<Decimal, String> $converterpriceTry =
      const DecimalConverter();
}

class AssetSnapshotRow extends DataClass
    implements Insertable<AssetSnapshotRow> {
  final String day;
  final String type;
  final String code;
  final Decimal quantity;
  final Decimal priceTry;
  const AssetSnapshotRow({
    required this.day,
    required this.type,
    required this.code,
    required this.quantity,
    required this.priceTry,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day'] = Variable<String>(day);
    map['type'] = Variable<String>(type);
    map['code'] = Variable<String>(code);
    {
      map['quantity'] = Variable<String>(
        $AssetSnapshotsTable.$converterquantity.toSql(quantity),
      );
    }
    {
      map['price_try'] = Variable<String>(
        $AssetSnapshotsTable.$converterpriceTry.toSql(priceTry),
      );
    }
    return map;
  }

  AssetSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return AssetSnapshotsCompanion(
      day: Value(day),
      type: Value(type),
      code: Value(code),
      quantity: Value(quantity),
      priceTry: Value(priceTry),
    );
  }

  factory AssetSnapshotRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssetSnapshotRow(
      day: serializer.fromJson<String>(json['day']),
      type: serializer.fromJson<String>(json['type']),
      code: serializer.fromJson<String>(json['code']),
      quantity: serializer.fromJson<Decimal>(json['quantity']),
      priceTry: serializer.fromJson<Decimal>(json['priceTry']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'day': serializer.toJson<String>(day),
      'type': serializer.toJson<String>(type),
      'code': serializer.toJson<String>(code),
      'quantity': serializer.toJson<Decimal>(quantity),
      'priceTry': serializer.toJson<Decimal>(priceTry),
    };
  }

  AssetSnapshotRow copyWith({
    String? day,
    String? type,
    String? code,
    Decimal? quantity,
    Decimal? priceTry,
  }) => AssetSnapshotRow(
    day: day ?? this.day,
    type: type ?? this.type,
    code: code ?? this.code,
    quantity: quantity ?? this.quantity,
    priceTry: priceTry ?? this.priceTry,
  );
  AssetSnapshotRow copyWithCompanion(AssetSnapshotsCompanion data) {
    return AssetSnapshotRow(
      day: data.day.present ? data.day.value : this.day,
      type: data.type.present ? data.type.value : this.type,
      code: data.code.present ? data.code.value : this.code,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      priceTry: data.priceTry.present ? data.priceTry.value : this.priceTry,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssetSnapshotRow(')
          ..write('day: $day, ')
          ..write('type: $type, ')
          ..write('code: $code, ')
          ..write('quantity: $quantity, ')
          ..write('priceTry: $priceTry')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(day, type, code, quantity, priceTry);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssetSnapshotRow &&
          other.day == this.day &&
          other.type == this.type &&
          other.code == this.code &&
          other.quantity == this.quantity &&
          other.priceTry == this.priceTry);
}

class AssetSnapshotsCompanion extends UpdateCompanion<AssetSnapshotRow> {
  final Value<String> day;
  final Value<String> type;
  final Value<String> code;
  final Value<Decimal> quantity;
  final Value<Decimal> priceTry;
  final Value<int> rowid;
  const AssetSnapshotsCompanion({
    this.day = const Value.absent(),
    this.type = const Value.absent(),
    this.code = const Value.absent(),
    this.quantity = const Value.absent(),
    this.priceTry = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssetSnapshotsCompanion.insert({
    required String day,
    required String type,
    required String code,
    required Decimal quantity,
    required Decimal priceTry,
    this.rowid = const Value.absent(),
  }) : day = Value(day),
       type = Value(type),
       code = Value(code),
       quantity = Value(quantity),
       priceTry = Value(priceTry);
  static Insertable<AssetSnapshotRow> custom({
    Expression<String>? day,
    Expression<String>? type,
    Expression<String>? code,
    Expression<String>? quantity,
    Expression<String>? priceTry,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (day != null) 'day': day,
      if (type != null) 'type': type,
      if (code != null) 'code': code,
      if (quantity != null) 'quantity': quantity,
      if (priceTry != null) 'price_try': priceTry,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssetSnapshotsCompanion copyWith({
    Value<String>? day,
    Value<String>? type,
    Value<String>? code,
    Value<Decimal>? quantity,
    Value<Decimal>? priceTry,
    Value<int>? rowid,
  }) {
    return AssetSnapshotsCompanion(
      day: day ?? this.day,
      type: type ?? this.type,
      code: code ?? this.code,
      quantity: quantity ?? this.quantity,
      priceTry: priceTry ?? this.priceTry,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<String>(
        $AssetSnapshotsTable.$converterquantity.toSql(quantity.value),
      );
    }
    if (priceTry.present) {
      map['price_try'] = Variable<String>(
        $AssetSnapshotsTable.$converterpriceTry.toSql(priceTry.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssetSnapshotsCompanion(')
          ..write('day: $day, ')
          ..write('type: $type, ')
          ..write('code: $code, ')
          ..write('quantity: $quantity, ')
          ..write('priceTry: $priceTry, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GoalsTable extends Goals with TableInfo<$GoalsTable, GoalRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Decimal, String> target =
      GeneratedColumn<String>(
        'target',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Decimal>($GoalsTable.$convertertarget);
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _assetTypeMeta = const VerificationMeta(
    'assetType',
  );
  @override
  late final GeneratedColumn<String> assetType = GeneratedColumn<String>(
    'asset_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _assetCodeMeta = const VerificationMeta(
    'assetCode',
  );
  @override
  late final GeneratedColumn<String> assetCode = GeneratedColumn<String>(
    'asset_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    kind,
    target,
    currency,
    assetType,
    assetCode,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<GoalRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('asset_type')) {
      context.handle(
        _assetTypeMeta,
        assetType.isAcceptableOrUnknown(data['asset_type']!, _assetTypeMeta),
      );
    }
    if (data.containsKey('asset_code')) {
      context.handle(
        _assetCodeMeta,
        assetCode.isAcceptableOrUnknown(data['asset_code']!, _assetCodeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GoalRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoalRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      target: $GoalsTable.$convertertarget.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}target'],
        )!,
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      ),
      assetType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asset_type'],
      ),
      assetCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asset_code'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $GoalsTable createAlias(String alias) {
    return $GoalsTable(attachedDatabase, alias);
  }

  static TypeConverter<Decimal, String> $convertertarget =
      const DecimalConverter();
}

class GoalRow extends DataClass implements Insertable<GoalRow> {
  final int id;
  final String title;

  /// portfolioValue | assetQuantity
  final String kind;
  final Decimal target;

  /// Value goals: tryLira | usd | eur.
  final String? currency;

  /// Quantity goals: the instrument.
  final String? assetType;
  final String? assetCode;
  final DateTime createdAt;
  const GoalRow({
    required this.id,
    required this.title,
    required this.kind,
    required this.target,
    this.currency,
    this.assetType,
    this.assetCode,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['kind'] = Variable<String>(kind);
    {
      map['target'] = Variable<String>(
        $GoalsTable.$convertertarget.toSql(target),
      );
    }
    if (!nullToAbsent || currency != null) {
      map['currency'] = Variable<String>(currency);
    }
    if (!nullToAbsent || assetType != null) {
      map['asset_type'] = Variable<String>(assetType);
    }
    if (!nullToAbsent || assetCode != null) {
      map['asset_code'] = Variable<String>(assetCode);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  GoalsCompanion toCompanion(bool nullToAbsent) {
    return GoalsCompanion(
      id: Value(id),
      title: Value(title),
      kind: Value(kind),
      target: Value(target),
      currency: currency == null && nullToAbsent
          ? const Value.absent()
          : Value(currency),
      assetType: assetType == null && nullToAbsent
          ? const Value.absent()
          : Value(assetType),
      assetCode: assetCode == null && nullToAbsent
          ? const Value.absent()
          : Value(assetCode),
      createdAt: Value(createdAt),
    );
  }

  factory GoalRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoalRow(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      kind: serializer.fromJson<String>(json['kind']),
      target: serializer.fromJson<Decimal>(json['target']),
      currency: serializer.fromJson<String?>(json['currency']),
      assetType: serializer.fromJson<String?>(json['assetType']),
      assetCode: serializer.fromJson<String?>(json['assetCode']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'kind': serializer.toJson<String>(kind),
      'target': serializer.toJson<Decimal>(target),
      'currency': serializer.toJson<String?>(currency),
      'assetType': serializer.toJson<String?>(assetType),
      'assetCode': serializer.toJson<String?>(assetCode),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  GoalRow copyWith({
    int? id,
    String? title,
    String? kind,
    Decimal? target,
    Value<String?> currency = const Value.absent(),
    Value<String?> assetType = const Value.absent(),
    Value<String?> assetCode = const Value.absent(),
    DateTime? createdAt,
  }) => GoalRow(
    id: id ?? this.id,
    title: title ?? this.title,
    kind: kind ?? this.kind,
    target: target ?? this.target,
    currency: currency.present ? currency.value : this.currency,
    assetType: assetType.present ? assetType.value : this.assetType,
    assetCode: assetCode.present ? assetCode.value : this.assetCode,
    createdAt: createdAt ?? this.createdAt,
  );
  GoalRow copyWithCompanion(GoalsCompanion data) {
    return GoalRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      kind: data.kind.present ? data.kind.value : this.kind,
      target: data.target.present ? data.target.value : this.target,
      currency: data.currency.present ? data.currency.value : this.currency,
      assetType: data.assetType.present ? data.assetType.value : this.assetType,
      assetCode: data.assetCode.present ? data.assetCode.value : this.assetCode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoalRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('kind: $kind, ')
          ..write('target: $target, ')
          ..write('currency: $currency, ')
          ..write('assetType: $assetType, ')
          ..write('assetCode: $assetCode, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    kind,
    target,
    currency,
    assetType,
    assetCode,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.kind == this.kind &&
          other.target == this.target &&
          other.currency == this.currency &&
          other.assetType == this.assetType &&
          other.assetCode == this.assetCode &&
          other.createdAt == this.createdAt);
}

class GoalsCompanion extends UpdateCompanion<GoalRow> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> kind;
  final Value<Decimal> target;
  final Value<String?> currency;
  final Value<String?> assetType;
  final Value<String?> assetCode;
  final Value<DateTime> createdAt;
  const GoalsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.kind = const Value.absent(),
    this.target = const Value.absent(),
    this.currency = const Value.absent(),
    this.assetType = const Value.absent(),
    this.assetCode = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  GoalsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String kind,
    required Decimal target,
    this.currency = const Value.absent(),
    this.assetType = const Value.absent(),
    this.assetCode = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : title = Value(title),
       kind = Value(kind),
       target = Value(target);
  static Insertable<GoalRow> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? kind,
    Expression<String>? target,
    Expression<String>? currency,
    Expression<String>? assetType,
    Expression<String>? assetCode,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (kind != null) 'kind': kind,
      if (target != null) 'target': target,
      if (currency != null) 'currency': currency,
      if (assetType != null) 'asset_type': assetType,
      if (assetCode != null) 'asset_code': assetCode,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  GoalsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? kind,
    Value<Decimal>? target,
    Value<String?>? currency,
    Value<String?>? assetType,
    Value<String?>? assetCode,
    Value<DateTime>? createdAt,
  }) {
    return GoalsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      kind: kind ?? this.kind,
      target: target ?? this.target,
      currency: currency ?? this.currency,
      assetType: assetType ?? this.assetType,
      assetCode: assetCode ?? this.assetCode,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (target.present) {
      map['target'] = Variable<String>(
        $GoalsTable.$convertertarget.toSql(target.value),
      );
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (assetType.present) {
      map['asset_type'] = Variable<String>(assetType.value);
    }
    if (assetCode.present) {
      map['asset_code'] = Variable<String>(assetCode.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('kind: $kind, ')
          ..write('target: $target, ')
          ..write('currency: $currency, ')
          ..write('assetType: $assetType, ')
          ..write('assetCode: $assetCode, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AssetsTable assets = $AssetsTable(this);
  late final $AssetTransactionsTable assetTransactions =
      $AssetTransactionsTable(this);
  late final $PriceCacheTable priceCache = $PriceCacheTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $KapDisclosuresTable kapDisclosures = $KapDisclosuresTable(this);
  late final $PortfolioSnapshotsTable portfolioSnapshots =
      $PortfolioSnapshotsTable(this);
  late final $AssetSnapshotsTable assetSnapshots = $AssetSnapshotsTable(this);
  late final $GoalsTable goals = $GoalsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    assets,
    assetTransactions,
    priceCache,
    appSettings,
    kapDisclosures,
    portfolioSnapshots,
    assetSnapshots,
    goals,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'assets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('asset_transactions', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$AssetsTableCreateCompanionBuilder =
    AssetsCompanion Function({
      Value<int> id,
      required String type,
      required String code,
      required String name,
      Value<DateTime> createdAt,
    });
typedef $$AssetsTableUpdateCompanionBuilder =
    AssetsCompanion Function({
      Value<int> id,
      Value<String> type,
      Value<String> code,
      Value<String> name,
      Value<DateTime> createdAt,
    });

final class $$AssetsTableReferences
    extends BaseReferences<_$AppDatabase, $AssetsTable, AssetRow> {
  $$AssetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AssetTransactionsTable, List<TransactionRow>>
  _assetTransactionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.assetTransactions,
        aliasName: 'assets__id__asset_transactions__asset_id',
      );

  $$AssetTransactionsTableProcessedTableManager get assetTransactionsRefs {
    final manager = $$AssetTransactionsTableTableManager(
      $_db,
      $_db.assetTransactions,
    ).filter((f) => f.assetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _assetTransactionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AssetsTableFilterComposer
    extends Composer<_$AppDatabase, $AssetsTable> {
  $$AssetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> assetTransactionsRefs(
    Expression<bool> Function($$AssetTransactionsTableFilterComposer f) f,
  ) {
    final $$AssetTransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assetTransactions,
      getReferencedColumn: (t) => t.assetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetTransactionsTableFilterComposer(
            $db: $db,
            $table: $db.assetTransactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AssetsTableOrderingComposer
    extends Composer<_$AppDatabase, $AssetsTable> {
  $$AssetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AssetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssetsTable> {
  $$AssetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> assetTransactionsRefs<T extends Object>(
    Expression<T> Function($$AssetTransactionsTableAnnotationComposer a) f,
  ) {
    final $$AssetTransactionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.assetTransactions,
          getReferencedColumn: (t) => t.assetId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AssetTransactionsTableAnnotationComposer(
                $db: $db,
                $table: $db.assetTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$AssetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssetsTable,
          AssetRow,
          $$AssetsTableFilterComposer,
          $$AssetsTableOrderingComposer,
          $$AssetsTableAnnotationComposer,
          $$AssetsTableCreateCompanionBuilder,
          $$AssetsTableUpdateCompanionBuilder,
          (AssetRow, $$AssetsTableReferences),
          AssetRow,
          PrefetchHooks Function({bool assetTransactionsRefs})
        > {
  $$AssetsTableTableManager(_$AppDatabase db, $AssetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AssetsCompanion(
                id: id,
                type: type,
                code: code,
                name: name,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String type,
                required String code,
                required String name,
                Value<DateTime> createdAt = const Value.absent(),
              }) => AssetsCompanion.insert(
                id: id,
                type: type,
                code: code,
                name: name,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AssetsTable, AssetRow>(table),
                  $$AssetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({assetTransactionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (assetTransactionsRefs) db.assetTransactions,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (assetTransactionsRefs)
                    await $_getPrefetchedDataByColumns<
                      AssetRow,
                      $AssetsTable,
                      TransactionRow,
                      $AssetTransactionsTable
                    >(
                      currentTable: table,
                      referencedTable: $$AssetsTableReferences
                          ._assetTransactionsRefsTable(db),
                      managerFromTypedResult: (p0) => $$AssetsTableReferences(
                        db,
                        table,
                        p0,
                      ).assetTransactionsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'asset_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AssetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssetsTable,
      AssetRow,
      $$AssetsTableFilterComposer,
      $$AssetsTableOrderingComposer,
      $$AssetsTableAnnotationComposer,
      $$AssetsTableCreateCompanionBuilder,
      $$AssetsTableUpdateCompanionBuilder,
      (AssetRow, $$AssetsTableReferences),
      AssetRow,
      PrefetchHooks Function({bool assetTransactionsRefs})
    >;
typedef $$AssetTransactionsTableCreateCompanionBuilder =
    AssetTransactionsCompanion Function({
      Value<int> id,
      required int assetId,
      required String kind,
      required Decimal quantity,
      Value<Decimal?> unitPriceTry,
      required DateTime date,
      Value<String?> note,
      Value<DateTime> createdAt,
    });
typedef $$AssetTransactionsTableUpdateCompanionBuilder =
    AssetTransactionsCompanion Function({
      Value<int> id,
      Value<int> assetId,
      Value<String> kind,
      Value<Decimal> quantity,
      Value<Decimal?> unitPriceTry,
      Value<DateTime> date,
      Value<String?> note,
      Value<DateTime> createdAt,
    });

final class $$AssetTransactionsTableReferences
    extends
        BaseReferences<_$AppDatabase, $AssetTransactionsTable, TransactionRow> {
  $$AssetTransactionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AssetsTable _assetIdTable(_$AppDatabase db) =>
      db.assets.createAlias('asset_transactions__asset_id__assets__id');

  $$AssetsTableProcessedTableManager get assetId {
    final $_column = $_itemColumn<int>('asset_id')!;

    final manager = $$AssetsTableTableManager(
      $_db,
      $_db.assets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_assetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AssetTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $AssetTransactionsTable> {
  $$AssetTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Decimal, Decimal, String> get quantity =>
      $composableBuilder(
        column: $table.quantity,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Decimal?, Decimal, String> get unitPriceTry =>
      $composableBuilder(
        column: $table.unitPriceTry,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$AssetsTableFilterComposer get assetId {
    final $$AssetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableFilterComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AssetTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $AssetTransactionsTable> {
  $$AssetTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitPriceTry => $composableBuilder(
    column: $table.unitPriceTry,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AssetsTableOrderingComposer get assetId {
    final $$AssetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableOrderingComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AssetTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssetTransactionsTable> {
  $$AssetTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Decimal, String> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Decimal?, String> get unitPriceTry =>
      $composableBuilder(
        column: $table.unitPriceTry,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$AssetsTableAnnotationComposer get assetId {
    final $$AssetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableAnnotationComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AssetTransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssetTransactionsTable,
          TransactionRow,
          $$AssetTransactionsTableFilterComposer,
          $$AssetTransactionsTableOrderingComposer,
          $$AssetTransactionsTableAnnotationComposer,
          $$AssetTransactionsTableCreateCompanionBuilder,
          $$AssetTransactionsTableUpdateCompanionBuilder,
          (TransactionRow, $$AssetTransactionsTableReferences),
          TransactionRow,
          PrefetchHooks Function({bool assetId})
        > {
  $$AssetTransactionsTableTableManager(
    _$AppDatabase db,
    $AssetTransactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssetTransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssetTransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssetTransactionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> assetId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<Decimal> quantity = const Value.absent(),
                Value<Decimal?> unitPriceTry = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AssetTransactionsCompanion(
                id: id,
                assetId: assetId,
                kind: kind,
                quantity: quantity,
                unitPriceTry: unitPriceTry,
                date: date,
                note: note,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int assetId,
                required String kind,
                required Decimal quantity,
                Value<Decimal?> unitPriceTry = const Value.absent(),
                required DateTime date,
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AssetTransactionsCompanion.insert(
                id: id,
                assetId: assetId,
                kind: kind,
                quantity: quantity,
                unitPriceTry: unitPriceTry,
                date: date,
                note: note,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AssetTransactionsTable, TransactionRow>(table),
                  $$AssetTransactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({assetId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (assetId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.assetId,
                                referencedTable:
                                    $$AssetTransactionsTableReferences
                                        ._assetIdTable(db),
                                referencedColumn:
                                    $$AssetTransactionsTableReferences
                                        ._assetIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AssetTransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssetTransactionsTable,
      TransactionRow,
      $$AssetTransactionsTableFilterComposer,
      $$AssetTransactionsTableOrderingComposer,
      $$AssetTransactionsTableAnnotationComposer,
      $$AssetTransactionsTableCreateCompanionBuilder,
      $$AssetTransactionsTableUpdateCompanionBuilder,
      (TransactionRow, $$AssetTransactionsTableReferences),
      TransactionRow,
      PrefetchHooks Function({bool assetId})
    >;
typedef $$PriceCacheTableCreateCompanionBuilder =
    PriceCacheCompanion Function({
      required String type,
      required String code,
      required Decimal priceTry,
      required String source,
      required DateTime fetchedAt,
      Value<String?> name,
      Value<Decimal?> changePercent,
      Value<DateTime?> asOf,
      Value<int> rowid,
    });
typedef $$PriceCacheTableUpdateCompanionBuilder =
    PriceCacheCompanion Function({
      Value<String> type,
      Value<String> code,
      Value<Decimal> priceTry,
      Value<String> source,
      Value<DateTime> fetchedAt,
      Value<String?> name,
      Value<Decimal?> changePercent,
      Value<DateTime?> asOf,
      Value<int> rowid,
    });

class $$PriceCacheTableFilterComposer
    extends Composer<_$AppDatabase, $PriceCacheTable> {
  $$PriceCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Decimal, Decimal, String> get priceTry =>
      $composableBuilder(
        column: $table.priceTry,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Decimal?, Decimal, String> get changePercent =>
      $composableBuilder(
        column: $table.changePercent,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get asOf => $composableBuilder(
    column: $table.asOf,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PriceCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $PriceCacheTable> {
  $$PriceCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priceTry => $composableBuilder(
    column: $table.priceTry,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get changePercent => $composableBuilder(
    column: $table.changePercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get asOf => $composableBuilder(
    column: $table.asOf,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PriceCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $PriceCacheTable> {
  $$PriceCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Decimal, String> get priceTry =>
      $composableBuilder(column: $table.priceTry, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Decimal?, String> get changePercent =>
      $composableBuilder(
        column: $table.changePercent,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get asOf =>
      $composableBuilder(column: $table.asOf, builder: (column) => column);
}

class $$PriceCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PriceCacheTable,
          PriceCacheRow,
          $$PriceCacheTableFilterComposer,
          $$PriceCacheTableOrderingComposer,
          $$PriceCacheTableAnnotationComposer,
          $$PriceCacheTableCreateCompanionBuilder,
          $$PriceCacheTableUpdateCompanionBuilder,
          (
            PriceCacheRow,
            BaseReferences<_$AppDatabase, $PriceCacheTable, PriceCacheRow>,
          ),
          PriceCacheRow,
          PrefetchHooks Function()
        > {
  $$PriceCacheTableTableManager(_$AppDatabase db, $PriceCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PriceCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PriceCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PriceCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> type = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<Decimal> priceTry = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<Decimal?> changePercent = const Value.absent(),
                Value<DateTime?> asOf = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PriceCacheCompanion(
                type: type,
                code: code,
                priceTry: priceTry,
                source: source,
                fetchedAt: fetchedAt,
                name: name,
                changePercent: changePercent,
                asOf: asOf,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String type,
                required String code,
                required Decimal priceTry,
                required String source,
                required DateTime fetchedAt,
                Value<String?> name = const Value.absent(),
                Value<Decimal?> changePercent = const Value.absent(),
                Value<DateTime?> asOf = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PriceCacheCompanion.insert(
                type: type,
                code: code,
                priceTry: priceTry,
                source: source,
                fetchedAt: fetchedAt,
                name: name,
                changePercent: changePercent,
                asOf: asOf,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PriceCacheTable, PriceCacheRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PriceCacheTable,
                    PriceCacheRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PriceCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PriceCacheTable,
      PriceCacheRow,
      $$PriceCacheTableFilterComposer,
      $$PriceCacheTableOrderingComposer,
      $$PriceCacheTableAnnotationComposer,
      $$PriceCacheTableCreateCompanionBuilder,
      $$PriceCacheTableUpdateCompanionBuilder,
      (
        PriceCacheRow,
        BaseReferences<_$AppDatabase, $PriceCacheTable, PriceCacheRow>,
      ),
      PriceCacheRow,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          SettingRow,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            SettingRow,
            BaseReferences<_$AppDatabase, $AppSettingsTable, SettingRow>,
          ),
          SettingRow,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, SettingRow>(table),
                  BaseReferences<_$AppDatabase, $AppSettingsTable, SettingRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      SettingRow,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        SettingRow,
        BaseReferences<_$AppDatabase, $AppSettingsTable, SettingRow>,
      ),
      SettingRow,
      PrefetchHooks Function()
    >;
typedef $$KapDisclosuresTableCreateCompanionBuilder =
    KapDisclosuresCompanion Function({
      required String id,
      required String symbol,
      required String title,
      Value<String?> summary,
      Value<String?> url,
      required DateTime publishedAt,
      Value<int> rowid,
    });
typedef $$KapDisclosuresTableUpdateCompanionBuilder =
    KapDisclosuresCompanion Function({
      Value<String> id,
      Value<String> symbol,
      Value<String> title,
      Value<String?> summary,
      Value<String?> url,
      Value<DateTime> publishedAt,
      Value<int> rowid,
    });

class $$KapDisclosuresTableFilterComposer
    extends Composer<_$AppDatabase, $KapDisclosuresTable> {
  $$KapDisclosuresTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KapDisclosuresTableOrderingComposer
    extends Composer<_$AppDatabase, $KapDisclosuresTable> {
  $$KapDisclosuresTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KapDisclosuresTableAnnotationComposer
    extends Composer<_$AppDatabase, $KapDisclosuresTable> {
  $$KapDisclosuresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => column,
  );
}

class $$KapDisclosuresTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $KapDisclosuresTable,
          KapDisclosureRow,
          $$KapDisclosuresTableFilterComposer,
          $$KapDisclosuresTableOrderingComposer,
          $$KapDisclosuresTableAnnotationComposer,
          $$KapDisclosuresTableCreateCompanionBuilder,
          $$KapDisclosuresTableUpdateCompanionBuilder,
          (
            KapDisclosureRow,
            BaseReferences<
              _$AppDatabase,
              $KapDisclosuresTable,
              KapDisclosureRow
            >,
          ),
          KapDisclosureRow,
          PrefetchHooks Function()
        > {
  $$KapDisclosuresTableTableManager(
    _$AppDatabase db,
    $KapDisclosuresTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KapDisclosuresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KapDisclosuresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KapDisclosuresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> symbol = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> summary = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<DateTime> publishedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KapDisclosuresCompanion(
                id: id,
                symbol: symbol,
                title: title,
                summary: summary,
                url: url,
                publishedAt: publishedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String symbol,
                required String title,
                Value<String?> summary = const Value.absent(),
                Value<String?> url = const Value.absent(),
                required DateTime publishedAt,
                Value<int> rowid = const Value.absent(),
              }) => KapDisclosuresCompanion.insert(
                id: id,
                symbol: symbol,
                title: title,
                summary: summary,
                url: url,
                publishedAt: publishedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$KapDisclosuresTable, KapDisclosureRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $KapDisclosuresTable,
                    KapDisclosureRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KapDisclosuresTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $KapDisclosuresTable,
      KapDisclosureRow,
      $$KapDisclosuresTableFilterComposer,
      $$KapDisclosuresTableOrderingComposer,
      $$KapDisclosuresTableAnnotationComposer,
      $$KapDisclosuresTableCreateCompanionBuilder,
      $$KapDisclosuresTableUpdateCompanionBuilder,
      (
        KapDisclosureRow,
        BaseReferences<_$AppDatabase, $KapDisclosuresTable, KapDisclosureRow>,
      ),
      KapDisclosureRow,
      PrefetchHooks Function()
    >;
typedef $$PortfolioSnapshotsTableCreateCompanionBuilder =
    PortfolioSnapshotsCompanion Function({
      required String day,
      required Decimal valueTry,
      Value<Decimal?> costTry,
      Value<Decimal?> usdTry,
      Value<Decimal?> eurTry,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$PortfolioSnapshotsTableUpdateCompanionBuilder =
    PortfolioSnapshotsCompanion Function({
      Value<String> day,
      Value<Decimal> valueTry,
      Value<Decimal?> costTry,
      Value<Decimal?> usdTry,
      Value<Decimal?> eurTry,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$PortfolioSnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $PortfolioSnapshotsTable> {
  $$PortfolioSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Decimal, Decimal, String> get valueTry =>
      $composableBuilder(
        column: $table.valueTry,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Decimal?, Decimal, String> get costTry =>
      $composableBuilder(
        column: $table.costTry,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Decimal?, Decimal, String> get usdTry =>
      $composableBuilder(
        column: $table.usdTry,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Decimal?, Decimal, String> get eurTry =>
      $composableBuilder(
        column: $table.eurTry,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PortfolioSnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $PortfolioSnapshotsTable> {
  $$PortfolioSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valueTry => $composableBuilder(
    column: $table.valueTry,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get costTry => $composableBuilder(
    column: $table.costTry,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get usdTry => $composableBuilder(
    column: $table.usdTry,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eurTry => $composableBuilder(
    column: $table.eurTry,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PortfolioSnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PortfolioSnapshotsTable> {
  $$PortfolioSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Decimal, String> get valueTry =>
      $composableBuilder(column: $table.valueTry, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Decimal?, String> get costTry =>
      $composableBuilder(column: $table.costTry, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Decimal?, String> get usdTry =>
      $composableBuilder(column: $table.usdTry, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Decimal?, String> get eurTry =>
      $composableBuilder(column: $table.eurTry, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PortfolioSnapshotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PortfolioSnapshotsTable,
          PortfolioSnapshotRow,
          $$PortfolioSnapshotsTableFilterComposer,
          $$PortfolioSnapshotsTableOrderingComposer,
          $$PortfolioSnapshotsTableAnnotationComposer,
          $$PortfolioSnapshotsTableCreateCompanionBuilder,
          $$PortfolioSnapshotsTableUpdateCompanionBuilder,
          (
            PortfolioSnapshotRow,
            BaseReferences<
              _$AppDatabase,
              $PortfolioSnapshotsTable,
              PortfolioSnapshotRow
            >,
          ),
          PortfolioSnapshotRow,
          PrefetchHooks Function()
        > {
  $$PortfolioSnapshotsTableTableManager(
    _$AppDatabase db,
    $PortfolioSnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PortfolioSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PortfolioSnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PortfolioSnapshotsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> day = const Value.absent(),
                Value<Decimal> valueTry = const Value.absent(),
                Value<Decimal?> costTry = const Value.absent(),
                Value<Decimal?> usdTry = const Value.absent(),
                Value<Decimal?> eurTry = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PortfolioSnapshotsCompanion(
                day: day,
                valueTry: valueTry,
                costTry: costTry,
                usdTry: usdTry,
                eurTry: eurTry,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String day,
                required Decimal valueTry,
                Value<Decimal?> costTry = const Value.absent(),
                Value<Decimal?> usdTry = const Value.absent(),
                Value<Decimal?> eurTry = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PortfolioSnapshotsCompanion.insert(
                day: day,
                valueTry: valueTry,
                costTry: costTry,
                usdTry: usdTry,
                eurTry: eurTry,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PortfolioSnapshotsTable, PortfolioSnapshotRow>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $PortfolioSnapshotsTable,
                    PortfolioSnapshotRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PortfolioSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PortfolioSnapshotsTable,
      PortfolioSnapshotRow,
      $$PortfolioSnapshotsTableFilterComposer,
      $$PortfolioSnapshotsTableOrderingComposer,
      $$PortfolioSnapshotsTableAnnotationComposer,
      $$PortfolioSnapshotsTableCreateCompanionBuilder,
      $$PortfolioSnapshotsTableUpdateCompanionBuilder,
      (
        PortfolioSnapshotRow,
        BaseReferences<
          _$AppDatabase,
          $PortfolioSnapshotsTable,
          PortfolioSnapshotRow
        >,
      ),
      PortfolioSnapshotRow,
      PrefetchHooks Function()
    >;
typedef $$AssetSnapshotsTableCreateCompanionBuilder =
    AssetSnapshotsCompanion Function({
      required String day,
      required String type,
      required String code,
      required Decimal quantity,
      required Decimal priceTry,
      Value<int> rowid,
    });
typedef $$AssetSnapshotsTableUpdateCompanionBuilder =
    AssetSnapshotsCompanion Function({
      Value<String> day,
      Value<String> type,
      Value<String> code,
      Value<Decimal> quantity,
      Value<Decimal> priceTry,
      Value<int> rowid,
    });

class $$AssetSnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $AssetSnapshotsTable> {
  $$AssetSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Decimal, Decimal, String> get quantity =>
      $composableBuilder(
        column: $table.quantity,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Decimal, Decimal, String> get priceTry =>
      $composableBuilder(
        column: $table.priceTry,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$AssetSnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $AssetSnapshotsTable> {
  $$AssetSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priceTry => $composableBuilder(
    column: $table.priceTry,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AssetSnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssetSnapshotsTable> {
  $$AssetSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Decimal, String> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Decimal, String> get priceTry =>
      $composableBuilder(column: $table.priceTry, builder: (column) => column);
}

class $$AssetSnapshotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssetSnapshotsTable,
          AssetSnapshotRow,
          $$AssetSnapshotsTableFilterComposer,
          $$AssetSnapshotsTableOrderingComposer,
          $$AssetSnapshotsTableAnnotationComposer,
          $$AssetSnapshotsTableCreateCompanionBuilder,
          $$AssetSnapshotsTableUpdateCompanionBuilder,
          (
            AssetSnapshotRow,
            BaseReferences<
              _$AppDatabase,
              $AssetSnapshotsTable,
              AssetSnapshotRow
            >,
          ),
          AssetSnapshotRow,
          PrefetchHooks Function()
        > {
  $$AssetSnapshotsTableTableManager(
    _$AppDatabase db,
    $AssetSnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssetSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssetSnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssetSnapshotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> day = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<Decimal> quantity = const Value.absent(),
                Value<Decimal> priceTry = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssetSnapshotsCompanion(
                day: day,
                type: type,
                code: code,
                quantity: quantity,
                priceTry: priceTry,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String day,
                required String type,
                required String code,
                required Decimal quantity,
                required Decimal priceTry,
                Value<int> rowid = const Value.absent(),
              }) => AssetSnapshotsCompanion.insert(
                day: day,
                type: type,
                code: code,
                quantity: quantity,
                priceTry: priceTry,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AssetSnapshotsTable, AssetSnapshotRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AssetSnapshotsTable,
                    AssetSnapshotRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AssetSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssetSnapshotsTable,
      AssetSnapshotRow,
      $$AssetSnapshotsTableFilterComposer,
      $$AssetSnapshotsTableOrderingComposer,
      $$AssetSnapshotsTableAnnotationComposer,
      $$AssetSnapshotsTableCreateCompanionBuilder,
      $$AssetSnapshotsTableUpdateCompanionBuilder,
      (
        AssetSnapshotRow,
        BaseReferences<_$AppDatabase, $AssetSnapshotsTable, AssetSnapshotRow>,
      ),
      AssetSnapshotRow,
      PrefetchHooks Function()
    >;
typedef $$GoalsTableCreateCompanionBuilder =
    GoalsCompanion Function({
      Value<int> id,
      required String title,
      required String kind,
      required Decimal target,
      Value<String?> currency,
      Value<String?> assetType,
      Value<String?> assetCode,
      Value<DateTime> createdAt,
    });
typedef $$GoalsTableUpdateCompanionBuilder =
    GoalsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> kind,
      Value<Decimal> target,
      Value<String?> currency,
      Value<String?> assetType,
      Value<String?> assetCode,
      Value<DateTime> createdAt,
    });

class $$GoalsTableFilterComposer extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Decimal, Decimal, String> get target =>
      $composableBuilder(
        column: $table.target,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assetType => $composableBuilder(
    column: $table.assetType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assetCode => $composableBuilder(
    column: $table.assetCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assetType => $composableBuilder(
    column: $table.assetType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assetCode => $composableBuilder(
    column: $table.assetCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Decimal, String> get target =>
      $composableBuilder(column: $table.target, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get assetType =>
      $composableBuilder(column: $table.assetType, builder: (column) => column);

  GeneratedColumn<String> get assetCode =>
      $composableBuilder(column: $table.assetCode, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$GoalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GoalsTable,
          GoalRow,
          $$GoalsTableFilterComposer,
          $$GoalsTableOrderingComposer,
          $$GoalsTableAnnotationComposer,
          $$GoalsTableCreateCompanionBuilder,
          $$GoalsTableUpdateCompanionBuilder,
          (GoalRow, BaseReferences<_$AppDatabase, $GoalsTable, GoalRow>),
          GoalRow,
          PrefetchHooks Function()
        > {
  $$GoalsTableTableManager(_$AppDatabase db, $GoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<Decimal> target = const Value.absent(),
                Value<String?> currency = const Value.absent(),
                Value<String?> assetType = const Value.absent(),
                Value<String?> assetCode = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => GoalsCompanion(
                id: id,
                title: title,
                kind: kind,
                target: target,
                currency: currency,
                assetType: assetType,
                assetCode: assetCode,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required String kind,
                required Decimal target,
                Value<String?> currency = const Value.absent(),
                Value<String?> assetType = const Value.absent(),
                Value<String?> assetCode = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => GoalsCompanion.insert(
                id: id,
                title: title,
                kind: kind,
                target: target,
                currency: currency,
                assetType: assetType,
                assetCode: assetCode,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GoalsTable, GoalRow>(table),
                  BaseReferences<_$AppDatabase, $GoalsTable, GoalRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GoalsTable,
      GoalRow,
      $$GoalsTableFilterComposer,
      $$GoalsTableOrderingComposer,
      $$GoalsTableAnnotationComposer,
      $$GoalsTableCreateCompanionBuilder,
      $$GoalsTableUpdateCompanionBuilder,
      (GoalRow, BaseReferences<_$AppDatabase, $GoalsTable, GoalRow>),
      GoalRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AssetsTableTableManager get assets =>
      $$AssetsTableTableManager(_db, _db.assets);
  $$AssetTransactionsTableTableManager get assetTransactions =>
      $$AssetTransactionsTableTableManager(_db, _db.assetTransactions);
  $$PriceCacheTableTableManager get priceCache =>
      $$PriceCacheTableTableManager(_db, _db.priceCache);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$KapDisclosuresTableTableManager get kapDisclosures =>
      $$KapDisclosuresTableTableManager(_db, _db.kapDisclosures);
  $$PortfolioSnapshotsTableTableManager get portfolioSnapshots =>
      $$PortfolioSnapshotsTableTableManager(_db, _db.portfolioSnapshots);
  $$AssetSnapshotsTableTableManager get assetSnapshots =>
      $$AssetSnapshotsTableTableManager(_db, _db.assetSnapshots);
  $$GoalsTableTableManager get goals =>
      $$GoalsTableTableManager(_db, _db.goals);
}
