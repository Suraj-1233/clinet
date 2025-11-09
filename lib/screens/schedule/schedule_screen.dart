import 'package:flutter/material.dart';
import '../../widgets/schedule_card.dart';

class ScheduleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Dummy data for scheduled pickups
    final List<Map<String, String>> schedules = [
      {
        'pickupDate': '25 Oct 2025',
        'pickupTime': '10:00 AM',
        'address': '123, MG Road, Jaunpur',
        'status': 'Pending'
      },
      {
        'pickupDate': '27 Oct 2025',
        'pickupTime': '02:00 PM',
        'address': '456, Station Road, Jaunpur',
        'status': 'Scheduled'
      },
      {
        'pickupDate': '30 Oct 2025',
        'pickupTime': '11:30 AM',
        'address': '789, Civil Line, Jaunpur',
        'status': 'Completed'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to new pickup scheduling screen
              },
              icon: Icon(Icons.add),
              label: Text('Schedule New Pickup'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: schedules.length,
                itemBuilder: (context, index) {
                  final item = schedules[index];
                  return ScheduleCard(
                    pickupDate: item['pickupDate']!,
                    pickupTime: item['pickupTime']!,
                    address: item['address']!,
                    status: item['status']!,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
