import 'dart:convert';

SubdistrictModel subdistrictModelFromJson(String str) => SubdistrictModel.fromJson(json.decode(str));

String subdistrictModelToJson(SubdistrictModel data) => json.encode(data.toJson());

class SubdistrictModel {
  SubdistrictModel({
    required this.subdistrictId,
    required this.provinceId,
    required this.province,
    required this.cityId,
    required this.city,
    required this.type,
    required this.subdistrictName,
  });

  String subdistrictId;
  String provinceId;
  String province;
  String cityId;
  String city;
  String type;
  String subdistrictName;

  factory SubdistrictModel.fromJson(Map<String, dynamic> json) => SubdistrictModel(
    subdistrictId: json["subdistrict_id"],
    provinceId: json["province_id"],
    province: json["province"],
    cityId: json["city_id"],
    city: json["city"],
    type: json["type"],
    subdistrictName: json["subdistrict_name"],
  );

  Map<String, dynamic> toJson() => {
    "subdistrict_id": subdistrictId,
    "province_id": provinceId,
    "province": province,
    "city_id": cityId,
    "city": city,
    "type": type,
    "subdistrict_name": subdistrictName,
  };
}
