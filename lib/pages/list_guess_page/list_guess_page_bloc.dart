import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:visito/models/datatamu.dart';
import 'package:http/http.dart' as http;
import 'package:visito/pages/dashboard_page/dashboard_page_bloc.dart';
import 'package:visito/system_parameter/system_parameter_cubit.dart';
import 'package:visito/system_parameter/tamu_controller/tamu_controller_cubit.dart';

part 'list_guess_page_event.dart';
part 'list_guess_page_state.dart';

class ListGuessPageBloc extends Bloc<ListGuessPageEvent, ListGuessPageState> {
  ListGuessPageBloc({required BuildContext context})
      : super(ListGuessPageState()) {
    // TODO: implement event handler
    systemParameterCubit = context.read<SystemParameterCubit>();
    on(mapEvent);
    add(FetchdataGuess());
    dbGuess = TamuControllerCubit(systemParameterCubit: systemParameterCubit);
  }
  BlueThermalPrinter printer = BlueThermalPrinter.instance;

  late SystemParameterCubit systemParameterCubit;
  late TamuControllerCubit dbGuess;
  Future<void> initialProcess({bool createInitialOrder = true}) async {
    // await loadDatas();=
  }

  Future<void> mapEvent(
      ListGuessPageEvent event, Emitter<ListGuessPageState> emit) async {
    if (event is FetchdataGuess) {
      //  try {
      // Fetch data from the database
      final String url = 'http://uhuy.com';

      http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Print the parsed JSON object

        // Check if it contains a list under a specific key (adjust key as needed)
        if (jsonResponse.containsKey('data')) {
          final List<dynamic> jsonData = jsonResponse['data'];

          // Convert JSON data to a list of DataKendaraan
          final List<DataKendaraan> dataList =
              jsonData.map((data) => DataKendaraan.fromJson(data)).toList();

          // Print the list of DataKendaraan objects

          await dbGuess.deleteOnline();

          // Add records to the database
          for (var datakendaraan in dataList) {
            int lastInsertedId = await dbGuess.addRecordsOcr(datakendaraan);
          }
        } else {}
      } else {
        final String url = 'http://kaka.com';

        http.Response response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          // Parse the JSON response
          final List<dynamic> jsonData = json.decode(response.body);
        } else {
          throw Exception('Failed to load data');
        }
        List<DataKendaraan> data = await dbGuess
            .fetchGuessall(); // Adjust this based on your actual method

        emit(state.copyWith(datas: data));

        // throw Exception('Failed to load data');
      }
      List<DataKendaraan> data = await dbGuess
          .fetchGuessall(); // Adjust this based on your actual method

      emit(state.copyWith(datas: data));
    } else if (event is CheckOutslist) {
      int lastInsertedId = await dbGuess.checkOut(event.id_guess.toString());
      add(FetchdataGuess());
      // add(EventSetStatuslist(status: PageStatuslist.checkoutCompleted));
    } else if (event is SendData) {
      List<DataKendaraan> data = await dbGuess
          .fetchGuessall(); // Adjust this based on your actual method
      int length = data.length;
      print(length);
      List<Map> finalMapList = [];
      for (int i = 0; i < length; i++) {
        Map newMap = {
          'checkIn': data[i].checkIn,
          'checkOut': data[i].checkOut,
          'companY': data[i].companY,
          'createdAt': data[i].createdAt,
          'employeName': data[i].employeName,
          'guessName': data[i].guessName,
          'id_guess': data[i].id_guess,
          'needfoR': data[i].needfoR,
          'noteS': data[i].noteS,
          'pathCard': data[i].pathCard,
          // 'permisioN': data[i].permisioN,
          'plateNumber': data[i].plateNumber,
        };

        finalMapList.add(newMap);
      }
    } else if (event is Reprint) {
      Map<String, dynamic>? findcode =
          await dbGuess.reprint(event.id_guess.toString());

      if (findcode != null) {
        // Use the data from the findcode map to create a DataKendaraan object
        DataKendaraan datakendaraan = DataKendaraan.fromMap(map: findcode);

        String employeName = datakendaraan.guessName;
        final firstName = employeName.split(' ').first.toUpperCase();
        String checkInset = datakendaraan.checkIn;

        // DateTime parsedDateTime = DateTime.parse(checkInset);
        // String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm').format(parsedDateTime);

        printer.printCustom(
            "POLO || ROTIO || KEDATON SPA || D'PRIMA || BEARDS PAPA'S || WOO",
            2,
            1);
        printer.printCustom("-------------------", 2, 1);
        printer.printCustom("${firstName}", 2, 1);
        printer.printNewLine();
        printer.printNewLine();
        printer.printCustom("Nama: ${employeName}", 1, 0);
        printer.printCustom("Jam Masuk: ${datakendaraan.checkIn}", 1, 0);
        printer.printCustom("Perusahaan: ${datakendaraan.companY}", 1, 0);
        // printer.printCustom("N0 Kendaraan: ${datakendaraan.plateNumber}", 1, 0);
        printer.printCustom("Bertemu: ${datakendaraan.employeName}", 1, 0);
        printer.printCustom("Keperluan: ${datakendaraan.needfoR}", 1, 0);
        // printer.printCustom("Janji: ${datakendaraan.permisioN}", 1, 0);
        printer.printCustom("Note: ${datakendaraan.noteS}", 1, 0);
        printer.printNewLine();
        printer.printCustom("${datakendaraan.needfoR}", 2, 1);
        printer.printNewLine();
        printer.printNewLine();
        add(GenerateBarcodes(
            nocode: datakendaraan.id_guess,
            nameguess: datakendaraan.employeName));
        // printer.paperCut();
      } else {}
    } else if (event is GenerateBarcodes) {
      await printQrCode(event.nocode);
      printer.printNewLine();
      printer.printCustom("${event.nocode}", 1, 1);
      printer.printNewLine();
      printer.printCustom("Paraf:", 1, 2);
      printer.printNewLine();
      printer.printNewLine();
      printer.printCustom("[Security] -- [${event.nameguess}]", 1, 2);
      printer.printNewLine();
      printer.paperCut();
    } else if (event is PencarianDatas) {
      print(event.kalimat);
      String searchTerm = event.kalimat.toLowerCase();
      List<DataKendaraan> filteredData = state.datas.where((data) {
        // Convert the fields to lowercase for comparison
        return data.guessName.toLowerCase().contains(searchTerm) ||
            data.id_guess.toLowerCase().contains(searchTerm);
      }).toList();
      print(filteredData);
      emit(state.copyWith(serchProduk: filteredData));
    }
  }

  Future<void> printQrCode(String data) async {
    try {
      final qrValidationResult = QrValidator.validate(
        data: data,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.H,
      );

      if (qrValidationResult.status == QrValidationStatus.valid) {
        final qrCode = qrValidationResult.qrCode!;
        final painter = QrPainter.withQr(
          qr: qrCode,
          color: const Color.fromARGB(255, 24, 13, 13),
          emptyColor: Colors.white,
          gapless: true,
        );

        final picData = await painter.toImageData(
          150,
          format: ImageByteFormat.png,
        );
        final buffer = picData!.buffer.asUint8List();

        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/qr_code.png';
        await File(filePath).writeAsBytes(buffer);

        final imageFile = File(filePath);
        if (await imageFile.exists()) {
          final imageBytes = await imageFile.readAsBytes();
          printer.printImageBytes(Uint8List.fromList(imageBytes));
        } else {}
      } else {}
    } catch (e) {}
  }
}
