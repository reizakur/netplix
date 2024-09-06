 
class DataKendaraan {
  late String id_guess;
  late String checkIn;
  late String checkOut;
  late String guessName;
  late String companY;
  late String plateNumber;
  late String employeName;
  late String permisioN;
  late String needfoR;
  late String noteS;
  late String pathCard; 
  late String createdAt;

DataKendaraan.fromJson(Map<String, dynamic> json)
      : id_guess = json['id'] ?? '',
        checkIn = json['check_in'] ?? '',
        checkOut = json['check_out']?.toString() ?? '',
        guessName = json['guess_name'] ?? '',
        companY = json['company'] ?? '',
        plateNumber = json['plate_number'] ?? '',
        employeName = json['employe_name'] ?? '',
        permisioN = 'ONLINE',
        needfoR = json['purpose'] ?? '',
        noteS = json['notes'] ?? '',
        pathCard = json['path_card'] ?? '',
        createdAt = json['created_at'] ?? '';


  DataKendaraan.fromMap({required Map map}) {
    id_guess = map['id_guess'] ?? '';
    checkIn = map['check_in'] ?? '';
    checkOut = map['check_out']?.toString() ?? '';
    guessName = map['guess_name'] ?? '';
    companY = map['company'] ?? '';
    plateNumber = map['plate_number'] ?? '';
    employeName = map['employe_name'] ?? '';
    permisioN = map['permission'] ?? '';
    needfoR = map['need_for'] ?? '';
    noteS = map['notes'] ?? '';
    pathCard = map['path_card'] ?? '';
    createdAt = map['created_at'] ?? '';
  }

  Map<String, dynamic> toMap() {
    return {
      'id_guess': id_guess,
      'check_in': checkIn,
      'check_out': '0',
      'guess_name': guessName,
      'company': companY,
      'plate_number': plateNumber,
      'employe_name': employeName,
      'permission': permisioN,
      'need_for': needfoR,
      'notes': noteS,
      'path_card': pathCard,
      'created_at': createdAt,
    };
  }
}
