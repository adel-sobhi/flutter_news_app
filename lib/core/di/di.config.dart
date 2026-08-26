// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/authentication/data/datasources/auth_local_datasource/auth_local_datasource.dart'
    as _i117;
import '../../features/authentication/data/datasources/auth_local_datasource/auth_local_datasource_impl.dart'
    as _i772;
import '../../features/authentication/data/datasources/auth_remote_datasource/auth_remote_datasource.dart'
    as _i755;
import '../../features/authentication/data/datasources/auth_remote_datasource/auth_remote_datasource_impl.dart'
    as _i998;
import '../../features/authentication/data/repositories/auth_repository_impl.dart'
    as _i317;
import '../../features/authentication/domain/repositories/auth_repository.dart'
    as _i742;
import '../../features/authentication/domain/usecases/check_auth_status_use_case.dart'
    as _i31;
import '../../features/authentication/domain/usecases/login_use_case.dart'
    as _i938;
import '../../features/authentication/domain/usecases/logout_use_case.dart'
    as _i694;
import '../../features/authentication/domain/usecases/register_use_case.dart'
    as _i377;
import '../../features/authentication/presentation/cubit/auth_cubit.dart'
    as _i678;
import '../../features/news/data/datasources/news_local_datasource/news_local_datasource.dart'
    as _i623;
import '../../features/news/data/datasources/news_local_datasource/news_local_datasource_impl.dart'
    as _i132;
import '../../features/news/data/datasources/news_remote_datasource/news_remote_datasource.dart'
    as _i989;
import '../../features/news/data/datasources/news_remote_datasource/news_remote_datasource_impl.dart'
    as _i660;
import '../../features/news/data/repositories/news_repository_impl.dart'
    as _i164;
import '../../features/news/domain/repositories/news_repository.dart' as _i258;
import '../../features/news/domain/usecases/get_news_use_case.dart' as _i147;
import '../../features/news/presentation/cubit/news_cubit.dart' as _i766;
import '../../features/sources/data/datasources/sources_local_datasource/sources_local_datasource.dart'
    as _i641;
import '../../features/sources/data/datasources/sources_local_datasource/sources_local_datasource_impl.dart'
    as _i478;
import '../../features/sources/data/datasources/sources_remote_datasource/sources_remote_datasource.dart'
    as _i601;
import '../../features/sources/data/datasources/sources_remote_datasource/sources_remote_datasource_impl.dart'
    as _i566;
import '../../features/sources/data/repositories/sources_repository_impl.dart'
    as _i243;
import '../../features/sources/domain/repositories/sources_repository.dart'
    as _i940;
import '../../features/sources/domain/usecases/get_sources_use_case.dart'
    as _i851;
import '../../features/sources/presentation/cubit/sources_cubit.dart' as _i910;
import '../api/Api_manager.dart' as _i571;
import 'secure_storage_module.dart' as _i897;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final secureStorageModule = _$SecureStorageModule();
    gh.singleton<_i571.ApiManager>(() => _i571.ApiManager());
    gh.lazySingleton<_i558.FlutterSecureStorage>(
        () => secureStorageModule.secureStorage);
    gh.factory<_i641.SourcesLocalDatasource>(
        () => _i478.SourcesLocalDatasourceImpl());
    gh.factory<_i623.NewsLocalDatasource>(
        () => _i132.NewsLocalDatasourceImpl());
    gh.factory<_i601.SourcesRemoteDatasource>(() =>
        _i566.SourcesRemoteDatasourceImpl(apiManager: gh<_i571.ApiManager>()));
    gh.factory<_i755.AuthRemoteDataSource>(() =>
        _i998.AuthRemoteDataSourceImpl(apiManager: gh<_i571.ApiManager>()));
    gh.factory<_i989.NewsRemoteDatasource>(() =>
        _i660.NewsRemoteDatasourceImpl(apiManager: gh<_i571.ApiManager>()));
    gh.factory<_i258.NewsRepository>(() => _i164.NewsRepositoryImpl(
          remoteDatasource: gh<_i989.NewsRemoteDatasource>(),
          localDatasource: gh<_i623.NewsLocalDatasource>(),
        ));
    gh.factory<_i117.AuthLocalDataSource>(
        () => _i772.AuthLocalDataSourceImpl(gh<_i558.FlutterSecureStorage>()));
    gh.factory<_i940.SourcesRepository>(() => _i243.SourcesRepositoryImpl(
          remoteDatasource: gh<_i601.SourcesRemoteDatasource>(),
          localDatasource: gh<_i641.SourcesLocalDatasource>(),
        ));
    gh.factory<_i742.AuthRepository>(() => _i317.AuthRepositoryImpl(
          gh<_i755.AuthRemoteDataSource>(),
          gh<_i117.AuthLocalDataSource>(),
        ));
    gh.factory<_i31.CheckAuthStatusUseCase>(
        () => _i31.CheckAuthStatusUseCase(gh<_i742.AuthRepository>()));
    gh.factory<_i938.LoginUseCase>(
        () => _i938.LoginUseCase(gh<_i742.AuthRepository>()));
    gh.factory<_i694.LogoutUseCase>(
        () => _i694.LogoutUseCase(gh<_i742.AuthRepository>()));
    gh.factory<_i377.RegisterUseCase>(
        () => _i377.RegisterUseCase(gh<_i742.AuthRepository>()));
    gh.factory<_i147.GetNewsUseCase>(
        () => _i147.GetNewsUseCase(gh<_i258.NewsRepository>()));
    gh.factory<_i766.NewsCubit>(
        () => _i766.NewsCubit(gh<_i147.GetNewsUseCase>()));
    gh.factory<_i851.GetSourcesUseCase>(
        () => _i851.GetSourcesUseCase(gh<_i940.SourcesRepository>()));
    gh.factory<_i678.AuthCubit>(() => _i678.AuthCubit(
          gh<_i938.LoginUseCase>(),
          gh<_i377.RegisterUseCase>(),
          gh<_i31.CheckAuthStatusUseCase>(),
          gh<_i694.LogoutUseCase>(),
        ));
    gh.factory<_i910.SourcesCubit>(
        () => _i910.SourcesCubit(gh<_i851.GetSourcesUseCase>()));
    return this;
  }
}

class _$SecureStorageModule extends _i897.SecureStorageModule {}
