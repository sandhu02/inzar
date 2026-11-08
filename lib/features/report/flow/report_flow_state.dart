import 'package:equatable/equatable.dart';
import '../../../domain/entities/incident_category.dart';

enum SubmissionStep {
  uploadingPhoto,
  checkingReport,
  completed,
}

enum SubmissionOutcome {
  published,
  underReview,
  notApproved,
}

class ReportFlowState extends Equatable {
  final String? photoPath;
  final String photoTimestamp;
  final IncidentCategory selectedCategory;
  final String description;
  final String locationName;
  final String shownPrecision;
  final double latitude;
  final double longitude;
  final bool isSubmitting;
  final SubmissionStep currentStep;
  final SubmissionOutcome outcome;

  const ReportFlowState({
    this.photoPath,
    this.photoTimestamp = '',
    this.selectedCategory = IncidentCategory.fire,
    this.description = '',
    this.locationName = 'Current Location',
    this.shownPrecision = 'Shown publicly at ~200 m',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.isSubmitting = false,
    this.currentStep = SubmissionStep.checkingReport,
    this.outcome = SubmissionOutcome.published,
  });

  ReportFlowState copyWith({
    String? Function()? photoPath,
    String? photoTimestamp,
    IncidentCategory? selectedCategory,
    String? description,
    String? locationName,
    String? shownPrecision,
    double? latitude,
    double? longitude,
    bool? isSubmitting,
    SubmissionStep? currentStep,
    SubmissionOutcome? outcome,
  }) {
    return ReportFlowState(
      photoPath: photoPath != null ? photoPath() : this.photoPath,
      photoTimestamp: photoTimestamp ?? this.photoTimestamp,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      description: description ?? this.description,
      locationName: locationName ?? this.locationName,
      shownPrecision: shownPrecision ?? this.shownPrecision,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      currentStep: currentStep ?? this.currentStep,
      outcome: outcome ?? this.outcome,
    );
  }

  @override
  List<Object?> get props => [
        photoPath,
        photoTimestamp,
        selectedCategory,
        description,
        locationName,
        shownPrecision,
        latitude,
        longitude,
        isSubmitting,
        currentStep,
        outcome,
      ];
}
