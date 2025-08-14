class ImageModel {
  final int id;
  final String imageUrl;
  final int? category; // Nullable
  final int? subcategory; // Nullable
  final int? user; // Nullable

  ImageModel({
    required this.id,
    required this.imageUrl,
    this.category,
    this.subcategory,
    this.user,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      id: json['id'] as int,
      imageUrl: json['image'] ?? '',
      category: json['category'] as int?, // safe cast
      subcategory: json['subcategory'] as int?,
      user: json['user'] as int?,
    );
  }
}
