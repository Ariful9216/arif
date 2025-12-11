class CategoryModel {
  final bool success;
  final String message;
  final List<CategoryData> data;

  CategoryModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      data: (json["data"] as List<dynamic>?)
          ?.map((item) => CategoryData.fromJson(item))
          .toList() ?? [],
    );
  }
}

class CategoryData {
  final String id;
  final String name;
  final String description;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  CategoryData({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(
      id: json["_id"] ?? "",
      name: json["name"] ?? "",
      description: json["description"] ?? "",
      isActive: json["isActive"] ?? false,
      createdAt: json["createdAt"] ?? "",
      updatedAt: json["updatedAt"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "description": description,
      "isActive": isActive,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
    };
  }
}