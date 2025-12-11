class OffersModel {
  final bool success;
  final String message;
  final List<OfferData> data;

  OffersModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory OffersModel.fromJson(Map<String, dynamic> json) {
    return OffersModel(
      success: json['success'],
      message: json['message'],
      data: List<OfferData>.from(json['data'].map((x) => OfferData.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((x) => x.toJson()).toList(),
    };
  }
}

class OfferData {
  final String id;
  final String title;
  final String description;
  final Operator operator;
  final String offerType;
  final num price;
  final num discountAmount;
  final num actualPrice;
  final num validity;
  final bool isActive;
  final String createdBy;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  OfferData({
    required this.id,
    required this.title,
    required this.description,
    required this.operator,
    required this.offerType,
    required this.price,
    required this.discountAmount,
    required this.actualPrice,
    required this.validity,
    required this.isActive,
    required this.createdBy,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OfferData.fromJson(Map<String, dynamic> json) {
    return OfferData(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      operator: Operator.fromJson(json['operator']),
      offerType: json['offerType'],
      price: json['price'],
      discountAmount: json['discountAmount'],
      actualPrice: json['actualPrice'],
      validity: json['validity'],
      isActive: json['isActive'],
      createdBy: json['createdBy'],
      isDeleted: json['isDeleted'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'operator': operator.toJson(),
      'offerType': offerType,
      'price': price,
      'discountAmount': discountAmount,
      'actualPrice': actualPrice,
      'validity': validity,
      'isActive': isActive,
      'createdBy': createdBy,
      'isDeleted': isDeleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class Operator {
  final String id;
  final String name;

  Operator({
    required this.id,
    required this.name,
  });

  factory Operator.fromJson(Map<String, dynamic> json) {
    return Operator(
      id: json['_id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
    };
  }
}
