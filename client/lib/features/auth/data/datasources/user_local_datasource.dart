import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/user.dart';

class UserLocalDatasource {
  final AppDatabase _db;

  UserLocalDatasource(this._db);

  /// Simpan user data ke local database
  Future<void> saveUser(User user) async {
    await _db.upsertUser(UsersCompanion(
      id: Value(user.id),
      email: Value(user.email),
      username: Value(user.username),
      fullName: Value(user.fullName),
      phone: Value(user.phone ?? ''),
      role: Value(user.role),
      kycStatus: Value(user.kycStatus),
      nik: Value(user.nik),
      province: Value(user.province),
      city: Value(user.city),
      district: Value(user.district),
      village: Value(user.village),
      postalCode: Value(user.postalCode),
      rt: Value(user.rt),
      rw: Value(user.rw),
      ktpPhotoUrl: Value(user.ktpPhotoUrl),
      profilePhotoUrl: Value(user.profilePhotoUrl),
      kycFaceUrl: Value(user.kycFaceUrl),
      gender: Value(user.gender),
    ));
  }

  /// Ambil user dari local database
  Future<User?> getUser(String userId) async {
    final entry = await _db.getUserById(userId);
    if (entry == null) return null;
    return _entryToUser(entry);
  }

  /// Ambil user aktif (satu-satunya user di DB)
  Future<User?> getActiveUser() async {
    final entry = await _db.getActiveUser();
    if (entry == null) return null;
    return _entryToUser(entry);
  }

  /// Update profile user dan tandai dirty
  Future<void> updateProfile({
    required String userId,
    String? fullName,
    String? phone,
    String? province,
    String? city,
    String? district,
    String? village,
    String? postalCode,
    String? rt,
    String? rw,
  }) async {
    await _db.updateUserDirty(
      userId,
      UsersCompanion(
        fullName: fullName != null ? Value(fullName) : const Value.absent(),
        phone: phone != null ? Value(phone) : const Value.absent(),
        province: province != null ? Value(province) : const Value.absent(),
        city: city != null ? Value(city) : const Value.absent(),
        district: district != null ? Value(district) : const Value.absent(),
        village: village != null ? Value(village) : const Value.absent(),
        postalCode: postalCode != null ? Value(postalCode) : const Value.absent(),
        rt: rt != null ? Value(rt) : const Value.absent(),
        rw: rw != null ? Value(rw) : const Value.absent(),
      ),
    );
  }

  /// Ambil user yang dirty (belum di-sync)
  Future<List<User>> getDirtyUsers() async {
    final entries = await _db.getDirtyUsers();
    return entries.map((e) => _entryToUser(e)).toList();
  }

  /// Update foto profil
  Future<void> updateProfilePhoto(String userId, String photoUrl) async {
    await (_db.update(_db.users)..where((u) => u.id.equals(userId))).write(
      UsersCompanion(
        profilePhotoUrl: Value(photoUrl),
        isDirty: const Value(true),
      ),
    );
  }

  /// Tandai user sebagai clean setelah sync
  Future<void> markUserClean(String userId) async {
    await _db.markUserClean(userId);
  }

  User _entryToUser(UserEntry entry) {
    return User(
      id: entry.id,
      email: entry.email,
      fullName: entry.fullName,
      username: entry.username,
      role: entry.role,
      phone: entry.phone,
      kycStatus: entry.kycStatus,
      nik: entry.nik,
      province: entry.province,
      city: entry.city,
      district: entry.district,
      village: entry.village,
      postalCode: entry.postalCode,
      rt: entry.rt,
      rw: entry.rw,
      ktpPhotoUrl: entry.ktpPhotoUrl,
      profilePhotoUrl: entry.profilePhotoUrl,
      kycFaceUrl: entry.kycFaceUrl,
      gender: entry.gender,
    );
  }
}
