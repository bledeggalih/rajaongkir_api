import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rajaongkir_api/api.dart';
import 'package:rajaongkir_api/models/city_model.dart';
import 'package:rajaongkir_api/models/courier_model.dart';
import 'package:rajaongkir_api/models/province_model.dart';
import 'package:rajaongkir_api/models/courier_service_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rajaongkir API',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF9B59BB),
        primarySwatch: buildMaterialColor(const Color(0xFF9B59BB))
      ),
      home: const MyHomePage(title: 'Flutter Rajaongkir API'),
    );
  }
}

MaterialColor buildMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final formatCurrency = NumberFormat.currency(locale: "id_ID", symbol: "Rp.", decimalDigits: 0);

  bool _loadProv = false;
  bool _loadCity = false;
  bool _loadSubs = false;

  final List<CourierModel> _courierLists = [
    CourierModel(
      name: "JNE",
      code: "jne"
    ),
    CourierModel(
      name: "POS Indonesia",
      code: "pos"
    ),
    CourierModel(
      name: "TIKI",
      code: "tiki"
    ),
  ];

  List<CourierServiceModel> _courierServiceLists = [];

  List<ProvinceModel> _originProvinceLists = [];
  List<CityModel> _originCityLists = [];
  List<ProvinceModel> _destinationProvinceLists = [];
  List<CityModel> _destinationCityLists = [];

  ProvinceModel? _originProvinceAddress;
  CityModel? _originCityAddress;
  ProvinceModel? _destinationProvinceAddress;
  CityModel? _destinationCityAddress;

  CourierModel? _choosedCourier;
  CourierServiceModel? _choosedCourierService;

  String? _originAddress = "";
  String? _destinationAddress = "";

  final TextEditingController _weight = TextEditingController();

  _showMsg(msg) {
    final snackBar = SnackBar(
      backgroundColor: Colors.grey,
      content: Text(
        msg,
        style: const TextStyle(
            color: Colors.black
        ),
      ),
      action: SnackBarAction(
        label: 'Close',
        textColor: Colors.black,
        onPressed: () {
          // Some code to undo the change!
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  _getProvince(String type) async {
    setState((){
      _loadProv = true;
    });
    type == "origin" ? _originProvinceLists.clear() : _destinationProvinceLists.clear();
    final response = await API().getProvince();
    if(response.statusCode == 200){
      final status = json.decode(response.body)['rajaongkir']['status'];
      if (status!['code'] == 200 && status!['description'] == "OK") {
        final data = json.decode(response.body);
        setState(() {
          for (Map<String, dynamic> i in data!['rajaongkir']['results']) {
            if (kDebugMode) {
              print('Data on map i = $i');
            }
            type == "origin"
              ? _originProvinceLists.add(ProvinceModel.fromJson(i))
              : _destinationProvinceLists.add(ProvinceModel.fromJson(i));
          }
        });
      }else{
        _showMsg("${status!['code']}, ${status!['description']}");
      }
    }else{
      _showMsg("Error ${response.statusCode} while get Province data!");
    }
    setState((){
      _loadProv = false;
    });
  }

  _getCity(String type, int provId) async {
    setState(() {
      _loadCity = true;
    });
    type == "origin" ? _originCityLists.clear() : _destinationCityLists.clear();
    final response = await API().getCity(provId);
    if(response.statusCode == 200){
      final status = json.decode(response.body)['rajaongkir']['status'];
      if (status!['code'] == 200 && status!['description'] == "OK") {
        final data = json.decode(response.body);
        setState(() {
          for (Map<String, dynamic> i in data!['rajaongkir']['results']) {
            if (kDebugMode) {
              print('Data on map i = $i');
            }
            type == "origin"
                ? _originCityLists.add(CityModel.fromJson(i))
                : _destinationCityLists.add(CityModel.fromJson(i));
          }
        });
      }else{
        _showMsg("${status!['code']}, ${status!['description']}");
      }
    }else{
      _showMsg("Error ${response.statusCode} while get City data!");
    }
    setState(() {
      _loadCity = false;
    });
  }

  _countShippingCost(int org, int des, double weight, String courier) async {
    _courierServiceLists.clear();
    final response = await API().getEstimatedCost(org, des, weight, courier);
    if(response.statusCode == 200){
      var status = json.decode(response.body)['rajaongkir']['status'];
      if (status!['code'] == 200 && status!['description'] == "OK") {
        final data = json.decode(response.body);
        setState(() {
          for (Map<String,
              dynamic> i in data!['rajaongkir']['results'][0]['costs']) {
            _courierServiceLists.add(CourierServiceModel.fromJson(i));
          }
        });
      }else{
        _showMsg("${status!['code']}, ${status!['description']}");
      }
    }else{
      _showMsg("Error ${response.statusCode}");
    }
  }

  @override
  void initState(){
    super.initState();
    _getProvince('origin');
    _getProvince('destination');
  }
  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: GestureDetector(
        onTap: (){
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: RefreshIndicator(
          onRefresh: (){
            return Future.delayed(const Duration(seconds: 1),(){
              _getProvince('origin');
              _getProvince('destination');
            });
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              margin: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.all(10),
                    child: const Text(
                      "Address Origin",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 15
                      ),
                    ),
                  ),
                  Container(
                      margin: const EdgeInsets.only(left: 10, top: 5, right: 10, bottom: 5),
                      height: 50,
                      child: ButtonTheme(
                        alignedDropdown: true,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(left: 10, bottom: -5),
                            label: const Text("Province"),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<ProvinceModel>(
                              items: _originProvinceLists.map<DropdownMenuItem<ProvinceModel>>((ProvinceModel val) {
                                return DropdownMenuItem<ProvinceModel>(
                                  value: val,
                                  child: Text(
                                    val.province,
                                    maxLines: 1,
                                    style: const TextStyle(
                                        fontSize: 13
                                    ),
                                  ),
                                );
                              }).toList(),
                              isExpanded: true,
                              hint: const Text("Province"),
                              icon: const Icon(Icons.arrow_drop_down),
                              value: _originProvinceAddress,
                              onChanged: (ProvinceModel? orgProvValue) {
                                FocusScope.of(context).requestFocus(FocusNode());
                                _getCity('origin',int.parse(orgProvValue!.provinceId));
                                setState((){
                                  _originProvinceAddress = orgProvValue;
                                  _originCityLists.clear();
                                  _originCityAddress = null;
                                });
                              },
                            ),
                          ),
                        ),
                      )
                  ),
                  Container(
                      margin: const EdgeInsets.only(left: 10, top: 5, right: 10, bottom: 5),
                      height: 50,
                      child: ButtonTheme(
                        alignedDropdown: true,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(
                                left: 10, bottom: -5),
                            label: const Text("City"),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<CityModel>(
                              items: _originCityLists.map<DropdownMenuItem<CityModel>>((CityModel val) {
                                return DropdownMenuItem<CityModel>(
                                  value: val,
                                  child: Text(
                                    val.type == null ? val.cityName : "${val.type} ${val.cityName}",
                                    maxLines: 1,
                                    style: const TextStyle(
                                        fontSize: 13
                                    ),
                                  ),
                                );
                              }).toList(),
                              isExpanded: true,
                              hint: const Text("City"),
                              icon: const Icon(Icons.arrow_drop_down),
                              value: _originCityAddress,
                              onChanged: (CityModel? orgCityValue) {
                                FocusScope.of(context).requestFocus(FocusNode());
                                setState(() {
                                  _originCityAddress = orgCityValue;
                                  _originAddress = "${_originCityAddress!.type} ${_originCityAddress!.cityName}, ${_originCityAddress!.province}";
                                });
                                if (kDebugMode) {
                                  print("Address Origin = ?prov=${_originProvinceAddress!.provinceId}&city=${_originCityAddress!.cityId}");
                                }
                              },
                            ),
                          ),
                        ),
                      )
                  ),
                  Container(
                    margin: const EdgeInsets.all(5),
                    child: Text(
                      _originAddress!
                    ),
                  ),
                  const Divider(
                    color: Colors.black,
                  ),
                  Container(
                    margin: const EdgeInsets.all(10),
                    child: const Text(
                      "Address Destination",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 15
                      ),
                    ),
                  ),
                  Container(
                      margin: const EdgeInsets.only(left: 10, top: 5, right: 10, bottom: 5),
                      height: 50,
                      child: ButtonTheme(
                        alignedDropdown: true,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(left: 10, bottom: -5),
                            label: const Text("Province"),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<ProvinceModel>(
                              items: _destinationProvinceLists.map<DropdownMenuItem<ProvinceModel>>((ProvinceModel val) {
                                return DropdownMenuItem<ProvinceModel>(
                                  value: val,
                                  child: Text(
                                    val.province,
                                    maxLines: 1,
                                    style: const TextStyle(
                                        fontSize: 13
                                    ),
                                  ),
                                );
                              }).toList(),
                              isExpanded: true,
                              hint: const Text("Province"),
                              icon: const Icon(Icons.arrow_drop_down),
                              value: _destinationProvinceAddress,
                              onChanged: (ProvinceModel? desProvValue) {
                                FocusScope.of(context).requestFocus(FocusNode());
                                _getCity('destination',int.parse(desProvValue!.provinceId));
                                setState((){
                                  _destinationProvinceAddress = desProvValue;
                                  _destinationCityLists.clear();
                                  _destinationCityAddress = null;
                                });
                              },
                            ),
                          ),
                        ),
                      )
                  ),
                  Container(
                      margin: const EdgeInsets.only(left: 10, top: 5, right: 10, bottom: 5),
                      height: 50,
                      child: ButtonTheme(
                        alignedDropdown: true,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(
                                left: 10, bottom: -5),
                            label: const Text("City"),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<CityModel>(
                              items: _destinationCityLists.map<DropdownMenuItem<CityModel>>((CityModel val) {
                                return DropdownMenuItem<CityModel>(
                                  value: val,
                                  child: Text(
                                    val.type == null ? val.cityName : "${val.type} ${val.cityName}",
                                    maxLines: 1,
                                    style: const TextStyle(
                                        fontSize: 13
                                    ),
                                  ),
                                );
                              }).toList(),
                              isExpanded: true,
                              hint: const Text("City"),
                              icon: const Icon(Icons.arrow_drop_down),
                              value: _destinationCityAddress,
                              onChanged: (CityModel? desCityValue) {
                                FocusScope.of(context).requestFocus(FocusNode());
                                setState(() {
                                  _destinationCityAddress = desCityValue;
                                  _destinationAddress = "${_destinationCityAddress!.type} ${_destinationCityAddress!.cityName}, ${_destinationCityAddress!.province}";
                                });
                                if (kDebugMode) {
                                  print("Address Destination = ?prov=${_destinationProvinceAddress!.provinceId}&city=${_destinationCityAddress!.cityId}");
                                }
                              },
                            ),
                          ),
                        ),
                      )
                  ),
                  Container(
                    margin: const EdgeInsets.all(5),
                    child: Text(
                        _destinationAddress!
                    ),
                  ),
                  const Divider(
                    color: Colors.black,
                  ),
                  Container(
                    height: 70,
                    margin: const EdgeInsets.only(left: 10, top: 5, right: 10, bottom: 5),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.only(left:10,right:10,bottom: -5),
                        border: OutlineInputBorder(),
                        labelText: 'Weight (in grams)',
                        hintText: 'ex. 100',
                        floatingLabelBehavior:FloatingLabelBehavior.always,
                      ),
                      keyboardType: TextInputType.number,
                      autocorrect: false,
                      controller: _weight,
                    ),
                  ),
                  Container(
                      margin: const EdgeInsets.only(left: 10, top: 5, right: 10, bottom: 5),
                      height: 50,
                      child: ButtonTheme(
                        alignedDropdown: true,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(left: 10, bottom: -5),
                            label: const Text("Courier"),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<CourierModel>(
                              items: _courierLists.map<DropdownMenuItem<CourierModel>>((CourierModel val) {
                                return DropdownMenuItem<CourierModel>(
                                  value: val,
                                  child: Text(
                                    val.name,
                                    maxLines: 1,
                                    style: const TextStyle(
                                        fontSize: 13
                                    ),
                                  ),
                                );
                              }).toList(),
                              isExpanded: true,
                              hint: const Text("Choose Courier"),
                              icon: const Icon(Icons.arrow_drop_down),
                              value: _choosedCourier,
                              onChanged: (CourierModel? courValue) {
                                FocusScope.of(context).requestFocus(FocusNode());
                                setState((){
                                  _choosedCourier = courValue;
                                });
                              },
                            ),
                          ),
                        ),
                      )
                  ),
                  Center(
                    child: ElevatedButton(
                        onPressed: () async {
                          Map data = {
                            "orId" : _originCityAddress!.cityId,
                            "desId" : _destinationCityAddress!.cityId,
                            "weight" : _weight.text,
                            "courier" : _choosedCourier!.code
                          };
                          _countShippingCost(int.parse(data['orId']), int.parse(data['desId']), double.parse(data['weight']), data['courier']);
                          _showMsg("Check Shipping Cost");
                        },
                        child: const Text(
                          "Check Shipping Cost",
                          style: TextStyle(
                            fontSize: 15
                          ),
                        )
                    ),
                  ),
                  _courierServiceLists.isEmpty
                  ? const SizedBox()
                  : Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.all(5),
                          child: const Text(
                              "Shipping Cost Lists",
                              style: TextStyle(
                                fontSize: 20
                              ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                          child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemCount: _courierServiceLists.length,
                              itemBuilder: (ctx, idx){
                                final serviceIdx = _courierServiceLists[idx];
                                final _etd = serviceIdx.cost[0].etd;
                                return Container(
                                  margin: const EdgeInsets.all(2),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.all(2),
                                        child: Card(
                                          elevation: 4,
                                          child: Container(
                                            margin: const EdgeInsets.all(20),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets.all(2),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisSize: MainAxisSize.max,
                                                    children: [
                                                      Text(
                                                          serviceIdx.service,
                                                          style: const TextStyle(
                                                            fontSize: 17
                                                          ),
                                                      ),
                                                      Text(
                                                          "Estimated until ${_etd == "1-1" ? "tomorrow" : _etd.replaceAll("hari", "").replaceAll("HARI", "").replaceAll(" hari", "").replaceAll(" HARI", "").replaceAll("0-", "today").replaceAll("1-", "tomorrow -").replaceAll(" ", "").replaceAll("-", " - ")}${_etd == "1-1" || _etd == "1" ? "" : " days"}",
                                                          style: const TextStyle(
                                                            fontSize: 13
                                                          ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  margin: const EdgeInsets.all(2),
                                                  child: Text(
                                                    formatCurrency.format(serviceIdx.cost[0].value)
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              }
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      )
    );
  }
}
