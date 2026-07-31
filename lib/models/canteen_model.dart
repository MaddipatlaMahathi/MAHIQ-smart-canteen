class CanteenModel {
  final String canteenId;
  final String canteenName;
  final String imageUrl;
  final String location;
  final String contactNumber;
  final int queueLength;
  final String status;
  final Map<String, int> slotOrders;

  CanteenModel({
    required this.canteenId,
    required this.canteenName,
    required this.imageUrl,
    this.location = '',
    this.contactNumber = '',
    this.queueLength = 0,
    this.status = 'Open',
    this.slotOrders = const {},
  });

  factory CanteenModel.fromMap(Map<String, dynamic> map, String documentId) {
    return CanteenModel(
      canteenId: documentId,
      canteenName: map['canteenName'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      location: map['location'] ?? '',
      contactNumber: map['contactNumber'] ?? '',
      queueLength: map['queueLength'] ?? 0,
      status: map['status'] ?? 'Open',
      slotOrders: map['slotOrders'] != null 
          ? Map<String, int>.from(map['slotOrders'])
          : {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'canteenName': canteenName,
      'imageUrl': imageUrl,
      'location': location,
      'contactNumber': contactNumber,
      'queueLength': queueLength,
      'status': status,
      'slotOrders': slotOrders,
    };
  }
}
