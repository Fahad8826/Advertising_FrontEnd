class ImageModel {
  final int id;
  final String imageUrl;
  final String? category; // Nullable
  final String? subcategory; // Nullable
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
      category: json['category_name'] ?? '', // safe cast
      subcategory: json['subcategory_name'] ?? '', // safe cast
      user: json['user'] as int?,
    );
  }
}
