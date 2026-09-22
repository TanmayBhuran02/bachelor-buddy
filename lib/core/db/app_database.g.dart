// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconKeyMeta = const VerificationMeta(
    'iconKey',
  );
  @override
  late final GeneratedColumn<String> iconKey = GeneratedColumn<String>(
    'icon_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('category'),
  );
  static const VerificationMeta _colorHexMeta = const VerificationMeta(
    'colorHex',
  );
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
    'color_hex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#6C63FF'),
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
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    iconKey,
    colorHex,
    kind,
    isDefault,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon_key')) {
      context.handle(
        _iconKeyMeta,
        iconKey.isAcceptableOrUnknown(data['icon_key']!, _iconKeyMeta),
      );
    }
    if (data.containsKey('color_hex')) {
      context.handle(
        _colorHexMeta,
        colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      iconKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_key'],
      )!,
      colorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_hex'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final String id;
  final String name;
  final String iconKey;
  final String colorHex;
  final String kind;
  final bool isDefault;
  const Category({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.colorHex,
    required this.kind,
    required this.isDefault,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['icon_key'] = Variable<String>(iconKey);
    map['color_hex'] = Variable<String>(colorHex);
    map['kind'] = Variable<String>(kind);
    map['is_default'] = Variable<bool>(isDefault);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      iconKey: Value(iconKey),
      colorHex: Value(colorHex),
      kind: Value(kind),
      isDefault: Value(isDefault),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      iconKey: serializer.fromJson<String>(json['iconKey']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
      kind: serializer.fromJson<String>(json['kind']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'iconKey': serializer.toJson<String>(iconKey),
      'colorHex': serializer.toJson<String>(colorHex),
      'kind': serializer.toJson<String>(kind),
      'isDefault': serializer.toJson<bool>(isDefault),
    };
  }

  Category copyWith({
    String? id,
    String? name,
    String? iconKey,
    String? colorHex,
    String? kind,
    bool? isDefault,
  }) => Category(
    id: id ?? this.id,
    name: name ?? this.name,
    iconKey: iconKey ?? this.iconKey,
    colorHex: colorHex ?? this.colorHex,
    kind: kind ?? this.kind,
    isDefault: isDefault ?? this.isDefault,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      iconKey: data.iconKey.present ? data.iconKey.value : this.iconKey,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      kind: data.kind.present ? data.kind.value : this.kind,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconKey: $iconKey, ')
          ..write('colorHex: $colorHex, ')
          ..write('kind: $kind, ')
          ..write('isDefault: $isDefault')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, iconKey, colorHex, kind, isDefault);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.iconKey == this.iconKey &&
          other.colorHex == this.colorHex &&
          other.kind == this.kind &&
          other.isDefault == this.isDefault);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> iconKey;
  final Value<String> colorHex;
  final Value<String> kind;
  final Value<bool> isDefault;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.kind = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String name,
    this.iconKey = const Value.absent(),
    this.colorHex = const Value.absent(),
    required String kind,
    this.isDefault = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       kind = Value(kind);
  static Insertable<Category> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? iconKey,
    Expression<String>? colorHex,
    Expression<String>? kind,
    Expression<bool>? isDefault,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (iconKey != null) 'icon_key': iconKey,
      if (colorHex != null) 'color_hex': colorHex,
      if (kind != null) 'kind': kind,
      if (isDefault != null) 'is_default': isDefault,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? iconKey,
    Value<String>? colorHex,
    Value<String>? kind,
    Value<bool>? isDefault,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      iconKey: iconKey ?? this.iconKey,
      colorHex: colorHex ?? this.colorHex,
      kind: kind ?? this.kind,
      isDefault: isDefault ?? this.isDefault,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (iconKey.present) {
      map['icon_key'] = Variable<String>(iconKey.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconKey: $iconKey, ')
          ..write('colorHex: $colorHex, ')
          ..write('kind: $kind, ')
          ..write('isDefault: $isDefault, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta(
    'amountPaise',
  );
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _sourceRefIdMeta = const VerificationMeta(
    'sourceRefId',
  );
  @override
  late final GeneratedColumn<String> sourceRefId = GeneratedColumn<String>(
    'source_ref_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSharedMeta = const VerificationMeta(
    'isShared',
  );
  @override
  late final GeneratedColumn<bool> isShared = GeneratedColumn<bool>(
    'is_shared',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_shared" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    amountPaise,
    type,
    categoryId,
    note,
    date,
    source,
    sourceRefId,
    isShared,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPaiseMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('source_ref_id')) {
      context.handle(
        _sourceRefIdMeta,
        sourceRefId.isAcceptableOrUnknown(
          data['source_ref_id']!,
          _sourceRefIdMeta,
        ),
      );
    }
    if (data.containsKey('is_shared')) {
      context.handle(
        _isSharedMeta,
        isShared.isAcceptableOrUnknown(data['is_shared']!, _isSharedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      amountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paise'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      sourceRefId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_ref_id'],
      ),
      isShared: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_shared'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final String id;
  final int amountPaise;
  final String type;
  final String categoryId;
  final String note;
  final String date;
  final String source;
  final String? sourceRefId;
  final bool isShared;
  final int createdAt;
  const Transaction({
    required this.id,
    required this.amountPaise,
    required this.type,
    required this.categoryId,
    required this.note,
    required this.date,
    required this.source,
    this.sourceRefId,
    required this.isShared,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['amount_paise'] = Variable<int>(amountPaise);
    map['type'] = Variable<String>(type);
    map['category_id'] = Variable<String>(categoryId);
    map['note'] = Variable<String>(note);
    map['date'] = Variable<String>(date);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || sourceRefId != null) {
      map['source_ref_id'] = Variable<String>(sourceRefId);
    }
    map['is_shared'] = Variable<bool>(isShared);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      amountPaise: Value(amountPaise),
      type: Value(type),
      categoryId: Value(categoryId),
      note: Value(note),
      date: Value(date),
      source: Value(source),
      sourceRefId: sourceRefId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceRefId),
      isShared: Value(isShared),
      createdAt: Value(createdAt),
    );
  }

  factory Transaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<String>(json['id']),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
      type: serializer.fromJson<String>(json['type']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      note: serializer.fromJson<String>(json['note']),
      date: serializer.fromJson<String>(json['date']),
      source: serializer.fromJson<String>(json['source']),
      sourceRefId: serializer.fromJson<String?>(json['sourceRefId']),
      isShared: serializer.fromJson<bool>(json['isShared']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'amountPaise': serializer.toJson<int>(amountPaise),
      'type': serializer.toJson<String>(type),
      'categoryId': serializer.toJson<String>(categoryId),
      'note': serializer.toJson<String>(note),
      'date': serializer.toJson<String>(date),
      'source': serializer.toJson<String>(source),
      'sourceRefId': serializer.toJson<String?>(sourceRefId),
      'isShared': serializer.toJson<bool>(isShared),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  Transaction copyWith({
    String? id,
    int? amountPaise,
    String? type,
    String? categoryId,
    String? note,
    String? date,
    String? source,
    Value<String?> sourceRefId = const Value.absent(),
    bool? isShared,
    int? createdAt,
  }) => Transaction(
    id: id ?? this.id,
    amountPaise: amountPaise ?? this.amountPaise,
    type: type ?? this.type,
    categoryId: categoryId ?? this.categoryId,
    note: note ?? this.note,
    date: date ?? this.date,
    source: source ?? this.source,
    sourceRefId: sourceRefId.present ? sourceRefId.value : this.sourceRefId,
    isShared: isShared ?? this.isShared,
    createdAt: createdAt ?? this.createdAt,
  );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      amountPaise: data.amountPaise.present
          ? data.amountPaise.value
          : this.amountPaise,
      type: data.type.present ? data.type.value : this.type,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      note: data.note.present ? data.note.value : this.note,
      date: data.date.present ? data.date.value : this.date,
      source: data.source.present ? data.source.value : this.source,
      sourceRefId: data.sourceRefId.present
          ? data.sourceRefId.value
          : this.sourceRefId,
      isShared: data.isShared.present ? data.isShared.value : this.isShared,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('type: $type, ')
          ..write('categoryId: $categoryId, ')
          ..write('note: $note, ')
          ..write('date: $date, ')
          ..write('source: $source, ')
          ..write('sourceRefId: $sourceRefId, ')
          ..write('isShared: $isShared, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    amountPaise,
    type,
    categoryId,
    note,
    date,
    source,
    sourceRefId,
    isShared,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.amountPaise == this.amountPaise &&
          other.type == this.type &&
          other.categoryId == this.categoryId &&
          other.note == this.note &&
          other.date == this.date &&
          other.source == this.source &&
          other.sourceRefId == this.sourceRefId &&
          other.isShared == this.isShared &&
          other.createdAt == this.createdAt);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<String> id;
  final Value<int> amountPaise;
  final Value<String> type;
  final Value<String> categoryId;
  final Value<String> note;
  final Value<String> date;
  final Value<String> source;
  final Value<String?> sourceRefId;
  final Value<bool> isShared;
  final Value<int> createdAt;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.type = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.note = const Value.absent(),
    this.date = const Value.absent(),
    this.source = const Value.absent(),
    this.sourceRefId = const Value.absent(),
    this.isShared = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String id,
    required int amountPaise,
    required String type,
    required String categoryId,
    this.note = const Value.absent(),
    required String date,
    this.source = const Value.absent(),
    this.sourceRefId = const Value.absent(),
    this.isShared = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       amountPaise = Value(amountPaise),
       type = Value(type),
       categoryId = Value(categoryId),
       date = Value(date),
       createdAt = Value(createdAt);
  static Insertable<Transaction> custom({
    Expression<String>? id,
    Expression<int>? amountPaise,
    Expression<String>? type,
    Expression<String>? categoryId,
    Expression<String>? note,
    Expression<String>? date,
    Expression<String>? source,
    Expression<String>? sourceRefId,
    Expression<bool>? isShared,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (type != null) 'type': type,
      if (categoryId != null) 'category_id': categoryId,
      if (note != null) 'note': note,
      if (date != null) 'date': date,
      if (source != null) 'source': source,
      if (sourceRefId != null) 'source_ref_id': sourceRefId,
      if (isShared != null) 'is_shared': isShared,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith({
    Value<String>? id,
    Value<int>? amountPaise,
    Value<String>? type,
    Value<String>? categoryId,
    Value<String>? note,
    Value<String>? date,
    Value<String>? source,
    Value<String?>? sourceRefId,
    Value<bool>? isShared,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      amountPaise: amountPaise ?? this.amountPaise,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      date: date ?? this.date,
      source: source ?? this.source,
      sourceRefId: sourceRefId ?? this.sourceRefId,
      isShared: isShared ?? this.isShared,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (sourceRefId.present) {
      map['source_ref_id'] = Variable<String>(sourceRefId.value);
    }
    if (isShared.present) {
      map['is_shared'] = Variable<bool>(isShared.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('type: $type, ')
          ..write('categoryId: $categoryId, ')
          ..write('note: $note, ')
          ..write('date: $date, ')
          ..write('source: $source, ')
          ..write('sourceRefId: $sourceRefId, ')
          ..write('isShared: $isShared, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BudgetsTable extends Budgets with TableInfo<$BudgetsTable, Budget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<String> month = GeneratedColumn<String>(
    'month',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _limitPaiseMeta = const VerificationMeta(
    'limitPaise',
  );
  @override
  late final GeneratedColumn<int> limitPaise = GeneratedColumn<int>(
    'limit_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, month, categoryId, limitPaise];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budgets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Budget> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('month')) {
      context.handle(
        _monthMeta,
        month.isAcceptableOrUnknown(data['month']!, _monthMeta),
      );
    } else if (isInserting) {
      context.missing(_monthMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('limit_paise')) {
      context.handle(
        _limitPaiseMeta,
        limitPaise.isAcceptableOrUnknown(data['limit_paise']!, _limitPaiseMeta),
      );
    } else if (isInserting) {
      context.missing(_limitPaiseMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {month, categoryId},
  ];
  @override
  Budget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Budget(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      month: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}month'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      limitPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}limit_paise'],
      )!,
    );
  }

  @override
  $BudgetsTable createAlias(String alias) {
    return $BudgetsTable(attachedDatabase, alias);
  }
}

class Budget extends DataClass implements Insertable<Budget> {
  final String id;
  final String month;
  final String? categoryId;
  final int limitPaise;
  const Budget({
    required this.id,
    required this.month,
    this.categoryId,
    required this.limitPaise,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['month'] = Variable<String>(month);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    map['limit_paise'] = Variable<int>(limitPaise);
    return map;
  }

  BudgetsCompanion toCompanion(bool nullToAbsent) {
    return BudgetsCompanion(
      id: Value(id),
      month: Value(month),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      limitPaise: Value(limitPaise),
    );
  }

  factory Budget.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Budget(
      id: serializer.fromJson<String>(json['id']),
      month: serializer.fromJson<String>(json['month']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      limitPaise: serializer.fromJson<int>(json['limitPaise']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'month': serializer.toJson<String>(month),
      'categoryId': serializer.toJson<String?>(categoryId),
      'limitPaise': serializer.toJson<int>(limitPaise),
    };
  }

  Budget copyWith({
    String? id,
    String? month,
    Value<String?> categoryId = const Value.absent(),
    int? limitPaise,
  }) => Budget(
    id: id ?? this.id,
    month: month ?? this.month,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    limitPaise: limitPaise ?? this.limitPaise,
  );
  Budget copyWithCompanion(BudgetsCompanion data) {
    return Budget(
      id: data.id.present ? data.id.value : this.id,
      month: data.month.present ? data.month.value : this.month,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      limitPaise: data.limitPaise.present
          ? data.limitPaise.value
          : this.limitPaise,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Budget(')
          ..write('id: $id, ')
          ..write('month: $month, ')
          ..write('categoryId: $categoryId, ')
          ..write('limitPaise: $limitPaise')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, month, categoryId, limitPaise);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Budget &&
          other.id == this.id &&
          other.month == this.month &&
          other.categoryId == this.categoryId &&
          other.limitPaise == this.limitPaise);
}

class BudgetsCompanion extends UpdateCompanion<Budget> {
  final Value<String> id;
  final Value<String> month;
  final Value<String?> categoryId;
  final Value<int> limitPaise;
  final Value<int> rowid;
  const BudgetsCompanion({
    this.id = const Value.absent(),
    this.month = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.limitPaise = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetsCompanion.insert({
    required String id,
    required String month,
    this.categoryId = const Value.absent(),
    required int limitPaise,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       month = Value(month),
       limitPaise = Value(limitPaise);
  static Insertable<Budget> custom({
    Expression<String>? id,
    Expression<String>? month,
    Expression<String>? categoryId,
    Expression<int>? limitPaise,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (month != null) 'month': month,
      if (categoryId != null) 'category_id': categoryId,
      if (limitPaise != null) 'limit_paise': limitPaise,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetsCompanion copyWith({
    Value<String>? id,
    Value<String>? month,
    Value<String?>? categoryId,
    Value<int>? limitPaise,
    Value<int>? rowid,
  }) {
    return BudgetsCompanion(
      id: id ?? this.id,
      month: month ?? this.month,
      categoryId: categoryId ?? this.categoryId,
      limitPaise: limitPaise ?? this.limitPaise,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (month.present) {
      map['month'] = Variable<String>(month.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (limitPaise.present) {
      map['limit_paise'] = Variable<int>(limitPaise.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetsCompanion(')
          ..write('id: $id, ')
          ..write('month: $month, ')
          ..write('categoryId: $categoryId, ')
          ..write('limitPaise: $limitPaise, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecurringExpensesTable extends RecurringExpenses
    with TableInfo<$RecurringExpensesTable, RecurringExpense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta(
    'amountPaise',
  );
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _dayOfMonthMeta = const VerificationMeta(
    'dayOfMonth',
  );
  @override
  late final GeneratedColumn<int> dayOfMonth = GeneratedColumn<int>(
    'day_of_month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lastGeneratedMonthMeta =
      const VerificationMeta('lastGeneratedMonth');
  @override
  late final GeneratedColumn<String> lastGeneratedMonth =
      GeneratedColumn<String>(
        'last_generated_month',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    amountPaise,
    categoryId,
    dayOfMonth,
    isActive,
    lastGeneratedMonth,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecurringExpense> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPaiseMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('day_of_month')) {
      context.handle(
        _dayOfMonthMeta,
        dayOfMonth.isAcceptableOrUnknown(
          data['day_of_month']!,
          _dayOfMonthMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dayOfMonthMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('last_generated_month')) {
      context.handle(
        _lastGeneratedMonthMeta,
        lastGeneratedMonth.isAcceptableOrUnknown(
          data['last_generated_month']!,
          _lastGeneratedMonthMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringExpense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringExpense(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      amountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paise'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      dayOfMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_of_month'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      lastGeneratedMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_generated_month'],
      )!,
    );
  }

  @override
  $RecurringExpensesTable createAlias(String alias) {
    return $RecurringExpensesTable(attachedDatabase, alias);
  }
}

class RecurringExpense extends DataClass
    implements Insertable<RecurringExpense> {
  final String id;
  final String title;
  final int amountPaise;
  final String categoryId;
  final int dayOfMonth;
  final bool isActive;
  final String lastGeneratedMonth;
  const RecurringExpense({
    required this.id,
    required this.title,
    required this.amountPaise,
    required this.categoryId,
    required this.dayOfMonth,
    required this.isActive,
    required this.lastGeneratedMonth,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['amount_paise'] = Variable<int>(amountPaise);
    map['category_id'] = Variable<String>(categoryId);
    map['day_of_month'] = Variable<int>(dayOfMonth);
    map['is_active'] = Variable<bool>(isActive);
    map['last_generated_month'] = Variable<String>(lastGeneratedMonth);
    return map;
  }

  RecurringExpensesCompanion toCompanion(bool nullToAbsent) {
    return RecurringExpensesCompanion(
      id: Value(id),
      title: Value(title),
      amountPaise: Value(amountPaise),
      categoryId: Value(categoryId),
      dayOfMonth: Value(dayOfMonth),
      isActive: Value(isActive),
      lastGeneratedMonth: Value(lastGeneratedMonth),
    );
  }

  factory RecurringExpense.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringExpense(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      dayOfMonth: serializer.fromJson<int>(json['dayOfMonth']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      lastGeneratedMonth: serializer.fromJson<String>(
        json['lastGeneratedMonth'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'amountPaise': serializer.toJson<int>(amountPaise),
      'categoryId': serializer.toJson<String>(categoryId),
      'dayOfMonth': serializer.toJson<int>(dayOfMonth),
      'isActive': serializer.toJson<bool>(isActive),
      'lastGeneratedMonth': serializer.toJson<String>(lastGeneratedMonth),
    };
  }

  RecurringExpense copyWith({
    String? id,
    String? title,
    int? amountPaise,
    String? categoryId,
    int? dayOfMonth,
    bool? isActive,
    String? lastGeneratedMonth,
  }) => RecurringExpense(
    id: id ?? this.id,
    title: title ?? this.title,
    amountPaise: amountPaise ?? this.amountPaise,
    categoryId: categoryId ?? this.categoryId,
    dayOfMonth: dayOfMonth ?? this.dayOfMonth,
    isActive: isActive ?? this.isActive,
    lastGeneratedMonth: lastGeneratedMonth ?? this.lastGeneratedMonth,
  );
  RecurringExpense copyWithCompanion(RecurringExpensesCompanion data) {
    return RecurringExpense(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      amountPaise: data.amountPaise.present
          ? data.amountPaise.value
          : this.amountPaise,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      dayOfMonth: data.dayOfMonth.present
          ? data.dayOfMonth.value
          : this.dayOfMonth,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      lastGeneratedMonth: data.lastGeneratedMonth.present
          ? data.lastGeneratedMonth.value
          : this.lastGeneratedMonth,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringExpense(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('categoryId: $categoryId, ')
          ..write('dayOfMonth: $dayOfMonth, ')
          ..write('isActive: $isActive, ')
          ..write('lastGeneratedMonth: $lastGeneratedMonth')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    amountPaise,
    categoryId,
    dayOfMonth,
    isActive,
    lastGeneratedMonth,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringExpense &&
          other.id == this.id &&
          other.title == this.title &&
          other.amountPaise == this.amountPaise &&
          other.categoryId == this.categoryId &&
          other.dayOfMonth == this.dayOfMonth &&
          other.isActive == this.isActive &&
          other.lastGeneratedMonth == this.lastGeneratedMonth);
}

class RecurringExpensesCompanion extends UpdateCompanion<RecurringExpense> {
  final Value<String> id;
  final Value<String> title;
  final Value<int> amountPaise;
  final Value<String> categoryId;
  final Value<int> dayOfMonth;
  final Value<bool> isActive;
  final Value<String> lastGeneratedMonth;
  final Value<int> rowid;
  const RecurringExpensesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.dayOfMonth = const Value.absent(),
    this.isActive = const Value.absent(),
    this.lastGeneratedMonth = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecurringExpensesCompanion.insert({
    required String id,
    required String title,
    required int amountPaise,
    required String categoryId,
    required int dayOfMonth,
    this.isActive = const Value.absent(),
    this.lastGeneratedMonth = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       amountPaise = Value(amountPaise),
       categoryId = Value(categoryId),
       dayOfMonth = Value(dayOfMonth);
  static Insertable<RecurringExpense> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<int>? amountPaise,
    Expression<String>? categoryId,
    Expression<int>? dayOfMonth,
    Expression<bool>? isActive,
    Expression<String>? lastGeneratedMonth,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (categoryId != null) 'category_id': categoryId,
      if (dayOfMonth != null) 'day_of_month': dayOfMonth,
      if (isActive != null) 'is_active': isActive,
      if (lastGeneratedMonth != null)
        'last_generated_month': lastGeneratedMonth,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecurringExpensesCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<int>? amountPaise,
    Value<String>? categoryId,
    Value<int>? dayOfMonth,
    Value<bool>? isActive,
    Value<String>? lastGeneratedMonth,
    Value<int>? rowid,
  }) {
    return RecurringExpensesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      amountPaise: amountPaise ?? this.amountPaise,
      categoryId: categoryId ?? this.categoryId,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      isActive: isActive ?? this.isActive,
      lastGeneratedMonth: lastGeneratedMonth ?? this.lastGeneratedMonth,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (dayOfMonth.present) {
      map['day_of_month'] = Variable<int>(dayOfMonth.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (lastGeneratedMonth.present) {
      map['last_generated_month'] = Variable<String>(lastGeneratedMonth.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringExpensesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('categoryId: $categoryId, ')
          ..write('dayOfMonth: $dayOfMonth, ')
          ..write('isActive: $isActive, ')
          ..write('lastGeneratedMonth: $lastGeneratedMonth, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TiffinPlansTable extends TiffinPlans
    with TableInfo<$TiffinPlansTable, TiffinPlan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TiffinPlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerNameMeta = const VerificationMeta(
    'providerName',
  );
  @override
  late final GeneratedColumn<String> providerName = GeneratedColumn<String>(
    'provider_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mealTypeMeta = const VerificationMeta(
    'mealType',
  );
  @override
  late final GeneratedColumn<String> mealType = GeneratedColumn<String>(
    'meal_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pricePerTiffinPaiseMeta =
      const VerificationMeta('pricePerTiffinPaise');
  @override
  late final GeneratedColumn<int> pricePerTiffinPaise = GeneratedColumn<int>(
    'price_per_tiffin_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeWeekdaysMaskMeta =
      const VerificationMeta('activeWeekdaysMask');
  @override
  late final GeneratedColumn<int> activeWeekdaysMask = GeneratedColumn<int>(
    'active_weekdays_mask',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reminderTimeMeta = const VerificationMeta(
    'reminderTime',
  );
  @override
  late final GeneratedColumn<String> reminderTime = GeneratedColumn<String>(
    'reminder_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('12:00'),
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    providerName,
    mealType,
    pricePerTiffinPaise,
    activeWeekdaysMask,
    reminderTime,
    startDate,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tiffin_plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<TiffinPlan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('provider_name')) {
      context.handle(
        _providerNameMeta,
        providerName.isAcceptableOrUnknown(
          data['provider_name']!,
          _providerNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_providerNameMeta);
    }
    if (data.containsKey('meal_type')) {
      context.handle(
        _mealTypeMeta,
        mealType.isAcceptableOrUnknown(data['meal_type']!, _mealTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mealTypeMeta);
    }
    if (data.containsKey('price_per_tiffin_paise')) {
      context.handle(
        _pricePerTiffinPaiseMeta,
        pricePerTiffinPaise.isAcceptableOrUnknown(
          data['price_per_tiffin_paise']!,
          _pricePerTiffinPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pricePerTiffinPaiseMeta);
    }
    if (data.containsKey('active_weekdays_mask')) {
      context.handle(
        _activeWeekdaysMaskMeta,
        activeWeekdaysMask.isAcceptableOrUnknown(
          data['active_weekdays_mask']!,
          _activeWeekdaysMaskMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_activeWeekdaysMaskMeta);
    }
    if (data.containsKey('reminder_time')) {
      context.handle(
        _reminderTimeMeta,
        reminderTime.isAcceptableOrUnknown(
          data['reminder_time']!,
          _reminderTimeMeta,
        ),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TiffinPlan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TiffinPlan(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      providerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_name'],
      )!,
      mealType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meal_type'],
      )!,
      pricePerTiffinPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price_per_tiffin_paise'],
      )!,
      activeWeekdaysMask: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}active_weekdays_mask'],
      )!,
      reminderTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder_time'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_date'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $TiffinPlansTable createAlias(String alias) {
    return $TiffinPlansTable(attachedDatabase, alias);
  }
}

class TiffinPlan extends DataClass implements Insertable<TiffinPlan> {
  final String id;
  final String providerName;
  final String mealType;
  final int pricePerTiffinPaise;
  final int activeWeekdaysMask;
  final String reminderTime;
  final String startDate;
  final bool isActive;
  const TiffinPlan({
    required this.id,
    required this.providerName,
    required this.mealType,
    required this.pricePerTiffinPaise,
    required this.activeWeekdaysMask,
    required this.reminderTime,
    required this.startDate,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['provider_name'] = Variable<String>(providerName);
    map['meal_type'] = Variable<String>(mealType);
    map['price_per_tiffin_paise'] = Variable<int>(pricePerTiffinPaise);
    map['active_weekdays_mask'] = Variable<int>(activeWeekdaysMask);
    map['reminder_time'] = Variable<String>(reminderTime);
    map['start_date'] = Variable<String>(startDate);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  TiffinPlansCompanion toCompanion(bool nullToAbsent) {
    return TiffinPlansCompanion(
      id: Value(id),
      providerName: Value(providerName),
      mealType: Value(mealType),
      pricePerTiffinPaise: Value(pricePerTiffinPaise),
      activeWeekdaysMask: Value(activeWeekdaysMask),
      reminderTime: Value(reminderTime),
      startDate: Value(startDate),
      isActive: Value(isActive),
    );
  }

  factory TiffinPlan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TiffinPlan(
      id: serializer.fromJson<String>(json['id']),
      providerName: serializer.fromJson<String>(json['providerName']),
      mealType: serializer.fromJson<String>(json['mealType']),
      pricePerTiffinPaise: serializer.fromJson<int>(
        json['pricePerTiffinPaise'],
      ),
      activeWeekdaysMask: serializer.fromJson<int>(json['activeWeekdaysMask']),
      reminderTime: serializer.fromJson<String>(json['reminderTime']),
      startDate: serializer.fromJson<String>(json['startDate']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'providerName': serializer.toJson<String>(providerName),
      'mealType': serializer.toJson<String>(mealType),
      'pricePerTiffinPaise': serializer.toJson<int>(pricePerTiffinPaise),
      'activeWeekdaysMask': serializer.toJson<int>(activeWeekdaysMask),
      'reminderTime': serializer.toJson<String>(reminderTime),
      'startDate': serializer.toJson<String>(startDate),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  TiffinPlan copyWith({
    String? id,
    String? providerName,
    String? mealType,
    int? pricePerTiffinPaise,
    int? activeWeekdaysMask,
    String? reminderTime,
    String? startDate,
    bool? isActive,
  }) => TiffinPlan(
    id: id ?? this.id,
    providerName: providerName ?? this.providerName,
    mealType: mealType ?? this.mealType,
    pricePerTiffinPaise: pricePerTiffinPaise ?? this.pricePerTiffinPaise,
    activeWeekdaysMask: activeWeekdaysMask ?? this.activeWeekdaysMask,
    reminderTime: reminderTime ?? this.reminderTime,
    startDate: startDate ?? this.startDate,
    isActive: isActive ?? this.isActive,
  );
  TiffinPlan copyWithCompanion(TiffinPlansCompanion data) {
    return TiffinPlan(
      id: data.id.present ? data.id.value : this.id,
      providerName: data.providerName.present
          ? data.providerName.value
          : this.providerName,
      mealType: data.mealType.present ? data.mealType.value : this.mealType,
      pricePerTiffinPaise: data.pricePerTiffinPaise.present
          ? data.pricePerTiffinPaise.value
          : this.pricePerTiffinPaise,
      activeWeekdaysMask: data.activeWeekdaysMask.present
          ? data.activeWeekdaysMask.value
          : this.activeWeekdaysMask,
      reminderTime: data.reminderTime.present
          ? data.reminderTime.value
          : this.reminderTime,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TiffinPlan(')
          ..write('id: $id, ')
          ..write('providerName: $providerName, ')
          ..write('mealType: $mealType, ')
          ..write('pricePerTiffinPaise: $pricePerTiffinPaise, ')
          ..write('activeWeekdaysMask: $activeWeekdaysMask, ')
          ..write('reminderTime: $reminderTime, ')
          ..write('startDate: $startDate, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    providerName,
    mealType,
    pricePerTiffinPaise,
    activeWeekdaysMask,
    reminderTime,
    startDate,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TiffinPlan &&
          other.id == this.id &&
          other.providerName == this.providerName &&
          other.mealType == this.mealType &&
          other.pricePerTiffinPaise == this.pricePerTiffinPaise &&
          other.activeWeekdaysMask == this.activeWeekdaysMask &&
          other.reminderTime == this.reminderTime &&
          other.startDate == this.startDate &&
          other.isActive == this.isActive);
}

class TiffinPlansCompanion extends UpdateCompanion<TiffinPlan> {
  final Value<String> id;
  final Value<String> providerName;
  final Value<String> mealType;
  final Value<int> pricePerTiffinPaise;
  final Value<int> activeWeekdaysMask;
  final Value<String> reminderTime;
  final Value<String> startDate;
  final Value<bool> isActive;
  final Value<int> rowid;
  const TiffinPlansCompanion({
    this.id = const Value.absent(),
    this.providerName = const Value.absent(),
    this.mealType = const Value.absent(),
    this.pricePerTiffinPaise = const Value.absent(),
    this.activeWeekdaysMask = const Value.absent(),
    this.reminderTime = const Value.absent(),
    this.startDate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TiffinPlansCompanion.insert({
    required String id,
    required String providerName,
    required String mealType,
    required int pricePerTiffinPaise,
    required int activeWeekdaysMask,
    this.reminderTime = const Value.absent(),
    required String startDate,
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       providerName = Value(providerName),
       mealType = Value(mealType),
       pricePerTiffinPaise = Value(pricePerTiffinPaise),
       activeWeekdaysMask = Value(activeWeekdaysMask),
       startDate = Value(startDate);
  static Insertable<TiffinPlan> custom({
    Expression<String>? id,
    Expression<String>? providerName,
    Expression<String>? mealType,
    Expression<int>? pricePerTiffinPaise,
    Expression<int>? activeWeekdaysMask,
    Expression<String>? reminderTime,
    Expression<String>? startDate,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (providerName != null) 'provider_name': providerName,
      if (mealType != null) 'meal_type': mealType,
      if (pricePerTiffinPaise != null)
        'price_per_tiffin_paise': pricePerTiffinPaise,
      if (activeWeekdaysMask != null)
        'active_weekdays_mask': activeWeekdaysMask,
      if (reminderTime != null) 'reminder_time': reminderTime,
      if (startDate != null) 'start_date': startDate,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TiffinPlansCompanion copyWith({
    Value<String>? id,
    Value<String>? providerName,
    Value<String>? mealType,
    Value<int>? pricePerTiffinPaise,
    Value<int>? activeWeekdaysMask,
    Value<String>? reminderTime,
    Value<String>? startDate,
    Value<bool>? isActive,
    Value<int>? rowid,
  }) {
    return TiffinPlansCompanion(
      id: id ?? this.id,
      providerName: providerName ?? this.providerName,
      mealType: mealType ?? this.mealType,
      pricePerTiffinPaise: pricePerTiffinPaise ?? this.pricePerTiffinPaise,
      activeWeekdaysMask: activeWeekdaysMask ?? this.activeWeekdaysMask,
      reminderTime: reminderTime ?? this.reminderTime,
      startDate: startDate ?? this.startDate,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (providerName.present) {
      map['provider_name'] = Variable<String>(providerName.value);
    }
    if (mealType.present) {
      map['meal_type'] = Variable<String>(mealType.value);
    }
    if (pricePerTiffinPaise.present) {
      map['price_per_tiffin_paise'] = Variable<int>(pricePerTiffinPaise.value);
    }
    if (activeWeekdaysMask.present) {
      map['active_weekdays_mask'] = Variable<int>(activeWeekdaysMask.value);
    }
    if (reminderTime.present) {
      map['reminder_time'] = Variable<String>(reminderTime.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(startDate.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TiffinPlansCompanion(')
          ..write('id: $id, ')
          ..write('providerName: $providerName, ')
          ..write('mealType: $mealType, ')
          ..write('pricePerTiffinPaise: $pricePerTiffinPaise, ')
          ..write('activeWeekdaysMask: $activeWeekdaysMask, ')
          ..write('reminderTime: $reminderTime, ')
          ..write('startDate: $startDate, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TiffinLogsTable extends TiffinLogs
    with TableInfo<$TiffinLogsTable, TiffinLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TiffinLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<String> planId = GeneratedColumn<String>(
    'plan_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tiffin_plans (id)',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _priceOverridePaiseMeta =
      const VerificationMeta('priceOverridePaise');
  @override
  late final GeneratedColumn<int> priceOverridePaise = GeneratedColumn<int>(
    'price_override_paise',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
    'transaction_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    planId,
    date,
    status,
    priceOverridePaise,
    transactionId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tiffin_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<TiffinLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('plan_id')) {
      context.handle(
        _planIdMeta,
        planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta),
      );
    } else if (isInserting) {
      context.missing(_planIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('price_override_paise')) {
      context.handle(
        _priceOverridePaiseMeta,
        priceOverridePaise.isAcceptableOrUnknown(
          data['price_override_paise']!,
          _priceOverridePaiseMeta,
        ),
      );
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {planId, date},
  ];
  @override
  TiffinLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TiffinLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      planId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      priceOverridePaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price_override_paise'],
      ),
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_id'],
      ),
    );
  }

  @override
  $TiffinLogsTable createAlias(String alias) {
    return $TiffinLogsTable(attachedDatabase, alias);
  }
}

class TiffinLog extends DataClass implements Insertable<TiffinLog> {
  final String id;
  final String planId;
  final String date;
  final String status;
  final int? priceOverridePaise;
  final String? transactionId;
  const TiffinLog({
    required this.id,
    required this.planId,
    required this.date,
    required this.status,
    this.priceOverridePaise,
    this.transactionId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['plan_id'] = Variable<String>(planId);
    map['date'] = Variable<String>(date);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || priceOverridePaise != null) {
      map['price_override_paise'] = Variable<int>(priceOverridePaise);
    }
    if (!nullToAbsent || transactionId != null) {
      map['transaction_id'] = Variable<String>(transactionId);
    }
    return map;
  }

  TiffinLogsCompanion toCompanion(bool nullToAbsent) {
    return TiffinLogsCompanion(
      id: Value(id),
      planId: Value(planId),
      date: Value(date),
      status: Value(status),
      priceOverridePaise: priceOverridePaise == null && nullToAbsent
          ? const Value.absent()
          : Value(priceOverridePaise),
      transactionId: transactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionId),
    );
  }

  factory TiffinLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TiffinLog(
      id: serializer.fromJson<String>(json['id']),
      planId: serializer.fromJson<String>(json['planId']),
      date: serializer.fromJson<String>(json['date']),
      status: serializer.fromJson<String>(json['status']),
      priceOverridePaise: serializer.fromJson<int?>(json['priceOverridePaise']),
      transactionId: serializer.fromJson<String?>(json['transactionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'planId': serializer.toJson<String>(planId),
      'date': serializer.toJson<String>(date),
      'status': serializer.toJson<String>(status),
      'priceOverridePaise': serializer.toJson<int?>(priceOverridePaise),
      'transactionId': serializer.toJson<String?>(transactionId),
    };
  }

  TiffinLog copyWith({
    String? id,
    String? planId,
    String? date,
    String? status,
    Value<int?> priceOverridePaise = const Value.absent(),
    Value<String?> transactionId = const Value.absent(),
  }) => TiffinLog(
    id: id ?? this.id,
    planId: planId ?? this.planId,
    date: date ?? this.date,
    status: status ?? this.status,
    priceOverridePaise: priceOverridePaise.present
        ? priceOverridePaise.value
        : this.priceOverridePaise,
    transactionId: transactionId.present
        ? transactionId.value
        : this.transactionId,
  );
  TiffinLog copyWithCompanion(TiffinLogsCompanion data) {
    return TiffinLog(
      id: data.id.present ? data.id.value : this.id,
      planId: data.planId.present ? data.planId.value : this.planId,
      date: data.date.present ? data.date.value : this.date,
      status: data.status.present ? data.status.value : this.status,
      priceOverridePaise: data.priceOverridePaise.present
          ? data.priceOverridePaise.value
          : this.priceOverridePaise,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TiffinLog(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('date: $date, ')
          ..write('status: $status, ')
          ..write('priceOverridePaise: $priceOverridePaise, ')
          ..write('transactionId: $transactionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, planId, date, status, priceOverridePaise, transactionId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TiffinLog &&
          other.id == this.id &&
          other.planId == this.planId &&
          other.date == this.date &&
          other.status == this.status &&
          other.priceOverridePaise == this.priceOverridePaise &&
          other.transactionId == this.transactionId);
}

class TiffinLogsCompanion extends UpdateCompanion<TiffinLog> {
  final Value<String> id;
  final Value<String> planId;
  final Value<String> date;
  final Value<String> status;
  final Value<int?> priceOverridePaise;
  final Value<String?> transactionId;
  final Value<int> rowid;
  const TiffinLogsCompanion({
    this.id = const Value.absent(),
    this.planId = const Value.absent(),
    this.date = const Value.absent(),
    this.status = const Value.absent(),
    this.priceOverridePaise = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TiffinLogsCompanion.insert({
    required String id,
    required String planId,
    required String date,
    this.status = const Value.absent(),
    this.priceOverridePaise = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       planId = Value(planId),
       date = Value(date);
  static Insertable<TiffinLog> custom({
    Expression<String>? id,
    Expression<String>? planId,
    Expression<String>? date,
    Expression<String>? status,
    Expression<int>? priceOverridePaise,
    Expression<String>? transactionId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (planId != null) 'plan_id': planId,
      if (date != null) 'date': date,
      if (status != null) 'status': status,
      if (priceOverridePaise != null)
        'price_override_paise': priceOverridePaise,
      if (transactionId != null) 'transaction_id': transactionId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TiffinLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? planId,
    Value<String>? date,
    Value<String>? status,
    Value<int?>? priceOverridePaise,
    Value<String?>? transactionId,
    Value<int>? rowid,
  }) {
    return TiffinLogsCompanion(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      date: date ?? this.date,
      status: status ?? this.status,
      priceOverridePaise: priceOverridePaise ?? this.priceOverridePaise,
      transactionId: transactionId ?? this.transactionId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<String>(planId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (priceOverridePaise.present) {
      map['price_override_paise'] = Variable<int>(priceOverridePaise.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TiffinLogsCompanion(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('date: $date, ')
          ..write('status: $status, ')
          ..write('priceOverridePaise: $priceOverridePaise, ')
          ..write('transactionId: $transactionId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TodosTable extends Todos with TableInfo<$TodosTable, Todo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TodosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<int> dueAt = GeneratedColumn<int>(
    'due_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _isDoneMeta = const VerificationMeta('isDone');
  @override
  late final GeneratedColumn<bool> isDone = GeneratedColumn<bool>(
    'is_done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _doneAtMeta = const VerificationMeta('doneAt');
  @override
  late final GeneratedColumn<int> doneAt = GeneratedColumn<int>(
    'done_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionTypeMeta = const VerificationMeta(
    'actionType',
  );
  @override
  late final GeneratedColumn<String> actionType = GeneratedColumn<String>(
    'action_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actionPayloadJsonMeta = const VerificationMeta(
    'actionPayloadJson',
  );
  @override
  late final GeneratedColumn<String> actionPayloadJson =
      GeneratedColumn<String>(
        'action_payload_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _actionStatusMeta = const VerificationMeta(
    'actionStatus',
  );
  @override
  late final GeneratedColumn<String> actionStatus = GeneratedColumn<String>(
    'action_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  static const VerificationMeta _recurrenceMeta = const VerificationMeta(
    'recurrence',
  );
  @override
  late final GeneratedColumn<String> recurrence = GeneratedColumn<String>(
    'recurrence',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  static const VerificationMeta _parentTodoIdMeta = const VerificationMeta(
    'parentTodoId',
  );
  @override
  late final GeneratedColumn<String> parentTodoId = GeneratedColumn<String>(
    'parent_todo_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    notes,
    dueAt,
    priority,
    isDone,
    doneAt,
    createdAt,
    actionType,
    actionPayloadJson,
    actionStatus,
    recurrence,
    parentTodoId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'todos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Todo> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('is_done')) {
      context.handle(
        _isDoneMeta,
        isDone.isAcceptableOrUnknown(data['is_done']!, _isDoneMeta),
      );
    }
    if (data.containsKey('done_at')) {
      context.handle(
        _doneAtMeta,
        doneAt.isAcceptableOrUnknown(data['done_at']!, _doneAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('action_type')) {
      context.handle(
        _actionTypeMeta,
        actionType.isAcceptableOrUnknown(data['action_type']!, _actionTypeMeta),
      );
    }
    if (data.containsKey('action_payload_json')) {
      context.handle(
        _actionPayloadJsonMeta,
        actionPayloadJson.isAcceptableOrUnknown(
          data['action_payload_json']!,
          _actionPayloadJsonMeta,
        ),
      );
    }
    if (data.containsKey('action_status')) {
      context.handle(
        _actionStatusMeta,
        actionStatus.isAcceptableOrUnknown(
          data['action_status']!,
          _actionStatusMeta,
        ),
      );
    }
    if (data.containsKey('recurrence')) {
      context.handle(
        _recurrenceMeta,
        recurrence.isAcceptableOrUnknown(data['recurrence']!, _recurrenceMeta),
      );
    }
    if (data.containsKey('parent_todo_id')) {
      context.handle(
        _parentTodoIdMeta,
        parentTodoId.isAcceptableOrUnknown(
          data['parent_todo_id']!,
          _parentTodoIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Todo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Todo(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}due_at'],
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      isDone: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_done'],
      )!,
      doneAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}done_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      actionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action_type'],
      ),
      actionPayloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action_payload_json'],
      ),
      actionStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action_status'],
      )!,
      recurrence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence'],
      )!,
      parentTodoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_todo_id'],
      ),
    );
  }

  @override
  $TodosTable createAlias(String alias) {
    return $TodosTable(attachedDatabase, alias);
  }
}

class Todo extends DataClass implements Insertable<Todo> {
  final String id;
  final String title;
  final String notes;
  final int? dueAt;
  final int priority;
  final bool isDone;
  final int? doneAt;
  final int createdAt;
  final String? actionType;
  final String? actionPayloadJson;
  final String actionStatus;
  final String recurrence;
  final String? parentTodoId;
  const Todo({
    required this.id,
    required this.title,
    required this.notes,
    this.dueAt,
    required this.priority,
    required this.isDone,
    this.doneAt,
    required this.createdAt,
    this.actionType,
    this.actionPayloadJson,
    required this.actionStatus,
    required this.recurrence,
    this.parentTodoId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['notes'] = Variable<String>(notes);
    if (!nullToAbsent || dueAt != null) {
      map['due_at'] = Variable<int>(dueAt);
    }
    map['priority'] = Variable<int>(priority);
    map['is_done'] = Variable<bool>(isDone);
    if (!nullToAbsent || doneAt != null) {
      map['done_at'] = Variable<int>(doneAt);
    }
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || actionType != null) {
      map['action_type'] = Variable<String>(actionType);
    }
    if (!nullToAbsent || actionPayloadJson != null) {
      map['action_payload_json'] = Variable<String>(actionPayloadJson);
    }
    map['action_status'] = Variable<String>(actionStatus);
    map['recurrence'] = Variable<String>(recurrence);
    if (!nullToAbsent || parentTodoId != null) {
      map['parent_todo_id'] = Variable<String>(parentTodoId);
    }
    return map;
  }

  TodosCompanion toCompanion(bool nullToAbsent) {
    return TodosCompanion(
      id: Value(id),
      title: Value(title),
      notes: Value(notes),
      dueAt: dueAt == null && nullToAbsent
          ? const Value.absent()
          : Value(dueAt),
      priority: Value(priority),
      isDone: Value(isDone),
      doneAt: doneAt == null && nullToAbsent
          ? const Value.absent()
          : Value(doneAt),
      createdAt: Value(createdAt),
      actionType: actionType == null && nullToAbsent
          ? const Value.absent()
          : Value(actionType),
      actionPayloadJson: actionPayloadJson == null && nullToAbsent
          ? const Value.absent()
          : Value(actionPayloadJson),
      actionStatus: Value(actionStatus),
      recurrence: Value(recurrence),
      parentTodoId: parentTodoId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentTodoId),
    );
  }

  factory Todo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Todo(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      notes: serializer.fromJson<String>(json['notes']),
      dueAt: serializer.fromJson<int?>(json['dueAt']),
      priority: serializer.fromJson<int>(json['priority']),
      isDone: serializer.fromJson<bool>(json['isDone']),
      doneAt: serializer.fromJson<int?>(json['doneAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      actionType: serializer.fromJson<String?>(json['actionType']),
      actionPayloadJson: serializer.fromJson<String?>(
        json['actionPayloadJson'],
      ),
      actionStatus: serializer.fromJson<String>(json['actionStatus']),
      recurrence: serializer.fromJson<String>(json['recurrence']),
      parentTodoId: serializer.fromJson<String?>(json['parentTodoId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'notes': serializer.toJson<String>(notes),
      'dueAt': serializer.toJson<int?>(dueAt),
      'priority': serializer.toJson<int>(priority),
      'isDone': serializer.toJson<bool>(isDone),
      'doneAt': serializer.toJson<int?>(doneAt),
      'createdAt': serializer.toJson<int>(createdAt),
      'actionType': serializer.toJson<String?>(actionType),
      'actionPayloadJson': serializer.toJson<String?>(actionPayloadJson),
      'actionStatus': serializer.toJson<String>(actionStatus),
      'recurrence': serializer.toJson<String>(recurrence),
      'parentTodoId': serializer.toJson<String?>(parentTodoId),
    };
  }

  Todo copyWith({
    String? id,
    String? title,
    String? notes,
    Value<int?> dueAt = const Value.absent(),
    int? priority,
    bool? isDone,
    Value<int?> doneAt = const Value.absent(),
    int? createdAt,
    Value<String?> actionType = const Value.absent(),
    Value<String?> actionPayloadJson = const Value.absent(),
    String? actionStatus,
    String? recurrence,
    Value<String?> parentTodoId = const Value.absent(),
  }) => Todo(
    id: id ?? this.id,
    title: title ?? this.title,
    notes: notes ?? this.notes,
    dueAt: dueAt.present ? dueAt.value : this.dueAt,
    priority: priority ?? this.priority,
    isDone: isDone ?? this.isDone,
    doneAt: doneAt.present ? doneAt.value : this.doneAt,
    createdAt: createdAt ?? this.createdAt,
    actionType: actionType.present ? actionType.value : this.actionType,
    actionPayloadJson: actionPayloadJson.present
        ? actionPayloadJson.value
        : this.actionPayloadJson,
    actionStatus: actionStatus ?? this.actionStatus,
    recurrence: recurrence ?? this.recurrence,
    parentTodoId: parentTodoId.present ? parentTodoId.value : this.parentTodoId,
  );
  Todo copyWithCompanion(TodosCompanion data) {
    return Todo(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      notes: data.notes.present ? data.notes.value : this.notes,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      priority: data.priority.present ? data.priority.value : this.priority,
      isDone: data.isDone.present ? data.isDone.value : this.isDone,
      doneAt: data.doneAt.present ? data.doneAt.value : this.doneAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      actionType: data.actionType.present
          ? data.actionType.value
          : this.actionType,
      actionPayloadJson: data.actionPayloadJson.present
          ? data.actionPayloadJson.value
          : this.actionPayloadJson,
      actionStatus: data.actionStatus.present
          ? data.actionStatus.value
          : this.actionStatus,
      recurrence: data.recurrence.present
          ? data.recurrence.value
          : this.recurrence,
      parentTodoId: data.parentTodoId.present
          ? data.parentTodoId.value
          : this.parentTodoId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Todo(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('dueAt: $dueAt, ')
          ..write('priority: $priority, ')
          ..write('isDone: $isDone, ')
          ..write('doneAt: $doneAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('actionType: $actionType, ')
          ..write('actionPayloadJson: $actionPayloadJson, ')
          ..write('actionStatus: $actionStatus, ')
          ..write('recurrence: $recurrence, ')
          ..write('parentTodoId: $parentTodoId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    notes,
    dueAt,
    priority,
    isDone,
    doneAt,
    createdAt,
    actionType,
    actionPayloadJson,
    actionStatus,
    recurrence,
    parentTodoId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Todo &&
          other.id == this.id &&
          other.title == this.title &&
          other.notes == this.notes &&
          other.dueAt == this.dueAt &&
          other.priority == this.priority &&
          other.isDone == this.isDone &&
          other.doneAt == this.doneAt &&
          other.createdAt == this.createdAt &&
          other.actionType == this.actionType &&
          other.actionPayloadJson == this.actionPayloadJson &&
          other.actionStatus == this.actionStatus &&
          other.recurrence == this.recurrence &&
          other.parentTodoId == this.parentTodoId);
}

class TodosCompanion extends UpdateCompanion<Todo> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> notes;
  final Value<int?> dueAt;
  final Value<int> priority;
  final Value<bool> isDone;
  final Value<int?> doneAt;
  final Value<int> createdAt;
  final Value<String?> actionType;
  final Value<String?> actionPayloadJson;
  final Value<String> actionStatus;
  final Value<String> recurrence;
  final Value<String?> parentTodoId;
  final Value<int> rowid;
  const TodosCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.notes = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.priority = const Value.absent(),
    this.isDone = const Value.absent(),
    this.doneAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.actionType = const Value.absent(),
    this.actionPayloadJson = const Value.absent(),
    this.actionStatus = const Value.absent(),
    this.recurrence = const Value.absent(),
    this.parentTodoId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TodosCompanion.insert({
    required String id,
    required String title,
    this.notes = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.priority = const Value.absent(),
    this.isDone = const Value.absent(),
    this.doneAt = const Value.absent(),
    required int createdAt,
    this.actionType = const Value.absent(),
    this.actionPayloadJson = const Value.absent(),
    this.actionStatus = const Value.absent(),
    this.recurrence = const Value.absent(),
    this.parentTodoId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       createdAt = Value(createdAt);
  static Insertable<Todo> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? notes,
    Expression<int>? dueAt,
    Expression<int>? priority,
    Expression<bool>? isDone,
    Expression<int>? doneAt,
    Expression<int>? createdAt,
    Expression<String>? actionType,
    Expression<String>? actionPayloadJson,
    Expression<String>? actionStatus,
    Expression<String>? recurrence,
    Expression<String>? parentTodoId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (notes != null) 'notes': notes,
      if (dueAt != null) 'due_at': dueAt,
      if (priority != null) 'priority': priority,
      if (isDone != null) 'is_done': isDone,
      if (doneAt != null) 'done_at': doneAt,
      if (createdAt != null) 'created_at': createdAt,
      if (actionType != null) 'action_type': actionType,
      if (actionPayloadJson != null) 'action_payload_json': actionPayloadJson,
      if (actionStatus != null) 'action_status': actionStatus,
      if (recurrence != null) 'recurrence': recurrence,
      if (parentTodoId != null) 'parent_todo_id': parentTodoId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TodosCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? notes,
    Value<int?>? dueAt,
    Value<int>? priority,
    Value<bool>? isDone,
    Value<int?>? doneAt,
    Value<int>? createdAt,
    Value<String?>? actionType,
    Value<String?>? actionPayloadJson,
    Value<String>? actionStatus,
    Value<String>? recurrence,
    Value<String?>? parentTodoId,
    Value<int>? rowid,
  }) {
    return TodosCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      dueAt: dueAt ?? this.dueAt,
      priority: priority ?? this.priority,
      isDone: isDone ?? this.isDone,
      doneAt: doneAt ?? this.doneAt,
      createdAt: createdAt ?? this.createdAt,
      actionType: actionType ?? this.actionType,
      actionPayloadJson: actionPayloadJson ?? this.actionPayloadJson,
      actionStatus: actionStatus ?? this.actionStatus,
      recurrence: recurrence ?? this.recurrence,
      parentTodoId: parentTodoId ?? this.parentTodoId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<int>(dueAt.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (isDone.present) {
      map['is_done'] = Variable<bool>(isDone.value);
    }
    if (doneAt.present) {
      map['done_at'] = Variable<int>(doneAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (actionType.present) {
      map['action_type'] = Variable<String>(actionType.value);
    }
    if (actionPayloadJson.present) {
      map['action_payload_json'] = Variable<String>(actionPayloadJson.value);
    }
    if (actionStatus.present) {
      map['action_status'] = Variable<String>(actionStatus.value);
    }
    if (recurrence.present) {
      map['recurrence'] = Variable<String>(recurrence.value);
    }
    if (parentTodoId.present) {
      map['parent_todo_id'] = Variable<String>(parentTodoId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TodosCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('dueAt: $dueAt, ')
          ..write('priority: $priority, ')
          ..write('isDone: $isDone, ')
          ..write('doneAt: $doneAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('actionType: $actionType, ')
          ..write('actionPayloadJson: $actionPayloadJson, ')
          ..write('actionStatus: $actionStatus, ')
          ..write('recurrence: $recurrence, ')
          ..write('parentTodoId: $parentTodoId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WaterSettingsTable extends WaterSettings
    with TableInfo<$WaterSettingsTable, WaterSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WaterSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _dailyGoalMlMeta = const VerificationMeta(
    'dailyGoalMl',
  );
  @override
  late final GeneratedColumn<int> dailyGoalMl = GeneratedColumn<int>(
    'daily_goal_ml',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2500),
  );
  static const VerificationMeta _glassMlMeta = const VerificationMeta(
    'glassMl',
  );
  @override
  late final GeneratedColumn<int> glassMl = GeneratedColumn<int>(
    'glass_ml',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(200),
  );
  static const VerificationMeta _dayStartMeta = const VerificationMeta(
    'dayStart',
  );
  @override
  late final GeneratedColumn<String> dayStart = GeneratedColumn<String>(
    'day_start',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('07:00'),
  );
  static const VerificationMeta _dayEndMeta = const VerificationMeta('dayEnd');
  @override
  late final GeneratedColumn<String> dayEnd = GeneratedColumn<String>(
    'day_end',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('22:00'),
  );
  static const VerificationMeta _reminderIntervalMinMeta =
      const VerificationMeta('reminderIntervalMin');
  @override
  late final GeneratedColumn<int> reminderIntervalMin = GeneratedColumn<int>(
    'reminder_interval_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(60),
  );
  static const VerificationMeta _remindersEnabledMeta = const VerificationMeta(
    'remindersEnabled',
  );
  @override
  late final GeneratedColumn<bool> remindersEnabled = GeneratedColumn<bool>(
    'reminders_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reminders_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dailyGoalMl,
    glassMl,
    dayStart,
    dayEnd,
    reminderIntervalMin,
    remindersEnabled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'water_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<WaterSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('daily_goal_ml')) {
      context.handle(
        _dailyGoalMlMeta,
        dailyGoalMl.isAcceptableOrUnknown(
          data['daily_goal_ml']!,
          _dailyGoalMlMeta,
        ),
      );
    }
    if (data.containsKey('glass_ml')) {
      context.handle(
        _glassMlMeta,
        glassMl.isAcceptableOrUnknown(data['glass_ml']!, _glassMlMeta),
      );
    }
    if (data.containsKey('day_start')) {
      context.handle(
        _dayStartMeta,
        dayStart.isAcceptableOrUnknown(data['day_start']!, _dayStartMeta),
      );
    }
    if (data.containsKey('day_end')) {
      context.handle(
        _dayEndMeta,
        dayEnd.isAcceptableOrUnknown(data['day_end']!, _dayEndMeta),
      );
    }
    if (data.containsKey('reminder_interval_min')) {
      context.handle(
        _reminderIntervalMinMeta,
        reminderIntervalMin.isAcceptableOrUnknown(
          data['reminder_interval_min']!,
          _reminderIntervalMinMeta,
        ),
      );
    }
    if (data.containsKey('reminders_enabled')) {
      context.handle(
        _remindersEnabledMeta,
        remindersEnabled.isAcceptableOrUnknown(
          data['reminders_enabled']!,
          _remindersEnabledMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WaterSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WaterSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      dailyGoalMl: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_goal_ml'],
      )!,
      glassMl: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}glass_ml'],
      )!,
      dayStart: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_start'],
      )!,
      dayEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_end'],
      )!,
      reminderIntervalMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_interval_min'],
      )!,
      remindersEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reminders_enabled'],
      )!,
    );
  }

  @override
  $WaterSettingsTable createAlias(String alias) {
    return $WaterSettingsTable(attachedDatabase, alias);
  }
}

class WaterSetting extends DataClass implements Insertable<WaterSetting> {
  final int id;
  final int dailyGoalMl;
  final int glassMl;
  final String dayStart;
  final String dayEnd;
  final int reminderIntervalMin;
  final bool remindersEnabled;
  const WaterSetting({
    required this.id,
    required this.dailyGoalMl,
    required this.glassMl,
    required this.dayStart,
    required this.dayEnd,
    required this.reminderIntervalMin,
    required this.remindersEnabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['daily_goal_ml'] = Variable<int>(dailyGoalMl);
    map['glass_ml'] = Variable<int>(glassMl);
    map['day_start'] = Variable<String>(dayStart);
    map['day_end'] = Variable<String>(dayEnd);
    map['reminder_interval_min'] = Variable<int>(reminderIntervalMin);
    map['reminders_enabled'] = Variable<bool>(remindersEnabled);
    return map;
  }

  WaterSettingsCompanion toCompanion(bool nullToAbsent) {
    return WaterSettingsCompanion(
      id: Value(id),
      dailyGoalMl: Value(dailyGoalMl),
      glassMl: Value(glassMl),
      dayStart: Value(dayStart),
      dayEnd: Value(dayEnd),
      reminderIntervalMin: Value(reminderIntervalMin),
      remindersEnabled: Value(remindersEnabled),
    );
  }

  factory WaterSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WaterSetting(
      id: serializer.fromJson<int>(json['id']),
      dailyGoalMl: serializer.fromJson<int>(json['dailyGoalMl']),
      glassMl: serializer.fromJson<int>(json['glassMl']),
      dayStart: serializer.fromJson<String>(json['dayStart']),
      dayEnd: serializer.fromJson<String>(json['dayEnd']),
      reminderIntervalMin: serializer.fromJson<int>(
        json['reminderIntervalMin'],
      ),
      remindersEnabled: serializer.fromJson<bool>(json['remindersEnabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dailyGoalMl': serializer.toJson<int>(dailyGoalMl),
      'glassMl': serializer.toJson<int>(glassMl),
      'dayStart': serializer.toJson<String>(dayStart),
      'dayEnd': serializer.toJson<String>(dayEnd),
      'reminderIntervalMin': serializer.toJson<int>(reminderIntervalMin),
      'remindersEnabled': serializer.toJson<bool>(remindersEnabled),
    };
  }

  WaterSetting copyWith({
    int? id,
    int? dailyGoalMl,
    int? glassMl,
    String? dayStart,
    String? dayEnd,
    int? reminderIntervalMin,
    bool? remindersEnabled,
  }) => WaterSetting(
    id: id ?? this.id,
    dailyGoalMl: dailyGoalMl ?? this.dailyGoalMl,
    glassMl: glassMl ?? this.glassMl,
    dayStart: dayStart ?? this.dayStart,
    dayEnd: dayEnd ?? this.dayEnd,
    reminderIntervalMin: reminderIntervalMin ?? this.reminderIntervalMin,
    remindersEnabled: remindersEnabled ?? this.remindersEnabled,
  );
  WaterSetting copyWithCompanion(WaterSettingsCompanion data) {
    return WaterSetting(
      id: data.id.present ? data.id.value : this.id,
      dailyGoalMl: data.dailyGoalMl.present
          ? data.dailyGoalMl.value
          : this.dailyGoalMl,
      glassMl: data.glassMl.present ? data.glassMl.value : this.glassMl,
      dayStart: data.dayStart.present ? data.dayStart.value : this.dayStart,
      dayEnd: data.dayEnd.present ? data.dayEnd.value : this.dayEnd,
      reminderIntervalMin: data.reminderIntervalMin.present
          ? data.reminderIntervalMin.value
          : this.reminderIntervalMin,
      remindersEnabled: data.remindersEnabled.present
          ? data.remindersEnabled.value
          : this.remindersEnabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WaterSetting(')
          ..write('id: $id, ')
          ..write('dailyGoalMl: $dailyGoalMl, ')
          ..write('glassMl: $glassMl, ')
          ..write('dayStart: $dayStart, ')
          ..write('dayEnd: $dayEnd, ')
          ..write('reminderIntervalMin: $reminderIntervalMin, ')
          ..write('remindersEnabled: $remindersEnabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    dailyGoalMl,
    glassMl,
    dayStart,
    dayEnd,
    reminderIntervalMin,
    remindersEnabled,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WaterSetting &&
          other.id == this.id &&
          other.dailyGoalMl == this.dailyGoalMl &&
          other.glassMl == this.glassMl &&
          other.dayStart == this.dayStart &&
          other.dayEnd == this.dayEnd &&
          other.reminderIntervalMin == this.reminderIntervalMin &&
          other.remindersEnabled == this.remindersEnabled);
}

class WaterSettingsCompanion extends UpdateCompanion<WaterSetting> {
  final Value<int> id;
  final Value<int> dailyGoalMl;
  final Value<int> glassMl;
  final Value<String> dayStart;
  final Value<String> dayEnd;
  final Value<int> reminderIntervalMin;
  final Value<bool> remindersEnabled;
  const WaterSettingsCompanion({
    this.id = const Value.absent(),
    this.dailyGoalMl = const Value.absent(),
    this.glassMl = const Value.absent(),
    this.dayStart = const Value.absent(),
    this.dayEnd = const Value.absent(),
    this.reminderIntervalMin = const Value.absent(),
    this.remindersEnabled = const Value.absent(),
  });
  WaterSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.dailyGoalMl = const Value.absent(),
    this.glassMl = const Value.absent(),
    this.dayStart = const Value.absent(),
    this.dayEnd = const Value.absent(),
    this.reminderIntervalMin = const Value.absent(),
    this.remindersEnabled = const Value.absent(),
  });
  static Insertable<WaterSetting> custom({
    Expression<int>? id,
    Expression<int>? dailyGoalMl,
    Expression<int>? glassMl,
    Expression<String>? dayStart,
    Expression<String>? dayEnd,
    Expression<int>? reminderIntervalMin,
    Expression<bool>? remindersEnabled,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dailyGoalMl != null) 'daily_goal_ml': dailyGoalMl,
      if (glassMl != null) 'glass_ml': glassMl,
      if (dayStart != null) 'day_start': dayStart,
      if (dayEnd != null) 'day_end': dayEnd,
      if (reminderIntervalMin != null)
        'reminder_interval_min': reminderIntervalMin,
      if (remindersEnabled != null) 'reminders_enabled': remindersEnabled,
    });
  }

  WaterSettingsCompanion copyWith({
    Value<int>? id,
    Value<int>? dailyGoalMl,
    Value<int>? glassMl,
    Value<String>? dayStart,
    Value<String>? dayEnd,
    Value<int>? reminderIntervalMin,
    Value<bool>? remindersEnabled,
  }) {
    return WaterSettingsCompanion(
      id: id ?? this.id,
      dailyGoalMl: dailyGoalMl ?? this.dailyGoalMl,
      glassMl: glassMl ?? this.glassMl,
      dayStart: dayStart ?? this.dayStart,
      dayEnd: dayEnd ?? this.dayEnd,
      reminderIntervalMin: reminderIntervalMin ?? this.reminderIntervalMin,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dailyGoalMl.present) {
      map['daily_goal_ml'] = Variable<int>(dailyGoalMl.value);
    }
    if (glassMl.present) {
      map['glass_ml'] = Variable<int>(glassMl.value);
    }
    if (dayStart.present) {
      map['day_start'] = Variable<String>(dayStart.value);
    }
    if (dayEnd.present) {
      map['day_end'] = Variable<String>(dayEnd.value);
    }
    if (reminderIntervalMin.present) {
      map['reminder_interval_min'] = Variable<int>(reminderIntervalMin.value);
    }
    if (remindersEnabled.present) {
      map['reminders_enabled'] = Variable<bool>(remindersEnabled.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WaterSettingsCompanion(')
          ..write('id: $id, ')
          ..write('dailyGoalMl: $dailyGoalMl, ')
          ..write('glassMl: $glassMl, ')
          ..write('dayStart: $dayStart, ')
          ..write('dayEnd: $dayEnd, ')
          ..write('reminderIntervalMin: $reminderIntervalMin, ')
          ..write('remindersEnabled: $remindersEnabled')
          ..write(')'))
        .toString();
  }
}

class $WaterLogsTable extends WaterLogs
    with TableInfo<$WaterLogsTable, WaterLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WaterLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMlMeta = const VerificationMeta(
    'amountMl',
  );
  @override
  late final GeneratedColumn<int> amountMl = GeneratedColumn<int>(
    'amount_ml',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _loggedAtMeta = const VerificationMeta(
    'loggedAt',
  );
  @override
  late final GeneratedColumn<int> loggedAt = GeneratedColumn<int>(
    'logged_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, amountMl, loggedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'water_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<WaterLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('amount_ml')) {
      context.handle(
        _amountMlMeta,
        amountMl.isAcceptableOrUnknown(data['amount_ml']!, _amountMlMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMlMeta);
    }
    if (data.containsKey('logged_at')) {
      context.handle(
        _loggedAtMeta,
        loggedAt.isAcceptableOrUnknown(data['logged_at']!, _loggedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_loggedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WaterLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WaterLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      amountMl: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_ml'],
      )!,
      loggedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}logged_at'],
      )!,
    );
  }

  @override
  $WaterLogsTable createAlias(String alias) {
    return $WaterLogsTable(attachedDatabase, alias);
  }
}

class WaterLog extends DataClass implements Insertable<WaterLog> {
  final String id;
  final int amountMl;
  final int loggedAt;
  const WaterLog({
    required this.id,
    required this.amountMl,
    required this.loggedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['amount_ml'] = Variable<int>(amountMl);
    map['logged_at'] = Variable<int>(loggedAt);
    return map;
  }

  WaterLogsCompanion toCompanion(bool nullToAbsent) {
    return WaterLogsCompanion(
      id: Value(id),
      amountMl: Value(amountMl),
      loggedAt: Value(loggedAt),
    );
  }

  factory WaterLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WaterLog(
      id: serializer.fromJson<String>(json['id']),
      amountMl: serializer.fromJson<int>(json['amountMl']),
      loggedAt: serializer.fromJson<int>(json['loggedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'amountMl': serializer.toJson<int>(amountMl),
      'loggedAt': serializer.toJson<int>(loggedAt),
    };
  }

  WaterLog copyWith({String? id, int? amountMl, int? loggedAt}) => WaterLog(
    id: id ?? this.id,
    amountMl: amountMl ?? this.amountMl,
    loggedAt: loggedAt ?? this.loggedAt,
  );
  WaterLog copyWithCompanion(WaterLogsCompanion data) {
    return WaterLog(
      id: data.id.present ? data.id.value : this.id,
      amountMl: data.amountMl.present ? data.amountMl.value : this.amountMl,
      loggedAt: data.loggedAt.present ? data.loggedAt.value : this.loggedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WaterLog(')
          ..write('id: $id, ')
          ..write('amountMl: $amountMl, ')
          ..write('loggedAt: $loggedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, amountMl, loggedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WaterLog &&
          other.id == this.id &&
          other.amountMl == this.amountMl &&
          other.loggedAt == this.loggedAt);
}

class WaterLogsCompanion extends UpdateCompanion<WaterLog> {
  final Value<String> id;
  final Value<int> amountMl;
  final Value<int> loggedAt;
  final Value<int> rowid;
  const WaterLogsCompanion({
    this.id = const Value.absent(),
    this.amountMl = const Value.absent(),
    this.loggedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WaterLogsCompanion.insert({
    required String id,
    required int amountMl,
    required int loggedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       amountMl = Value(amountMl),
       loggedAt = Value(loggedAt);
  static Insertable<WaterLog> custom({
    Expression<String>? id,
    Expression<int>? amountMl,
    Expression<int>? loggedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amountMl != null) 'amount_ml': amountMl,
      if (loggedAt != null) 'logged_at': loggedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WaterLogsCompanion copyWith({
    Value<String>? id,
    Value<int>? amountMl,
    Value<int>? loggedAt,
    Value<int>? rowid,
  }) {
    return WaterLogsCompanion(
      id: id ?? this.id,
      amountMl: amountMl ?? this.amountMl,
      loggedAt: loggedAt ?? this.loggedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (amountMl.present) {
      map['amount_ml'] = Variable<int>(amountMl.value);
    }
    if (loggedAt.present) {
      map['logged_at'] = Variable<int>(loggedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WaterLogsCompanion(')
          ..write('id: $id, ')
          ..write('amountMl: $amountMl, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
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
    Insertable<AppSetting> instance, {
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
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
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

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
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

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
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

  AppSetting copyWith({String? key, String? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
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
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
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
  static Insertable<AppSetting> custom({
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

class $DebugLogsTable extends DebugLogs
    with TableInfo<$DebugLogsTable, DebugLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DebugLogsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<int> timestamp = GeneratedColumn<int>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contextMeta = const VerificationMeta(
    'context',
  );
  @override
  late final GeneratedColumn<String> context = GeneratedColumn<String>(
    'context',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    level,
    message,
    timestamp,
    context,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'debug_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<DebugLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('context')) {
      context.handle(
        _contextMeta,
        this.context.isAcceptableOrUnknown(data['context']!, _contextMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DebugLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DebugLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timestamp'],
      )!,
      context: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}context'],
      )!,
    );
  }

  @override
  $DebugLogsTable createAlias(String alias) {
    return $DebugLogsTable(attachedDatabase, alias);
  }
}

class DebugLog extends DataClass implements Insertable<DebugLog> {
  final int id;
  final String level;
  final String message;
  final int timestamp;
  final String context;
  const DebugLog({
    required this.id,
    required this.level,
    required this.message,
    required this.timestamp,
    required this.context,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['level'] = Variable<String>(level);
    map['message'] = Variable<String>(message);
    map['timestamp'] = Variable<int>(timestamp);
    map['context'] = Variable<String>(context);
    return map;
  }

  DebugLogsCompanion toCompanion(bool nullToAbsent) {
    return DebugLogsCompanion(
      id: Value(id),
      level: Value(level),
      message: Value(message),
      timestamp: Value(timestamp),
      context: Value(context),
    );
  }

  factory DebugLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DebugLog(
      id: serializer.fromJson<int>(json['id']),
      level: serializer.fromJson<String>(json['level']),
      message: serializer.fromJson<String>(json['message']),
      timestamp: serializer.fromJson<int>(json['timestamp']),
      context: serializer.fromJson<String>(json['context']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'level': serializer.toJson<String>(level),
      'message': serializer.toJson<String>(message),
      'timestamp': serializer.toJson<int>(timestamp),
      'context': serializer.toJson<String>(context),
    };
  }

  DebugLog copyWith({
    int? id,
    String? level,
    String? message,
    int? timestamp,
    String? context,
  }) => DebugLog(
    id: id ?? this.id,
    level: level ?? this.level,
    message: message ?? this.message,
    timestamp: timestamp ?? this.timestamp,
    context: context ?? this.context,
  );
  DebugLog copyWithCompanion(DebugLogsCompanion data) {
    return DebugLog(
      id: data.id.present ? data.id.value : this.id,
      level: data.level.present ? data.level.value : this.level,
      message: data.message.present ? data.message.value : this.message,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      context: data.context.present ? data.context.value : this.context,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DebugLog(')
          ..write('id: $id, ')
          ..write('level: $level, ')
          ..write('message: $message, ')
          ..write('timestamp: $timestamp, ')
          ..write('context: $context')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, level, message, timestamp, context);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DebugLog &&
          other.id == this.id &&
          other.level == this.level &&
          other.message == this.message &&
          other.timestamp == this.timestamp &&
          other.context == this.context);
}

class DebugLogsCompanion extends UpdateCompanion<DebugLog> {
  final Value<int> id;
  final Value<String> level;
  final Value<String> message;
  final Value<int> timestamp;
  final Value<String> context;
  const DebugLogsCompanion({
    this.id = const Value.absent(),
    this.level = const Value.absent(),
    this.message = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.context = const Value.absent(),
  });
  DebugLogsCompanion.insert({
    this.id = const Value.absent(),
    required String level,
    required String message,
    required int timestamp,
    this.context = const Value.absent(),
  }) : level = Value(level),
       message = Value(message),
       timestamp = Value(timestamp);
  static Insertable<DebugLog> custom({
    Expression<int>? id,
    Expression<String>? level,
    Expression<String>? message,
    Expression<int>? timestamp,
    Expression<String>? context,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (level != null) 'level': level,
      if (message != null) 'message': message,
      if (timestamp != null) 'timestamp': timestamp,
      if (context != null) 'context': context,
    });
  }

  DebugLogsCompanion copyWith({
    Value<int>? id,
    Value<String>? level,
    Value<String>? message,
    Value<int>? timestamp,
    Value<String>? context,
  }) {
    return DebugLogsCompanion(
      id: id ?? this.id,
      level: level ?? this.level,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      context: context ?? this.context,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<int>(timestamp.value);
    }
    if (context.present) {
      map['context'] = Variable<String>(context.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DebugLogsCompanion(')
          ..write('id: $id, ')
          ..write('level: $level, ')
          ..write('message: $message, ')
          ..write('timestamp: $timestamp, ')
          ..write('context: $context')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $BudgetsTable budgets = $BudgetsTable(this);
  late final $RecurringExpensesTable recurringExpenses =
      $RecurringExpensesTable(this);
  late final $TiffinPlansTable tiffinPlans = $TiffinPlansTable(this);
  late final $TiffinLogsTable tiffinLogs = $TiffinLogsTable(this);
  late final $TodosTable todos = $TodosTable(this);
  late final $WaterSettingsTable waterSettings = $WaterSettingsTable(this);
  late final $WaterLogsTable waterLogs = $WaterLogsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $DebugLogsTable debugLogs = $DebugLogsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categories,
    transactions,
    budgets,
    recurringExpenses,
    tiffinPlans,
    tiffinLogs,
    todos,
    waterSettings,
    waterLogs,
    appSettings,
    debugLogs,
  ];
}

typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  required String id,
  required String name,
  Value<String> iconKey,
  Value<String> colorHex,
  required String kind,
  Value<bool> isDefault,
  Value<int> rowid,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> iconKey,
  Value<String> colorHex,
  Value<String> kind,
  Value<bool> isDefault,
  Value<int> rowid,
});

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TransactionsTable, List<Transaction>>
  _transactionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: 'categories__id__transactions__category_id',
  );

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RecurringExpensesTable, List<RecurringExpense>>
  _recurringExpensesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.recurringExpenses,
        aliasName: 'categories__id__recurring_expenses__category_id',
      );

  $$RecurringExpensesTableProcessedTableManager get recurringExpensesRefs {
    final manager = $$RecurringExpensesTableTableManager(
      $_db,
      $_db.recurringExpenses,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _recurringExpensesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> transactionsRefs(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> recurringExpensesRefs(
    Expression<bool> Function($$RecurringExpensesTableFilterComposer f) f,
  ) {
    final $$RecurringExpensesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recurringExpenses,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecurringExpensesTableFilterComposer(
            $db: $db,
            $table: $db.recurringExpenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get iconKey =>
      $composableBuilder(column: $table.iconKey, builder: (column) => column);

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  Expression<T> transactionsRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> recurringExpensesRefs<T extends Object>(
    Expression<T> Function($$RecurringExpensesTableAnnotationComposer a) f,
  ) {
    final $$RecurringExpensesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.recurringExpenses,
          getReferencedColumn: (t) => t.categoryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringExpensesTableAnnotationComposer(
                $db: $db,
                $table: $db.recurringExpenses,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, $$CategoriesTableReferences),
          Category,
          PrefetchHooks Function({
            bool transactionsRefs,
            bool recurringExpensesRefs,
          })
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> iconKey = const Value.absent(),
                Value<String> colorHex = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                iconKey: iconKey,
                colorHex: colorHex,
                kind: kind,
                isDefault: isDefault,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> iconKey = const Value.absent(),
                Value<String> colorHex = const Value.absent(),
                required String kind,
                Value<bool> isDefault = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                iconKey: iconKey,
                colorHex: colorHex,
                kind: kind,
                isDefault: isDefault,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoriesTable, Category>(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({transactionsRefs = false, recurringExpensesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transactionsRefs) db.transactions,
                    if (recurringExpensesRefs) db.recurringExpenses,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transactionsRefs)
                        await $_getPrefetchedData<
                          Category,
                          $CategoriesTable,
                          Transaction
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._transactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (recurringExpensesRefs)
                        await $_getPrefetchedData<
                          Category,
                          $CategoriesTable,
                          RecurringExpense
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._recurringExpensesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).recurringExpensesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, $$CategoriesTableReferences),
      Category,
      PrefetchHooks Function({
        bool transactionsRefs,
        bool recurringExpensesRefs,
      })
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      required String id,
      required int amountPaise,
      required String type,
      required String categoryId,
      Value<String> note,
      required String date,
      Value<String> source,
      Value<String?> sourceRefId,
      Value<bool> isShared,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<String> id,
      Value<int> amountPaise,
      Value<String> type,
      Value<String> categoryId,
      Value<String> note,
      Value<String> date,
      Value<String> source,
      Value<String?> sourceRefId,
      Value<bool> isShared,
      Value<int> createdAt,
      Value<int> rowid,
    });

final class $$TransactionsTableReferences
    extends BaseReferences<_$AppDatabase, $TransactionsTable, Transaction> {
  $$TransactionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias('transactions__category_id__categories__id');

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<String>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
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

  ColumnFilters<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceRefId => $composableBuilder(
    column: $table.sourceRefId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isShared => $composableBuilder(
    column: $table.isShared,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
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

  ColumnOrderings<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceRefId => $composableBuilder(
    column: $table.sourceRefId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isShared => $composableBuilder(
    column: $table.isShared,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get sourceRefId => $composableBuilder(
    column: $table.sourceRefId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isShared =>
      $composableBuilder(column: $table.isShared, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          Transaction,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (Transaction, $$TransactionsTableReferences),
          Transaction,
          PrefetchHooks Function({bool categoryId})
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> sourceRefId = const Value.absent(),
                Value<bool> isShared = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                amountPaise: amountPaise,
                type: type,
                categoryId: categoryId,
                note: note,
                date: date,
                source: source,
                sourceRefId: sourceRefId,
                isShared: isShared,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int amountPaise,
                required String type,
                required String categoryId,
                Value<String> note = const Value.absent(),
                required String date,
                Value<String> source = const Value.absent(),
                Value<String?> sourceRefId = const Value.absent(),
                Value<bool> isShared = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                amountPaise: amountPaise,
                type: type,
                categoryId: categoryId,
                note: note,
                date: date,
                source: source,
                sourceRefId: sourceRefId,
                isShared: isShared,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TransactionsTable, Transaction>(table),
                  $$TransactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
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
                    if (categoryId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.categoryId,
                        referencedTable: $$TransactionsTableReferences
                            ._categoryIdTable(db),
                        referencedColumn: $$TransactionsTableReferences
                            ._categoryIdTable(db)
                            .id,
                      ) as T;
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

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      Transaction,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (Transaction, $$TransactionsTableReferences),
      Transaction,
      PrefetchHooks Function({bool categoryId})
    >;
typedef $$BudgetsTableCreateCompanionBuilder = BudgetsCompanion Function({
  required String id,
  required String month,
  Value<String?> categoryId,
  required int limitPaise,
  Value<int> rowid,
});
typedef $$BudgetsTableUpdateCompanionBuilder = BudgetsCompanion Function({
  Value<String> id,
  Value<String> month,
  Value<String?> categoryId,
  Value<int> limitPaise,
  Value<int> rowid,
});

class $$BudgetsTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableFilterComposer({
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

  ColumnFilters<String> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get limitPaise => $composableBuilder(
    column: $table.limitPaise,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BudgetsTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableOrderingComposer({
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

  ColumnOrderings<String> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get limitPaise => $composableBuilder(
    column: $table.limitPaise,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BudgetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get limitPaise => $composableBuilder(
    column: $table.limitPaise,
    builder: (column) => column,
  );
}

class $$BudgetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BudgetsTable,
          Budget,
          $$BudgetsTableFilterComposer,
          $$BudgetsTableOrderingComposer,
          $$BudgetsTableAnnotationComposer,
          $$BudgetsTableCreateCompanionBuilder,
          $$BudgetsTableUpdateCompanionBuilder,
          (Budget, BaseReferences<_$AppDatabase, $BudgetsTable, Budget>),
          Budget,
          PrefetchHooks Function()
        > {
  $$BudgetsTableTableManager(_$AppDatabase db, $BudgetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> month = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<int> limitPaise = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetsCompanion(
                id: id,
                month: month,
                categoryId: categoryId,
                limitPaise: limitPaise,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String month,
                Value<String?> categoryId = const Value.absent(),
                required int limitPaise,
                Value<int> rowid = const Value.absent(),
              }) => BudgetsCompanion.insert(
                id: id,
                month: month,
                categoryId: categoryId,
                limitPaise: limitPaise,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BudgetsTable, Budget>(table),
                  BaseReferences<_$AppDatabase, $BudgetsTable, Budget>(
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

typedef $$BudgetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BudgetsTable,
      Budget,
      $$BudgetsTableFilterComposer,
      $$BudgetsTableOrderingComposer,
      $$BudgetsTableAnnotationComposer,
      $$BudgetsTableCreateCompanionBuilder,
      $$BudgetsTableUpdateCompanionBuilder,
      (Budget, BaseReferences<_$AppDatabase, $BudgetsTable, Budget>),
      Budget,
      PrefetchHooks Function()
    >;
typedef $$RecurringExpensesTableCreateCompanionBuilder =
    RecurringExpensesCompanion Function({
      required String id,
      required String title,
      required int amountPaise,
      required String categoryId,
      required int dayOfMonth,
      Value<bool> isActive,
      Value<String> lastGeneratedMonth,
      Value<int> rowid,
    });
typedef $$RecurringExpensesTableUpdateCompanionBuilder =
    RecurringExpensesCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<int> amountPaise,
      Value<String> categoryId,
      Value<int> dayOfMonth,
      Value<bool> isActive,
      Value<String> lastGeneratedMonth,
      Value<int> rowid,
    });

final class $$RecurringExpensesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $RecurringExpensesTable,
          RecurringExpense
        > {
  $$RecurringExpensesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) => db.categories
      .createAlias('recurring_expenses__category_id__categories__id');

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<String>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RecurringExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringExpensesTable> {
  $$RecurringExpensesTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayOfMonth => $composableBuilder(
    column: $table.dayOfMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastGeneratedMonth => $composableBuilder(
    column: $table.lastGeneratedMonth,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecurringExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringExpensesTable> {
  $$RecurringExpensesTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayOfMonth => $composableBuilder(
    column: $table.dayOfMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastGeneratedMonth => $composableBuilder(
    column: $table.lastGeneratedMonth,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecurringExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringExpensesTable> {
  $$RecurringExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dayOfMonth => $composableBuilder(
    column: $table.dayOfMonth,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get lastGeneratedMonth => $composableBuilder(
    column: $table.lastGeneratedMonth,
    builder: (column) => column,
  );

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecurringExpensesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecurringExpensesTable,
          RecurringExpense,
          $$RecurringExpensesTableFilterComposer,
          $$RecurringExpensesTableOrderingComposer,
          $$RecurringExpensesTableAnnotationComposer,
          $$RecurringExpensesTableCreateCompanionBuilder,
          $$RecurringExpensesTableUpdateCompanionBuilder,
          (RecurringExpense, $$RecurringExpensesTableReferences),
          RecurringExpense,
          PrefetchHooks Function({bool categoryId})
        > {
  $$RecurringExpensesTableTableManager(
    _$AppDatabase db,
    $RecurringExpensesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurringExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecurringExpensesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<int> dayOfMonth = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String> lastGeneratedMonth = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurringExpensesCompanion(
                id: id,
                title: title,
                amountPaise: amountPaise,
                categoryId: categoryId,
                dayOfMonth: dayOfMonth,
                isActive: isActive,
                lastGeneratedMonth: lastGeneratedMonth,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required int amountPaise,
                required String categoryId,
                required int dayOfMonth,
                Value<bool> isActive = const Value.absent(),
                Value<String> lastGeneratedMonth = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurringExpensesCompanion.insert(
                id: id,
                title: title,
                amountPaise: amountPaise,
                categoryId: categoryId,
                dayOfMonth: dayOfMonth,
                isActive: isActive,
                lastGeneratedMonth: lastGeneratedMonth,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RecurringExpensesTable, RecurringExpense>(table),
                  $$RecurringExpensesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
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
                    if (categoryId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.categoryId,
                        referencedTable: $$RecurringExpensesTableReferences
                            ._categoryIdTable(db),
                        referencedColumn: $$RecurringExpensesTableReferences
                            ._categoryIdTable(db)
                            .id,
                      ) as T;
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

typedef $$RecurringExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecurringExpensesTable,
      RecurringExpense,
      $$RecurringExpensesTableFilterComposer,
      $$RecurringExpensesTableOrderingComposer,
      $$RecurringExpensesTableAnnotationComposer,
      $$RecurringExpensesTableCreateCompanionBuilder,
      $$RecurringExpensesTableUpdateCompanionBuilder,
      (RecurringExpense, $$RecurringExpensesTableReferences),
      RecurringExpense,
      PrefetchHooks Function({bool categoryId})
    >;
typedef $$TiffinPlansTableCreateCompanionBuilder =
    TiffinPlansCompanion Function({
      required String id,
      required String providerName,
      required String mealType,
      required int pricePerTiffinPaise,
      required int activeWeekdaysMask,
      Value<String> reminderTime,
      required String startDate,
      Value<bool> isActive,
      Value<int> rowid,
    });
typedef $$TiffinPlansTableUpdateCompanionBuilder =
    TiffinPlansCompanion Function({
      Value<String> id,
      Value<String> providerName,
      Value<String> mealType,
      Value<int> pricePerTiffinPaise,
      Value<int> activeWeekdaysMask,
      Value<String> reminderTime,
      Value<String> startDate,
      Value<bool> isActive,
      Value<int> rowid,
    });

final class $$TiffinPlansTableReferences
    extends BaseReferences<_$AppDatabase, $TiffinPlansTable, TiffinPlan> {
  $$TiffinPlansTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TiffinLogsTable, List<TiffinLog>>
  _tiffinLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.tiffinLogs,
    aliasName: 'tiffin_plans__id__tiffin_logs__plan_id',
  );

  $$TiffinLogsTableProcessedTableManager get tiffinLogsRefs {
    final manager = $$TiffinLogsTableTableManager(
      $_db,
      $_db.tiffinLogs,
    ).filter((f) => f.planId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tiffinLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TiffinPlansTableFilterComposer
    extends Composer<_$AppDatabase, $TiffinPlansTable> {
  $$TiffinPlansTableFilterComposer({
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

  ColumnFilters<String> get providerName => $composableBuilder(
    column: $table.providerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mealType => $composableBuilder(
    column: $table.mealType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pricePerTiffinPaise => $composableBuilder(
    column: $table.pricePerTiffinPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get activeWeekdaysMask => $composableBuilder(
    column: $table.activeWeekdaysMask,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> tiffinLogsRefs(
    Expression<bool> Function($$TiffinLogsTableFilterComposer f) f,
  ) {
    final $$TiffinLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tiffinLogs,
      getReferencedColumn: (t) => t.planId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TiffinLogsTableFilterComposer(
            $db: $db,
            $table: $db.tiffinLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TiffinPlansTableOrderingComposer
    extends Composer<_$AppDatabase, $TiffinPlansTable> {
  $$TiffinPlansTableOrderingComposer({
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

  ColumnOrderings<String> get providerName => $composableBuilder(
    column: $table.providerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mealType => $composableBuilder(
    column: $table.mealType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pricePerTiffinPaise => $composableBuilder(
    column: $table.pricePerTiffinPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get activeWeekdaysMask => $composableBuilder(
    column: $table.activeWeekdaysMask,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TiffinPlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $TiffinPlansTable> {
  $$TiffinPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get providerName => $composableBuilder(
    column: $table.providerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mealType =>
      $composableBuilder(column: $table.mealType, builder: (column) => column);

  GeneratedColumn<int> get pricePerTiffinPaise => $composableBuilder(
    column: $table.pricePerTiffinPaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get activeWeekdaysMask => $composableBuilder(
    column: $table.activeWeekdaysMask,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  Expression<T> tiffinLogsRefs<T extends Object>(
    Expression<T> Function($$TiffinLogsTableAnnotationComposer a) f,
  ) {
    final $$TiffinLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tiffinLogs,
      getReferencedColumn: (t) => t.planId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TiffinLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.tiffinLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TiffinPlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TiffinPlansTable,
          TiffinPlan,
          $$TiffinPlansTableFilterComposer,
          $$TiffinPlansTableOrderingComposer,
          $$TiffinPlansTableAnnotationComposer,
          $$TiffinPlansTableCreateCompanionBuilder,
          $$TiffinPlansTableUpdateCompanionBuilder,
          (TiffinPlan, $$TiffinPlansTableReferences),
          TiffinPlan,
          PrefetchHooks Function({bool tiffinLogsRefs})
        > {
  $$TiffinPlansTableTableManager(_$AppDatabase db, $TiffinPlansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TiffinPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TiffinPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TiffinPlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> providerName = const Value.absent(),
                Value<String> mealType = const Value.absent(),
                Value<int> pricePerTiffinPaise = const Value.absent(),
                Value<int> activeWeekdaysMask = const Value.absent(),
                Value<String> reminderTime = const Value.absent(),
                Value<String> startDate = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TiffinPlansCompanion(
                id: id,
                providerName: providerName,
                mealType: mealType,
                pricePerTiffinPaise: pricePerTiffinPaise,
                activeWeekdaysMask: activeWeekdaysMask,
                reminderTime: reminderTime,
                startDate: startDate,
                isActive: isActive,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String providerName,
                required String mealType,
                required int pricePerTiffinPaise,
                required int activeWeekdaysMask,
                Value<String> reminderTime = const Value.absent(),
                required String startDate,
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TiffinPlansCompanion.insert(
                id: id,
                providerName: providerName,
                mealType: mealType,
                pricePerTiffinPaise: pricePerTiffinPaise,
                activeWeekdaysMask: activeWeekdaysMask,
                reminderTime: reminderTime,
                startDate: startDate,
                isActive: isActive,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TiffinPlansTable, TiffinPlan>(table),
                  $$TiffinPlansTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tiffinLogsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (tiffinLogsRefs) db.tiffinLogs],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tiffinLogsRefs)
                    await $_getPrefetchedData<
                      TiffinPlan,
                      $TiffinPlansTable,
                      TiffinLog
                    >(
                      currentTable: table,
                      referencedTable: $$TiffinPlansTableReferences
                          ._tiffinLogsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TiffinPlansTableReferences(
                            db,
                            table,
                            p0,
                          ).tiffinLogsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.planId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TiffinPlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TiffinPlansTable,
      TiffinPlan,
      $$TiffinPlansTableFilterComposer,
      $$TiffinPlansTableOrderingComposer,
      $$TiffinPlansTableAnnotationComposer,
      $$TiffinPlansTableCreateCompanionBuilder,
      $$TiffinPlansTableUpdateCompanionBuilder,
      (TiffinPlan, $$TiffinPlansTableReferences),
      TiffinPlan,
      PrefetchHooks Function({bool tiffinLogsRefs})
    >;
typedef $$TiffinLogsTableCreateCompanionBuilder = TiffinLogsCompanion Function({
  required String id,
  required String planId,
  required String date,
  Value<String> status,
  Value<int?> priceOverridePaise,
  Value<String?> transactionId,
  Value<int> rowid,
});
typedef $$TiffinLogsTableUpdateCompanionBuilder = TiffinLogsCompanion Function({
  Value<String> id,
  Value<String> planId,
  Value<String> date,
  Value<String> status,
  Value<int?> priceOverridePaise,
  Value<String?> transactionId,
  Value<int> rowid,
});

final class $$TiffinLogsTableReferences
    extends BaseReferences<_$AppDatabase, $TiffinLogsTable, TiffinLog> {
  $$TiffinLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TiffinPlansTable _planIdTable(_$AppDatabase db) =>
      db.tiffinPlans.createAlias('tiffin_logs__plan_id__tiffin_plans__id');

  $$TiffinPlansTableProcessedTableManager get planId {
    final $_column = $_itemColumn<String>('plan_id')!;

    final manager = $$TiffinPlansTableTableManager(
      $_db,
      $_db.tiffinPlans,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_planIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TiffinLogsTableFilterComposer
    extends Composer<_$AppDatabase, $TiffinLogsTable> {
  $$TiffinLogsTableFilterComposer({
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

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priceOverridePaise => $composableBuilder(
    column: $table.priceOverridePaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnFilters(column),
  );

  $$TiffinPlansTableFilterComposer get planId {
    final $$TiffinPlansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.tiffinPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TiffinPlansTableFilterComposer(
            $db: $db,
            $table: $db.tiffinPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TiffinLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $TiffinLogsTable> {
  $$TiffinLogsTableOrderingComposer({
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

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priceOverridePaise => $composableBuilder(
    column: $table.priceOverridePaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnOrderings(column),
  );

  $$TiffinPlansTableOrderingComposer get planId {
    final $$TiffinPlansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.tiffinPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TiffinPlansTableOrderingComposer(
            $db: $db,
            $table: $db.tiffinPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TiffinLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TiffinLogsTable> {
  $$TiffinLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get priceOverridePaise => $composableBuilder(
    column: $table.priceOverridePaise,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => column,
  );

  $$TiffinPlansTableAnnotationComposer get planId {
    final $$TiffinPlansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.tiffinPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TiffinPlansTableAnnotationComposer(
            $db: $db,
            $table: $db.tiffinPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TiffinLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TiffinLogsTable,
          TiffinLog,
          $$TiffinLogsTableFilterComposer,
          $$TiffinLogsTableOrderingComposer,
          $$TiffinLogsTableAnnotationComposer,
          $$TiffinLogsTableCreateCompanionBuilder,
          $$TiffinLogsTableUpdateCompanionBuilder,
          (TiffinLog, $$TiffinLogsTableReferences),
          TiffinLog,
          PrefetchHooks Function({bool planId})
        > {
  $$TiffinLogsTableTableManager(_$AppDatabase db, $TiffinLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TiffinLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TiffinLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TiffinLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> planId = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> priceOverridePaise = const Value.absent(),
                Value<String?> transactionId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TiffinLogsCompanion(
                id: id,
                planId: planId,
                date: date,
                status: status,
                priceOverridePaise: priceOverridePaise,
                transactionId: transactionId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String planId,
                required String date,
                Value<String> status = const Value.absent(),
                Value<int?> priceOverridePaise = const Value.absent(),
                Value<String?> transactionId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TiffinLogsCompanion.insert(
                id: id,
                planId: planId,
                date: date,
                status: status,
                priceOverridePaise: priceOverridePaise,
                transactionId: transactionId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TiffinLogsTable, TiffinLog>(table),
                  $$TiffinLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({planId = false}) {
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
                    if (planId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.planId,
                        referencedTable: $$TiffinLogsTableReferences
                            ._planIdTable(db),
                        referencedColumn: $$TiffinLogsTableReferences
                            ._planIdTable(db)
                            .id,
                      ) as T;
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

typedef $$TiffinLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TiffinLogsTable,
      TiffinLog,
      $$TiffinLogsTableFilterComposer,
      $$TiffinLogsTableOrderingComposer,
      $$TiffinLogsTableAnnotationComposer,
      $$TiffinLogsTableCreateCompanionBuilder,
      $$TiffinLogsTableUpdateCompanionBuilder,
      (TiffinLog, $$TiffinLogsTableReferences),
      TiffinLog,
      PrefetchHooks Function({bool planId})
    >;
typedef $$TodosTableCreateCompanionBuilder = TodosCompanion Function({
  required String id,
  required String title,
  Value<String> notes,
  Value<int?> dueAt,
  Value<int> priority,
  Value<bool> isDone,
  Value<int?> doneAt,
  required int createdAt,
  Value<String?> actionType,
  Value<String?> actionPayloadJson,
  Value<String> actionStatus,
  Value<String> recurrence,
  Value<String?> parentTodoId,
  Value<int> rowid,
});
typedef $$TodosTableUpdateCompanionBuilder = TodosCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> notes,
  Value<int?> dueAt,
  Value<int> priority,
  Value<bool> isDone,
  Value<int?> doneAt,
  Value<int> createdAt,
  Value<String?> actionType,
  Value<String?> actionPayloadJson,
  Value<String> actionStatus,
  Value<String> recurrence,
  Value<String?> parentTodoId,
  Value<int> rowid,
});

class $$TodosTableFilterComposer extends Composer<_$AppDatabase, $TodosTable> {
  $$TodosTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDone => $composableBuilder(
    column: $table.isDone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get doneAt => $composableBuilder(
    column: $table.doneAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actionPayloadJson => $composableBuilder(
    column: $table.actionPayloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actionStatus => $composableBuilder(
    column: $table.actionStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentTodoId => $composableBuilder(
    column: $table.parentTodoId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TodosTableOrderingComposer
    extends Composer<_$AppDatabase, $TodosTable> {
  $$TodosTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDone => $composableBuilder(
    column: $table.isDone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get doneAt => $composableBuilder(
    column: $table.doneAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actionPayloadJson => $composableBuilder(
    column: $table.actionPayloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actionStatus => $composableBuilder(
    column: $table.actionStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentTodoId => $composableBuilder(
    column: $table.parentTodoId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TodosTableAnnotationComposer
    extends Composer<_$AppDatabase, $TodosTable> {
  $$TodosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<bool> get isDone =>
      $composableBuilder(column: $table.isDone, builder: (column) => column);

  GeneratedColumn<int> get doneAt =>
      $composableBuilder(column: $table.doneAt, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get actionPayloadJson => $composableBuilder(
    column: $table.actionPayloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get actionStatus => $composableBuilder(
    column: $table.actionStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parentTodoId => $composableBuilder(
    column: $table.parentTodoId,
    builder: (column) => column,
  );
}

class $$TodosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TodosTable,
          Todo,
          $$TodosTableFilterComposer,
          $$TodosTableOrderingComposer,
          $$TodosTableAnnotationComposer,
          $$TodosTableCreateCompanionBuilder,
          $$TodosTableUpdateCompanionBuilder,
          (Todo, BaseReferences<_$AppDatabase, $TodosTable, Todo>),
          Todo,
          PrefetchHooks Function()
        > {
  $$TodosTableTableManager(_$AppDatabase db, $TodosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TodosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TodosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TodosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int?> dueAt = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<bool> isDone = const Value.absent(),
                Value<int?> doneAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String?> actionType = const Value.absent(),
                Value<String?> actionPayloadJson = const Value.absent(),
                Value<String> actionStatus = const Value.absent(),
                Value<String> recurrence = const Value.absent(),
                Value<String?> parentTodoId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TodosCompanion(
                id: id,
                title: title,
                notes: notes,
                dueAt: dueAt,
                priority: priority,
                isDone: isDone,
                doneAt: doneAt,
                createdAt: createdAt,
                actionType: actionType,
                actionPayloadJson: actionPayloadJson,
                actionStatus: actionStatus,
                recurrence: recurrence,
                parentTodoId: parentTodoId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String> notes = const Value.absent(),
                Value<int?> dueAt = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<bool> isDone = const Value.absent(),
                Value<int?> doneAt = const Value.absent(),
                required int createdAt,
                Value<String?> actionType = const Value.absent(),
                Value<String?> actionPayloadJson = const Value.absent(),
                Value<String> actionStatus = const Value.absent(),
                Value<String> recurrence = const Value.absent(),
                Value<String?> parentTodoId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TodosCompanion.insert(
                id: id,
                title: title,
                notes: notes,
                dueAt: dueAt,
                priority: priority,
                isDone: isDone,
                doneAt: doneAt,
                createdAt: createdAt,
                actionType: actionType,
                actionPayloadJson: actionPayloadJson,
                actionStatus: actionStatus,
                recurrence: recurrence,
                parentTodoId: parentTodoId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TodosTable, Todo>(table),
                  BaseReferences<_$AppDatabase, $TodosTable, Todo>(
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

typedef $$TodosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TodosTable,
      Todo,
      $$TodosTableFilterComposer,
      $$TodosTableOrderingComposer,
      $$TodosTableAnnotationComposer,
      $$TodosTableCreateCompanionBuilder,
      $$TodosTableUpdateCompanionBuilder,
      (Todo, BaseReferences<_$AppDatabase, $TodosTable, Todo>),
      Todo,
      PrefetchHooks Function()
    >;
typedef $$WaterSettingsTableCreateCompanionBuilder =
    WaterSettingsCompanion Function({
      Value<int> id,
      Value<int> dailyGoalMl,
      Value<int> glassMl,
      Value<String> dayStart,
      Value<String> dayEnd,
      Value<int> reminderIntervalMin,
      Value<bool> remindersEnabled,
    });
typedef $$WaterSettingsTableUpdateCompanionBuilder =
    WaterSettingsCompanion Function({
      Value<int> id,
      Value<int> dailyGoalMl,
      Value<int> glassMl,
      Value<String> dayStart,
      Value<String> dayEnd,
      Value<int> reminderIntervalMin,
      Value<bool> remindersEnabled,
    });

class $$WaterSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $WaterSettingsTable> {
  $$WaterSettingsTableFilterComposer({
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

  ColumnFilters<int> get dailyGoalMl => $composableBuilder(
    column: $table.dailyGoalMl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get glassMl => $composableBuilder(
    column: $table.glassMl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dayStart => $composableBuilder(
    column: $table.dayStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dayEnd => $composableBuilder(
    column: $table.dayEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderIntervalMin => $composableBuilder(
    column: $table.reminderIntervalMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get remindersEnabled => $composableBuilder(
    column: $table.remindersEnabled,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WaterSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $WaterSettingsTable> {
  $$WaterSettingsTableOrderingComposer({
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

  ColumnOrderings<int> get dailyGoalMl => $composableBuilder(
    column: $table.dailyGoalMl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get glassMl => $composableBuilder(
    column: $table.glassMl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dayStart => $composableBuilder(
    column: $table.dayStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dayEnd => $composableBuilder(
    column: $table.dayEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderIntervalMin => $composableBuilder(
    column: $table.reminderIntervalMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get remindersEnabled => $composableBuilder(
    column: $table.remindersEnabled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WaterSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WaterSettingsTable> {
  $$WaterSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get dailyGoalMl => $composableBuilder(
    column: $table.dailyGoalMl,
    builder: (column) => column,
  );

  GeneratedColumn<int> get glassMl =>
      $composableBuilder(column: $table.glassMl, builder: (column) => column);

  GeneratedColumn<String> get dayStart =>
      $composableBuilder(column: $table.dayStart, builder: (column) => column);

  GeneratedColumn<String> get dayEnd =>
      $composableBuilder(column: $table.dayEnd, builder: (column) => column);

  GeneratedColumn<int> get reminderIntervalMin => $composableBuilder(
    column: $table.reminderIntervalMin,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get remindersEnabled => $composableBuilder(
    column: $table.remindersEnabled,
    builder: (column) => column,
  );
}

class $$WaterSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WaterSettingsTable,
          WaterSetting,
          $$WaterSettingsTableFilterComposer,
          $$WaterSettingsTableOrderingComposer,
          $$WaterSettingsTableAnnotationComposer,
          $$WaterSettingsTableCreateCompanionBuilder,
          $$WaterSettingsTableUpdateCompanionBuilder,
          (
            WaterSetting,
            BaseReferences<_$AppDatabase, $WaterSettingsTable, WaterSetting>,
          ),
          WaterSetting,
          PrefetchHooks Function()
        > {
  $$WaterSettingsTableTableManager(_$AppDatabase db, $WaterSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WaterSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WaterSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WaterSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> dailyGoalMl = const Value.absent(),
                Value<int> glassMl = const Value.absent(),
                Value<String> dayStart = const Value.absent(),
                Value<String> dayEnd = const Value.absent(),
                Value<int> reminderIntervalMin = const Value.absent(),
                Value<bool> remindersEnabled = const Value.absent(),
              }) => WaterSettingsCompanion(
                id: id,
                dailyGoalMl: dailyGoalMl,
                glassMl: glassMl,
                dayStart: dayStart,
                dayEnd: dayEnd,
                reminderIntervalMin: reminderIntervalMin,
                remindersEnabled: remindersEnabled,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> dailyGoalMl = const Value.absent(),
                Value<int> glassMl = const Value.absent(),
                Value<String> dayStart = const Value.absent(),
                Value<String> dayEnd = const Value.absent(),
                Value<int> reminderIntervalMin = const Value.absent(),
                Value<bool> remindersEnabled = const Value.absent(),
              }) => WaterSettingsCompanion.insert(
                id: id,
                dailyGoalMl: dailyGoalMl,
                glassMl: glassMl,
                dayStart: dayStart,
                dayEnd: dayEnd,
                reminderIntervalMin: reminderIntervalMin,
                remindersEnabled: remindersEnabled,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WaterSettingsTable, WaterSetting>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $WaterSettingsTable,
                    WaterSetting
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WaterSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WaterSettingsTable,
      WaterSetting,
      $$WaterSettingsTableFilterComposer,
      $$WaterSettingsTableOrderingComposer,
      $$WaterSettingsTableAnnotationComposer,
      $$WaterSettingsTableCreateCompanionBuilder,
      $$WaterSettingsTableUpdateCompanionBuilder,
      (
        WaterSetting,
        BaseReferences<_$AppDatabase, $WaterSettingsTable, WaterSetting>,
      ),
      WaterSetting,
      PrefetchHooks Function()
    >;
typedef $$WaterLogsTableCreateCompanionBuilder = WaterLogsCompanion Function({
  required String id,
  required int amountMl,
  required int loggedAt,
  Value<int> rowid,
});
typedef $$WaterLogsTableUpdateCompanionBuilder = WaterLogsCompanion Function({
  Value<String> id,
  Value<int> amountMl,
  Value<int> loggedAt,
  Value<int> rowid,
});

class $$WaterLogsTableFilterComposer
    extends Composer<_$AppDatabase, $WaterLogsTable> {
  $$WaterLogsTableFilterComposer({
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

  ColumnFilters<int> get amountMl => $composableBuilder(
    column: $table.amountMl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WaterLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $WaterLogsTable> {
  $$WaterLogsTableOrderingComposer({
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

  ColumnOrderings<int> get amountMl => $composableBuilder(
    column: $table.amountMl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WaterLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WaterLogsTable> {
  $$WaterLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountMl =>
      $composableBuilder(column: $table.amountMl, builder: (column) => column);

  GeneratedColumn<int> get loggedAt =>
      $composableBuilder(column: $table.loggedAt, builder: (column) => column);
}

class $$WaterLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WaterLogsTable,
          WaterLog,
          $$WaterLogsTableFilterComposer,
          $$WaterLogsTableOrderingComposer,
          $$WaterLogsTableAnnotationComposer,
          $$WaterLogsTableCreateCompanionBuilder,
          $$WaterLogsTableUpdateCompanionBuilder,
          (WaterLog, BaseReferences<_$AppDatabase, $WaterLogsTable, WaterLog>),
          WaterLog,
          PrefetchHooks Function()
        > {
  $$WaterLogsTableTableManager(_$AppDatabase db, $WaterLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WaterLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WaterLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WaterLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> amountMl = const Value.absent(),
                Value<int> loggedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WaterLogsCompanion(
                id: id,
                amountMl: amountMl,
                loggedAt: loggedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int amountMl,
                required int loggedAt,
                Value<int> rowid = const Value.absent(),
              }) => WaterLogsCompanion.insert(
                id: id,
                amountMl: amountMl,
                loggedAt: loggedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WaterLogsTable, WaterLog>(table),
                  BaseReferences<_$AppDatabase, $WaterLogsTable, WaterLog>(
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

typedef $$WaterLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WaterLogsTable,
      WaterLog,
      $$WaterLogsTableFilterComposer,
      $$WaterLogsTableOrderingComposer,
      $$WaterLogsTableAnnotationComposer,
      $$WaterLogsTableCreateCompanionBuilder,
      $$WaterLogsTableUpdateCompanionBuilder,
      (WaterLog, BaseReferences<_$AppDatabase, $WaterLogsTable, WaterLog>),
      WaterLog,
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
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
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
          updateCompanionCallback: ({
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
                  e.readTable<$AppSettingsTable, AppSetting>(table),
                  BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>(
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
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$DebugLogsTableCreateCompanionBuilder = DebugLogsCompanion Function({
  Value<int> id,
  required String level,
  required String message,
  required int timestamp,
  Value<String> context,
});
typedef $$DebugLogsTableUpdateCompanionBuilder = DebugLogsCompanion Function({
  Value<int> id,
  Value<String> level,
  Value<String> message,
  Value<int> timestamp,
  Value<String> context,
});

class $$DebugLogsTableFilterComposer
    extends Composer<_$AppDatabase, $DebugLogsTable> {
  $$DebugLogsTableFilterComposer({
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

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get context => $composableBuilder(
    column: $table.context,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DebugLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $DebugLogsTable> {
  $$DebugLogsTableOrderingComposer({
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

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get context => $composableBuilder(
    column: $table.context,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DebugLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DebugLogsTable> {
  $$DebugLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<int> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get context =>
      $composableBuilder(column: $table.context, builder: (column) => column);
}

class $$DebugLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DebugLogsTable,
          DebugLog,
          $$DebugLogsTableFilterComposer,
          $$DebugLogsTableOrderingComposer,
          $$DebugLogsTableAnnotationComposer,
          $$DebugLogsTableCreateCompanionBuilder,
          $$DebugLogsTableUpdateCompanionBuilder,
          (DebugLog, BaseReferences<_$AppDatabase, $DebugLogsTable, DebugLog>),
          DebugLog,
          PrefetchHooks Function()
        > {
  $$DebugLogsTableTableManager(_$AppDatabase db, $DebugLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DebugLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DebugLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DebugLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<String> message = const Value.absent(),
                Value<int> timestamp = const Value.absent(),
                Value<String> context = const Value.absent(),
              }) => DebugLogsCompanion(
                id: id,
                level: level,
                message: message,
                timestamp: timestamp,
                context: context,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String level,
                required String message,
                required int timestamp,
                Value<String> context = const Value.absent(),
              }) => DebugLogsCompanion.insert(
                id: id,
                level: level,
                message: message,
                timestamp: timestamp,
                context: context,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DebugLogsTable, DebugLog>(table),
                  BaseReferences<_$AppDatabase, $DebugLogsTable, DebugLog>(
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

typedef $$DebugLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DebugLogsTable,
      DebugLog,
      $$DebugLogsTableFilterComposer,
      $$DebugLogsTableOrderingComposer,
      $$DebugLogsTableAnnotationComposer,
      $$DebugLogsTableCreateCompanionBuilder,
      $$DebugLogsTableUpdateCompanionBuilder,
      (DebugLog, BaseReferences<_$AppDatabase, $DebugLogsTable, DebugLog>),
      DebugLog,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$BudgetsTableTableManager get budgets =>
      $$BudgetsTableTableManager(_db, _db.budgets);
  $$RecurringExpensesTableTableManager get recurringExpenses =>
      $$RecurringExpensesTableTableManager(_db, _db.recurringExpenses);
  $$TiffinPlansTableTableManager get tiffinPlans =>
      $$TiffinPlansTableTableManager(_db, _db.tiffinPlans);
  $$TiffinLogsTableTableManager get tiffinLogs =>
      $$TiffinLogsTableTableManager(_db, _db.tiffinLogs);
  $$TodosTableTableManager get todos =>
      $$TodosTableTableManager(_db, _db.todos);
  $$WaterSettingsTableTableManager get waterSettings =>
      $$WaterSettingsTableTableManager(_db, _db.waterSettings);
  $$WaterLogsTableTableManager get waterLogs =>
      $$WaterLogsTableTableManager(_db, _db.waterLogs);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$DebugLogsTableTableManager get debugLogs =>
      $$DebugLogsTableTableManager(_db, _db.debugLogs);
}
