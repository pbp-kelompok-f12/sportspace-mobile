class Booking {
  final String id;
  final String username;
  final String venueName;
  final String bookingDate;
  final String startTime;
  final String endTime;
  final String customerName;
  final String customerEmail;
  final String customerPhone;

  Booking({
    required this.id,
    required this.username,
    required this.venueName,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      username: json['username'],
      venueName: json['venue_name'],
      bookingDate: json['booking_date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      customerName: json['customer_name'],
      customerEmail: json['customer_email'],
      customerPhone: json['customer_phone'],
    );
  }
}