import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _selectedFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF4F7FB), Colors.white, Color(0xFFC7F4ED)],
          stops: [0.0, 0.4, 1.0],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _buildSearchAndFilter(),
                const SizedBox(height: 16),
                _buildFilterChips(),
                const SizedBox(height: 24),
                Expanded(child: _buildTransactionList()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1B1E28)),
        onPressed: widget.onBack,
      ),
      title: const Text(
        'Riwayat Transaksi',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1B1E28),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black54, width: 1.5),
            ),
            child: const Icon(
              Icons.question_mark_rounded,
              color: Colors.black87,
              size: 16,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3F6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E6EE)),
            ),
            child: const TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search_rounded, color: Colors.grey),
                hintText: 'Cari Transaksi',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F3F6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E6EE)),
          ),
          child: const Icon(
            Icons.tune_rounded,
            color: Color(0xFF1B1E28),
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip('Semua'),
          const SizedBox(width: 8),
          _buildChip('Masuk'),
          const SizedBox(width: 8),
          _buildChip('Keluar'),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    final isActive = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFBEEFF0) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? const Color(0xFF8EDBE0) : const Color(0xFFE2E6EE),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isActive ? const Color(0xFF103B3D) : const Color(0xFF4A4A54),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    // Standard mock list grouped by date as shown in UI mock
    return ListView(
      children: [
        _buildSectionHeader('BULAN INI', '25 Mei 2026'),
        const SizedBox(height: 12),
        _buildTransactionItem(
          initials: 'BD',
          avatarBg: const Color(0xFFFFB01A),
          title: 'BUDI',
          date: '18 Mei 2026',
          amount: '-Rp15.000',
          isNegative: true,
        ),
        const Divider(height: 24, thickness: 0.5, color: Color(0xFFE2E6EE)),
        _buildTransactionItem(
          initials: 'TF',
          avatarBg: const Color(0xFF00C4D4),
          title: 'THORIQ FIRDAUSI',
          date: '10 Mei 2026',
          amount: '+Rp32.000',
          isNegative: false,
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('APR 2026', ''),
        const SizedBox(height: 12),
        _buildTransactionItem(
          initials: 'ED',
          avatarBg: const Color(0xFF8A2BE2),
          title: 'EDWIN',
          date: '28 Apr 2026',
          amount: '+Rp30.000',
          isNegative: false,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String date) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Color(0xFF4E5E72),
            letterSpacing: 0.5,
          ),
        ),
        if (date.isNotEmpty)
          Text(
            date,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
      ],
    );
  }

  Widget _buildTransactionItem({
    required String initials,
    required Color avatarBg,
    required String title,
    required String date,
    required String amount,
    required bool isNegative,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(color: avatarBg, shape: BoxShape.circle),
          child: Center(
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E24),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: isNegative
                ? const Color(0xFFD14B5A)
                : const Color(0xFF1F8062),
          ),
        ),
      ],
    );
  }
}
