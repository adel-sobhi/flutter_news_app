import '../../../sources/data/models/sources_response_model.dart';
import '../../domain/entities/news_response_entities.dart';

class NewsResponseModel extends NewsResponseEntity {
  NewsResponseModel({
    super.status,
    super.totalResults,
    super.articles,
    super.code,
    super.message,
    super.isFromCache,
  });

  factory NewsResponseModel.fromJson(Map<String, dynamic> json) {
    return NewsResponseModel(
      status: json['status'],
      totalResults: json['totalResults'],
      code: json['code'],
      message: json['message'],
      articles: json['articles'] != null
          ? (json['articles'] as List)
          .map((article) => NewsModel.fromJson(article))
          .toList()
          : null,
    );
  }

  /// Used to serialize the response so it can be stored locally with sqflite.
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'totalResults': totalResults,
      'code': code,
      'message': message,
      'articles': articles
          ?.map((article) => (article as NewsModel).toJson())
          .toList(),
    };
  }
}

class NewsModel extends NewsEntity {
  NewsModel({
    super.source,
    super.author,
    super.title,
    super.description,
    super.url,
    super.urlToImage,
    super.publishedAt,
    super.content,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      source: json['source'] != null ? SourceModel.fromJson(json['source']) : null,
      author: json['author'],
      title: json['title'],
      description: json['description'],
      url: json['url'],
      urlToImage: json['urlToImage'],
      publishedAt: json['publishedAt'],
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'source': source != null ? (source as SourceModel).toJson() : null,
      'author': author,
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': urlToImage,
      'publishedAt': publishedAt,
      'content': content,
    };
  }
}

