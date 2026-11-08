import 'package:equatable/equatable.dart';

class AppPublicConfig extends Equatable {
  final int maxSearchRadiusKm;
  final List<int> allowedRadiusOptionsKm;
  final int maxDescriptionLength;
  final int fuzzDistanceM;

  const AppPublicConfig({
    this.maxSearchRadiusKm = 50,
    this.allowedRadiusOptionsKm = const [1, 3, 5, 10, 25, 50],
    this.maxDescriptionLength = 1000,
    this.fuzzDistanceM = 200,
  });

  @override
  List<Object?> get props => [
        maxSearchRadiusKm,
        allowedRadiusOptionsKm,
        maxDescriptionLength,
        fuzzDistanceM,
      ];
}

