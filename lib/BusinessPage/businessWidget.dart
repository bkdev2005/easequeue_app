import 'dart:developer';

import 'package:eqlite/Component/BusinessDetail/business_info_widget.dart';
import 'package:eqlite/ServicePage/AddServicePageWidget.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:screenshot/screenshot.dart';
import '../function.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '../apiFunction.dart';
import '/flutter_flow/random_data_util.dart' as random_data;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'businessModel.dart';

class BusinessPageWidget extends StatefulWidget {
  const BusinessPageWidget(
      {super.key,
      required this.categoryId,
      this.latitude,
      this.longitude,
      required this.categoryName});
  final String categoryId;
  final String categoryName;
  final String? latitude;
  final String? longitude;
  @override
  State<BusinessPageWidget> createState() => _BusinessPageWidgetState();
}

class _BusinessPageWidgetState extends State<BusinessPageWidget> {
  late BusinessPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<String> favBusinessList = [];
  List<dynamic> services = [];
  List<String> selectServiceId = [];
  String? latitude;
  String? longitude;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BusinessPageModel());
    setState(() {
      isMainLoading = true;
    });
    next7Days = getNext7DaysAsMap();
    setState(() {
      selectDay = next7Days.first;
    });

    // if (widget.longitude == null && widget.latitude == null) {
    //   getLocation().then((value) {
    //     log('location: ${value?[1]}, ${value?[2]}');
    //     latitude = value?[1].toString();
    //     longitude = value?[2].toString();
    //     callBusinessApi();
    //   });
    // } else {
    //   latitude = widget.latitude;
    //   longitude = widget.longitude;
    //   callBusinessApi();
    // }

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
          callBusinessApi();
        }
      }
    });
  }

  void callBusinessApi() {
    // Construct services query
    final servicesQuery = selectServiceId.map((id) => 'services=$id').join('&');

    // Construct location query if available
    final locationQuery = (latitude != null && longitude != null)
        ? '&user_location=$latitude&user_location=$longitude'
        : '';

    // Construct full URL
    final url = 'business_list?page=$page&page_size=$limit'
        '&filter_date=${jsonDecode(selectDay)['year']}-${getMonthNumber(jsonDecode(selectDay)['month'])}-${jsonDecode(selectDay)['date']}'
        '&category_id=${widget.categoryId}'
        '${servicesQuery.isNotEmpty ? '&$servicesQuery' : ''}'
        '$locationQuery';

    fetchData(url, context)?.then((value) {
      log('url: $url');
      log('value: $value');
      if (value != null) {
        setState(() {
          data =
              getJsonField(value, r'''$.data.data[:]''', true)?.toList() ?? [];
          if (value.length < limit) {
            hasMore = false;
          } else {
            hasMore = true;
            page++;
          }
          setState(()=> isMainLoading = false );

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
                                  'business_list?category_id=${widget.categoryId}&search=$_'
                                  '&filter_date=${jsonDecode(selectDay)['year']}-${getMonthNumber(jsonDecode(selectDay)['month'])}-${jsonDecode(selectDay)['date']}',
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
                            borderSide: const BorderSide(
                              color: Color(0x00000000),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
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
                                page = 1;
                              });
                              callBusinessApi();
                            },
                          ),
                          fillColor: const Color(0xFFF4F4F4),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                          ),
                        )))
                : Text(
                    widget.categoryName,
                    style: const TextStyle(
                        fontSize: 24,
                        fontFamily: 'Inter',
                        color: Colors.white,
                        fontWeight: FontWeight.w500),
                  ),
            centerTitle: false,
            elevation: 2,
          ),
          body: SafeArea(
            top: true,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                    padding: EdgeInsets.only(top: 15, left: 10, bottom: 3),
                    child: Row(
                      children: List.generate(services.length, (index) {
                        final service = services[index];
                        return Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: GestureDetector(
                                onTap: () {
                                  final uuid =
                                  getJsonField(service, r'''$.uuid''');
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
                                      border: Border.all(
                                          color: (selectServiceId.contains(
                                              getJsonField(
                                                  service, r'''$.uuid''')))
                                              ? Colors.transparent
                                              : Colors.black26),
                                      color: (selectServiceId.contains(
                                          getJsonField(
                                              service, r'''$.uuid''')))
                                          ? FlutterFlowTheme.of(context).primary
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(30)),
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(15, 6, 15, 6),
                                    child: Text(
                                      getJsonField(service, r'''$.name'''),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: (selectServiceId.contains(
                                            getJsonField(
                                                service, r'''$.uuid''')))
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                )));
                      }),
                    )),
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
                            final businessListItem =
                                businessList[businessListIndex];
                            final isFavourite = favBusinessList
                                .contains(businessListItem['uuid']);
                            bool temporaryClosed =
                                (businessListItem['temporary_closed'] ||
                                    businessListItem['is_closed']);

                            return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AddServicePageWidget(
                                        businessDetail: businessListItem,
                                        lat: widget.latitude,
                                        long: widget.longitude,
                                        businessId: businessListItem['uuid'],
                                      ),
                                    ),
                                  ).then((value){
                                    callBusinessApi();
                                    setState(() {
                                    });
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: Material(
                                    elevation: 1,
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.white,
                                    child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 0, vertical: 0),
                                        padding: const EdgeInsets.fromLTRB(
                                            15, 10, 0, 10),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.transparent,
                                              Colors.green.withOpacity(0.09), // Or any color for the bottom glow
                                            ],
                                          ),
                                          border: Border.all(color: Colors.green.shade50),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                  padding:
                                                      const EdgeInsets.only(top: 5),
                                                  child: Container(
                                                      width: 40,
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                            color:
                                                                Colors.black26,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5)),
                                                      child: (businessListItem[
                                                                  'profile_picture'] !=
                                                              null)
                                                          ? Image.network(
                                                              'http://43.204.107.110/shared/${businessListItem['profile_picture']}',
                                                              fit: BoxFit.cover,
                                                            )
                                                          : Padding(
                                                              padding:
                                                                 const EdgeInsets
                                                                      .all(8),
                                                              child: Image.asset(
                                                                  'assets/images/images.png')))),
                                              // Business Info
                                              Expanded(
                                                  child: Padding(
                                                padding:
                                                    EdgeInsets.only(left: 10),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      businessListItem[
                                                              'name'] ??
                                                          'N/A',
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontSize: 18,
                                                            fontFamily: 'Inter',
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                    ),
                                                    if (businessListItem[
                                                            'address'] !=
                                                        null)
                                                      Text(
                                                        businessListItem[
                                                                    'address']
                                                                ['street_1'] ??
                                                            '',
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontSize: 14,
                                                                  fontFamily:
                                                                      'Inter',
                                                                  letterSpacing:
                                                                      0.0,
                                                                ),
                                                      ),
                                                    const SizedBox(height: 3),

                                                       Row( crossAxisAlignment: CrossAxisAlignment.start,
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                Text((businessListItem[
                                                                'status'].toString().toLowerCase() == 'closed')? 'Closed' : 'Open',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          color: (businessListItem[
                                                                          'status'].toString().toLowerCase() != 'closed')? Colors.green :
                                                                              Colors.redAccent,
                                                                          fontFamily:
                                                                              'Inter',
                                                                          letterSpacing:
                                                                              0.0,
                                                                        )),
                                                                Expanded(child: Text(' • ${businessListItem[
                                                                'status_message']}',
                                                                    style: FlutterFlowTheme.of(
                                                                        context)
                                                                        .bodyMedium
                                                                        .override(
                                                                      fontSize:
                                                                      12,
                                                                      fontWeight:
                                                                      FontWeight.w400,
                                                                      color:
                                                                      Colors.black45,
                                                                      fontFamily:
                                                                      'Inter',
                                                                      letterSpacing:
                                                                      0.0,
                                                                    )),
                                                                )]),
                                                      ],
                                                ),
                                              )),

                                              const SizedBox(width: 12),

                                              // Info Icon
                                              // const Icon(Icons.info_outline_rounded, color: Colors.black54, size: 20,),
                                              Column(
                                                children: [
                                                  IconButton(
                                                    onPressed: () {
                                                      // setState(() {
                                                      //   page = 1;
                                                      //   // data.clear();
                                                      // });
                                                      sendData({
                                                        "user_id":
                                                            FFAppState().userId,
                                                        "business_id":
                                                            businessListItem[
                                                                'uuid']
                                                      }, 'favourite')
                                                          .then((value) {
                                                        log('value: $value');
                                                        callBusinessApi();
                                                      });
                                                    },
                                                    icon: Icon(
                                                        businessListItem[
                                                                'is_favourite']
                                                            ? Icons
                                                                .favorite_rounded
                                                            : Icons
                                                                .favorite_border_rounded,
                                                        size: 24,
                                                        color: isFavourite
                                                            ? FlutterFlowTheme
                                                                    .of(context)
                                                                .primary
                                                            : FlutterFlowTheme
                                                                    .of(context)
                                                                .primary),
                                                  ),
                                                ],
                                              ),
                                            ])),
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
