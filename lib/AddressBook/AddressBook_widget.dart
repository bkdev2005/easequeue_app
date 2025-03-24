import 'dart:developer';

import 'package:eqlite/Component/Confirmation/permissionConfirmation.dart';
import 'package:eqlite/flutter_flow/nav/nav.dart';
import 'package:eqlite/function.dart';

import '../AddAddress/NewAddress_widget.dart';
import '../CompleteLocation/CompleteLocation_widget.dart';
import '../apiFunction.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/flutter_flow/random_data_util.dart' as random_data;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';


class AddressBookWidget extends StatefulWidget {
  const AddressBookWidget({super.key});

  @override
  State<AddressBookWidget> createState() => _AddressBookWidgetState();
}

class _AddressBookWidgetState extends State<AddressBookWidget> {

  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<dynamic> address = [];
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
    fetchData(
        'address?entity_type=USER&entity_id=${FFAppState().userId}', context)?.then((value) {
      if(value['data'] != null){
        final data = getJsonField(value, r'''$.data[:]''', true)?.toList()??[];
        setState(() {
          address = data;
          isMainLoading = false;
        });
      }else{
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
        appBar: appBarWidget(context, 'Addresses'),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(child: Builder(
                  builder: (context) {
                    final addressList = address;

                    if(isMainLoading){
                      return loading(context);
                    }
                    if(!isMainLoading && addressList.isEmpty){
                      return emptyList();
                    }
                    return ListView.builder(
                      padding: const  EdgeInsets.fromLTRB(
                        0,
                        10,
                        0,
                        0,
                      ),
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: addressList.length,
                      itemBuilder: (context, addressListIndex) {
                        final addressListItem = addressList[addressListIndex];
                        return InkWell(
                            onLongPress: (){
                              showDialog(context: context,
                                  builder: (context){
                                    return const Center(child: ConfirmationWidget(
                                      title: 'Delete address',
                                      subtitle: 'Are you sure want to delete this address?',
                                    ),);
                                  }).then((value) {
                                    if(value){
                                      deleteData({}, "address/${addressListItem['uuid']}").then((value) {
                                        log('value: $value');
                                        if(value) {
                                        setState(() {
                                        address.clear();
                                        });
                                        callApi();
                                        }
                                        });
                                    }
                              });
                            },
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context)=> BusinessCompletelocationWidget(
                                    address: addressListItem,
                                    id: addressListItem['uuid'],
                                  ))).then(
                                      (value) {
                                    log('value: $value');
                                    if(value != null) {
                                      setState(() {
                                        address.clear();
                                      });
                                      callApi();
                                    }
                                  });
                            }, child: Padding(
                          padding:
                          EdgeInsetsDirectional.fromSTEB(15, 10, 20, 0),
                          child:  Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                (addressListItem['address_type']=='HOME')? Icons.home_outlined:
                                (addressListItem['address_type']=='WORK')? Icons.business: Icons.location_on_outlined,
                                color: FlutterFlowTheme.of(context).primaryText,
                                size: 24,
                              ),
                             Expanded(child:  Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      10, 0, 0, 0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                         addressListItem['address_type']??'N/A',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                          fontFamily: 'Inter',
                                          fontSize: 18,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                     Padding(
                                          padding:
                                          EdgeInsetsDirectional.fromSTEB(
                                              0, 5, 0, 5),
                                          child: Text(
                                              formatAddress(
                                                  {
                                                    "unit_number": addressListItem['unit_number'],
                                                    "building": addressListItem['building'],
                                                    "street_2": addressListItem['street_2'],
                                                    "postal_code": addressListItem['postal_code']
                                                  }),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                              fontFamily: 'Inter',
                                              fontSize: 14,
                                              letterSpacing: 0.0,
                                            ),
                                          ),
                                        ),
                                       // Padding(
                                       //    padding:
                                       //    EdgeInsetsDirectional.fromSTEB(
                                       //        0, 8, 0, 12),
                                       //    child: Text(
                                       //      'Phone number: 18455465575',
                                       //      style: FlutterFlowTheme.of(context)
                                       //          .bodyMedium
                                       //          .override(
                                       //        fontFamily: 'Inter',
                                       //        fontSize: 14,
                                       //        letterSpacing: 0.0,
                                       //      ),
                                       //    ),
                                       //  ),

                                      Divider(
                                        thickness: 1,
                                      ),
                                    ],
                                  ),
                                )),

                            ],
                          ),
                        ));
                      },
                    );
                  },
                )),

              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20, 10, 20, 20),
                child: FFButtonWidget(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context)=>
                       BusinessLocationWidget())).then(
                           (value) {
                             log('value: $value');
                             if(value != null) {
                               setState(() {
                                 address.clear();
                               });
                               callApi();
                             }
                           });
                  },
                  text: 'Add new address',
                  options: buttonStyle(context)
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
