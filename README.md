# Nirpay — Offline CBDC Wallet

**Nirpay** adalah sebuah sistem dompet digital (*digital wallet*) inovatif yang dirancang khusus untuk mendukung penggunaan **CBDC (Central Bank Digital Currency)**. Keunggulan utama dari Nirpay adalah kemampuannya untuk memfasilitasi transaksi pembayaran antar pengguna secara *offline* (tanpa koneksi internet) menggunakan teknologi **NFC** dan **Bluetooth**.

Sistem ini didesain untuk daerah dengan konektivitas rendah atau saat terjadi gangguan jaringan, memastikan transaksi dapat terus berjalan dengan aman dan nantinya akan direkonsiliasi secara otomatis ke server pusat saat perangkat kembali *online*.

## ✨ Fitur Utama

- **Offline P2P Transfer**: Kirim dan terima uang langsung antar pengguna (*peer-to-peer*) tanpa perlu akses internet melalui NFC (Host Card Emulation) dan komunikasi Bluetooth.
- **Sinkronisasi Otomatis (Reconciliation)**: Transaksi offline disimpan dengan aman di perangkat lokal dan akan disinkronisasi ke server (Global Ledger) ketika koneksi internet kembali tersedia.
- **Pencegahan Double-Spend**: Sistem backend yang handal untuk mendeteksi, menangani, dan melakukan *rollback* jika terdeteksi anomali atau percobaan pembelanjaan ganda (*double-spending*).
- **Keamanan Kriptografi Tingkat Tinggi**: Menggunakan algoritma *Ed25519* untuk tanda tangan digital transaksi offline dan enkripsi *AES-256* (memanfaatkan *Android Keystore* / TEE) untuk mengamankan data dompet di perangkat.

## 🏗️ Struktur Proyek (Monorepo)

Proyek ini adalah *monorepo* yang terdiri dari 3 sistem utama yang saling terhubung:

- 📱 **`client/` (Mobile App)** 
  Aplikasi pengguna akhir yang dibangun menggunakan **Flutter**. Berfungsi sebagai dompet digital offline dengan penyimpanan lokal terenkripsi.
- ⚙️ **`backend/` (API & Core Ledger)**
  Server pusat yang dibangun dengan **NestJS (Node.js)**. Bertugas sebagai *mock bank* CBDC, menangani proses sinkronisasi, validasi kriptografi, dan penyelesaian akhir (*settlement*).
- 🖥️ **`dashboard/` (Admin Panel)**
  Web administrasi yang dibangun dengan **Next.js**. Digunakan oleh staf/admin untuk memantau lalu lintas transaksi, verifikasi pengguna (KYC), dan mengawasi kesehatan *ledger*.

## 🛠️ Tech Stack

| Komponen | Teknologi Pendukung |
|---|---|
| **Client** | Flutter, Dart, SQLite (+ SQLCipher), Drift ORM |
| **Backend** | Node.js (NestJS), PostgreSQL, Prisma ORM, Redis |
| **Dashboard** | Next.js, React, Tailwind CSS |
| **Keamanan** | AES-256, Ed25519, Argon2 |
| **Konektivitas** | NFC (HCE), Bluetooth |

## 🚀 Panduan Instalasi & Menjalankan

Berikut adalah cara menjalankan masing-masing komponen proyek di lingkungan lokal (development):

### 1. Client (Mobile App)
Pastikan kamu telah menginstal SDK Flutter.
```bash
cd client
flutter pub get
flutter run
```

### 2. Backend (API Server)
Pastikan Node.js, npm, dan PostgreSQL sudah tersedia.
```bash
cd backend
npm install
# Sesuaikan file .env untuk koneksi database
npx prisma generate
npx prisma db push
npm run start:dev
```

### 3. Dashboard (Admin Web)
Pastikan Backend sudah berjalan karena dashboard membutuhkan API backend.
```bash
cd dashboard
npm install
# Sesuaikan file .env untuk menunjuk ke URL Backend API
npm run dev
```

---
*Catatan: File dan dokumen rancangan internal (sprint plan, wireframe, dll.) dikecualikan dari repository ini dan dikelola secara terpisah.*
