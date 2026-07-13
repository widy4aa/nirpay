import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nirpay/core/router/app_router.dart';
import 'package:camera/camera.dart';

class RegisterStep4Page extends StatefulWidget {
  const RegisterStep4Page({super.key});

  @override
  State<RegisterStep4Page> createState() => _RegisterStep4PageState();
}

class _RegisterStep4PageState extends State<RegisterStep4Page> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        // Find front camera if available
        final frontCamera = _cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras.first,
        );

        _controller = CameraController(
          frontCamera,
          ResolutionPreset.medium,
          enableAudio: false,
        );

        await _controller!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

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
        appBar: _buildAppBar(context),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 16.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildProgressBar(),
                          const SizedBox(height: 32),
                          _buildHeader(),
                          const SizedBox(height: 40),
                          _buildCameraPreview(),
                          const Spacer(),
                          const SizedBox(height: 40),
                          _buildNextButton(context),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1B1E28)),
        onPressed: () => context.pop(),
      ),
      title: const Text(
        'Verifikasi Muka',
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

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Langkah 4 dari 5',
          style: TextStyle(
            color: Color(0xFF009CFF),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 4,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF009CFF),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              flex: 1,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E6EE),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verifikasi Wajah Anda',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E1E24),
            height: 1.3,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Arahkan wajah Anda ke dalam bingkai kamera\nuntuk proses verifikasi keamanan.',
          style: TextStyle(fontSize: 14, color: Color(0xFF7D8C9E), height: 1.5),
        ),
      ],
    );
  }

  Widget _buildCameraPreview() {
    return Center(
      child: Container(
        width: 250,
        height: 300,
        decoration: BoxDecoration(
          color: const Color(0xFFDDE2EC).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(150),
          border: Border.all(color: const Color(0xFF009CFF), width: 3),
        ),
        child: ClipOval(
          child: _isCameraInitialized && _controller != null
              ? AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: CameraPreview(_controller!),
                )
              : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Color(0xFF009CFF)),
                      SizedBox(height: 16),
                      Text(
                        'Menginisialisasi Kamera...',
                        style: TextStyle(
                          color: Color(0xFF7D8C9E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => context.pushNamed(AppRouteNames.registerStep5),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF009CFF),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: const Color(0xFF009CFF).withValues(alpha: 0.3),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Selanjutnya',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, size: 20),
          ],
        ),
      ),
    );
  }
}
