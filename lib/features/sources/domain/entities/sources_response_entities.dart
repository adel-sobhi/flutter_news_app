
class SourcesResponseEntity   {
  SourcesResponseEntity({
      this.status, 
      this.sources,
    this.code,
    this.message,
    this.isFromCache = false,
  });


  String? status;
  List<SourcesEntity>? sources;
  String? code;
  String? message;
  bool isFromCache;

}

class SourcesEntity {
  SourcesEntity({
      this.id, 
      this.name, 
      this.description, 
      this.url, 
      this.category, 
      this.language, 
      this.country,});

  String? id;
  String? name;
  String? description;
  String? url;
  String? category;
  String? language;
  String? country;


}