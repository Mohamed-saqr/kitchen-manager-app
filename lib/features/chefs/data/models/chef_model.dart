
class ChefModel {
  final String id;
  final String name;
  final String position;
  final String specialty;
  final String image;
  final String nationalId;
  final String address;
  final String phone;          // 👈 رقم الهاتف الأساسي
  final String? secondaryPhone; // 👈 رقم هاتف إضافي (اختياري)
  final double foodSafety;
  final double hygiene;
  final double attendance;
  final double wasteControl;

  ChefModel({
    required this.id,
    required this.name,
    required this.position,
    required this.specialty,
    required this.image,
    required this.nationalId,
    required this.address,
    required this.phone,        // 👈 مطلوب
    this.secondaryPhone,        // 👈 اختياري
    this.foodSafety = 0.0,
    this.hygiene = 0.0,
    this.attendance = 0.0,
    this.wasteControl = 0.0,
  });

  // حساب متوسط التقييم (KPIs)
  double get averageRating {
    double total = foodSafety + hygiene + attendance + wasteControl;
    return total > 0 ? (total / 4) : 0.0;
  }

  // 🟢 تحويل من Map (Firebase/Hive) إلى Model
  factory ChefModel.fromMap(Map<String, dynamic> map, String key) {
    return ChefModel(
      id: key,
      name: map['name'] ?? '',
      position: map['position'] ?? '',
      specialty: map['specialty'] ?? '',
      image: map['image'] ?? '',
      nationalId: map['nationalId'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',                // 👈 قراءة رقم الهاتف
      secondaryPhone: map['secondaryPhone'],    // 👈 قراءة الرقم الإضافي
      foodSafety: (map['food_safety'] ?? 0.0).toDouble(),
      hygiene: (map['hygiene'] ?? 0.0).toDouble(),
      attendance: (map['attendance'] ?? 0.0).toDouble(),
      wasteControl: (map['waste_control'] ?? 0.0).toDouble(),
    );
  }

  // 🟢 تحويل من Model إلى Map للرفع على Firebase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'position': position,
      'specialty': specialty,
      'image': image,
      'nationalId': nationalId,
      'address': address,
      'phone': phone,                         // 👈 رفع رقم الهاتف
      'secondaryPhone': secondaryPhone,       // 👈 رفع الرقم الإضافي
      'food_safety': foodSafety,
      'hygiene': hygiene,
      'attendance': attendance,
      'waste_control': wasteControl,
      'rating': averageRating,
    };
  }
}