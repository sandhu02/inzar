import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import '../../../app/di.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/storage/incident_media_cache.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../flow/report_flow_bloc.dart';
import '../flow/report_flow_event.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isCameraReady = false;
  bool _isPermissionDenied = false;
  bool _isFlashOn = false;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cameraController = _controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    // Check permission first
    if (getIt.isRegistered<PermissionService>()) {
      final isGranted = await getIt<PermissionService>().isCameraGranted();
      if (!isGranted) {
        final granted = await getIt<PermissionService>().requestCamera();
        if (!granted) {
          if (mounted) setState(() => _isPermissionDenied = true);
          return;
        }
      }
    }

    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (mounted) setState(() => _isCameraReady = false);
        return;
      }

      final camera = _cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();

      if (mounted) {
        setState(() {
          _controller = controller;
          _isCameraReady = true;
          _isPermissionDenied = false;
        });
      }
    } catch (e) {
      debugPrint('[CameraPage] Initialization error: $e');
      if (mounted) {
        setState(() {
          _isCameraReady = false;
        });
      }
    }
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      final newFlash = !_isFlashOn;
      await _controller!.setFlashMode(newFlash ? FlashMode.torch : FlashMode.off);
      if (mounted) setState(() => _isFlashOn = newFlash);
    } catch (_) {}
  }

  Future<void> _handleCapture() async {
    if (_isCapturing) return;

    final flowBloc = context.read<ReportFlowBloc>();
    final timeNow = DateFormat('HH:mm').format(DateTime.now());

    // 1. Capture from actual camera controller
    if (_controller != null && _controller!.value.isInitialized) {
      setState(() => _isCapturing = true);
      try {
        final XFile photo = await _controller!.takePicture();
        IncidentMediaCache.setLastCaptured(photo.path);

        flowBloc.add(
          PhotoCaptured(
            photoPath: photo.path,
            timestamp: timeNow,
          ),
        );

        // Fetch location in background
        await _recordCurrentLocation(flowBloc);

        if (mounted) {
          context.push('/report/form');
        }
        return;
      } catch (e) {
        debugPrint('[CameraPage] Photo capture failed: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to capture photo. Please try again.'),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isCapturing = false);
      }
    } else {
      // In tests / simulator without camera hardware, inform user cleanly
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera feed is not ready. Please allow camera permissions.'),
        ),
      );
    }
  }

  Future<void> _recordCurrentLocation(ReportFlowBloc flowBloc) async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('[CameraPage] Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugPrint('[CameraPage] Location permission denied ($permission).');
        return;
      }

      // Fast snap: use last known position immediately
      final lastPos = await Geolocator.getLastKnownPosition();
      if (lastPos != null) {
        flowBloc.add(
          LocationAdjusted(
            locationName: 'Current Location',
            shownPrecision: 'GPS Accuracy ~${lastPos.accuracy.toStringAsFixed(0)}m',
            latitude: lastPos.latitude,
            longitude: lastPos.longitude,
          ),
        );
      }

      // Fresh position
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 4),
        ),
      );
      flowBloc.add(
        LocationAdjusted(
          locationName: 'Current Location',
          shownPrecision: 'GPS Accuracy ~${pos.accuracy.toStringAsFixed(0)}m',
          latitude: pos.latitude,
          longitude: pos.longitude,
        ),
      );
    } catch (e) {
      debugPrint('[CameraPage] Location recording failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Live camera viewfinder feed
            Positioned.fill(
              child: _buildCameraFeed(),
            ),

            // 2. Framing Reticle (4 corner brackets)
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.78,
                height: MediaQuery.of(context).size.height * 0.52,
                child: CustomPaint(
                  painter: _CornerBracketsPainter(),
                ),
              ),
            ),

            // 3. Top Action Bar: Close & Flash
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCircleButton(
                    icon: Icons.close_rounded,
                    onTap: () => context.pop(),
                  ),
                  _buildCircleButton(
                    icon: _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                    color: _isFlashOn ? AppColors.textHighlight : AppColors.textPrimary,
                    onTap: _toggleFlash,
                  ),
                ],
              ),
            ),

            // 4. Floating Guidance Pill
            Positioned(
              top: 76,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: Text(
                    "Capture what's happening",
                    style: AppTypography.fontMono.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            // 5. Bottom Controls: Location badge + Large Shutter Button
            Positioned(
              bottom: 28,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.gps_fixed_rounded,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Location on  ·  shared approximately',
                        style: AppTypography.disclaimer.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Shutter Button
                  GestureDetector(
                    onTap: _handleCapture,
                    child: Container(
                      width: 76,
                      height: 76,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 3.5,
                        ),
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.buttonLight,
                          shape: BoxShape.circle,
                        ),
                        child: _isCapturing
                            ? const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.black,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraFeed() {
    if (_isPermissionDenied) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.videocam_off_outlined, size: 48, color: AppColors.textMuted),
              const SizedBox(height: 14),
              Text(
                'Camera Permission Required',
                style: AppTypography.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Inzar requires camera access to capture verified incident photos.',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: _initializeCamera,
                child: const Text('Allow Camera'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isCameraReady && _controller != null && _controller!.value.isInitialized) {
      // Real live camera viewfinder feed filling the viewfinder
      return ClipRect(
        child: OverflowBox(
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller!.value.previewSize?.height ?? 1080,
              height: _controller!.value.previewSize?.width ?? 1920,
              child: CameraPreview(_controller!),
            ),
          ),
        ),
      );
    }

    // Camera hardware warming up
    return const Center(
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    Color color = AppColors.textPrimary,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated.withValues(alpha: 0.7),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 22),
        onPressed: onTap,
      ),
    );
  }
}

class _CornerBracketsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    const cornerLength = 22.0;

    // Top-left
    canvas.drawLine(const Offset(0, 0), const Offset(cornerLength, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, cornerLength), paint);

    // Top-right
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - cornerLength, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, cornerLength), paint);

    // Bottom-left
    canvas.drawLine(Offset(0, size.height), Offset(cornerLength, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - cornerLength), paint);

    // Bottom-right
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - cornerLength, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
