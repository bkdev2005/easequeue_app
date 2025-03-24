import 'dart:developer';

import 'package:eqlite/Component/Confirmation/permissionConfirmation.dart';
import 'package:eqlite/flutter_flow/nav/nav.dart';

import '../apiFunction.dart';
import '../function.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FavoriteBusinessWidget extends StatefulWidget {
  const FavoriteBusinessWidget({super.key});

  @override
  State<FavoriteBusinessWidget> createState() => _FavoriteBusinessWidgetState();
}

class _FavoriteBusinessWidgetState extends State<FavoriteBusinessWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<dynamic> businesses = [];
  bool isMainLoading = false;

  @override
  void initState() {
    callApi();
    super.initState();
  }

  void callApi(){
    setState(() {
      isMainLoading = true;
    });
    fetchData('favourites/${FFAppState().userId}', context)?.then((value) {
      if (value != null) {
        final data =
            getJsonField(value, r'''$.data[:]''', true)?.toList() ?? [];
        setState(() {
          businesses = data;
          isMainLoading = false;
        });
      } else {
        setState(() {
          isMainLoading = false;
        });
      }
      log('value: $value');
    });
  }

  @override
  void dispose() {
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
        appBar: appBarWidget(context, 'Favorite Businesses'),
        body: SafeArea(
            top: true,
            child: Builder(builder: (context) {
              final businessList = businesses?.toList(growable: true) ?? [];

              if (isMainLoading) {
                return loading(context);
              }

              if (businessList.isEmpty && isMainLoading == false) {
                return emptyList();
              }

              return ListView.builder(
                  padding: EdgeInsets.only(bottom: 20, top: 10),
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: businessList.length,
                  itemBuilder: (context, index) {
                    final business = businessList[index];
                    return Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(15, 10, 15, 0),
                      child: Card(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                          child: Text(
                                            business['business_name']??'N/A',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Inter',
                                              fontSize: 16,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      )),
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0, 5, 0, 0),
                                    child: Text(
                                      formatAddress(business['business_address']),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Inter',
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 0, 15, 0),
                              child: IconButton(
                                onPressed: (){
                                  showDialog(context: context,
                                      builder: (context){
                                    return const Center(child: ConfirmationWidget(title: 'Remove favourite business',
                                    subtitle: 'Are you sure want remove favourite business?',
                                    ),);
                                      }).then((value) {
                                    if (value) {
                                      sendData(
                                          {
                                            "user_id": FFAppState().userId,
                                            "business_id": business['business_id']
                                          }, 'favourite').then((value) {
                                        log('value: $value');
                                      }).then((value) {
                                        setState(() {
                                          businessList.clear();
                                        });
                                        callApi();
                                      });
                                    }
                                  });
                                },
                                icon: Icon(
                                Icons.favorite_rounded,
                                color:
                                    FlutterFlowTheme.of(context).primary,
                                size: 30,
                              ),
                            )),
                          ],
                        ),
                      ),
                    );
                  });
            })),
      ),
    );
  }
}
