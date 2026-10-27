import 'package:equatable/equatable.dart';
import '../../../domain/entities/incident.dart';
import 'activity_event.dart';

class ActivityState extends Equatable {
  final ActivityFilter currentFilter;
  final List<Incident> allReports;
  final List<Incident> filteredReports;
  final bool isLoading;

  const ActivityState({
    this.currentFilter = ActivityFilter.all,
    this.allReports = const [],
    this.filteredReports = const [],
    this.isLoading = false,
  });

  ActivityState copyWith({
    ActivityFilter? currentFilter,
    List<Incident>? allReports,
    List<Incident>? filteredReports,
    bool? isLoading,
  }) {
    return ActivityState(
      currentFilter: currentFilter ?? this.currentFilter,
      allReports: allReports ?? this.allReports,
      filteredReports: filteredReports ?? this.filteredReports,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [currentFilter, allReports, filteredReports, isLoading];
}

