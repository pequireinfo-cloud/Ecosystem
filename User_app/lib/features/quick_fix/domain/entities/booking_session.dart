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
  String? userId;
  double? price;
  dynamic pickupLocation;
  String? pickupAddress;


  BookingSession({
    required this.category, 
    this.price,
    this.userId,
    this.pickupLocation,
    this.pickupAddress,
  });
}

class LaundryItem {
  final int id;
  String? rawImageData; // Using a string to mock/hold file path/base64 for web
  String? fabricType;

  LaundryItem({required this.id});
}
