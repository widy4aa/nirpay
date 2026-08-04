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
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('USER'),
  );
  static const VerificationMeta _kycStatusMeta = const VerificationMeta(
    'kycStatus',
  );
  @override
  late final GeneratedColumn<String> kycStatus = GeneratedColumn<String>(
    'kyc_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nikMeta = const VerificationMeta('nik');
  @override
  late final GeneratedColumn<String> nik = GeneratedColumn<String>(
    'nik',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _provinceMeta = const VerificationMeta(
    'province',
  );
  @override
  late final GeneratedColumn<String> province = GeneratedColumn<String>(
    'province',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
    'city',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _districtMeta = const VerificationMeta(
    'district',
  );
  @override
  late final GeneratedColumn<String> district = GeneratedColumn<String>(
    'district',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _villageMeta = const VerificationMeta(
    'village',
  );
  @override
  late final GeneratedColumn<String> village = GeneratedColumn<String>(
    'village',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _postalCodeMeta = const VerificationMeta(
    'postalCode',
  );
  @override
  late final GeneratedColumn<String> postalCode = GeneratedColumn<String>(
    'postal_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rtMeta = const VerificationMeta('rt');
  @override
  late final GeneratedColumn<String> rt = GeneratedColumn<String>(
    'rt',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rwMeta = const VerificationMeta('rw');
  @override
  late final GeneratedColumn<String> rw = GeneratedColumn<String>(
    'rw',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ktpPhotoUrlMeta = const VerificationMeta(
    'ktpPhotoUrl',
  );
  @override
  late final GeneratedColumn<String> ktpPhotoUrl = GeneratedColumn<String>(
    'ktp_photo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _profilePhotoUrlMeta = const VerificationMeta(
    'profilePhotoUrl',
  );
  @override
  late final GeneratedColumn<String> profilePhotoUrl = GeneratedColumn<String>(
    'profile_photo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kycFaceUrlMeta = const VerificationMeta(
    'kycFaceUrl',
  );
  @override
  late final GeneratedColumn<String> kycFaceUrl = GeneratedColumn<String>(
    'kyc_face_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
    'gender',
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
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    fullName,
    phone,
    role,
    kycStatus,
    nik,
    province,
    city,
    district,
    village,
    postalCode,
    rt,
    rw,
    ktpPhotoUrl,
    profilePhotoUrl,
    kycFaceUrl,
    gender,
    publicKeyB64,
    isDirty,
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
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('kyc_status')) {
      context.handle(
        _kycStatusMeta,
        kycStatus.isAcceptableOrUnknown(data['kyc_status']!, _kycStatusMeta),
      );
    }
    if (data.containsKey('nik')) {
      context.handle(
        _nikMeta,
        nik.isAcceptableOrUnknown(data['nik']!, _nikMeta),
      );
    }
    if (data.containsKey('province')) {
      context.handle(
        _provinceMeta,
        province.isAcceptableOrUnknown(data['province']!, _provinceMeta),
      );
    }
    if (data.containsKey('city')) {
      context.handle(
        _cityMeta,
        city.isAcceptableOrUnknown(data['city']!, _cityMeta),
      );
    }
    if (data.containsKey('district')) {
      context.handle(
        _districtMeta,
        district.isAcceptableOrUnknown(data['district']!, _districtMeta),
      );
    }
    if (data.containsKey('village')) {
      context.handle(
        _villageMeta,
        village.isAcceptableOrUnknown(data['village']!, _villageMeta),
      );
    }
    if (data.containsKey('postal_code')) {
      context.handle(
        _postalCodeMeta,
        postalCode.isAcceptableOrUnknown(data['postal_code']!, _postalCodeMeta),
      );
    }
    if (data.containsKey('rt')) {
      context.handle(_rtMeta, rt.isAcceptableOrUnknown(data['rt']!, _rtMeta));
    }
    if (data.containsKey('rw')) {
      context.handle(_rwMeta, rw.isAcceptableOrUnknown(data['rw']!, _rwMeta));
    }
    if (data.containsKey('ktp_photo_url')) {
      context.handle(
        _ktpPhotoUrlMeta,
        ktpPhotoUrl.isAcceptableOrUnknown(
          data['ktp_photo_url']!,
          _ktpPhotoUrlMeta,
        ),
      );
    }
    if (data.containsKey('profile_photo_url')) {
      context.handle(
        _profilePhotoUrlMeta,
        profilePhotoUrl.isAcceptableOrUnknown(
          data['profile_photo_url']!,
          _profilePhotoUrlMeta,
        ),
      );
    }
    if (data.containsKey('kyc_face_url')) {
      context.handle(
        _kycFaceUrlMeta,
        kycFaceUrl.isAcceptableOrUnknown(
          data['kyc_face_url']!,
          _kycFaceUrlMeta,
        ),
      );
    }
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
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
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
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
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      kycStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kyc_status'],
      ),
      nik: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nik'],
      ),
      province: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}province'],
      ),
      city: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city'],
      ),
      district: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}district'],
      ),
      village: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}village'],
      ),
      postalCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}postal_code'],
      ),
      rt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rt'],
      ),
      rw: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rw'],
      ),
      ktpPhotoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ktp_photo_url'],
      ),
      profilePhotoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_photo_url'],
      ),
      kycFaceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kyc_face_url'],
      ),
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender'],
      ),
      publicKeyB64: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}public_key_b64'],
      ),
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
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
  final String fullName;
  final String? phone;
  final String role;
  final String? kycStatus;
  final String? nik;
  final String? province;
  final String? city;
  final String? district;
  final String? village;
  final String? postalCode;
  final String? rt;
  final String? rw;
  final String? ktpPhotoUrl;
  final String? profilePhotoUrl;
  final String? kycFaceUrl;
  final String? gender;
  final String? publicKeyB64;
  final bool isDirty;
  final DateTime createdAt;
  const UserEntry({
    required this.id,
    required this.email,
    required this.username,
    required this.fullName,
    this.phone,
    required this.role,
    this.kycStatus,
    this.nik,
    this.province,
    this.city,
    this.district,
    this.village,
    this.postalCode,
    this.rt,
    this.rw,
    this.ktpPhotoUrl,
    this.profilePhotoUrl,
    this.kycFaceUrl,
    this.gender,
    this.publicKeyB64,
    required this.isDirty,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['email'] = Variable<String>(email);
    map['username'] = Variable<String>(username);
    map['full_name'] = Variable<String>(fullName);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || kycStatus != null) {
      map['kyc_status'] = Variable<String>(kycStatus);
    }
    if (!nullToAbsent || nik != null) {
      map['nik'] = Variable<String>(nik);
    }
    if (!nullToAbsent || province != null) {
      map['province'] = Variable<String>(province);
    }
    if (!nullToAbsent || city != null) {
      map['city'] = Variable<String>(city);
    }
    if (!nullToAbsent || district != null) {
      map['district'] = Variable<String>(district);
    }
    if (!nullToAbsent || village != null) {
      map['village'] = Variable<String>(village);
    }
    if (!nullToAbsent || postalCode != null) {
      map['postal_code'] = Variable<String>(postalCode);
    }
    if (!nullToAbsent || rt != null) {
      map['rt'] = Variable<String>(rt);
    }
    if (!nullToAbsent || rw != null) {
      map['rw'] = Variable<String>(rw);
    }
    if (!nullToAbsent || ktpPhotoUrl != null) {
      map['ktp_photo_url'] = Variable<String>(ktpPhotoUrl);
    }
    if (!nullToAbsent || profilePhotoUrl != null) {
      map['profile_photo_url'] = Variable<String>(profilePhotoUrl);
    }
    if (!nullToAbsent || kycFaceUrl != null) {
      map['kyc_face_url'] = Variable<String>(kycFaceUrl);
    }
    if (!nullToAbsent || gender != null) {
      map['gender'] = Variable<String>(gender);
    }
    if (!nullToAbsent || publicKeyB64 != null) {
      map['public_key_b64'] = Variable<String>(publicKeyB64);
    }
    map['is_dirty'] = Variable<bool>(isDirty);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      email: Value(email),
      username: Value(username),
      fullName: Value(fullName),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      role: Value(role),
      kycStatus: kycStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(kycStatus),
      nik: nik == null && nullToAbsent ? const Value.absent() : Value(nik),
      province: province == null && nullToAbsent
          ? const Value.absent()
          : Value(province),
      city: city == null && nullToAbsent ? const Value.absent() : Value(city),
      district: district == null && nullToAbsent
          ? const Value.absent()
          : Value(district),
      village: village == null && nullToAbsent
          ? const Value.absent()
          : Value(village),
      postalCode: postalCode == null && nullToAbsent
          ? const Value.absent()
          : Value(postalCode),
      rt: rt == null && nullToAbsent ? const Value.absent() : Value(rt),
      rw: rw == null && nullToAbsent ? const Value.absent() : Value(rw),
      ktpPhotoUrl: ktpPhotoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(ktpPhotoUrl),
      profilePhotoUrl: profilePhotoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(profilePhotoUrl),
      kycFaceUrl: kycFaceUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(kycFaceUrl),
      gender: gender == null && nullToAbsent
          ? const Value.absent()
          : Value(gender),
      publicKeyB64: publicKeyB64 == null && nullToAbsent
          ? const Value.absent()
          : Value(publicKeyB64),
      isDirty: Value(isDirty),
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
      fullName: serializer.fromJson<String>(json['fullName']),
      phone: serializer.fromJson<String?>(json['phone']),
      role: serializer.fromJson<String>(json['role']),
      kycStatus: serializer.fromJson<String?>(json['kycStatus']),
      nik: serializer.fromJson<String?>(json['nik']),
      province: serializer.fromJson<String?>(json['province']),
      city: serializer.fromJson<String?>(json['city']),
      district: serializer.fromJson<String?>(json['district']),
      village: serializer.fromJson<String?>(json['village']),
      postalCode: serializer.fromJson<String?>(json['postalCode']),
      rt: serializer.fromJson<String?>(json['rt']),
      rw: serializer.fromJson<String?>(json['rw']),
      ktpPhotoUrl: serializer.fromJson<String?>(json['ktpPhotoUrl']),
      profilePhotoUrl: serializer.fromJson<String?>(json['profilePhotoUrl']),
      kycFaceUrl: serializer.fromJson<String?>(json['kycFaceUrl']),
      gender: serializer.fromJson<String?>(json['gender']),
      publicKeyB64: serializer.fromJson<String?>(json['publicKeyB64']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
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
      'fullName': serializer.toJson<String>(fullName),
      'phone': serializer.toJson<String?>(phone),
      'role': serializer.toJson<String>(role),
      'kycStatus': serializer.toJson<String?>(kycStatus),
      'nik': serializer.toJson<String?>(nik),
      'province': serializer.toJson<String?>(province),
      'city': serializer.toJson<String?>(city),
      'district': serializer.toJson<String?>(district),
      'village': serializer.toJson<String?>(village),
      'postalCode': serializer.toJson<String?>(postalCode),
      'rt': serializer.toJson<String?>(rt),
      'rw': serializer.toJson<String?>(rw),
      'ktpPhotoUrl': serializer.toJson<String?>(ktpPhotoUrl),
      'profilePhotoUrl': serializer.toJson<String?>(profilePhotoUrl),
      'kycFaceUrl': serializer.toJson<String?>(kycFaceUrl),
      'gender': serializer.toJson<String?>(gender),
      'publicKeyB64': serializer.toJson<String?>(publicKeyB64),
      'isDirty': serializer.toJson<bool>(isDirty),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  UserEntry copyWith({
    String? id,
    String? email,
    String? username,
    String? fullName,
    Value<String?> phone = const Value.absent(),
    String? role,
    Value<String?> kycStatus = const Value.absent(),
    Value<String?> nik = const Value.absent(),
    Value<String?> province = const Value.absent(),
    Value<String?> city = const Value.absent(),
    Value<String?> district = const Value.absent(),
    Value<String?> village = const Value.absent(),
    Value<String?> postalCode = const Value.absent(),
    Value<String?> rt = const Value.absent(),
    Value<String?> rw = const Value.absent(),
    Value<String?> ktpPhotoUrl = const Value.absent(),
    Value<String?> profilePhotoUrl = const Value.absent(),
    Value<String?> kycFaceUrl = const Value.absent(),
    Value<String?> gender = const Value.absent(),
    Value<String?> publicKeyB64 = const Value.absent(),
    bool? isDirty,
    DateTime? createdAt,
  }) => UserEntry(
    id: id ?? this.id,
    email: email ?? this.email,
    username: username ?? this.username,
    fullName: fullName ?? this.fullName,
    phone: phone.present ? phone.value : this.phone,
    role: role ?? this.role,
    kycStatus: kycStatus.present ? kycStatus.value : this.kycStatus,
    nik: nik.present ? nik.value : this.nik,
    province: province.present ? province.value : this.province,
    city: city.present ? city.value : this.city,
    district: district.present ? district.value : this.district,
    village: village.present ? village.value : this.village,
    postalCode: postalCode.present ? postalCode.value : this.postalCode,
    rt: rt.present ? rt.value : this.rt,
    rw: rw.present ? rw.value : this.rw,
    ktpPhotoUrl: ktpPhotoUrl.present ? ktpPhotoUrl.value : this.ktpPhotoUrl,
    profilePhotoUrl: profilePhotoUrl.present
        ? profilePhotoUrl.value
        : this.profilePhotoUrl,
    kycFaceUrl: kycFaceUrl.present ? kycFaceUrl.value : this.kycFaceUrl,
    gender: gender.present ? gender.value : this.gender,
    publicKeyB64: publicKeyB64.present ? publicKeyB64.value : this.publicKeyB64,
    isDirty: isDirty ?? this.isDirty,
    createdAt: createdAt ?? this.createdAt,
  );
  UserEntry copyWithCompanion(UsersCompanion data) {
    return UserEntry(
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      username: data.username.present ? data.username.value : this.username,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      phone: data.phone.present ? data.phone.value : this.phone,
      role: data.role.present ? data.role.value : this.role,
      kycStatus: data.kycStatus.present ? data.kycStatus.value : this.kycStatus,
      nik: data.nik.present ? data.nik.value : this.nik,
      province: data.province.present ? data.province.value : this.province,
      city: data.city.present ? data.city.value : this.city,
      district: data.district.present ? data.district.value : this.district,
      village: data.village.present ? data.village.value : this.village,
      postalCode: data.postalCode.present
          ? data.postalCode.value
          : this.postalCode,
      rt: data.rt.present ? data.rt.value : this.rt,
      rw: data.rw.present ? data.rw.value : this.rw,
      ktpPhotoUrl: data.ktpPhotoUrl.present
          ? data.ktpPhotoUrl.value
          : this.ktpPhotoUrl,
      profilePhotoUrl: data.profilePhotoUrl.present
          ? data.profilePhotoUrl.value
          : this.profilePhotoUrl,
      kycFaceUrl: data.kycFaceUrl.present
          ? data.kycFaceUrl.value
          : this.kycFaceUrl,
      gender: data.gender.present ? data.gender.value : this.gender,
      publicKeyB64: data.publicKeyB64.present
          ? data.publicKeyB64.value
          : this.publicKeyB64,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserEntry(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('username: $username, ')
          ..write('fullName: $fullName, ')
          ..write('phone: $phone, ')
          ..write('role: $role, ')
          ..write('kycStatus: $kycStatus, ')
          ..write('nik: $nik, ')
          ..write('province: $province, ')
          ..write('city: $city, ')
          ..write('district: $district, ')
          ..write('village: $village, ')
          ..write('postalCode: $postalCode, ')
          ..write('rt: $rt, ')
          ..write('rw: $rw, ')
          ..write('ktpPhotoUrl: $ktpPhotoUrl, ')
          ..write('profilePhotoUrl: $profilePhotoUrl, ')
          ..write('kycFaceUrl: $kycFaceUrl, ')
          ..write('gender: $gender, ')
          ..write('publicKeyB64: $publicKeyB64, ')
          ..write('isDirty: $isDirty, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    email,
    username,
    fullName,
    phone,
    role,
    kycStatus,
    nik,
    province,
    city,
    district,
    village,
    postalCode,
    rt,
    rw,
    ktpPhotoUrl,
    profilePhotoUrl,
    kycFaceUrl,
    gender,
    publicKeyB64,
    isDirty,
    createdAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserEntry &&
          other.id == this.id &&
          other.email == this.email &&
          other.username == this.username &&
          other.fullName == this.fullName &&
          other.phone == this.phone &&
          other.role == this.role &&
          other.kycStatus == this.kycStatus &&
          other.nik == this.nik &&
          other.province == this.province &&
          other.city == this.city &&
          other.district == this.district &&
          other.village == this.village &&
          other.postalCode == this.postalCode &&
          other.rt == this.rt &&
          other.rw == this.rw &&
          other.ktpPhotoUrl == this.ktpPhotoUrl &&
          other.profilePhotoUrl == this.profilePhotoUrl &&
          other.kycFaceUrl == this.kycFaceUrl &&
          other.gender == this.gender &&
          other.publicKeyB64 == this.publicKeyB64 &&
          other.isDirty == this.isDirty &&
          other.createdAt == this.createdAt);
}

class UsersCompanion extends UpdateCompanion<UserEntry> {
  final Value<String> id;
  final Value<String> email;
  final Value<String> username;
  final Value<String> fullName;
  final Value<String?> phone;
  final Value<String> role;
  final Value<String?> kycStatus;
  final Value<String?> nik;
  final Value<String?> province;
  final Value<String?> city;
  final Value<String?> district;
  final Value<String?> village;
  final Value<String?> postalCode;
  final Value<String?> rt;
  final Value<String?> rw;
  final Value<String?> ktpPhotoUrl;
  final Value<String?> profilePhotoUrl;
  final Value<String?> kycFaceUrl;
  final Value<String?> gender;
  final Value<String?> publicKeyB64;
  final Value<bool> isDirty;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.username = const Value.absent(),
    this.fullName = const Value.absent(),
    this.phone = const Value.absent(),
    this.role = const Value.absent(),
    this.kycStatus = const Value.absent(),
    this.nik = const Value.absent(),
    this.province = const Value.absent(),
    this.city = const Value.absent(),
    this.district = const Value.absent(),
    this.village = const Value.absent(),
    this.postalCode = const Value.absent(),
    this.rt = const Value.absent(),
    this.rw = const Value.absent(),
    this.ktpPhotoUrl = const Value.absent(),
    this.profilePhotoUrl = const Value.absent(),
    this.kycFaceUrl = const Value.absent(),
    this.gender = const Value.absent(),
    this.publicKeyB64 = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String email,
    required String username,
    this.fullName = const Value.absent(),
    this.phone = const Value.absent(),
    this.role = const Value.absent(),
    this.kycStatus = const Value.absent(),
    this.nik = const Value.absent(),
    this.province = const Value.absent(),
    this.city = const Value.absent(),
    this.district = const Value.absent(),
    this.village = const Value.absent(),
    this.postalCode = const Value.absent(),
    this.rt = const Value.absent(),
    this.rw = const Value.absent(),
    this.ktpPhotoUrl = const Value.absent(),
    this.profilePhotoUrl = const Value.absent(),
    this.kycFaceUrl = const Value.absent(),
    this.gender = const Value.absent(),
    this.publicKeyB64 = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       email = Value(email),
       username = Value(username);
  static Insertable<UserEntry> custom({
    Expression<String>? id,
    Expression<String>? email,
    Expression<String>? username,
    Expression<String>? fullName,
    Expression<String>? phone,
    Expression<String>? role,
    Expression<String>? kycStatus,
    Expression<String>? nik,
    Expression<String>? province,
    Expression<String>? city,
    Expression<String>? district,
    Expression<String>? village,
    Expression<String>? postalCode,
    Expression<String>? rt,
    Expression<String>? rw,
    Expression<String>? ktpPhotoUrl,
    Expression<String>? profilePhotoUrl,
    Expression<String>? kycFaceUrl,
    Expression<String>? gender,
    Expression<String>? publicKeyB64,
    Expression<bool>? isDirty,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (username != null) 'username': username,
      if (fullName != null) 'full_name': fullName,
      if (phone != null) 'phone': phone,
      if (role != null) 'role': role,
      if (kycStatus != null) 'kyc_status': kycStatus,
      if (nik != null) 'nik': nik,
      if (province != null) 'province': province,
      if (city != null) 'city': city,
      if (district != null) 'district': district,
      if (village != null) 'village': village,
      if (postalCode != null) 'postal_code': postalCode,
      if (rt != null) 'rt': rt,
      if (rw != null) 'rw': rw,
      if (ktpPhotoUrl != null) 'ktp_photo_url': ktpPhotoUrl,
      if (profilePhotoUrl != null) 'profile_photo_url': profilePhotoUrl,
      if (kycFaceUrl != null) 'kyc_face_url': kycFaceUrl,
      if (gender != null) 'gender': gender,
      if (publicKeyB64 != null) 'public_key_b64': publicKeyB64,
      if (isDirty != null) 'is_dirty': isDirty,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    Value<String>? id,
    Value<String>? email,
    Value<String>? username,
    Value<String>? fullName,
    Value<String?>? phone,
    Value<String>? role,
    Value<String?>? kycStatus,
    Value<String?>? nik,
    Value<String?>? province,
    Value<String?>? city,
    Value<String?>? district,
    Value<String?>? village,
    Value<String?>? postalCode,
    Value<String?>? rt,
    Value<String?>? rw,
    Value<String?>? ktpPhotoUrl,
    Value<String?>? profilePhotoUrl,
    Value<String?>? kycFaceUrl,
    Value<String?>? gender,
    Value<String?>? publicKeyB64,
    Value<bool>? isDirty,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      kycStatus: kycStatus ?? this.kycStatus,
      nik: nik ?? this.nik,
      province: province ?? this.province,
      city: city ?? this.city,
      district: district ?? this.district,
      village: village ?? this.village,
      postalCode: postalCode ?? this.postalCode,
      rt: rt ?? this.rt,
      rw: rw ?? this.rw,
      ktpPhotoUrl: ktpPhotoUrl ?? this.ktpPhotoUrl,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      kycFaceUrl: kycFaceUrl ?? this.kycFaceUrl,
      gender: gender ?? this.gender,
      publicKeyB64: publicKeyB64 ?? this.publicKeyB64,
      isDirty: isDirty ?? this.isDirty,
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
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (kycStatus.present) {
      map['kyc_status'] = Variable<String>(kycStatus.value);
    }
    if (nik.present) {
      map['nik'] = Variable<String>(nik.value);
    }
    if (province.present) {
      map['province'] = Variable<String>(province.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (district.present) {
      map['district'] = Variable<String>(district.value);
    }
    if (village.present) {
      map['village'] = Variable<String>(village.value);
    }
    if (postalCode.present) {
      map['postal_code'] = Variable<String>(postalCode.value);
    }
    if (rt.present) {
      map['rt'] = Variable<String>(rt.value);
    }
    if (rw.present) {
      map['rw'] = Variable<String>(rw.value);
    }
    if (ktpPhotoUrl.present) {
      map['ktp_photo_url'] = Variable<String>(ktpPhotoUrl.value);
    }
    if (profilePhotoUrl.present) {
      map['profile_photo_url'] = Variable<String>(profilePhotoUrl.value);
    }
    if (kycFaceUrl.present) {
      map['kyc_face_url'] = Variable<String>(kycFaceUrl.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (publicKeyB64.present) {
      map['public_key_b64'] = Variable<String>(publicKeyB64.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
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
          ..write('fullName: $fullName, ')
          ..write('phone: $phone, ')
          ..write('role: $role, ')
          ..write('kycStatus: $kycStatus, ')
          ..write('nik: $nik, ')
          ..write('province: $province, ')
          ..write('city: $city, ')
          ..write('district: $district, ')
          ..write('village: $village, ')
          ..write('postalCode: $postalCode, ')
          ..write('rt: $rt, ')
          ..write('rw: $rw, ')
          ..write('ktpPhotoUrl: $ktpPhotoUrl, ')
          ..write('profilePhotoUrl: $profilePhotoUrl, ')
          ..write('kycFaceUrl: $kycFaceUrl, ')
          ..write('gender: $gender, ')
          ..write('publicKeyB64: $publicKeyB64, ')
          ..write('isDirty: $isDirty, ')
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
  static const VerificationMeta _counterpartyNameMeta = const VerificationMeta(
    'counterpartyName',
  );
  @override
  late final GeneratedColumn<String> counterpartyName = GeneratedColumn<String>(
    'counterparty_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _counterpartyIdMeta = const VerificationMeta(
    'counterpartyId',
  );
  @override
  late final GeneratedColumn<String> counterpartyId = GeneratedColumn<String>(
    'counterparty_id',
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
    txId,
    direction,
    txType,
    amountCent,
    hopCount,
    syncStatus,
    counterpartyName,
    counterpartyId,
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
    if (data.containsKey('counterparty_name')) {
      context.handle(
        _counterpartyNameMeta,
        counterpartyName.isAcceptableOrUnknown(
          data['counterparty_name']!,
          _counterpartyNameMeta,
        ),
      );
    }
    if (data.containsKey('counterparty_id')) {
      context.handle(
        _counterpartyIdMeta,
        counterpartyId.isAcceptableOrUnknown(
          data['counterparty_id']!,
          _counterpartyIdMeta,
        ),
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
      counterpartyName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}counterparty_name'],
      ),
      counterpartyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}counterparty_id'],
      ),
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
  final String? counterpartyName;
  final String? counterpartyId;
  final DateTime createdAt;
  const TransactionEntry({
    required this.id,
    required this.txId,
    required this.direction,
    required this.txType,
    required this.amountCent,
    required this.hopCount,
    required this.syncStatus,
    this.counterpartyName,
    this.counterpartyId,
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
    if (!nullToAbsent || counterpartyName != null) {
      map['counterparty_name'] = Variable<String>(counterpartyName);
    }
    if (!nullToAbsent || counterpartyId != null) {
      map['counterparty_id'] = Variable<String>(counterpartyId);
    }
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
      counterpartyName: counterpartyName == null && nullToAbsent
          ? const Value.absent()
          : Value(counterpartyName),
      counterpartyId: counterpartyId == null && nullToAbsent
          ? const Value.absent()
          : Value(counterpartyId),
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
      counterpartyName: serializer.fromJson<String?>(json['counterpartyName']),
      counterpartyId: serializer.fromJson<String?>(json['counterpartyId']),
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
      'counterpartyName': serializer.toJson<String?>(counterpartyName),
      'counterpartyId': serializer.toJson<String?>(counterpartyId),
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
    Value<String?> counterpartyName = const Value.absent(),
    Value<String?> counterpartyId = const Value.absent(),
    DateTime? createdAt,
  }) => TransactionEntry(
    id: id ?? this.id,
    txId: txId ?? this.txId,
    direction: direction ?? this.direction,
    txType: txType ?? this.txType,
    amountCent: amountCent ?? this.amountCent,
    hopCount: hopCount ?? this.hopCount,
    syncStatus: syncStatus ?? this.syncStatus,
    counterpartyName: counterpartyName.present
        ? counterpartyName.value
        : this.counterpartyName,
    counterpartyId: counterpartyId.present
        ? counterpartyId.value
        : this.counterpartyId,
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
      counterpartyName: data.counterpartyName.present
          ? data.counterpartyName.value
          : this.counterpartyName,
      counterpartyId: data.counterpartyId.present
          ? data.counterpartyId.value
          : this.counterpartyId,
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
          ..write('counterpartyName: $counterpartyName, ')
          ..write('counterpartyId: $counterpartyId, ')
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
    counterpartyName,
    counterpartyId,
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
          other.counterpartyName == this.counterpartyName &&
          other.counterpartyId == this.counterpartyId &&
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
  final Value<String?> counterpartyName;
  final Value<String?> counterpartyId;
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
    this.counterpartyName = const Value.absent(),
    this.counterpartyId = const Value.absent(),
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
    this.counterpartyName = const Value.absent(),
    this.counterpartyId = const Value.absent(),
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
    Expression<String>? counterpartyName,
    Expression<String>? counterpartyId,
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
      if (counterpartyName != null) 'counterparty_name': counterpartyName,
      if (counterpartyId != null) 'counterparty_id': counterpartyId,
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
    Value<String?>? counterpartyName,
    Value<String?>? counterpartyId,
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
      counterpartyName: counterpartyName ?? this.counterpartyName,
      counterpartyId: counterpartyId ?? this.counterpartyId,
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
    if (counterpartyName.present) {
      map['counterparty_name'] = Variable<String>(counterpartyName.value);
    }
    if (counterpartyId.present) {
      map['counterparty_id'] = Variable<String>(counterpartyId.value);
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
          ..write('counterpartyName: $counterpartyName, ')
          ..write('counterpartyId: $counterpartyId, ')
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
      Value<String> fullName,
      Value<String?> phone,
      Value<String> role,
      Value<String?> kycStatus,
      Value<String?> nik,
      Value<String?> province,
      Value<String?> city,
      Value<String?> district,
      Value<String?> village,
      Value<String?> postalCode,
      Value<String?> rt,
      Value<String?> rw,
      Value<String?> ktpPhotoUrl,
      Value<String?> profilePhotoUrl,
      Value<String?> kycFaceUrl,
      Value<String?> gender,
      Value<String?> publicKeyB64,
      Value<bool> isDirty,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<String> id,
      Value<String> email,
      Value<String> username,
      Value<String> fullName,
      Value<String?> phone,
      Value<String> role,
      Value<String?> kycStatus,
      Value<String?> nik,
      Value<String?> province,
      Value<String?> city,
      Value<String?> district,
      Value<String?> village,
      Value<String?> postalCode,
      Value<String?> rt,
      Value<String?> rw,
      Value<String?> ktpPhotoUrl,
      Value<String?> profilePhotoUrl,
      Value<String?> kycFaceUrl,
      Value<String?> gender,
      Value<String?> publicKeyB64,
      Value<bool> isDirty,
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

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kycStatus => $composableBuilder(
    column: $table.kycStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nik => $composableBuilder(
    column: $table.nik,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get province => $composableBuilder(
    column: $table.province,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get district => $composableBuilder(
    column: $table.district,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get village => $composableBuilder(
    column: $table.village,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get postalCode => $composableBuilder(
    column: $table.postalCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rt => $composableBuilder(
    column: $table.rt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rw => $composableBuilder(
    column: $table.rw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ktpPhotoUrl => $composableBuilder(
    column: $table.ktpPhotoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profilePhotoUrl => $composableBuilder(
    column: $table.profilePhotoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kycFaceUrl => $composableBuilder(
    column: $table.kycFaceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publicKeyB64 => $composableBuilder(
    column: $table.publicKeyB64,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
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

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kycStatus => $composableBuilder(
    column: $table.kycStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nik => $composableBuilder(
    column: $table.nik,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get province => $composableBuilder(
    column: $table.province,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get district => $composableBuilder(
    column: $table.district,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get village => $composableBuilder(
    column: $table.village,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get postalCode => $composableBuilder(
    column: $table.postalCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rt => $composableBuilder(
    column: $table.rt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rw => $composableBuilder(
    column: $table.rw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ktpPhotoUrl => $composableBuilder(
    column: $table.ktpPhotoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profilePhotoUrl => $composableBuilder(
    column: $table.profilePhotoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kycFaceUrl => $composableBuilder(
    column: $table.kycFaceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publicKeyB64 => $composableBuilder(
    column: $table.publicKeyB64,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
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

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get kycStatus =>
      $composableBuilder(column: $table.kycStatus, builder: (column) => column);

  GeneratedColumn<String> get nik =>
      $composableBuilder(column: $table.nik, builder: (column) => column);

  GeneratedColumn<String> get province =>
      $composableBuilder(column: $table.province, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<String> get district =>
      $composableBuilder(column: $table.district, builder: (column) => column);

  GeneratedColumn<String> get village =>
      $composableBuilder(column: $table.village, builder: (column) => column);

  GeneratedColumn<String> get postalCode => $composableBuilder(
    column: $table.postalCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rt =>
      $composableBuilder(column: $table.rt, builder: (column) => column);

  GeneratedColumn<String> get rw =>
      $composableBuilder(column: $table.rw, builder: (column) => column);

  GeneratedColumn<String> get ktpPhotoUrl => $composableBuilder(
    column: $table.ktpPhotoUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get profilePhotoUrl => $composableBuilder(
    column: $table.profilePhotoUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kycFaceUrl => $composableBuilder(
    column: $table.kycFaceUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<String> get publicKeyB64 => $composableBuilder(
    column: $table.publicKeyB64,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

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
                Value<String> fullName = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String?> kycStatus = const Value.absent(),
                Value<String?> nik = const Value.absent(),
                Value<String?> province = const Value.absent(),
                Value<String?> city = const Value.absent(),
                Value<String?> district = const Value.absent(),
                Value<String?> village = const Value.absent(),
                Value<String?> postalCode = const Value.absent(),
                Value<String?> rt = const Value.absent(),
                Value<String?> rw = const Value.absent(),
                Value<String?> ktpPhotoUrl = const Value.absent(),
                Value<String?> profilePhotoUrl = const Value.absent(),
                Value<String?> kycFaceUrl = const Value.absent(),
                Value<String?> gender = const Value.absent(),
                Value<String?> publicKeyB64 = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                email: email,
                username: username,
                fullName: fullName,
                phone: phone,
                role: role,
                kycStatus: kycStatus,
                nik: nik,
                province: province,
                city: city,
                district: district,
                village: village,
                postalCode: postalCode,
                rt: rt,
                rw: rw,
                ktpPhotoUrl: ktpPhotoUrl,
                profilePhotoUrl: profilePhotoUrl,
                kycFaceUrl: kycFaceUrl,
                gender: gender,
                publicKeyB64: publicKeyB64,
                isDirty: isDirty,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String email,
                required String username,
                Value<String> fullName = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String?> kycStatus = const Value.absent(),
                Value<String?> nik = const Value.absent(),
                Value<String?> province = const Value.absent(),
                Value<String?> city = const Value.absent(),
                Value<String?> district = const Value.absent(),
                Value<String?> village = const Value.absent(),
                Value<String?> postalCode = const Value.absent(),
                Value<String?> rt = const Value.absent(),
                Value<String?> rw = const Value.absent(),
                Value<String?> ktpPhotoUrl = const Value.absent(),
                Value<String?> profilePhotoUrl = const Value.absent(),
                Value<String?> kycFaceUrl = const Value.absent(),
                Value<String?> gender = const Value.absent(),
                Value<String?> publicKeyB64 = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                email: email,
                username: username,
                fullName: fullName,
                phone: phone,
                role: role,
                kycStatus: kycStatus,
                nik: nik,
                province: province,
                city: city,
                district: district,
                village: village,
                postalCode: postalCode,
                rt: rt,
                rw: rw,
                ktpPhotoUrl: ktpPhotoUrl,
                profilePhotoUrl: profilePhotoUrl,
                kycFaceUrl: kycFaceUrl,
                gender: gender,
                publicKeyB64: publicKeyB64,
                isDirty: isDirty,
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
      Value<String?> counterpartyName,
      Value<String?> counterpartyId,
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
      Value<String?> counterpartyName,
      Value<String?> counterpartyId,
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

  ColumnFilters<String> get counterpartyName => $composableBuilder(
    column: $table.counterpartyName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get counterpartyId => $composableBuilder(
    column: $table.counterpartyId,
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

  ColumnOrderings<String> get counterpartyName => $composableBuilder(
    column: $table.counterpartyName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get counterpartyId => $composableBuilder(
    column: $table.counterpartyId,
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

  GeneratedColumn<String> get counterpartyName => $composableBuilder(
    column: $table.counterpartyName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get counterpartyId => $composableBuilder(
    column: $table.counterpartyId,
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
                Value<String?> counterpartyName = const Value.absent(),
                Value<String?> counterpartyId = const Value.absent(),
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
                counterpartyName: counterpartyName,
                counterpartyId: counterpartyId,
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
                Value<String?> counterpartyName = const Value.absent(),
                Value<String?> counterpartyId = const Value.absent(),
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
                counterpartyName: counterpartyName,
                counterpartyId: counterpartyId,
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
