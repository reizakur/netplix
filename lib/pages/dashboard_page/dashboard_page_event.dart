part of 'dashboard_page_bloc.dart';

@immutable
abstract class DashboardPageEvent {
  const DashboardPageEvent();
}

class PickImage extends DashboardPageEvent {}

class InputTamu extends DashboardPageEvent {
  String checkIn;
  String checkOut;
  String guessName;
  String companY;
  String plateNumber;
  String employeName;
  String permisioN;
  String needfoR;
  String noteS;
  String pathCard;
  InputTamu({
    required this.checkIn,
    required this.checkOut,
    required this.guessName,
    required this.companY,
    required this.plateNumber,
    required this.employeName,
    required this.permisioN,
    required this.needfoR,
    required this.noteS,
    required this.pathCard,
  });
}

class UpdateEmployeeNameEvent extends DashboardPageEvent {
  final String employeNameVar;

  UpdateEmployeeNameEvent({required this.employeNameVar});
}

class pickImage extends DashboardPageEvent {
 
}

class FetchdataGuess extends DashboardPageEvent {
  
}


class ContainerText extends DashboardPageEvent {
  String? data;

  ContainerText({this.data});
}

class ScanBarcode extends DashboardPageEvent {
  String? code;
  ScanBarcode({this.code});
}

class CheckOuts extends DashboardPageEvent {
  String? id_guess;
  CheckOuts({this.id_guess});
}



class needForEvents extends DashboardPageEvent {
  String needForVar;

  needForEvents({required this.needForVar});
}

class guessNameEvents extends DashboardPageEvent {
  String guessNameVar;

  guessNameEvents({required this.guessNameVar});
}

class plateNumberEvents extends DashboardPageEvent {
  String plateNumberVar;

  plateNumberEvents({required this.plateNumberVar});
}

class employeNameEvents extends DashboardPageEvent {
  String employeNameVar;

  employeNameEvents({required this.employeNameVar});
}

class companyEvents extends DashboardPageEvent {
  String companyVar;

  companyEvents({required this.companyVar});
}

class notesEvents extends DashboardPageEvent {
  String notesVar;

  notesEvents({required this.notesVar});
}

// class PencarianDatas extends DashboardPageEvent {
//   String kalimat;

//   PencarianDatas({required this.kalimat});
// }

class EventSetStatus extends DashboardPageEvent {
  PageStatus status;
  EventSetStatus({required this.status});
}

class GenerateBarcodes extends DashboardPageEvent {
  String nocode;
  String? nameguess;
  String? status;
  GenerateBarcodes({required this.nocode,this.nameguess,this.status});
}


class GenerateBarcodesOnline extends DashboardPageEvent {
  String nocode;
  String? nameguess;
  String? status;
  GenerateBarcodesOnline({required this.nocode,this.nameguess,this.status});
}



class RadioOptionChanged extends DashboardPageEvent {
  final String selectedOption;
  RadioOptionChanged(this.selectedOption);
}

class UpdateSuggestionsEvent extends DashboardPageEvent {
  final List<String> lines;
 final File imageFile;

  UpdateSuggestionsEvent(this.lines,this.imageFile);
}

class ConnectBlue extends DashboardPageEvent {
  BluetoothDevice perangkat;

  ConnectBlue({required this.perangkat});
}

class DisconnectBlue extends DashboardPageEvent {}

class ListGuestView extends DashboardPageEvent {
  ListGuestView();
}

class BarcodeScanned extends DashboardPageEvent {
  String barcode;
  BarcodeScanned(this.barcode);
}

class EventLoadData extends DashboardPageEvent {
  List<BluetoothDevice> devices;
  EventLoadData({required this.devices});
}

class loadDatas extends DashboardPageEvent {
  loadDatas();
}

class PendingTreatmentEventChangePrinter extends DashboardPageEvent {
  final BluetoothDevice? value;
  PendingTreatmentEventChangePrinter({required this.value});
}
