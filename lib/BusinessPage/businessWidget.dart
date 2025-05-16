import 'dart:developer';

import 'package:eqlite/ServicePage/AddServicePageWidget.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import '../apiFunction.dart';
import '../function.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/flutter_flow/random_data_util.dart' as random_data;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'businessModel.dart';

class BusinessPageWidget extends StatefulWidget {
  const BusinessPageWidget({super.key, required this.categoryId});
  final String categoryId;
  @override
  State<BusinessPageWidget> createState() => _BusinessPageWidgetState();
}

class _BusinessPageWidgetState extends State<BusinessPageWidget> {
  late BusinessPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<String> favBusinessList = [];
  List<dynamic> services = [];
  List<String> selectServiceId = [];
  Location location = Location();
  LocationData? _locationData;
  bool _serviceEnabled = false;
  PermissionStatus? _permissionGranted;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BusinessPageModel());
    setState(() {
      isMainLoading = true;
    });
    getLocation();
    location.onLocationChanged.listen((LocationData currentLocation) {
      print('Updated Location: ${currentLocation.latitude}, ${currentLocation.longitude}');
    });
    next7Days = getNext7DaysAsMap();
    setState(() {
      selectDay = next7Days.first;
    });
    callBusinessApi();
    fetchData('services/${widget.categoryId}', context)?.then((value) {
      log('value: $value');
      if (value != null) {
        setState(() {
          services = getJsonField(value, r'''$.data[:]''', true);
        });
      }
    });
    controller.addListener(() {
      log('hasMore: $hasMore');
      if (hasMore) {
        if (controller.position.maxScrollExtent == controller.offset) {
          fetchData(
                  'business_list?page=$page&page_size=$limit&category_id=${widget.categoryId}&filter_date=${jsonDecode(selectDay)['year']}-${getMonthNumber(jsonDecode(selectDay)['month'])}-${jsonDecode(selectDay)['date']}',
                  context)
              ?.then((value) {
            log('value: $value');
            setState(() {
              data.addAll(value!);
              if (value.length < limit) {
                hasMore = false;
              } else {
                hasMore = true;
                page++;
              }
            });
          });
        }
      }
    });
  }

  Future<void> getLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) return;
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) return;
    }

    _locationData = await location.getLocation();

    log('Latitude: ${_locationData?.latitude}');
    log('Longitude: ${_locationData?.longitude}');

    setState(() {}); // Update UI
  }

  void callBusinessApi() {
    // Construct services query
    final servicesQuery = selectServiceId
        .map((id) => 'services=$id')
        .join('&');

    // Construct full URL
    final url = 'business_list?page=$page&page_size=$limit'
        '&category_id=${widget.categoryId}'
        '${servicesQuery.isNotEmpty ? '&$servicesQuery' : ''}';

    fetchData(url, context)?.then((value) {
      log('value: $value');
      if (value != null) {
        setState(() {
          data = getJsonField(value, r'''$.data.data[:]''', true)?.toList() ?? [];
          if (value.length < limit) {
            hasMore = false;
          } else {
            hasMore = true;
            page++;
          }
          isMainLoading = false;
        });
      } else {
        setState(() {
          isMainLoading = false;
        });
      }
    });
  }

  bool searchBar = false;
  final controller = ScrollController();
  List<dynamic> data = [];
  bool hasMore = false;
  bool isMainLoading = false;
  int page = 1;
  int limit = 10;
  String selectDay = '';
  List<dynamic> next7Days = [];

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          appBar: AppBar(
            toolbarHeight: 70,
            backgroundColor: FlutterFlowTheme.of(context).primary,
            automaticallyImplyLeading: false,
            leading: (!searchBar) ? backIcon(context) : null,
            actions: [
              if (!searchBar)
                IconButton(
                    onPressed: () {
                      setState(() {
                        searchBar = true;
                      });
                      log('button pressed');
                    },
                    icon: const Icon(
                      Icons.search,
                      color: Colors.white,
                    ))
            ],
            title: (searchBar)
                ? Padding(
                    padding: const EdgeInsets.only(
                        left: 0, right: 0, top: 0, bottom: 0),
                    child: TextFormField(
                        controller: _model.textController,
                        focusNode: _model.textFieldFocusNode,
                        onChanged: (_) {
                          setState(() {
                            data.clear();
                          });
                          fetchData(
                                  'business_list?category_id=${widget.categoryId}&search=$_',
                                  // '&filter_date=${jsonDecode(selectDay)['year']}-${getMonthNumber(jsonDecode(selectDay)['month'])}-${jsonDecode(selectDay)['date']}',
                                  context)
                              ?.then((value) {
                            log('value: $value');
                            if (value != null) {
                              setState(() {
                                data = getJsonField(
                                            value, r'''$.data.data[:]''', true)
                                        ?.toList() ??
                                    [];
                                if (value.length < limit) {
                                  hasMore = false;
                                } else {
                                  hasMore = true;
                                  page++;
                                }
                              });
                              setState(() {
                                isMainLoading = false;
                              });
                            } else {
                              setState(() {
                                isMainLoading = false;
                              });
                            }
                          });
                        },
                        autofocus: false,
                        obscureText: false,
                        decoration: InputDecoration(
                          isDense: true,
                          labelStyle:
                              FlutterFlowTheme.of(context).labelMedium.override(
                                    fontFamily: 'Inter',
                                    letterSpacing: 0.0,
                                  ),
                          hintText: 'Search business',
                          hintStyle:
                              FlutterFlowTheme.of(context).labelMedium.override(
                                    fontFamily: 'Inter',
                                    letterSpacing: 0.0,
                                  ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0x00000000),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0x00000000),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          contentPadding: EdgeInsets.all(0),
                          filled: true,
                          suffixIcon: IconButton(
                            icon: Icon(Icons.close),
                            iconSize: 24,
                            onPressed: () {
                              setState(() {
                                searchBar = false;
                                data.clear();
                                page = 1;
                              });
                              callBusinessApi();
                            },
                          ),
                          fillColor: Color(0xFFF4F4F4),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                          ),
                        )))
                : null,
            centerTitle: false,
            elevation: 2,
          ),
          body: SafeArea(
            top: true,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                    height: 85,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: List.generate(next7Days.length, (index) {
                        final day = jsonDecode(next7Days[index]);
                        return Material(
                            elevation: 2,
                            child: InkWell(
                                onTap: () {
                                  setState(() {
                                    selectDay = next7Days[index];
                                    data.clear();
                                    page = 1;
                                  });
                                  callBusinessApi();
                                  log('day: $selectDay');
                                },
                                child: Container(
                                    color: (next7Days[index] == selectDay)
                                        ? FlutterFlowTheme.of(context).primary
                                        : Colors.transparent,
                                    child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 18,
                                            right: 18,
                                            top: 5,
                                            bottom: 5),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              day['day'],
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: (next7Days[index] ==
                                                          selectDay)
                                                      ? Colors.white
                                                      : Colors.black),
                                            ),
                                            Text(
                                              day['date'],
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w500,
                                                  color: (next7Days[index] ==
                                                          selectDay)
                                                      ? Colors.white
                                                      : Colors.black),
                                            ),
                                            Text(
                                              day['month'],
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w300,
                                                  color: (next7Days[index] ==
                                                          selectDay)
                                                      ? Colors.white
                                                      : Colors.black),
                                            )
                                          ],
                                        )))));
                      }),
                    )),
                const Divider(
                  thickness: 1,
                  height: 0,
                ),
                Padding(
                    padding: EdgeInsets.only(top: 10, left: 5),
                    child: Row(
                      children: List.generate(services.length, (index) {
                        final service = services[index];
                        return Padding(padding: EdgeInsets.only(left: 10) ,child: GestureDetector(
                            onTap: () {
                              final uuid = getJsonField(service, r'''$.uuid''');
                              setState(() {
                                if (selectServiceId.contains(uuid)) {
                                  selectServiceId.remove(uuid);
                                } else {
                                  selectServiceId.add(uuid);
                                }
                              });
                              callBusinessApi();
                            },
                            child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: (selectServiceId.contains(getJsonField(service, r'''$.uuid''')))? Colors.transparent : Colors.black26),
                              color: (selectServiceId.contains(getJsonField(service, r'''$.uuid''')))?
                              FlutterFlowTheme.of(context).primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(30)),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(15 , 6, 15, 6),
                            child: Text(
                              getJsonField(service, r'''$.name'''),
                              style: TextStyle(
                                fontSize: 16,
                                color: (selectServiceId.contains(getJsonField(service, r'''$.uuid''')))? Colors.white: Colors.black,
                              ),
                            ),
                          ),
                        )));
                      }),
                    )),
                Divider(),
                Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
                    child: Builder(
                      builder: (context) {
                        final businessList = data.toList() ?? [];

                        if (isMainLoading) {
                          return Center(
                            child: loading(context),
                          );
                        }

                        if (businessList.isEmpty) {
                          return Center(
                            child: emptyList(),
                          );
                        }
                        return ListView.builder(
                          controller: controller,
                          padding: const EdgeInsets.only(bottom: 20),
                          itemCount: businessList.length,
                          itemBuilder: (context, businessListIndex) {
                            final businessListItem = businessList[businessListIndex];
                            final isFavourite = favBusinessList.contains(businessListItem['uuid']);

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddServicePageWidget(
                                      businessDetail: businessListItem,
                                      date: selectDay,
                                    ),
                                  ),
                                );
                              },
                              child: Padding( padding: EdgeInsets.only(top: 12), child: Material(
                                elevation: 2,
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                  Padding( padding: EdgeInsets.only(top: 5), child:
                                      Container(
                                        width: 35,
                                          height: 35,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.black26,
                                            ),
                                            borderRadius: BorderRadius.circular(5)
                                          ),
                                          child: Padding( padding: EdgeInsets.all(8), child: (businessListItem['profile_picture']!= null)?
                                              Image.network('http://15.207.20.38/shared/${businessListItem['profile_picture']}',
                                                fit: BoxFit.contain,):
                                      Image.asset('assets/images/images.png'))
                                      )),
                                      // Business Info
                                      Expanded(
                                        child: Padding( padding: EdgeInsets.only(left: 10), child:  Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              businessListItem['name'] ?? 'N/A',
                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                fontSize: 18,
                                                fontFamily: 'Inter',
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            if (businessListItem['address'] != null)
                                              Text(
                                                businessListItem['address']['building'] ?? '',
                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  fontSize: 14,
                                                  fontFamily: 'Inter',
                                                  letterSpacing: 0.0,
                                                ),
                                              ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(Icons.timer_sharp, size: 16),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${businessListItem['distance_time']} - ${businessListItem['distance']}',
                                                  style:
                                                  FlutterFlowTheme.of(context).bodyMedium.override(
                                                    fontSize: 12,
                                                    fontFamily: 'Inter',
                                                    letterSpacing: 0.0,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )),

                                      const SizedBox(width: 12),

                                      // Info Icon
                                      // const Icon(Icons.info_outline_rounded, color: Colors.black54, size: 20,),

                                      GestureDetector(
                                        onTap: () {
                                          // setState(() {
                                          //   page = 1;
                                          //   // data.clear();
                                          // });
                                          sendData({
                                            "user_id": FFAppState().userId,
                                            "business_id": businessListItem['uuid']
                                          }, 'favourite').then((value) {
                                            log('value: $value');
                                            callBusinessApi();
                                          });
                                        },
                                        child: Icon(
                                          businessListItem['is_favourite']
                                              ? Icons.favorite_rounded
                                              : Icons.favorite_border_rounded,
                                          size: 28,
                                          color: isFavourite
                                              ? FlutterFlowTheme.of(context).primary

                                              : FlutterFlowTheme.of(context).primary
                                        ),
                                      ),

                                    ],
                                  ),
                                ),
                              ),
                            ));
                          },
                        );

                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
