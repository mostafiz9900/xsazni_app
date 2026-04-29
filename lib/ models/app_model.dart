class AppModel {
  final String id;
  final String name;
  final String url;
  final String icon;
  final DateTime createdAt;
  
  AppModel({
    required this.id,
    required this.name,
    required this.url,
    this.icon = '🌐',
    required this.createdAt,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'icon': icon,
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  factory AppModel.fromJson(Map<String, dynamic> json) {
    return AppModel(
      id: json['id'],
      name: json['name'],
      url: json['url'],
      icon: json['icon'] ?? '🌐',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
  
  AppModel copyWith({
    String? id,
    String? name,
    String? url,
    String? icon,
    DateTime? createdAt,
  }) {
    return AppModel(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}