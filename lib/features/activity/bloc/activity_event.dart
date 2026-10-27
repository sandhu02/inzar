import 'package:equatable/equatable.dart';

enum ActivityFilter {
  all('All'),
  review('Review'),
  live('Live'),
  denied('Denied');

  const ActivityFilter(this.label);
  final String label;
}

abstract class ActivityEvent extends Equatable {
  const ActivityEvent();

  @override
  List<Object?> get props => [];
}

class ActivityInitialized extends ActivityEvent {
  const ActivityInitialized();
}

class ActivityFilterChanged extends ActivityEvent {
  final ActivityFilter filter;
  const ActivityFilterChanged(this.filter);

  @override
  List<Object?> get props => [filter];
}

