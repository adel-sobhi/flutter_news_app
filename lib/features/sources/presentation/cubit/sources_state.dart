import '../../../../core/errors/errors.dart';
import '../../domain/entities/sources_response_entities.dart';

abstract class SourcesState {}

class SourcesInitial extends SourcesState {}

class SourcesLoading extends SourcesState {}

class SourcesError extends SourcesState {
  final Errors errorMessage;
  SourcesError({required this.errorMessage});
}

class SourcesSuccess extends SourcesState {
  final SourcesResponseEntity sourcesResponse;
  final int selectedIndex;

  SourcesSuccess({required this.sourcesResponse, this.selectedIndex = 0});
}