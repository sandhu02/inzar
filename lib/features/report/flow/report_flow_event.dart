import 'package:equatable/equatable.dart';
import '../../../domain/entities/incident_category.dart';

abstract class ReportFlowEvent extends Equatable {
  const ReportFlowEvent();

  @override
  List<Object?> get props => [];
}

class PhotoCaptured extends ReportFlowEvent {
  final String photoPath;
  final String timestamp;

  const PhotoCaptured({required this.photoPath, required this.timestamp});

  @override
  List<Object?> get props => [photoPath, timestamp];
}

class CategorySelected extends ReportFlowEvent {
  final IncidentCategory category;
  const CategorySelected(this.category);

  @override
  List<Object?> get props => [category];
}

class DescriptionChanged extends ReportFlowEvent {
  final String description;
  const DescriptionChanged(this.description);

  @override
  List<Object?> get props => [description];
}

class LocationAdjusted extends ReportFlowEvent {
  final String locationName;
  final String shownPrecision;
  const LocationAdjusted({required this.locationName, required this.shownPrecision});

  @override
  List<Object?> get props => [locationName, shownPrecision];
}

class ReportSubmitted extends ReportFlowEvent {
  const ReportSubmitted();
}

class RetakePhotoRequested extends ReportFlowEvent {
  const RetakePhotoRequested();
}

class ResetReportFlow extends ReportFlowEvent {
  const ResetReportFlow();
}

