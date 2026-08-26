import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/get_sources_use_case.dart';
import 'sources_state.dart';

@injectable
class SourcesCubit extends Cubit<SourcesState> {
  final GetSourcesUseCase getSourcesUseCase;

  SourcesCubit(this.getSourcesUseCase) : super(SourcesInitial());

  void getSources(String categoryId) async {
    emit(SourcesLoading());

    var result = await getSourcesUseCase(categoryId);

    result.fold(
          (error) => emit(SourcesError(errorMessage: error)),
          (sourcesEntity) => emit(SourcesSuccess(
        sourcesResponse: sourcesEntity,
        selectedIndex: 0,
      )),
    );
  }

  void changeTabIndex(int newIndex) {
    var currentState = state;
    if (currentState is SourcesSuccess) {
      emit(SourcesSuccess(
        sourcesResponse: currentState.sourcesResponse,
        selectedIndex: newIndex,
      ));
    }
  }
}