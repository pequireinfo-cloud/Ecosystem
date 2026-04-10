class BookingSession {
  final String category; // 'Plumbing Services', 'Electrical Works', 'Laundry & Dry Clean', 'Carpentry'
  
  // Trades fields
  String? selectedProblem;
  String? selectedAppliance;
  
  // Laundry fields
  int? numberOfClothes;
  List<LaundryItem>? laundryItems;

  // Booking context
  String? bookingId;

  BookingSession({required this.category});
}

class LaundryItem {
  final int id;
  String? rawImageData; // Using a string to mock/hold file path/base64 for web
  String? fabricType;

  LaundryItem({required this.id});
}
