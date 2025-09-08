import 'dart:developer';

import 'package:eqlite/apiFunction.dart';
import 'package:eqlite/app_state.dart';
import 'package:eqlite/flutter_flow/flutter_flow_theme.dart';
import 'package:eqlite/flutter_flow/flutter_flow_widgets.dart';
import 'package:eqlite/flutter_flow/nav/nav.dart';
import 'package:eqlite/function.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:screenshot/screenshot.dart';

class BusinessRatingDialog extends StatefulWidget {
  const BusinessRatingDialog({super.key, required this.businessId});
  final String businessId;
  @override
  _BusinessRatingDialogState createState() => _BusinessRatingDialogState();
}

class _BusinessRatingDialogState extends State<BusinessRatingDialog> {
  double _rating = 4.0;
  final TextEditingController _feedbackController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        color: Colors.green.withOpacity(0.03),
        padding: EdgeInsets.all(24),
        width: MediaQuery.of(context).size.width * 0.85,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star_rate_rounded,
                  size: 64, color: FlutterFlowTheme.of(context).primary),
              SizedBox(height: 12),
              Text(
                "Rate Our Business",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: FlutterFlowTheme.of(context).primary,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "How was your experience?",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 36,
                unratedColor: Colors.teal.shade100,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: FlutterFlowTheme.of(context).primary,
                ),
                onRatingUpdate: (rating) {
                  _rating = rating;
                },
              ),
              const SizedBox(height: 20),
              TextField(
                cursorColor: FlutterFlowTheme.of(context).primary,
                controller: _feedbackController,
                decoration: InputDecoration(
                  labelText: "Leave a comment (optional)",
                  labelStyle:
                      TextStyle(color: FlutterFlowTheme.of(context).primary),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: FlutterFlowTheme.of(context).primary),
                      borderRadius: BorderRadius.circular(12)),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Row(
                spacing: 12,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: FFButtonWidget(
                          text: 'Cancel',
                          onPressed: () {
                            context.pop();
                          },
                          options: FFButtonOptions(
                              width: double.infinity,
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.black),
                              color: Colors.white,
                              elevation: 0,
                              textStyle:
                                  const TextStyle(color: Colors.black)))),
                  Expanded(
                      child: FFButtonWidget(
                          text: 'Submit',
                          onPressed: () async {
                            final review = await sendData({
                              "user_id": FFAppState().userId,
                              "employee_id":
                                  "3fa85f64-5717-4562-b3fc-2c963f66afa6",
                              "queue_id":
                                  "3fa85f64-5717-4562-b3fc-2c963f66afa6",
                              "service_id":
                                  "3fa85f64-5717-4562-b3fc-2c963f66afa6",
                              "business_id":
                                  "3fa85f64-5717-4562-b3fc-2c963f66afa6",
                              "queue_user_id":
                                  "3fa85f64-5717-4562-b3fc-2c963f66afa6",
                              "rating": _rating,
                              "comment": "string",
                              "is_verified": true
                            }, 'review')
                                .then((response) {
                              log('response: $response');
                            });
                          },
                          options: FFButtonOptions(
                              width: double.infinity,
                              borderRadius: BorderRadius.circular(10),
                              color: FlutterFlowTheme.of(context).primary,
                              elevation: 0,
                              textStyle: const TextStyle(color: Colors.white))))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
