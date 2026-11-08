import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/di.dart';
import '../../../core/config/app_config.dart';
import '../../../core/storage/incident_media_cache.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/design_system/status_badge.dart';
import '../../../core/design_system/app_button.dart';
import '../../../domain/entities/incident.dart';
import '../../../domain/entities/incident_category.dart';
import '../../../domain/entities/review_status.dart';
import '../../../domain/repositories/incident_repository.dart';

class IncidentDetailsPage extends StatefulWidget {
  final Incident? incident;

  const IncidentDetailsPage({
    super.key,
    this.incident,
  });

  @override
  State<IncidentDetailsPage> createState() => _IncidentDetailsPageState();
}

class _IncidentDetailsPageState extends State<IncidentDetailsPage> {
  late Incident _item;

  @override
  void initState() {
    super.initState();
    _item = widget.incident ??
        const Incident(
          id: '',
          category: IncidentCategory.other,
          title: 'Incident Details',
          description: '',
          locationName: 'Location',
          areaCode: '',
          distanceKm: 0.0,
          reportedTime: '',
          lastUpdateTime: '',
          status: 'Active',
          reviewStatus: ReviewStatus.published,
          photoTimestamp: '',
          latitude: 0.0,
          longitude: 0.0,
        );

    _loadLatestDetails();
  }

  Future<void> _loadLatestDetails() async {
    if (_item.id.isEmpty) return;

    try {
      final res = await getIt<IIncidentRepository>().getIncidentDetails(_item.id);
      if (res.isSuccess && res.data != null && mounted) {
        setState(() {
          _item = res.data!;
        });
      }
    } catch (_) {}
  }

  String _formatDisplayId(String id) {
    if (id.isEmpty) return '';
    if (id.startsWith('#')) return id;
    if (id.contains('-') || id.length > 12) {
      final clean = id.replaceAll('-', '');
      final prefix = clean.length >= 8 ? clean.substring(0, 8).toUpperCase() : clean.toUpperCase();
      return '#$prefix';
    }
    return '#$id';
  }

  Widget _buildPhotoWidget(Incident item) {
    String? photo = item.photoUrl;

    if (photo == null || photo.isEmpty) {
      photo = IncidentMediaCache.get(item.id);
    }

    if (photo != null && photo.isNotEmpty) {
      // 1. Remote HTTP/HTTPS image
      if (photo.startsWith('http://') || photo.startsWith('https://')) {
        return Image.network(
          photo,
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, stack) => _buildFallbackPhoto(),
          loadingBuilder: (ctx, child, progress) {
            if (progress == null) return child;
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            );
          },
        );
      }

