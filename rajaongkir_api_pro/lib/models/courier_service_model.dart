import 'dart:convert';

CourierServiceModel courierServiceModelFromJson(String str) => CourierServiceModel.fromJson(json.decode(str));

String courierServiceModelToJson(CourierServiceModel data) => json.encode(data.toJson());

class CourierServiceModel {
  CourierServiceModel({
    required this.service,
    required this.description,
    required this.cost,
  });

  String service;
  String description;
  List<Cost> cost;

  factory CourierServiceModel.fromJson(Map<String, dynamic> json) => CourierServiceModel(
    service: json["service"],
    description: json["description"],
    cost: List<Cost>.from(json["cost"].map((x) => Cost.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "service": service,
    "description": description,
    "cost": List<dynamic>.from(cost.map((x) => x.toJson())),
  };
}

class Cost {
  Cost({
    required this.value,
    required this.etd,
    required this.note,
  });

  int value;
  String etd;
  String note;

  factory Cost.fromJson(Map<String, dynamic> json) => Cost(
    value: json["value"],
    etd: json["etd"],
    note: json["note"],
  );

  Map<String, dynamic> toJson() => {
    "value": value,
    "etd": etd,
    "note": note,
  };
}