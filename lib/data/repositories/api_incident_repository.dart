import '../../core/error/app_failure.dart';
import '../../core/error/result.dart';
import '../../core/storage/incident_media_cache.dart';
import '../../domain/entities/incident.dart';
import '../../domain/entities/report_draft.dart';
import '../../domain/entities/review_status.dart';
import '../../domain/repositories/incident_repository.dart';
import '../datasources/incident_remote_data_source.dart';
import '../datasources/media_remote_data_source.dart';
import '../datasources/category_remote_data_source.dart';

class ApiIncidentRepository implements IIncidentRepository {
  final IncidentRemoteDataSource _incidentDataSource;
  final MediaRemoteDataSource _mediaDataSource;
  final CategoryRemoteDataSource _categoryDataSource;

  final List<Incident> _recentIncidents = [];

  ApiIncidentRepository(
    this._incidentDataSource,
    this._mediaDataSource,
    this._categoryDataSource,
  );

  @override
  Future<Result<List<Incident>>> getNearbyIncidents({
    required double latitude,
    required double longitude,
    required int radiusKm,
    String? categoryId,
    bool clustered = false,
  }) async {
    final response = await _incidentDataSource.fetchNearbyIncidents(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
      categoryId: categoryId,
      clustered: clustered,
    );

    List<Incident> remoteList = [];
    if (response.isSuccess && response.data != null) {
      remoteList = response.data!;
    }

    final merged = <Incident>[];
    final ids = <String>{};

    for (final inc in _recentIncidents) {
      if (ids.add(inc.id)) {
        merged.add(inc);
      }
    }
    for (final inc in remoteList) {
      if (ids.add(inc.id)) {
        merged.add(inc);
      }
    }

    return Result.success(merged);
  }

  @override
  Future<Result<List<Incident>>> getViewportIncidents({
    required double minLat,
    required double minLon,
    required double maxLat,
    required double maxLon,
  }) async {
    final response = await _incidentDataSource.fetchViewportIncidents(
      minLat: minLat,
      minLon: minLon,
      maxLat: maxLat,
      maxLon: maxLon,
    );

    List<Incident> remoteList = [];
    if (response.isSuccess && response.data != null) {
      remoteList = response.data!;
    }

    final merged = <Incident>[];
    final ids = <String>{};

    for (final inc in _recentIncidents) {
      if (ids.add(inc.id)) {
        merged.add(inc);
      }
    }
    for (final inc in remoteList) {
      if (ids.add(inc.id)) {
        merged.add(inc);
      }
    }

    return Result.success(merged);
  }

  @override
  Future<Result<Incident>> getIncidentDetails(String id, {double? userLat, double? userLon}) async {
    final response = await _incidentDataSource.fetchIncidentDetails(
      id,
      userLat: userLat,
      userLon: userLon,
    );

    if (response.isSuccess && response.data != null) {
      var item = response.data!;
      final cachedPhoto = IncidentMediaCache.get(id);
      if ((item.photoUrl == null || item.photoUrl!.isEmpty) && cachedPhoto != null) {
        item = item.copyWith(photoUrl: cachedPhoto);
      }
      return Result.success(item);
    }

    // Check recent local incidents
    final localMatch = _recentIncidents.cast<Incident?>().firstWhere(
      (i) => i?.id == id,
      orElse: () => null,
    );
    if (localMatch != null) {
      return Result.success(localMatch);
    }

    return Result.failure(
      ServerFailure(response.error?.message ?? 'Incident not found'),
    );
  }

  @override
  Future<Result<List<Incident>>> getMyReports() async {
    final response = await _incidentDataSource.fetchMyIncidents();
    List<Incident> remoteList = [];
    if (response.isSuccess && response.data != null) {
      remoteList = response.data!;
    }

    final merged = <Incident>[];
    final ids = <String>{};

    for (final inc in _recentIncidents) {
      if (ids.add(inc.id)) {
        merged.add(inc);
      }
    }
    for (final inc in remoteList) {
      if (ids.add(inc.id)) {
        merged.add(inc);
      }
    }

    return Result.success(merged);
  }

