import 'dart:developer';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:eqlite/Component/BusinessDetail/business_info_widget.dart';
import 'package:eqlite/ServicePage/AddServicePageWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:screenshot/screenshot.dart';
import '../function.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:ui';
import '../apiFunction.dart';

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
  late stt.SpeechToText _speech;
  bool _isListening = false;
  late ScrollController _scrollController;
  String? longitude;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BusinessPageModel());
    _model.textController = TextEditingController();
    _model.textFieldFocusNode = FocusNode();
    _speech = stt.SpeechToText();
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _scrollOffset = _scrollController.offset;
        });
      });
    setState(() {
      isMainLoading = true;
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
          callBusinessApi();
        }
      }
    });
  }

  void callBusinessApi({String? search}) {
    // Construct services query
    final servicesQuery = selectServiceId.map((id) => 'services=$id').join('&');

    // Construct location query if available
    final locationQuery = (latitude != null && longitude != null)
        ? '&user_location=$latitude&user_location=$longitude'
        : '';

    // Construct full URL
    final url = 'business_list?page=$page&page_size=$limit'
        '&search=${search ?? ''}'
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
          setState(() => isMainLoading = false);
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
  double _scrollOffset = 0.0;

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double maxScrollExtent = 5; // Adjust as per your requirement
    final double opacity = (_scrollOffset / maxScrollExtent).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: appBarWidget(context, widget.categoryName),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Material(
              elevation: 0,
              color:  FlutterFlowTheme.of(context).primary,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
            child: Column(
            children: [
            Padding(
                padding: const EdgeInsets.only(
                    left: 15, right: 15, top: 4, bottom: 0),
                child: TextFormField(
                    cursorColor: FlutterFlowTheme.of(context).primary,
                    controller: _model.textController,
                    focusNode: _model.textFieldFocusNode,
                    onChanged: (_) {
                      if (_.length > 3) {
                        setState(() {
                          data.clear();
                        });
                        callBusinessApi(search: _);
                      } else {
                        callBusinessApi();
                      }
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
                      suffixIcon: _model.textController!.text.isNotEmpty
                          ? GestureDetector(
                              onTap: () async {
                                _model.textController?.clear();
                                setState(() {});
                                callBusinessApi();
                              },
                              child: const Icon(
                                Icons.clear,
                                size: 22,
                              ),
                            )
                          : (_isListening)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: Image.asset(
                                    'assets/images/voice.gif',
                                    height: 50,
                                    width: 50,
                                  ))
                              : GestureDetector(
                                  onTap: () async {
                                    toggleListening();
                                    setState(() {});
                                  },
                                  child: const Icon(
                                    Icons.mic,
                                    size: 22,
                                  ),
                                ),
                      fillColor: FlutterFlowTheme.of(context).primaryBackground,
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                      ),
                    ))),
            Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                scrollDirection: Axis.horizontal,
                    child: Row(
                      spacing: 12,
                  children: List.generate(services.length, (index) {
                    final service = services[index];
                    return GestureDetector(
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
                                  color: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(13, 6, 10, 6),
                                  child: Row(children: [
                                    Text(
                                      getJsonField(service, r'''$.name'''),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 4,
                                    ),
                                    if (selectServiceId.contains(
                                        getJsonField(service, r'''$.uuid''')))
                                      const Icon(
                                        Icons.close_rounded,
                                        size: 18,
                                        color: Colors.black54,
                                      )
                                  ])),
                            ));
                  }),
                )),))])),
            Expanded(
              child: Material(
                color: FlutterFlowTheme.of(context).primaryBackground,
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(15, 0, 15, 0),
                  child: Builder(
                    builder: (context) {
                      final businessList = data?.toList() ?? [];

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
                                    builder: (context) => AddServicePageWidget(
                                      businessDetail: businessListItem,
                                      lat: widget.latitude,
                                      long: widget.longitude,
                                      businessId: businessListItem['uuid'],
                                    ),
                                  ),
                                ).then((value) {
                                  callBusinessApi();
                                  setState(() {});
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
                                            Colors.green.withOpacity(
                                                0.09), // Or any color for the bottom glow
                                          ],
                                        ),
                                        border: Border.all(
                                            color: Colors.green.shade50),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 5),
                                                child: Container(
                                                    width: 40,
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: Colors.black26,
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
                                                    businessListItem['name'] ??
                                                        'N/A',
                                                    style: FlutterFlowTheme.of(
                                                            context)
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
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontSize: 14,
                                                            fontFamily: 'Inter',
                                                            letterSpacing: 0.0,
                                                          ),
                                                    ),
                                                  const SizedBox(height: 3),
                                                  Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Text(
                                                            (businessListItem[
                                                                            'status']
                                                                        .toString()
                                                                        .toLowerCase() ==
                                                                    'closed')
                                                                ? 'Closed'
                                                                : 'Open',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: (businessListItem[
                                                                                  'status']
                                                                              .toString()
                                                                              .toLowerCase() !=
                                                                          'closed')
                                                                      ? Colors
                                                                          .green
                                                                      : Colors
                                                                          .redAccent,
                                                                  fontFamily:
                                                                      'Inter',
                                                                  letterSpacing:
                                                                      0.0,
                                                                )),
                                                        Expanded(
                                                          child: Text(
                                                              ' • ${businessListItem['status_message']}',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    color: Colors
                                                                        .black45,
                                                                    fontFamily:
                                                                        'Inter',
                                                                    letterSpacing:
                                                                        0.0,
                                                                  )),
                                                        )
                                                      ]),
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
                                                          ? FlutterFlowTheme.of(
                                                                  context)
                                                              .primary
                                                          : FlutterFlowTheme.of(
                                                                  context)
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
            )
          ],
        ),
      ),
    );
  }

  void toggleListening() async {
    if (_isListening) {
      _speech.stop().then((_) {
        setState(() {
          _isListening = false;
        });
      });
    } else {
      bool available = await _speech.initialize(
        onStatus: (status) {
          log('Speech status: $status');
          if (status == 'done' || status == 'notListening') {
            setState(() {
              _isListening = false;
            });
          }
        },
        onError: (error) {
          log('Speech error: $error');
          setState(() {
            _isListening = false;
          });
        },
      );

      if (available) {
        setState(() => _isListening = true);

        _speech.listen(
          onResult: (result) {
            final recognizedText = result.recognizedWords;
            setState(() {
              _model.textController?.text = recognizedText;
            });

            callBusinessApi(search: _model.textController?.text);
          },
          listenFor: const Duration(seconds: 10), // session timeout
          pauseFor: const Duration(seconds: 3), // stop after 3s silence
          onSoundLevelChange: (level) {
            // Optional: can use for wave animation if needed
            log('level: $level');
          },
          // onSoundLevelChangeTimeout: Duration(milliseconds: 500),
        );

        // Handle status changes (silence / session end)
        _speech.statusListener = (status) {
          log('Speech status: $status');
          if (status == 'notListening' || status == 'done') {
            setState(() => _isListening = false);
            log('Listening closed due to silence or timeout');
          }
        };

        // Handle errors
        _speech.errorListener = (error) {
          log('Speech error: $error');
          setState(() => _isListening = false);
        };
      }
    }
  }
}
