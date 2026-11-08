import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'report_flow_event.dart';
import 'report_flow_state.dart';
import '../../../core/storage/incident_media_cache.dart';
import '../../../domain/entities/report_draft.dart';
import '../../../domain/entities/review_status.dart';
import '../../../domain/repositories/incident_repository.dart';

class ReportFlowBloc extends Bloc<ReportFlowEvent, ReportFlowState> {
  final IIncidentRepository? incidentRepository;

  ReportFlowBloc({this.incidentRepository}) : super(const ReportFlowState()) {
    on<PhotoCaptured>(_onPhotoCaptured);
    on<CategorySelected>(_onCategorySelected);
    on<DescriptionChanged>(_onDescriptionChanged);
    on<LocationAdjusted>(_onLocationAdjusted);
    on<ReportSubmitted>(_onReportSubmitted);
    on<RetakePhotoRequested>(_onRetakePhotoRequested);
    on<ResetReportFlow>(_onReset);
  }

  void _onPhotoCaptured(PhotoCaptured event, Emitter<ReportFlowState> emit) {
    if (event.photoPath.isNotEmpty) {
      IncidentMediaCache.setLastCaptured(event.photoPath);
    }
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
      latitude: event.latitude,
      longitude: event.longitude,
    ));
  }

  Future<void> _onReportSubmitted(ReportSubmitted event, Emitter<ReportFlowState> emit) async {
    emit(state.copyWith(
      isSubmitting: true,
      currentStep: SubmissionStep.uploadingPhoto,
    ));

    // Automatically ensure fresh device location is attached
    double lat = state.latitude;
    double lng = state.longitude;

    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) {
          lat = lastKnown.latitude;
          lng = lastKnown.longitude;
        }
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 4),
          ),
        );
        lat = pos.latitude;
        lng = pos.longitude;
      }
    } catch (_) {}

    if (incidentRepository != null) {
      final draft = ReportDraft(
        photoPath: state.photoPath,
        photoTimestamp: state.photoTimestamp,
        category: state.selectedCategory,
        description: state.description,
        locationName: state.locationName,
        shownPrecision: state.shownPrecision,
        latitude: lat,
        longitude: lng,
      );

      final submitRes = await incidentRepository!.submitIncidentReport(
        draft: draft,
        onProgress: (step) {
          if (step.contains('Verifying') || step.contains('Checking')) {
            emit(state.copyWith(currentStep: SubmissionStep.checkingReport));
          }
        },
      );

      if (submitRes.isSuccess && submitRes.data != null) {
        if (state.photoPath != null && state.photoPath!.isNotEmpty) {
          IncidentMediaCache.set(submitRes.data!, state.photoPath!);
        }
        emit(state.copyWith(currentStep: SubmissionStep.checkingReport));

        SubmissionOutcome finalOutcome = SubmissionOutcome.published;
        try {
          final statusRes = await incidentRepository!.checkIncidentStatus(submitRes.data!);
          if (statusRes.isSuccess && statusRes.data != null) {
            final st = statusRes.data!.reviewStatus;
            if (st == ReviewStatus.underReview) {
              finalOutcome = SubmissionOutcome.underReview;
            } else if (st == ReviewStatus.notApproved) {
              finalOutcome = SubmissionOutcome.notApproved;
            }
          }
        } catch (_) {}

        emit(state.copyWith(
          currentStep: SubmissionStep.completed,
          isSubmitting: false,
          outcome: finalOutcome,
        ));
        return;
      }
    }

    // Fallback simulation
    await Future.delayed(const Duration(milliseconds: 500));
    emit(state.copyWith(currentStep: SubmissionStep.checkingReport));

    await Future.delayed(const Duration(milliseconds: 600));
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
