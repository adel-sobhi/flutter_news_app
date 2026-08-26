import '../../../sources/domain/entities/sources_response_entities.dart';

class NewsResponseEntity {
  NewsResponseEntity({
      this.status, 
      this.totalResults, 
      this.articles,
      this.code,
      this.message,
      this.isFromCache = false,
  });

  String? status;
  num? totalResults;
  String? code;
  String? message;
  List<NewsEntity>? articles;


  bool isFromCache;


}

class NewsEntity {
  NewsEntity({
      this.source, 
      this.author, 
      this.title, 
      this.description, 
      this.url, 
      this.urlToImage, 
      this.publishedAt, 
      this.content,});

  SourcesEntity? source;
  String? author;
  String? title;
  String? description;
  String? url;
  String? urlToImage;
  String? publishedAt;
  String? content;


}