  @override
  Future<Result<String>> submitIncidentReport({
    required ReportDraft draft,
    void Function(String step)? onProgress,
  }) async {
    onProgress?.call('Creating incident report...');

    String? categoryUuid;
    try {
      final catResponse = await _categoryDataSource.fetchCategories();
      if (catResponse.isSuccess && catResponse.data != null) {
        final match = catResponse.data!.firstWhere(
          (c) => c.slug.toLowerCase() == draft.category.id.toLowerCase(),
          orElse: () => catResponse.data!.first,
        );
        categoryUuid = match.id;
      }
    } catch (_) {}

    final createRes = await _incidentDataSource.createIncident(draft, categoryUuid: categoryUuid);
    if (!createRes.isSuccess || createRes.data == null) {
      return Result.failure(
        ServerFailure(createRes.error?.message ?? 'Failed to submit incident report'),
      );
    }

    final incidentId = createRes.data!['incident_id']?.toString() ??
        createRes.data!['id']?.toString() ??
        'inc_${DateTime.now().millisecondsSinceEpoch}';

    if (draft.photoPath != null) {
      IncidentMediaCache.set(incidentId, draft.photoPath!);
    }

    final uploadParams = createRes.data!['upload_params'] is Map<String, dynamic>
        ? createRes.data!['upload_params'] as Map<String, dynamic>
        : null;

    if (draft.photoPath != null && uploadParams != null) {
      onProgress?.call('Compressing incident photo...');
      final cdnResult = await _mediaDataSource.uploadToCloudinary(
        photoPath: draft.photoPath!,
        uploadParams: uploadParams,
        onProgress: onProgress,
      );

      if (cdnResult != null && cdnResult['secure_url'] != null) {
        final secureUrl = cdnResult['secure_url'].toString();
        IncidentMediaCache.set(incidentId, secureUrl);
        if (cdnResult['local_compressed_path'] != null) {
          IncidentMediaCache.set(incidentId, cdnResult['local_compressed_path'].toString());
        }

        onProgress?.call('Verifying and confirming media...');
        await _mediaDataSource.confirmMediaUpload(
          incidentId: incidentId,
          cloudinaryPublicId: cdnResult['public_id']?.toString() ?? uploadParams['public_id']?.toString() ?? '',
          secureUrl: secureUrl,
          width: (cdnResult['width'] as num?)?.toInt() ?? 1920,
          height: (cdnResult['height'] as num?)?.toInt() ?? 1080,
          bytes: (cdnResult['bytes'] as num?)?.toInt() ??
              (cdnResult['compressed_bytes'] as num?)?.toInt() ??
              250000,
          format: cdnResult['format']?.toString() ?? 'jpg',
        );
      }
    }

    final newIncident = Incident(
      id: incidentId,
      category: draft.category,
      categoryId: categoryUuid ?? draft.category.id,
      title: draft.description.length > 50
          ? '${draft.description.substring(0, 47)}...'
          : draft.description,
      description: draft.description,
      locationName: draft.locationName,
      areaCode: draft.locationName,
      distanceKm: 0.0,
      reportedTime: 'Just now',
      lastUpdateTime: 'Just now',
      status: 'Active',
      reviewStatus: ReviewStatus.aiReviewed,
      photoTimestamp: draft.photoTimestamp,
      latitude: draft.latitude,
      longitude: draft.longitude,
      photoUrl: draft.photoPath,
    );

    _recentIncidents.removeWhere((i) => i.id == incidentId);
    _recentIncidents.insert(0, newIncident);

    return Result.success(incidentId);
  }

  @override
  Future<Result<IncidentStatusResult>> checkIncidentStatus(String id) async {
    final response = await _incidentDataSource.fetchIncidentStatus(id);
    if (response.isSuccess && response.data != null) {
      return Result.success(response.data!);
    }

    return Result.failure(
      ServerFailure(response.error?.message ?? 'Failed to check incident status'),
    );
  }

  @override
  Future<Result<void>> flagIncident({
    required String id,
    required String type,
    String? note,
  }) async {
    final response = await _incidentDataSource.flagIncident(id: id, type: type, note: note);
    if (response.isSuccess) {
      return const Result.success(null);
    }
    return Result.failure(
      ServerFailure(response.error?.message ?? 'Failed to flag incident'),
    );
  }

  @override
  Future<Result<void>> resolveIncident(String id) async {
    final response = await _incidentDataSource.resolveIncident(id);
    if (response.isSuccess) {
      return const Result.success(null);
    }
    return Result.failure(
      ServerFailure(response.error?.message ?? 'Failed to mark incident resolved'),
    );
  }
}
