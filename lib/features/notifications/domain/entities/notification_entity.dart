class NotificationEntity {
  final String id;
  final String title;
  final String body;
  final String? url;
  final String? imageUrl;
  final String? sourceId;
  final String? categoryId;
  final String? author;
  final String? publishedAt;
  final String? description;
  final String? content;
  final bool isRead;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    this.url,
    this.imageUrl,
    this.sourceId,
    this.categoryId,
    this.author,
    this.publishedAt,
    this.description,
    this.content,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationEntity.fromJson(Map<String, dynamic> json) {
    final isReadValue = json['isRead'];
    return NotificationEntity(
      id: json['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title']?.toString() ?? 'Breaking News',
      body: json['body']?.toString() ?? '',
      url: json['url']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      sourceId: json['sourceId']?.toString() ?? json['source_id']?.toString(),
      categoryId:
          json['categoryId']?.toString() ?? json['category_id']?.toString(),
      author: json['author']?.toString(),
      publishedAt: json['publishedAt']?.toString(),
      description: json['description']?.toString(),
      content: json['content']?.toString(),
      isRead: isReadValue == true || isReadValue == 1,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'url': url,
      'imageUrl': imageUrl,
      'sourceId': sourceId,
      'categoryId': categoryId,
      'author': author,
      'publishedAt': publishedAt,
      'description': description,
      'content': content,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
