class IncidentMediaCache {
  IncidentMediaCache._();

  static final Map<String, String> _cache = {};
  static String? _lastCapturedPhoto;

  /// Associates an incident ID with a local photo path or remote URL.
  static void set(String incidentId, String pathOrUrl) {
    if (incidentId.isNotEmpty && pathOrUrl.isNotEmpty) {
      _cache[incidentId] = pathOrUrl;
    }
  }

  /// Retrieves the cached photo path or URL for the given incident ID.
  static String? get(String incidentId) {
    return _cache[incidentId] ?? _lastCapturedPhoto;
  }

  /// Caches the most recently captured photo file path.
  static void setLastCaptured(String path) {
    _lastCapturedPhoto = path;
  }

  /// Gets the most recently captured photo file path.
  static String? getLastCaptured() => _lastCapturedPhoto;

  /// Clears cache.
  static void clear() {
    _cache.clear();
    _lastCapturedPhoto = null;
  }
}

