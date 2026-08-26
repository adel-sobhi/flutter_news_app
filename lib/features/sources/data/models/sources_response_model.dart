import 'package:notes_app/features/sources/domain/entities/sources_response_entities.dart';


class SourcesResponseModel  extends SourcesResponseEntity {
  SourcesResponseModel({
    super.status,
    super.code,
    super.message,
    super.sources,
    super.isFromCache,});

  SourcesResponseModel.fromJson(dynamic json) {
    status = json['status'];
    code = json['code'];
    message = json['message'];
    if (json['sources'] != null) {
      sources = [];
      json['sources'].forEach((v) {
        sources?.add(SourceModel.fromJson(v));
      });
    }
  }

  /// Used to serialize the response so it can be stored locally with sqflite.
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'code': code,
      'message': message,
      'sources': sources?.map((s) => (s as SourceModel).toJson()).toList(),
    };
  }


}


class SourceModel extends SourcesEntity {
  SourceModel({
    super.id,
    super.name,
    super.description,
    super.url,
    super.category,
    super.language,
    super.country,});

  SourceModel.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    url = json['url'];
    category = json['category'];
    language = json['language'];
    country = json['country'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'url': url,
      'category': category,
      'language': language,
      'country': country,
    };
  }
}