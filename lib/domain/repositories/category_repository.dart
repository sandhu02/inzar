import '../../core/error/result.dart';
import '../entities/incident_category.dart';

abstract class ICategoryRepository {
  Future<Result<List<CategoryData>>> getCategories();
}

