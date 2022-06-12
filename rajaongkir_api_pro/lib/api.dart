import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:rajaongkir_api/env.dart';
import 'dart:convert';

class API{
  final String _url = apiUrl;
  final String _androidKey = androidKey;
  final String _iosKey = iosKey;
  final String _key = apiKey;

  _setHeaders(String _androidKey, String _iosKey, String _key) =>{
      'Content-type' : 'application/json',
      'Accept' : 'application/json',
      'android-key' : _androidKey,
      'ios-key' : _iosKey,
      'key' : _key
  };

  getProvince() async {
    final response = await http.get(Uri.parse("$_url/province"), headers: _setHeaders(_androidKey, _iosKey, _key));
    if(response.statusCode == 200) {
      var status = json.decode(response.body)['rajaongkir']['status'];
      if (status!['code'] != 200 && status!['description'] != "OK") {
        if (kDebugMode) {
          print("Error ${status!['code']}, ${status!['description']}");
        }
      }
    }else{
      if (kDebugMode) {
        print("Error code : ${response.statusCode}, while getting province API!");
      }
    }
    return response;
  }

  getCity(int _provId) async {
    String _query = "/city?province=$_provId";
    final response = await http.get(Uri.parse(_url+_query), headers: _setHeaders(_androidKey, _iosKey, _key));
    if(response.statusCode == 200) {
      var status = json.decode(response.body)['rajaongkir']['status'];
      if (status!['code'] != 200 && status!['description'] != "OK") {
        if (kDebugMode) {
          print("Error ${status!['code']}, ${status!['description']}");
        }
      }
    }else{
      if (kDebugMode) {
        print("Error code : ${response.statusCode}, while getting city API!");
      }
    }
    return response;
  }

  getSubdistrict(int _cityId) async {
    String _query = "/subdistrict?city=$_cityId";
    final response = await http.get(Uri.parse(_url+_query), headers: _setHeaders(_androidKey, _iosKey, _key));
    if(response.statusCode == 200) {
      var status = json.decode(response.body)['rajaongkir']['status'];
      if (status!['code'] != 200 && status!['description'] != "OK") {
        if (kDebugMode) {
          print("Error ${status!['code']}, ${status!['description']}");
        }
      }
    }else{
      if (kDebugMode) {
        print("Error code : ${response.statusCode}, while getting subdistrict API!");
      }
    }
    return response;
  }

  getEstimatedCost(int org, String orgTp, int des, String desTp, double weight, String courier) async {
    Map query = {
      "origin":org,
      "originType":orgTp,
      "destination":des,
      "destinationType":desTp,
      "weight":weight,
      "courier":courier
    };
    var bodyQuery = json.encode(query);
    final response = await http.post(Uri.parse("$_url/cost"), body: bodyQuery, headers: _setHeaders(_androidKey, _iosKey, _key));
    if(response.statusCode == 200) {
      var status = json.decode(response.body)['rajaongkir']['status'];
      if (status!['code'] != 200 && status!['description'] != "OK") {
        if (kDebugMode) {
          print("Error ${status!['code']}, ${status!['description']}");
        }
      }
    }else{
      if (kDebugMode) {
        print(response.body);
        print("Error code : ${response.statusCode}, while getting cost API!");
      }
    }
    return response;
  }

}