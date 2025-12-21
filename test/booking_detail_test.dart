import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'package:sportspace_app/screens/booking_detail.dart';
import 'package:sportspace_app/screens/my_bookings.dart';

/// A lightweight fake of CookieRequest that returns canned responses
/// for the endpoints used by booking screens.
class FakeCookieRequest extends CookieRequest {
  @override
  Future<dynamic> get(String url) async {
    if (url.contains('lapangan-to-venue')) {
      return {'venue_id': '123e4567-e89b-12d3-a456-426614174000'};
    }
    if (url.contains('booking/api/venue-time-slots')) {
      return {
        'selected_date': '2025-01-01',
        'time_slots': [
          {
            'start_time': '10:00',
            'end_time': '11:00',
            'display': '10:00 - 11:00',
            'is_past': false,
            'is_booked': false,
            'is_unavailable': false,
          },
          {
            'start_time': '11:00',
            'end_time': '12:00',
            'display': '11:00 - 12:00',
            'is_past': false,
            'is_booked': true,
            'is_unavailable': true,
          },
        ],
      };
    }
    if (url.contains('booking/api/my-bookings-json')) {
      return {
        'results': [
          {
            'id': 'b1',
            'venue': {
              'id': 'v1',
              'name': 'Venue A',
              'location': 'Jakarta',
              'address': 'Jl. Sudirman',
              'image_url': '',
            },
            'booking_date': '2025-01-02',
            'start_time': '14:00',
            'end_time': '15:00',
            'customer_name': 'Tester',
            'customer_email': 'tester@example.com',
            'customer_phone': '+62123456789',
            'status': 'Booking on going',
            'is_past': false,
          }
        ],
      };
    }
    return {};
  }

  @override
  Future<dynamic> postJson(String url, dynamic body) async {
    // Simulate a successful create/update/delete
    return {'success': true, 'message': 'ok'};
  }
}

void main() {
  group('Booking screens smoke tests', () {
    testWidgets('BookingDetailPage shows slots and 7-day chips',
        (WidgetTester tester) async {
      final fakeRequest = FakeCookieRequest();
      await tester.pumpWidget(
        Provider<CookieRequest>.value(
          value: fakeRequest,
          child: const MaterialApp(
            home: BookingDetailPage(
              lapanganPk: 1,
              nama: 'Lapangan A',
              alamat: 'Jakarta',
              imageUrl: '',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show time slot text from fake response
      expect(find.text('10:00 - 11:00'), findsOneWidget);
      // Should render chips for date selection (Hari Ini + others)
      expect(find.byType(ChoiceChip), findsNWidgets(7));
    });

    testWidgets('MyBookingsPage shows booking card',
        (WidgetTester tester) async {
      final fakeRequest = FakeCookieRequest();
      await tester.pumpWidget(
        Provider<CookieRequest>.value(
          value: fakeRequest,
          child: const MaterialApp(
            home: MyBookingsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Venue A'), findsOneWidget);
      expect(find.textContaining('Tester'), findsOneWidget);
      expect(find.text('Booking on going'), findsOneWidget);
    });
  });
}


