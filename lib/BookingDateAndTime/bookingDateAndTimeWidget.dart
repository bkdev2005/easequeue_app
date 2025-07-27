import 'package:eqlite/flutter_flow/flutter_flow_theme.dart';
import 'package:eqlite/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:eqlite/function.dart';

class BookTablePage extends StatefulWidget {
  const BookTablePage({super.key});

  @override
  _BookTablePageState createState() => _BookTablePageState();
}

class _BookTablePageState extends State<BookTablePage> {
  int selectedGuests = 2;
  int selectedDateIndex = 0;
  int selectedLunchTimeIndex = -1;

  List<String> dates = ["26 Jul", "27 Jul", "28 Jul", "29 Jul", "30 Jul"];
  List<String> times = ["12:00 PM", "01:00 PM", "02:00 PM", "03:00 PM", "04:00 PM"];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: appBarWidget(context, 'Select Date'),
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Pizzaiolo - The wood Fired Pizza", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            const Text("Number of guest(s)", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                int guestCount = index + 1;
                return GestureDetector(
                  onTap: () => setState(() => selectedGuests = guestCount),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(color: selectedGuests == guestCount ? FlutterFlowTheme.of(context).primary : Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(8),
                      color: selectedGuests == guestCount ? Colors.teal.withOpacity(0.1) : Colors.white,
                    ),
                    alignment: Alignment.center,
                    child: Text('$guestCount'),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            const Text("When are you visiting?", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(dates.length, (index) {
                return GestureDetector(
                  onTap: () => setState(() => selectedDateIndex = index),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: selectedDateIndex == index ? FlutterFlowTheme.of(context).primary : Colors.grey[400]!,
                      width: selectedDateIndex == index ? 2 : 1
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(index == 0 ? "Today" : "Day", style: TextStyle(fontSize: 12)),
                        Text(dates[index], style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 5),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text("25% off", style: TextStyle(color: Colors.white, fontSize: 10)),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            const Text("Select the time of day to see the offers", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.wb_sunny_outlined),
                      SizedBox(width: 8),
                      Text("Lunch (12:00 PM to 05:00 PM)"),
                    ],
                  ),
                  SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(times.length, (index) {
                      return GestureDetector(
                        onTap: () => setState(() => selectedLunchTimeIndex = index),
                        child: Container(
                          width: 80,
                          padding: EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: selectedLunchTimeIndex == index ? FlutterFlowTheme.of(context).primary : Colors.grey[400]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Text(times[index]),
                              Text("25% off", style: TextStyle(fontSize: 10)),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.nights_stay_outlined),
                  SizedBox(width: 8),
                  Text("Dinner (05:00 PM to 01:00 AM)"),
                ],
              ),
            ),
            const Spacer(),
            
            FFButtonWidget(text: 'Save',
                onPressed: (){},
                options: buttonStyle(context)
            ),

          ],
        ),
      ),
    );
  }
}
