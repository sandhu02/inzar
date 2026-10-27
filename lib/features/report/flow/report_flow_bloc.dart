import 'package:flutter_bloc/flutter_bloc.dart';
import 'report_flow_event.dart';
import 'report_flow_state.dart';

class ReportFlowBloc extends Bloc<ReportFlowEvent, ReportFlowState> {
  ReportFlowBloc() : super(const ReportFlowState()) {
    on<PhotoCaptured>(_onPhotoCaptured);
    on<CategorySelected>(_onCategorySelected);
    on<DescriptionChanged>(_onDescriptionChanged);
    on<LocationAdjusted>(_onLocationAdjusted);
    on<ReportSubmitted>(_onReportSubmitted);
    on<RetakePhotoRequested>(_onRetakePhotoRequested);
    on<ResetReportFlow>(_onReset);
  }

  void _onPhotoCaptured(PhotoCaptured event, Emitter<ReportFlowState> emit) {
    emit(state.copyWith(
      photoPath: () => event.photoPath,
      photoTimestamp: event.timestamp,
    ));
  }

  void _onCategorySelected(CategorySelected event, Emitter<ReportFlowState> emit) {
    emit(state.copyWith(selectedCategory: event.category));
  }

  void _onDescriptionChanged(DescriptionChanged event, Emitter<ReportFlowState> emit) {
    emit(state.copyWith(description: event.description));
  }

  void _onLocationAdjusted(LocationAdjusted event, Emitter<ReportFlowState> emit) {
    emit(state.copyWith(
      locationName: event.locationName,
      shownPrecision: event.shownPrecision,
    ));
  }

  Future<void> _onReportSubmitted(ReportSubmitted event, Emitter<ReportFlowState> emit) async {
    emit(state.copyWith(
      isSubmitting: true,
      currentStep: SubmissionStep.uploadingPhoto,
    ));

    await Future.delayed(const Duration(milliseconds: 600));
    emit(state.copyWith(currentStep: SubmissionStep.checkingReport));

    await Future.delayed(const Duration(milliseconds: 800));
    emit(state.copyWith(
      currentStep: SubmissionStep.completed,
      isSubmitting: false,
      outcome: SubmissionOutcome.published,
    ));
  }

  void _onRetakePhotoRequested(RetakePhotoRequested event, Emitter<ReportFlowState> emit) {
    emit(state.copyWith(photoPath: () => null));
  }

  void _onReset(ResetReportFlow event, Emitter<ReportFlowState> emit) {
    emit(const ReportFlowState());
  }
}
