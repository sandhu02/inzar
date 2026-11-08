import '../../core/error/result.dart';
import '../../domain/entities/incident_category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_data_source.dart';

class ApiCategoryRepository implements ICategoryRepository {
  final CategoryRemoteDataSource _dataSource;
  List<CategoryData>? _cachedCategories;

  ApiCategoryRepository(this._dataSource);

  @override
  Future<Result<List<CategoryData>>> getCategories() async {
    if (_cachedCategories != null && _cachedCategories!.isNotEmpty) {
      return Result.success(_cachedCategories!);
    }

    final response = await _dataSource.fetchCategories();
    if (response.isSuccess && response.data != null && response.data!.isNotEmpty) {
      _cachedCategories = response.data!;
      return Result.success(response.data!);
    }

    // Default built-in categories matching Section 5.2
    final defaultCategories = [
      const CategoryData(
        id: 'cat_fire',
        slug: 'fire',
        name: 'Fire',
        iconKey: 'flame',
        colorHex: '#EF4444',
        sortOrder: 1,
        urgency: 'high',
        safetyNote: 'Keep a safe distance and do not obstruct emergency responders.',
      ),
      const CategoryData(
        id: 'cat_accident',
        slug: 'accident',
        name: 'Traffic Accident',
        iconKey: 'car-crash',
        colorHex: '#F97316',
        sortOrder: 2,
        urgency: 'routine',
        safetyNote: 'Do not stop on active highways. Watch for oncoming traffic.',
      ),
      const CategoryData(
        id: 'cat_roadblock',
        slug: 'road_block',
        name: 'Road block',
        iconKey: 'barrier',
        colorHex: '#CFD8DC',
        sortOrder: 3,
        urgency: 'routine',
      ),
      const CategoryData(
        id: 'cat_flooding',
        slug: 'flooding',
        name: 'Flooding',
        iconKey: 'waves',
        colorHex: '#42A5F5',
        sortOrder: 4,
        urgency: 'high',
      ),
      const CategoryData(
        id: 'cat_gathering',
        slug: 'gathering',
        name: 'Gathering',
        iconKey: 'people',
        colorHex: '#AB47BC',
        sortOrder: 5,
        urgency: 'routine',
      ),
      const CategoryData(
        id: 'cat_other',
        slug: 'other',
        name: 'Other',
        iconKey: 'warning',
        colorHex: '#90A4AE',
        sortOrder: 6,
        urgency: 'routine',
      ),
    ];

    _cachedCategories = defaultCategories;
    return Result.success(defaultCategories);
  }
}

