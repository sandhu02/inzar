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
  final bool isSubmitting;
  final SubmissionStep currentStep;
  final SubmissionOutcome outcome;

  const ReportFlowState({
    this.photoPath,
    this.photoTimestamp = '14:22',
    this.selectedCategory = IncidentCategory.fire,
    this.description = 'Brush fire on the slope above Trail 4, smoke drifting toward the road. No people nearby.',
    this.locationName = 'Near Trail 4, Margalla Rd',
    this.shownPrecision = 'Shown publicly at ~200 m',
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
        isSubmitting,
        currentStep,
        outcome,
      ];
}
