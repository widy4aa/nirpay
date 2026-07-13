// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, UserEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _publicKeyB64Meta = const VerificationMeta(
    'publicKeyB64',
  );
  @override
  late final GeneratedColumn<String> publicKeyB64 = GeneratedColumn<String>(
    'public_key_b64',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pinHashMeta = const VerificationMeta(
    'pinHash',
  );
  @override
  late final GeneratedColumn<String> pinHash = GeneratedColumn<String>(
    'pin_hash',
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
    email,
    username,
    phone,
    publicKeyB64,
    pinHash,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('public_key_b64')) {
      context.handle(
        _publicKeyB64Meta,
        publicKeyB64.isAcceptableOrUnknown(
          data['public_key_b64']!,
          _publicKeyB64Meta,
        ),
      );
    }
    if (data.containsKey('pin_hash')) {
      context.handle(
        _pinHashMeta,
        pinHash.isAcceptableOrUnknown(data['pin_hash']!, _pinHashMeta),
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
  UserEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      publicKeyB64: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}public_key_b64'],
      ),
      pinHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pin_hash'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class UserEntry extends DataClass implements Insertable<UserEntry> {
  final String id;
  final String email;
  final String username;
  final String? phone;
  final String? publicKeyB64;
  final String? pinHash;
  final DateTime createdAt;
  const UserEntry({
    required this.id,
    required this.email,
    required this.username,
    this.phone,
    this.publicKeyB64,
    this.pinHash,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['email'] = Variable<String>(email);
    map['username'] = Variable<String>(username);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || publicKeyB64 != null) {
      map['public_key_b64'] = Variable<String>(publicKeyB64);
    }
    if (!nullToAbsent || pinHash != null) {
      map['pin_hash'] = Variable<String>(pinHash);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      email: Value(email),
      username: Value(username),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      publicKeyB64: publicKeyB64 == null && nullToAbsent
          ? const Value.absent()
          : Value(publicKeyB64),
      pinHash: pinHash == null && nullToAbsent
          ? const Value.absent()
          : Value(pinHash),
      createdAt: Value(createdAt),
    );
  }

  factory UserEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserEntry(
      id: serializer.fromJson<String>(json['id']),
      email: serializer.fromJson<String>(json['email']),
      username: serializer.fromJson<String>(json['username']),
      phone: serializer.fromJson<String?>(json['phone']),
      publicKeyB64: serializer.fromJson<String?>(json['publicKeyB64']),
      pinHash: serializer.fromJson<String?>(json['pinHash']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'email': serializer.toJson<String>(email),
      'username': serializer.toJson<String>(username),
      'phone': serializer.toJson<String?>(phone),
      'publicKeyB64': serializer.toJson<String?>(publicKeyB64),
      'pinHash': serializer.toJson<String?>(pinHash),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  UserEntry copyWith({
    String? id,
    String? email,
    String? username,
    Value<String?> phone = const Value.absent(),
    Value<String?> publicKeyB64 = const Value.absent(),
    Value<String?> pinHash = const Value.absent(),
    DateTime? createdAt,
  }) => UserEntry(
    id: id ?? this.id,
    email: email ?? this.email,
    username: username ?? this.username,
    phone: phone.present ? phone.value : this.phone,
    publicKeyB64: publicKeyB64.present ? publicKeyB64.value : this.publicKeyB64,
    pinHash: pinHash.present ? pinHash.value : this.pinHash,
    createdAt: createdAt ?? this.createdAt,
  );
  UserEntry copyWithCompanion(UsersCompanion data) {
    return UserEntry(
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      username: data.username.present ? data.username.value : this.username,
      phone: data.phone.present ? data.phone.value : this.phone,
      publicKeyB64: data.publicKeyB64.present
          ? data.publicKeyB64.value
          : this.publicKeyB64,
      pinHash: data.pinHash.present ? data.pinHash.value : this.pinHash,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserEntry(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('username: $username, ')
          ..write('phone: $phone, ')
          ..write('publicKeyB64: $publicKeyB64, ')
          ..write('pinHash: $pinHash, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, email, username, phone, publicKeyB64, pinHash, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserEntry &&
          other.id == this.id &&
          other.email == this.email &&
          other.username == this.username &&
          other.phone == this.phone &&
          other.publicKeyB64 == this.publicKeyB64 &&
          other.pinHash == this.pinHash &&
          other.createdAt == this.createdAt);
}

class UsersCompanion extends UpdateCompanion<UserEntry> {
  final Value<String> id;
  final Value<String> email;
  final Value<String> username;
  final Value<String?> phone;
  final Value<String?> publicKeyB64;
  final Value<String?> pinHash;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.username = const Value.absent(),
    this.phone = const Value.absent(),
    this.publicKeyB64 = const Value.absent(),
    this.pinHash = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String email,
    required String username,
    this.phone = const Value.absent(),
    this.publicKeyB64 = const Value.absent(),
    this.pinHash = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       email = Value(email),
       username = Value(username);
  static Insertable<UserEntry> custom({
    Expression<String>? id,
    Expression<String>? email,
    Expression<String>? username,
    Expression<String>? phone,
    Expression<String>? publicKeyB64,
    Expression<String>? pinHash,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (username != null) 'username': username,
      if (phone != null) 'phone': phone,
      if (publicKeyB64 != null) 'public_key_b64': publicKeyB64,
      if (pinHash != null) 'pin_hash': pinHash,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    Value<String>? id,
    Value<String>? email,
    Value<String>? username,
    Value<String?>? phone,
    Value<String?>? publicKeyB64,
    Value<String?>? pinHash,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      publicKeyB64: publicKeyB64 ?? this.publicKeyB64,
      pinHash: pinHash ?? this.pinHash,
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
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (publicKeyB64.present) {
      map['public_key_b64'] = Variable<String>(publicKeyB64.value);
    }
    if (pinHash.present) {
      map['pin_hash'] = Variable<String>(pinHash.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('username: $username, ')
          ..write('phone: $phone, ')
          ..write('publicKeyB64: $publicKeyB64, ')
          ..write('pinHash: $pinHash, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WalletBalancesTable extends WalletBalances
    with TableInfo<$WalletBalancesTable, WalletBalanceEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WalletBalancesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountCentMeta = const VerificationMeta(
    'amountCent',
  );
  @override
  late final GeneratedColumn<int> amountCent = GeneratedColumn<int>(
    'amount_cent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _reservedCentMeta = const VerificationMeta(
    'reservedCent',
  );
  @override
  late final GeneratedColumn<int> reservedCent = GeneratedColumn<int>(
    'reserved_cent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _hopCountMeta = const VerificationMeta(
    'hopCount',
  );
  @override
  late final GeneratedColumn<int> hopCount = GeneratedColumn<int>(
    'hop_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _maxHopMeta = const VerificationMeta('maxHop');
  @override
  late final GeneratedColumn<int> maxHop = GeneratedColumn<int>(
    'max_hop',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('IDR'),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    amountCent,
    reservedCent,
    hopCount,
    maxHop,
    currency,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wallet_balances';
  @override
  VerificationContext validateIntegrity(
    Insertable<WalletBalanceEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('amount_cent')) {
      context.handle(
        _amountCentMeta,
        amountCent.isAcceptableOrUnknown(data['amount_cent']!, _amountCentMeta),
      );
    }
    if (data.containsKey('reserved_cent')) {
      context.handle(
        _reservedCentMeta,
        reservedCent.isAcceptableOrUnknown(
          data['reserved_cent']!,
          _reservedCentMeta,
        ),
      );
    }
    if (data.containsKey('hop_count')) {
      context.handle(
        _hopCountMeta,
        hopCount.isAcceptableOrUnknown(data['hop_count']!, _hopCountMeta),
      );
    }
    if (data.containsKey('max_hop')) {
      context.handle(
        _maxHopMeta,
        maxHop.isAcceptableOrUnknown(data['max_hop']!, _maxHopMeta),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WalletBalanceEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WalletBalanceEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      amountCent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_cent'],
      )!,
      reservedCent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reserved_cent'],
      )!,
      hopCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hop_count'],
      )!,
      maxHop: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_hop'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WalletBalancesTable createAlias(String alias) {
    return $WalletBalancesTable(attachedDatabase, alias);
  }
}

class WalletBalanceEntry extends DataClass
    implements Insertable<WalletBalanceEntry> {
  final String id;
  final String userId;
  final int amountCent;
  final int reservedCent;
  final int hopCount;
  final int maxHop;
  final String currency;
  final DateTime updatedAt;
  const WalletBalanceEntry({
    required this.id,
    required this.userId,
    required this.amountCent,
    required this.reservedCent,
    required this.hopCount,
    required this.maxHop,
    required this.currency,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['amount_cent'] = Variable<int>(amountCent);
    map['reserved_cent'] = Variable<int>(reservedCent);
    map['hop_count'] = Variable<int>(hopCount);
    map['max_hop'] = Variable<int>(maxHop);
    map['currency'] = Variable<String>(currency);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WalletBalancesCompanion toCompanion(bool nullToAbsent) {
    return WalletBalancesCompanion(
      id: Value(id),
      userId: Value(userId),
      amountCent: Value(amountCent),
      reservedCent: Value(reservedCent),
      hopCount: Value(hopCount),
      maxHop: Value(maxHop),
      currency: Value(currency),
      updatedAt: Value(updatedAt),
    );
  }

  factory WalletBalanceEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WalletBalanceEntry(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      amountCent: serializer.fromJson<int>(json['amountCent']),
      reservedCent: serializer.fromJson<int>(json['reservedCent']),
      hopCount: serializer.fromJson<int>(json['hopCount']),
      maxHop: serializer.fromJson<int>(json['maxHop']),
      currency: serializer.fromJson<String>(json['currency']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'amountCent': serializer.toJson<int>(amountCent),
      'reservedCent': serializer.toJson<int>(reservedCent),
      'hopCount': serializer.toJson<int>(hopCount),
      'maxHop': serializer.toJson<int>(maxHop),
      'currency': serializer.toJson<String>(currency),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WalletBalanceEntry copyWith({
    String? id,
    String? userId,
    int? amountCent,
    int? reservedCent,
    int? hopCount,
    int? maxHop,
    String? currency,
    DateTime? updatedAt,
  }) => WalletBalanceEntry(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    amountCent: amountCent ?? this.amountCent,
    reservedCent: reservedCent ?? this.reservedCent,
    hopCount: hopCount ?? this.hopCount,
    maxHop: maxHop ?? this.maxHop,
    currency: currency ?? this.currency,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  WalletBalanceEntry copyWithCompanion(WalletBalancesCompanion data) {
    return WalletBalanceEntry(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      amountCent: data.amountCent.present
          ? data.amountCent.value
          : this.amountCent,
      reservedCent: data.reservedCent.present
          ? data.reservedCent.value
          : this.reservedCent,
      hopCount: data.hopCount.present ? data.hopCount.value : this.hopCount,
      maxHop: data.maxHop.present ? data.maxHop.value : this.maxHop,
      currency: data.currency.present ? data.currency.value : this.currency,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WalletBalanceEntry(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('amountCent: $amountCent, ')
          ..write('reservedCent: $reservedCent, ')
          ..write('hopCount: $hopCount, ')
          ..write('maxHop: $maxHop, ')
          ..write('currency: $currency, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    amountCent,
    reservedCent,
    hopCount,
    maxHop,
    currency,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WalletBalanceEntry &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.amountCent == this.amountCent &&
          other.reservedCent == this.reservedCent &&
          other.hopCount == this.hopCount &&
          other.maxHop == this.maxHop &&
          other.currency == this.currency &&
          other.updatedAt == this.updatedAt);
}

class WalletBalancesCompanion extends UpdateCompanion<WalletBalanceEntry> {
  final Value<String> id;
  final Value<String> userId;
  final Value<int> amountCent;
  final Value<int> reservedCent;
  final Value<int> hopCount;
  final Value<int> maxHop;
  final Value<String> currency;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const WalletBalancesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.amountCent = const Value.absent(),
    this.reservedCent = const Value.absent(),
    this.hopCount = const Value.absent(),
    this.maxHop = const Value.absent(),
    this.currency = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WalletBalancesCompanion.insert({
    required String id,
    required String userId,
    this.amountCent = const Value.absent(),
    this.reservedCent = const Value.absent(),
    this.hopCount = const Value.absent(),
    this.maxHop = const Value.absent(),
    this.currency = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId);
  static Insertable<WalletBalanceEntry> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<int>? amountCent,
    Expression<int>? reservedCent,
    Expression<int>? hopCount,
    Expression<int>? maxHop,
    Expression<String>? currency,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (amountCent != null) 'amount_cent': amountCent,
      if (reservedCent != null) 'reserved_cent': reservedCent,
      if (hopCount != null) 'hop_count': hopCount,
      if (maxHop != null) 'max_hop': maxHop,
      if (currency != null) 'currency': currency,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WalletBalancesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<int>? amountCent,
    Value<int>? reservedCent,
    Value<int>? hopCount,
    Value<int>? maxHop,
    Value<String>? currency,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return WalletBalancesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amountCent: amountCent ?? this.amountCent,
      reservedCent: reservedCent ?? this.reservedCent,
      hopCount: hopCount ?? this.hopCount,
      maxHop: maxHop ?? this.maxHop,
      currency: currency ?? this.currency,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (amountCent.present) {
      map['amount_cent'] = Variable<int>(amountCent.value);
    }
    if (reservedCent.present) {
      map['reserved_cent'] = Variable<int>(reservedCent.value);
    }
    if (hopCount.present) {
      map['hop_count'] = Variable<int>(hopCount.value);
    }
    if (maxHop.present) {
      map['max_hop'] = Variable<int>(maxHop.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
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
    return (StringBuffer('WalletBalancesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('amountCent: $amountCent, ')
          ..write('reservedCent: $reservedCent, ')
          ..write('hopCount: $hopCount, ')
          ..write('maxHop: $maxHop, ')
          ..write('currency: $currency, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, TransactionEntry> {
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
  static const VerificationMeta _txIdMeta = const VerificationMeta('txId');
  @override
  late final GeneratedColumn<String> txId = GeneratedColumn<String>(
    'tx_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 7,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _txTypeMeta = const VerificationMeta('txType');
  @override
  late final GeneratedColumn<String> txType = GeneratedColumn<String>(
    'tx_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountCentMeta = const VerificationMeta(
    'amountCent',
  );
  @override
  late final GeneratedColumn<int> amountCent = GeneratedColumn<int>(
    'amount_cent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hopCountMeta = const VerificationMeta(
    'hopCount',
  );
  @override
  late final GeneratedColumn<int> hopCount = GeneratedColumn<int>(
    'hop_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PENDING'),
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
    txId,
    direction,
    txType,
    amountCent,
    hopCount,
    syncStatus,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tx_id')) {
      context.handle(
        _txIdMeta,
        txId.isAcceptableOrUnknown(data['tx_id']!, _txIdMeta),
      );
    } else if (isInserting) {
      context.missing(_txIdMeta);
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('tx_type')) {
      context.handle(
        _txTypeMeta,
        txType.isAcceptableOrUnknown(data['tx_type']!, _txTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_txTypeMeta);
    }
    if (data.containsKey('amount_cent')) {
      context.handle(
        _amountCentMeta,
        amountCent.isAcceptableOrUnknown(data['amount_cent']!, _amountCentMeta),
      );
    } else if (isInserting) {
      context.missing(_amountCentMeta);
    }
    if (data.containsKey('hop_count')) {
      context.handle(
        _hopCountMeta,
        hopCount.isAcceptableOrUnknown(data['hop_count']!, _hopCountMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
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
  TransactionEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      txId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tx_id'],
      )!,
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction'],
      )!,
      txType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tx_type'],
      )!,
      amountCent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_cent'],
      )!,
      hopCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hop_count'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class TransactionEntry extends DataClass
    implements Insertable<TransactionEntry> {
  final String id;
  final String txId;
  final String direction;
  final String txType;
  final int amountCent;
  final int hopCount;
  final String syncStatus;
  final DateTime createdAt;
  const TransactionEntry({
    required this.id,
    required this.txId,
    required this.direction,
    required this.txType,
    required this.amountCent,
    required this.hopCount,
    required this.syncStatus,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tx_id'] = Variable<String>(txId);
    map['direction'] = Variable<String>(direction);
    map['tx_type'] = Variable<String>(txType);
    map['amount_cent'] = Variable<int>(amountCent);
    map['hop_count'] = Variable<int>(hopCount);
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      txId: Value(txId),
      direction: Value(direction),
      txType: Value(txType),
      amountCent: Value(amountCent),
      hopCount: Value(hopCount),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
    );
  }

  factory TransactionEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionEntry(
      id: serializer.fromJson<String>(json['id']),
      txId: serializer.fromJson<String>(json['txId']),
      direction: serializer.fromJson<String>(json['direction']),
      txType: serializer.fromJson<String>(json['txType']),
      amountCent: serializer.fromJson<int>(json['amountCent']),
      hopCount: serializer.fromJson<int>(json['hopCount']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'txId': serializer.toJson<String>(txId),
      'direction': serializer.toJson<String>(direction),
      'txType': serializer.toJson<String>(txType),
      'amountCent': serializer.toJson<int>(amountCent),
      'hopCount': serializer.toJson<int>(hopCount),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TransactionEntry copyWith({
    String? id,
    String? txId,
    String? direction,
    String? txType,
    int? amountCent,
    int? hopCount,
    String? syncStatus,
    DateTime? createdAt,
  }) => TransactionEntry(
    id: id ?? this.id,
    txId: txId ?? this.txId,
    direction: direction ?? this.direction,
    txType: txType ?? this.txType,
    amountCent: amountCent ?? this.amountCent,
    hopCount: hopCount ?? this.hopCount,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
  );
  TransactionEntry copyWithCompanion(TransactionsCompanion data) {
    return TransactionEntry(
      id: data.id.present ? data.id.value : this.id,
      txId: data.txId.present ? data.txId.value : this.txId,
      direction: data.direction.present ? data.direction.value : this.direction,
      txType: data.txType.present ? data.txType.value : this.txType,
      amountCent: data.amountCent.present
          ? data.amountCent.value
          : this.amountCent,
      hopCount: data.hopCount.present ? data.hopCount.value : this.hopCount,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionEntry(')
          ..write('id: $id, ')
          ..write('txId: $txId, ')
          ..write('direction: $direction, ')
          ..write('txType: $txType, ')
          ..write('amountCent: $amountCent, ')
          ..write('hopCount: $hopCount, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    txId,
    direction,
    txType,
    amountCent,
    hopCount,
    syncStatus,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionEntry &&
          other.id == this.id &&
          other.txId == this.txId &&
          other.direction == this.direction &&
          other.txType == this.txType &&
          other.amountCent == this.amountCent &&
          other.hopCount == this.hopCount &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt);
}

class TransactionsCompanion extends UpdateCompanion<TransactionEntry> {
  final Value<String> id;
  final Value<String> txId;
  final Value<String> direction;
  final Value<String> txType;
  final Value<int> amountCent;
  final Value<int> hopCount;
  final Value<String> syncStatus;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.txId = const Value.absent(),
    this.direction = const Value.absent(),
    this.txType = const Value.absent(),
    this.amountCent = const Value.absent(),
    this.hopCount = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String id,
    required String txId,
    required String direction,
    required String txType,
    required int amountCent,
    this.hopCount = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       txId = Value(txId),
       direction = Value(direction),
       txType = Value(txType),
       amountCent = Value(amountCent);
  static Insertable<TransactionEntry> custom({
    Expression<String>? id,
    Expression<String>? txId,
    Expression<String>? direction,
    Expression<String>? txType,
    Expression<int>? amountCent,
    Expression<int>? hopCount,
    Expression<String>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (txId != null) 'tx_id': txId,
      if (direction != null) 'direction': direction,
      if (txType != null) 'tx_type': txType,
      if (amountCent != null) 'amount_cent': amountCent,
      if (hopCount != null) 'hop_count': hopCount,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith({
    Value<String>? id,
    Value<String>? txId,
    Value<String>? direction,
    Value<String>? txType,
    Value<int>? amountCent,
    Value<int>? hopCount,
    Value<String>? syncStatus,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      txId: txId ?? this.txId,
      direction: direction ?? this.direction,
      txType: txType ?? this.txType,
      amountCent: amountCent ?? this.amountCent,
      hopCount: hopCount ?? this.hopCount,
      syncStatus: syncStatus ?? this.syncStatus,
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
    if (txId.present) {
      map['tx_id'] = Variable<String>(txId.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (txType.present) {
      map['tx_type'] = Variable<String>(txType.value);
    }
    if (amountCent.present) {
      map['amount_cent'] = Variable<int>(amountCent.value);
    }
    if (hopCount.present) {
      map['hop_count'] = Variable<int>(hopCount.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
          ..write('txId: $txId, ')
          ..write('direction: $direction, ')
          ..write('txType: $txType, ')
          ..write('amountCent: $amountCent, ')
          ..write('hopCount: $hopCount, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $WalletBalancesTable walletBalances = $WalletBalancesTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    walletBalances,
    transactions,
  ];
}

typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      required String id,
      required String email,
      required String username,
      Value<String?> phone,
      Value<String?> publicKeyB64,
      Value<String?> pinHash,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<String> id,
      Value<String> email,
      Value<String> username,
      Value<String?> phone,
      Value<String?> publicKeyB64,
      Value<String?> pinHash,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
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

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publicKeyB64 => $composableBuilder(
    column: $table.publicKeyB64,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinHash => $composableBuilder(
    column: $table.pinHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
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

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publicKeyB64 => $composableBuilder(
    column: $table.publicKeyB64,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinHash => $composableBuilder(
    column: $table.pinHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get publicKeyB64 => $composableBuilder(
    column: $table.publicKeyB64,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pinHash =>
      $composableBuilder(column: $table.pinHash, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          UserEntry,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (UserEntry, BaseReferences<_$AppDatabase, $UsersTable, UserEntry>),
          UserEntry,
          PrefetchHooks Function()
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> publicKeyB64 = const Value.absent(),
                Value<String?> pinHash = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                email: email,
                username: username,
                phone: phone,
                publicKeyB64: publicKeyB64,
                pinHash: pinHash,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String email,
                required String username,
                Value<String?> phone = const Value.absent(),
                Value<String?> publicKeyB64 = const Value.absent(),
                Value<String?> pinHash = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                email: email,
                username: username,
                phone: phone,
                publicKeyB64: publicKeyB64,
                pinHash: pinHash,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      UserEntry,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (UserEntry, BaseReferences<_$AppDatabase, $UsersTable, UserEntry>),
      UserEntry,
      PrefetchHooks Function()
    >;
typedef $$WalletBalancesTableCreateCompanionBuilder =
    WalletBalancesCompanion Function({
      required String id,
      required String userId,
      Value<int> amountCent,
      Value<int> reservedCent,
      Value<int> hopCount,
      Value<int> maxHop,
      Value<String> currency,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$WalletBalancesTableUpdateCompanionBuilder =
    WalletBalancesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<int> amountCent,
      Value<int> reservedCent,
      Value<int> hopCount,
      Value<int> maxHop,
      Value<String> currency,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$WalletBalancesTableFilterComposer
    extends Composer<_$AppDatabase, $WalletBalancesTable> {
  $$WalletBalancesTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountCent => $composableBuilder(
    column: $table.amountCent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reservedCent => $composableBuilder(
    column: $table.reservedCent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hopCount => $composableBuilder(
    column: $table.hopCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxHop => $composableBuilder(
    column: $table.maxHop,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WalletBalancesTableOrderingComposer
    extends Composer<_$AppDatabase, $WalletBalancesTable> {
  $$WalletBalancesTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountCent => $composableBuilder(
    column: $table.amountCent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reservedCent => $composableBuilder(
    column: $table.reservedCent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hopCount => $composableBuilder(
    column: $table.hopCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxHop => $composableBuilder(
    column: $table.maxHop,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WalletBalancesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WalletBalancesTable> {
  $$WalletBalancesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get amountCent => $composableBuilder(
    column: $table.amountCent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reservedCent => $composableBuilder(
    column: $table.reservedCent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hopCount =>
      $composableBuilder(column: $table.hopCount, builder: (column) => column);

  GeneratedColumn<int> get maxHop =>
      $composableBuilder(column: $table.maxHop, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$WalletBalancesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WalletBalancesTable,
          WalletBalanceEntry,
          $$WalletBalancesTableFilterComposer,
          $$WalletBalancesTableOrderingComposer,
          $$WalletBalancesTableAnnotationComposer,
          $$WalletBalancesTableCreateCompanionBuilder,
          $$WalletBalancesTableUpdateCompanionBuilder,
          (
            WalletBalanceEntry,
            BaseReferences<
              _$AppDatabase,
              $WalletBalancesTable,
              WalletBalanceEntry
            >,
          ),
          WalletBalanceEntry,
          PrefetchHooks Function()
        > {
  $$WalletBalancesTableTableManager(
    _$AppDatabase db,
    $WalletBalancesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WalletBalancesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WalletBalancesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WalletBalancesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<int> amountCent = const Value.absent(),
                Value<int> reservedCent = const Value.absent(),
                Value<int> hopCount = const Value.absent(),
                Value<int> maxHop = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WalletBalancesCompanion(
                id: id,
                userId: userId,
                amountCent: amountCent,
                reservedCent: reservedCent,
                hopCount: hopCount,
                maxHop: maxHop,
                currency: currency,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                Value<int> amountCent = const Value.absent(),
                Value<int> reservedCent = const Value.absent(),
                Value<int> hopCount = const Value.absent(),
                Value<int> maxHop = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WalletBalancesCompanion.insert(
                id: id,
                userId: userId,
                amountCent: amountCent,
                reservedCent: reservedCent,
                hopCount: hopCount,
                maxHop: maxHop,
                currency: currency,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WalletBalancesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WalletBalancesTable,
      WalletBalanceEntry,
      $$WalletBalancesTableFilterComposer,
      $$WalletBalancesTableOrderingComposer,
      $$WalletBalancesTableAnnotationComposer,
      $$WalletBalancesTableCreateCompanionBuilder,
      $$WalletBalancesTableUpdateCompanionBuilder,
      (
        WalletBalanceEntry,
        BaseReferences<_$AppDatabase, $WalletBalancesTable, WalletBalanceEntry>,
      ),
      WalletBalanceEntry,
      PrefetchHooks Function()
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      required String id,
      required String txId,
      required String direction,
      required String txType,
      required int amountCent,
      Value<int> hopCount,
      Value<String> syncStatus,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<String> id,
      Value<String> txId,
      Value<String> direction,
      Value<String> txType,
      Value<int> amountCent,
      Value<int> hopCount,
      Value<String> syncStatus,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

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

  ColumnFilters<String> get txId => $composableBuilder(
    column: $table.txId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get txType => $composableBuilder(
    column: $table.txType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountCent => $composableBuilder(
    column: $table.amountCent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hopCount => $composableBuilder(
    column: $table.hopCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
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

  ColumnOrderings<String> get txId => $composableBuilder(
    column: $table.txId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get txType => $composableBuilder(
    column: $table.txType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountCent => $composableBuilder(
    column: $table.amountCent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hopCount => $composableBuilder(
    column: $table.hopCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
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

  GeneratedColumn<String> get txId =>
      $composableBuilder(column: $table.txId, builder: (column) => column);

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<String> get txType =>
      $composableBuilder(column: $table.txType, builder: (column) => column);

  GeneratedColumn<int> get amountCent => $composableBuilder(
    column: $table.amountCent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hopCount =>
      $composableBuilder(column: $table.hopCount, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          TransactionEntry,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (
            TransactionEntry,
            BaseReferences<_$AppDatabase, $TransactionsTable, TransactionEntry>,
          ),
          TransactionEntry,
          PrefetchHooks Function()
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
                Value<String> txId = const Value.absent(),
                Value<String> direction = const Value.absent(),
                Value<String> txType = const Value.absent(),
                Value<int> amountCent = const Value.absent(),
                Value<int> hopCount = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                txId: txId,
                direction: direction,
                txType: txType,
                amountCent: amountCent,
                hopCount: hopCount,
                syncStatus: syncStatus,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String txId,
                required String direction,
                required String txType,
                required int amountCent,
                Value<int> hopCount = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                txId: txId,
                direction: direction,
                txType: txType,
                amountCent: amountCent,
                hopCount: hopCount,
                syncStatus: syncStatus,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      TransactionEntry,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (
        TransactionEntry,
        BaseReferences<_$AppDatabase, $TransactionsTable, TransactionEntry>,
      ),
      TransactionEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$WalletBalancesTableTableManager get walletBalances =>
      $$WalletBalancesTableTableManager(_db, _db.walletBalances);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
}
