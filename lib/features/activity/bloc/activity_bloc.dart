import 'package:flutter_bloc/flutter_bloc.dart';
import 'activity_event.dart';
import 'activity_state.dart';
import '../../../domain/entities/incident.dart';
import '../../../domain/entities/review_status.dart';
import '../../../domain/repositories/incident_repository.dart';

class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  final IIncidentRepository? incidentRepository;

  ActivityBloc({this.incidentRepository}) : super(const ActivityState()) {
    on<ActivityInitialized>(_onInitialized);
    on<ActivityFilterChanged>(_onFilterChanged);
  }

  Future<void> _onInitialized(ActivityInitialized event, Emitter<ActivityState> emit) async {
    List<Incident> list = [];
    if (incidentRepository != null) {
      final res = await incidentRepository!.getMyReports();
      if (res.isSuccess && res.data != null) {
        list = res.data!;
      }
    }

    emit(state.copyWith(
      allReports: list,
      filteredReports: list,
    ));
  }

  void _onFilterChanged(ActivityFilterChanged event, Emitter<ActivityState> emit) {
    List<Incident> filtered;
    switch (event.filter) {
      case ActivityFilter.all:
        filtered = state.allReports;
        break;
      case ActivityFilter.review:
        filtered = state.allReports.where((i) => i.reviewStatus == ReviewStatus.underReview).toList();
        break;
      case ActivityFilter.live:
        filtered = state.allReports.where((i) => i.reviewStatus == ReviewStatus.published || i.reviewStatus == ReviewStatus.aiReviewed).toList();
        break;
      case ActivityFilter.denied:
        filtered = state.allReports.where((i) => i.reviewStatus == ReviewStatus.notApproved).toList();
        break;
    }

    emit(state.copyWith(
      currentFilter: event.filter,
      filteredReports: filtered,
    ));
  }
}
