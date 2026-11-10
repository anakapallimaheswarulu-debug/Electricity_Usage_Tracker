class ElectricityReading {
  final int? id;
  final int userId;
  final double previousReading;
  final double currentReading;
  final double units;
  final double billAmount;
  final String date;

  ElectricityReading({
    this.id,
    required this.userId,
    required this.previousReading,
    required this.currentReading,
    required this.units,
    required this.billAmount,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'previous_reading': previousReading,
      'current_reading': currentReading,
      'units': units,
      'bill_amount': billAmount,
      'date': date,
    };
  }

  factory ElectricityReading.fromMap(
    Map<String, dynamic> map,
  ) {
    return ElectricityReading(
      id: map['id'],
      userId: map['user_id'] as int,
      previousReading:
          (map['previous_reading'] as num).toDouble(),
      currentReading:
          (map['current_reading'] as num).toDouble(),
      units: (map['units'] as num).toDouble(),
      billAmount:
          (map['bill_amount'] as num).toDouble(),
      date: map['date'] as String,
    );
  }
}