      // 2. Local file on device
      final cleanPath = photo.startsWith('file://') ? photo.replaceFirst('file://', '') : photo;
      final file = File(cleanPath);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, stack) => _buildFallbackPhoto(),
        );
      }

      // 3. Relative server path
      if (photo.startsWith('/')) {
        final base = AppConfig.instance.apiBaseUrl.replaceAll('/api/v1', '');
        return Image.network(
          '$base$photo',
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, stack) => _buildFallbackPhoto(),
        );
      }
    }

    // 4. Last captured photo in this session
    final lastCaptured = IncidentMediaCache.getLastCaptured();
    if (lastCaptured != null && File(lastCaptured).existsSync()) {
      return Image.file(
        File(lastCaptured),
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, stack) => _buildFallbackPhoto(),
      );
    }

    return _buildFallbackPhoto();
  }

  Widget _buildFallbackPhoto() {
    return CustomPaint(
      painter: _DiagonalStripeLargePainter(),
    );
  }

  Future<void> _handleDirections(BuildContext context, double lat, double lon) async {
    if (lat == 0.0 && lon == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location coordinates unavailable')),
      );
      return;
    }

    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lon',
    );
    final geoUri = Uri.parse('google.navigation:q=$lat,$lon');

    try {
      if (await canLaunchUrl(geoUri)) {
        await launchUrl(geoUri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {}

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
        return;
      } else {
        await launchUrl(googleMapsUrl, mode: LaunchMode.platformDefault);
        return;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open map: $e')),
        );
      }
    }
  }

  Future<void> _handleShare(BuildContext context, Incident item) async {
    String desc = item.description.trim();
    if (desc.isEmpty) {
      desc = item.title;
    }
    if (desc.length > 150) {
      desc = '${desc.substring(0, 147)}...';
    }

    final mapUrl = 'https://www.google.com/maps/search/?api=1&query=${item.latitude}%2C${item.longitude}';

    final shareText = '''
🚨 Inzar Incident Alert: ${item.category.displayName}
$desc

$mapUrl

Reported on Inzar · Local Safety & Incident Network'''.trim();

    try {
      // ignore: deprecated_member_use
      await Share.share(
        shareText,
        subject: 'Inzar Incident Alert: ${item.title}',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share incident: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = _item;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textPrimary),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'INCIDENT  ·  ${_formatDisplayId(item.id)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.technicalTag.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category icon & name
                    Row(
                      children: [
                        Icon(
                          item.category.iconData,
                          size: 18,
                          color: item.category.color,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item.category.displayName.toUpperCase(),
                          style: AppTypography.sectionHeader.copyWith(
                            color: item.category.color,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Title
                    Text(
                      item.title,
                      style: AppTypography.screenTitle.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Badges
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        StatusBadge.aiReviewed(),
                        StatusBadge.notConfirmed(),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Photo card: network or local file image if available, else striped painter
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 180,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E252E),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border, width: 1),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: _buildPhotoWidget(item),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'reporter photo  ·  taken in app ${item.photoTimestamp}',
                          style: AppTypography.technicalSub.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Description text
                    Text(
                      item.description,
                      style: AppTypography.body.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 2x2 Metadata grid in a card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildMetaItem('REPORTED', item.reportedTime),
                              ),
                              Expanded(
                                child: _buildMetaItem('LAST UPDATE', item.lastUpdateTime),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(color: AppColors.border, height: 1),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _buildMetaItem('DISTANCE', '${item.distanceKm.toStringAsFixed(1)} km · approx.'),
                              ),
                              Expanded(
                                child: _buildMetaItem('STATUS', item.status),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Mini map preview with real street map
                    Container(
                      height: 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF161D26),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: (item.latitude != 0.0 && item.longitude != 0.0)
                            ? FlutterMap(
                                options: MapOptions(
                                  initialCenter: LatLng(item.latitude, item.longitude),
                                  initialZoom: 14.2,
                                  interactionOptions: const InteractionOptions(
                                    flags: InteractiveFlag.none,
                                  ),
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        AppConfig.instance.getMapTileUrl(isDark: true),
                                    userAgentPackageName: 'com.inzar.app',
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: LatLng(item.latitude, item.longitude),
                                        width: 38,
                                        height: 38,
                                        child: Center(
                                          child: Container(
                                            width: 34,
                                            height: 34,
                                            decoration: BoxDecoration(
                                              color: item.category.color,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.white, width: 2),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.5),
                                                  blurRadius: 8,
                                                )
                                              ],
                                            ),
                                            child: Icon(
                                              item.category.iconData,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : Stack(
                                children: [
                                  Positioned.fill(
                                    child: CustomPaint(
                                      painter: _MiniMapPainter(),
                                    ),
                                  ),
                                  Center(
                                    child: Container(
                                      width: 34,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        color: item.category.color,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.5),
                                            blurRadius: 8,
                                          )
                                        ],
                                      ),
                                      child: Icon(
                                        item.category.iconData,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Action buttons: Directions & Share
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: 'Directions',
                            variant: AppButtonVariant.secondaryLight,
                            height: 48,
                            onPressed: () => _handleDirections(context, item.latitude, item.longitude),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppButton(
                            label: 'Share',
                            variant: AppButtonVariant.secondaryDark,
                            height: 48,
                            onPressed: () => _handleShare(context, item),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Secondary action links: Report incorrect info & Mark resolved
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => _showFlagDialog(context, item.id),
                          child: Text(
                            'Report incorrect info',
                            style: AppTypography.bodySmall.copyWith(
                              decoration: TextDecoration.underline,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _handleResolve(context, item.id),
                          child: Text(
                            'Mark resolved',
                            style: AppTypography.bodySmall.copyWith(
                              decoration: TextDecoration.underline,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Safety Disclaimer Note
                    Text(
                      'AI review checks that photo and description fit the category. It does not prove the incident occurred. Inzar is not an emergency service; call 15 or 1122 for emergencies.',
                      style: AppTypography.disclaimer.copyWith(
                        color: AppColors.textMuted,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFlagDialog(BuildContext context, String incidentId) {
    String selectedType = 'incorrect';
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surfaceElevated,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Flag Incident', style: AppTypography.titleMedium),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedType,
                dropdownColor: AppColors.surfaceElevated,
                items: const [
                  DropdownMenuItem(value: 'incorrect', child: Text('Incorrect information', style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: 'abuse', child: Text('Spam or inappropriate', style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: 'resolved', child: Text('Incident already cleared', style: TextStyle(color: Colors.white))),
                ],
                onChanged: (val) {
                  if (val != null) setDialogState(() => selectedType = val);
                },
                decoration: const InputDecoration(labelText: 'Feedback Type'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(hintText: 'Optional details...'),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogCtx).pop();
                final res = await getIt<IIncidentRepository>().flagIncident(
                  id: incidentId,
                  type: selectedType,
                  note: noteController.text.trim(),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(res.isSuccess ? 'Feedback submitted. Thank you.' : (res.failure?.message ?? 'Failed to submit feedback')),
                    ),
                  );
                }
              },
              child: const Text('Submit', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleResolve(BuildContext context, String incidentId) async {
    final res = await getIt<IIncidentRepository>().resolveIncident(incidentId);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.isSuccess ? 'Incident marked as resolved' : (res.failure?.message ?? 'Action failed')),
        ),
      );
    }
  }

  Widget _buildMetaItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.sectionHeader.copyWith(
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.body.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _DiagonalStripeLargePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFF1E2632);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final linePaint = Paint()
      ..color = const Color(0xFF283445)
      ..strokeWidth = 3.5;

    for (double i = -size.height; i < size.width; i += 18) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MiniMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = const Color(0xFF2B3747)
      ..strokeWidth = 3.0;

    canvas.drawLine(Offset(0, size.height * 0.3), Offset(size.width, size.height * 0.7), roadPaint);
    canvas.drawLine(Offset(size.width * 0.2, 0), Offset(size.width * 0.8, size.height), roadPaint);

    final linePaint = Paint()
      ..color = const Color(0xFF202A38)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(0, size.height * 0.6), Offset(size.width, size.height * 0.4), linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
