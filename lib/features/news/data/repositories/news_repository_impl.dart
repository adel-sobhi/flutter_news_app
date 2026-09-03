import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/errors.dart';
import '../../domain/entities/news_response_entities.dart';
import '../../domain/repositories/news_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../datasources/news_local_datasource/news_local_datasource.dart';
import '../datasources/news_remote_datasource/news_remote_datasource.dart';

@Injectable(as: NewsRepository)
class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDatasource remoteDatasource;
  final NewsLocalDatasource localDatasource;

  NewsRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
  });

  @override
  Future<Either<Errors, NewsResponseEntity>> getNews(String sourceId, {int page = 1}) async {
    var either = await remoteDatasource.getNews(sourceId, page: page);

    return either.fold(
      (error) async {
        try {
          final cachedNews = await localDatasource.getCachedNews(sourceId);
          if (cachedNews != null) {
            return Right(cachedNews);
          }
        } catch (_) {
          //نتجاهل أي خطأ ثانوي (زي فشل التخزين المؤقت) وما نخليهوش يوقف التطبيق أو يأثر على تجربة المستخدم الأساسية.

        }
        return Left(error);
      },
      (responseModel) async {

        if (page == 1) {
          try {
            await localDatasource.cacheNews(sourceId, responseModel);
          } catch (_) {
          }

          // Store the latest (first) article in Firestore so the app or notifications
          // can reliably open the exact article later. This is best-effort and
          // must not break the main flow.
          try {
            final articles = responseModel.articles ?? [];
            if (articles.isNotEmpty) {
              final first = articles[0];
              final docRef = FirebaseFirestore.instance
                  .collection('latest_articles')
                  .doc(sourceId);

              await docRef.set({
                'title': first.title,
                'url': first.url,
                'author': first.author,
                'description': first.description,
                'urlToImage': first.urlToImage,
                'publishedAt': first.publishedAt,
                'source': {
                  'id': first.source?.id,
                  'name': first.source?.name,
                },
                'updated_at': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));
            }
          } catch (_) {
            // Ignore Firestore errors to avoid impacting user flow
          }
        }
        return Right(responseModel);
      },
    );
  }
}
