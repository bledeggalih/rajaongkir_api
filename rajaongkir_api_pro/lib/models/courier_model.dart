import 'dart:convert';

CourierModel courierModelFromJson(String str) => CourierModel.fromJson(json.decode(str));

String courierModelToJson(CourierModel data) => json.encode(data.toJson());

class CourierModel {
  CourierModel({
    required this.name,
    required this.code,
  });

  String name;
  String code;

  factory CourierModel.fromJson(Map<String, dynamic> json) => CourierModel(
    name: json["name"],
    code: json["code"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "code": code,
  };
}