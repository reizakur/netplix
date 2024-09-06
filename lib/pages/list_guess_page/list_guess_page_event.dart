part of 'list_guess_page_bloc.dart';

@immutable
abstract class ListGuessPageEvent {
  const ListGuessPageEvent();
}

class FetchdataGuess extends ListGuessPageEvent {
  
}

class EventSetStatuslist extends ListGuessPageEvent {
  PageStatuslist status;
  EventSetStatuslist({required this.status});
}

class CheckOutslist extends ListGuessPageEvent {
    String? id_guess;
    CheckOutslist({this.id_guess});
}
 
class PencarianDatas extends ListGuessPageEvent {
  String kalimat;

  PencarianDatas({required this.kalimat});
}


class GenerateBarcodes extends ListGuessPageEvent {
  String nocode;
  String? nameguess;
  GenerateBarcodes({required this.nocode,this.nameguess});
}
class Reprint extends ListGuessPageEvent {
  String? id_guess;
    Reprint({this.id_guess});
}



class SendData extends ListGuessPageEvent {
  
}


// class ListGuessPageEvent {
//   final List<DataKendaraan>? data; // Replace with your actual data model
//   final String? error;

//   ListGuessPageEvent({this.data, this.error});
// }



