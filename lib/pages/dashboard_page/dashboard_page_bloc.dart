import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:visito/models/datatamu.dart';
import 'package:visito/system_parameter/system_parameter_cubit.dart';
import 'package:visito/system_parameter/tamu_controller/tamu_controller_cubit.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'dart:convert';
part 'dashboard_page_event.dart';
part 'dashboard_page_state.dart';

class DashboardPageBloc extends Bloc<DashboardPageEvent, DashboardPageState> {
  DashboardPageBloc({required BuildContext context})
      : super(DashboardPageState()) {
    systemParameterCubit = context.read<SystemParameterCubit>();

    on(mapEvent);
    add(FetchdataGuess());
    dbGuess = TamuControllerCubit(systemParameterCubit: systemParameterCubit);
    add(loadDatas());
  }

  // late APIPointOfSaleService apiPos;
  BlueThermalPrinter printer = BlueThermalPrinter.instance;
  late SystemParameterCubit systemParameterCubit;
  late TamuControllerCubit dbGuess;
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _device;

  final textRecognizer = TextRecognizer();
  Future<void> initialProcess() async {}

  Future<void> loadData() async {
    try {
      _devices = await BlueThermalPrinter.instance.getBondedDevices();
    } catch (e) {}
    add(EventLoadData(
      devices: _devices,
    ));
  }

  Future<void> mapEvent(
      DashboardPageEvent event, Emitter<DashboardPageState> emit) async {
    if (event is InputTamu) {
      final uuid = Uuid();
      String generatedNik = uuid.v1();
      DateTime checkInDate = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd').format(checkInDate);

      String idprimary = await dbGuess.fetchPrimaryKey(formattedDate);

      String newId;
      if (idprimary.isEmpty) {
        String dateformat = DateFormat('yyyyMMdd').format(checkInDate);
        newId = '${dateformat}00001';
      } else {
        int incrementedId = int.parse(idprimary) + 1;
        newId = incrementedId.toString().padLeft(idprimary.length, '0');
      }

      Map<String, dynamic> maps = {
        'id_guess': newId,
        'check_in': DateTime.now().toString(),
        'guess_name': event.guessName,
        'company': event.companY,
        'path_card': event.pathCard,
        'plate_number': event.plateNumber,
        'employe_name': event.employeName,
        'permission': 'OFFLINE',
        'need_for': event.needfoR,
        'notes': event.noteS,
        'created_at': DateFormat('yyyy-MM-dd').format(DateTime.now())
      };

      DataKendaraan datakendaraan = DataKendaraan.fromMap(map: maps);

      DateTime now = DateTime.now();

      // Define the format you want
      String format = 'yyyy-MM-dd HH:mm:ss';

      // Create a formatter
      DateFormat dateFormat = DateFormat(format);

      // Format the DateTime object
      String checkIn = dateFormat.format(now);
      String checkOut = state.checkOut.text;
      String guessName = state.guessName.text;
      String companY = state.companY.text;
      String plateNumber = state.plateNumber.text;
      String employeName = state.employeName.text;
      // String permisioN = state.selectedOption.toString();

      String needfoR = state.needfoR.text;
      String noteS = state.noteS.text;
      String pathCard = state.image.toString();
      final firstName = guessName.split(' ').first.toUpperCase();
      String checkInset = '${checkIn}';

      // DateTime parsedDateTime = checkInset;

      // String formattedDateTime =
      //     DateFormat('yyyy-MM-dd HH:mm').format(checkInset);

      int lastInsertedId = await dbGuess.addRecordsOcr(datakendaraan);

      if (lastInsertedId > 0) {
        printer.printCustom(
            "POLO || ROTIO || KEDATON SPA || D'PRIMA || BEARDS PAPA'S || WOO",
            2,
            1);
        printer.printCustom("-------------------", 2, 1);
        printer.printCustom("${firstName}", 2, 1);
        printer.printNewLine();
        printer.printNewLine();
        printer.printCustom("Nama: ${guessName}", 1, 0);
        printer.printCustom("Jam Masuk: ${checkIn}", 1, 0);
        printer.printCustom("Perusahaan: ${companY}", 1, 0);
        printer.printCustom("Bertemu: ${employeName}", 1, 0);
        printer.printCustom("Keperluan: ${needfoR}", 1, 0);
        printer.printCustom("Note: ${noteS}", 1, 0);
        printer.printNewLine();
        printer.printCustom("${needfoR}", 2, 1);
        printer.printNewLine();
        printer.printNewLine();
        add(GenerateBarcodes(nocode: newId, nameguess: employeName));
      } else {}

      List<DataKendaraan> dataguess = await dbGuess.fetchbeforetodays();

      int length = dataguess.length;
      List<Map<String, dynamic>> finalMapList = [];
      List<File> imageFiles = []; // Add your logic to populate this list

      for (int i = 0; i < length; i++) {
        Map<String, dynamic> newMap = {
          'id_guess': dataguess[i].id_guess,
          'check_in': dataguess[i].checkIn,
          'check_out': dataguess[i].checkOut == '0'
              ? DateTime.now().toIso8601String()
              : dataguess[i].checkOut,
          'guess_name': dataguess[i].guessName,
          'path_card': dataguess[i].pathCard,
          'company': dataguess[i].companY,
          'plate_number': dataguess[i].plateNumber,
          'employe_name': dataguess[i].employeName,
          // 'permission': dataguess[i].permisioN,
          'need_for': dataguess[i].needfoR,
          'notes': dataguess[i].noteS,
          'created_at': dataguess[i].createdAt
        };
        finalMapList.add(newMap);
        String filePath = dataguess[i]
            .pathCard
            .replaceFirst("File: '", '') // Remove "File: '"
            .replaceFirst("'", '');
        var file = File(filePath.toString());

        // if (file.existsSync()) {

        imageFiles.add(file);

        // } else {
        //
        // }
      }

      late Map<String, dynamic> apiResponse;
      try {
        apiResponse = await pushAllTransaction(
          map: finalMapList,
          imageFiles: imageFiles,
        );

        add(EventSetStatus(status: PageStatus.dashboard));
      } catch (e) {}
    } else if (event is BarcodeScanned) {
      emit(state.copyWith(scannedResult: event.barcode));
    } else if (event is FetchdataGuess) {
      try {
        // Fetch data from the database
        List<DataKendaraan> data = await dbGuess
            .fetchGuessDisc(); // Adjust this based on your actual method

        emit(state.copyWith(namakaryawan: data));
      } catch (e) {
        // emit(ListGuessPageEvent(error: e.toString())); // Emit error state if necessary
      }
    } else if (event is ListGuestView) {
      add(EventSetStatus(status: PageStatus.dataguess));
      add(EventSetStatus(status: PageStatus.idle));
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
    } else if (event is GenerateBarcodesOnline) {
      await printQrCodeOnline(event.nocode);
      printer.printNewLine();
      printer.printCustom("${event.nocode}", 1, 1);
      printer.printNewLine();
      printer.printCustom("Paraf:", 1, 2);
      printer.printNewLine();
      printer.printNewLine();
      printer.printCustom("[Security] -- [${event.nameguess}]", 1, 2);
      printer.printNewLine();
      printer.paperCut();
    } else if (event is EventSetStatus) {
      emit((state as DashboardPageState).copyWith(status: event.status));
    } else if (event is loadDatas) {
      await systemParameterCubit.loadFromPreferences();
      await loadData();
    } else if (event is PendingTreatmentEventChangePrinter) {
      emit(state.copyWith(
          selectedDevice: (event as PendingTreatmentEventChangePrinter).value));
    } else if (event is EventLoadData) {
      emit(state.copyWith(devices: event.devices));
    } else if (event is UpdateEmployeeNameEvent) {
      // Update the employee name in the state
      emit(state.copyWith(employeNameVar: event.employeNameVar));
    } else if (event is UpdateSuggestionsEvent) {
      emit(state.copyWith(isLoading: true));
      String cleanedData =
          event.lines.toString().replaceAll('[', '').replaceAll(']', '');
      // Split the data into individual entries
      List<String> entries =
          cleanedData.split('], [').map((e) => e.trim()).toList();

      // List to store potential names
      List<String> potentialNames = [];

      // Define keywords or patterns to exclude
      List<String> exclusionKeywords = [
        'NIK',
        'Nama',
        'Tempat',
        'Tanggal',
        'Tgl',
        'Beriaku',
        'KABUPATEN',
        'Lahir',
        'Jenis',
        'Kelamin',
        'Alamat',
        'RT',
        'RW',
        'Kelurahan',
        'Desa',
        'Kecamatan',
        'Agama',
        'Status',
        'JAWA',
        'Perkawinan',
        'Pekerjaan',
        'islam',
        'kristen',
        'hindu',
        'budha',
        'katolik',
        'konghucu',
        'protestan',
        'Kewarganegaraan',
        'WNI',
        'Berlaku',
        'Hingga',
        'Gol',
        'Darah',
        'Pegawai Negeri Sipil',
        'PNS',
        'Tentara Nasional Indonesia',
        'TNI',
        'Polisi Republik Indonesia',
        'Polri',
        'Swasta',
        'Pengusaha',
        'bekerja',
        'kawin',
        'Petani',
        'Nelayan',
        'Buruh',
        'Pelajar/Mahasiswa',
        'Pensiunan',
        'Karyawan',
        'Dokter',
        'Guru',
        'Perawat',
        'Advokat',
        'Akuntan',
        'Programmer',
        'Bidan',
        'Apoteker',
        'Arsitek',
        'Jurnalis',
        'daerah',
        'Kepala Desa',
        'Usahawan',
        'Wiraswasta',
        'Seniman',
        'Teknisi',
        'Driver',
        'Koki',
        'Desainer',
        'Laki-laki',
        'Perempuan',
        'belum',
        'mahasiswa',
        'pelajar',
        'hidup',
        'seumur',
        'PROVINSI',
        'barat',
        'timur',
        'selatan',
        'pusat',
        'kota',
        'Kewarga',
        'negara'
      ];

      // Process each entry to extract potential names
      for (String entry in entries) {
        // Split each entry by commas and trim extra spaces
        List<String> fields =
            entry.split(',').map((field) => field.trim()).toList();

        for (String field in fields) {
          // Check if the field is not in the exclusion list and does not contain numbers
          if (_isPotentialName(field, exclusionKeywords)) {
            // Convert to uppercase before adding to the potential names list
            potentialNames.add(field.toUpperCase());
          }
        }
      }
      // Print potential names for debugging

      List<String> singleNameList = potentialNames.isNotEmpty
          ? [potentialNames[0]]
          : []; // Create singleNameList based on potentialNames

// Check if singleNameList is not empty
      if (singleNameList.isNotEmpty) {
        // Convert the list to a string
        String getname = singleNameList
            .join(', '); // Join list elements with a comma if needed

        // Emit the state with the extracted name
        emit(state.copyWith(guessNameVar: getname));
      } else {
        // Handle the case when the list is empty, e.g., emit a default or empty string
        emit(state.copyWith(guessNameVar: ''));
      }

// Emit state with the image file
      emit(state.copyWith(image: event.imageFile));
    } else if (event is ScanBarcode) {
      //
      //zaaaaa
      add(EventSetStatus(status: PageStatus.loadingpop));
      try {
        String codeString = '${event.code.toString()}';

        String cleanedString =
            codeString.replaceAll('[', '').replaceAll(']', '');
        List<String> parts = cleanedString
            .split(',')
            .map((part) => part.trim().replaceAll("'", ""))
            .toList();

        String device = parts[0];
        String status = parts[1];
        String idcode = parts[2];

        add(EventSetStatus(status: PageStatus.dashboard));

//
        if (device == 'online') {
          if (status == 'in') {
            final String url = 'http://uhuy.com';

            try {
              Map data = {
                "id_guess": idcode,
                "status": status,
              };

              http.Response response =
                  await http.post(Uri.parse(url), body: data);

              if (response.statusCode == 200) {
                final Map<String, dynamic> responseData =
                    jsonDecode(response.body);

                final List<dynamic> dataList = responseData['data'];
                if (dataList.isNotEmpty) {
                  final Map<String, dynamic> dataEntry = dataList[0];

                  // Extract values
                  String guessName = dataEntry['guess_name'] ?? '';
                  String checkIn = dataEntry['check_in'] ?? '';
                  String company = dataEntry['company'] ?? '';
                  String employeName = dataEntry['employe_name'] ?? '';
                  String needfoR = dataEntry['purpose'] ?? '';
                  String noteS = dataEntry['notes'] ?? '';
                  String id = dataEntry['id'] ?? '';

                  // Print formatted data using printer.printCustom
                  printer.printCustom(
                      "POLO || ROTIO || KEDATON SPA || D'PRIMA || BEARDS PAPA'S || WOO",
                      2,
                      1);
                  printer.printCustom("-------------------", 2, 1);
                  // printer.printCustom(firstName, 2, 1); // Assuming firstName is defined somewhere
                  printer.printNewLine();
                  printer.printNewLine();
                  printer.printCustom("Nama: $guessName", 1, 0);
                  printer.printCustom("Jam Masuk: $checkIn", 1, 0);
                  printer.printCustom("Perusahaan: $company", 1, 0);
                  printer.printCustom("Bertemu: $employeName", 1, 0);
                  printer.printCustom("Keperluan: $needfoR", 1, 0);
                  printer.printCustom("Note: $noteS", 1, 0);
                  printer.printNewLine();
                  printer.printCustom("$needfoR", 2, 1);
                  printer.printNewLine();
                  printer.printNewLine();
                  add(GenerateBarcodesOnline(
                      nocode: id, nameguess: employeName, status: 'out'));

                  // add(GenerateBarcodes(nocode: id,nameguess:employeName,status: 'out' ));
                  // Add barcode generation or other tasks here
                  // Example: add(GenerateBarcodes(nocode: newId, nameguess: employeName));
                } else {}
              } else {
                final String url = 'http://kaka.com';
                Map data = {
                  "id_guess": idcode,
                  "status": status,
                };
                http.Response response =
                    await http.post(Uri.parse(url), body: data);

                if (response.statusCode == 200) {
                  final Map<String, dynamic> responseData =
                      jsonDecode(response.body);

                  final List<dynamic> dataList = responseData['data'];
                  if (dataList.isNotEmpty) {
                    final Map<String, dynamic> dataEntry = dataList[0];

                    // Extract values
                    String guessName = dataEntry['guess_name'] ?? '';
                    String checkIn = dataEntry['check_in'] ?? '';
                    String company = dataEntry['company'] ?? '';
                    String employeName = dataEntry['employe_name'] ?? '';
                    String needfoR = dataEntry['purpose'] ?? '';
                    String noteS = dataEntry['notes'] ?? '';
                    String id = dataEntry['id'] ?? '';

                    // Print formatted data using printer.printCustom
                    printer.printCustom(
                        "POLO || ROTIO || KEDATON SPA || D'PRIMA || BEARDS PAPA'S || WOO",
                        2,
                        1);
                    printer.printCustom("-------------------", 2, 1);
                    // printer.printCustom(firstName, 2, 1); // Assuming firstName is defined somewhere
                    printer.printNewLine();
                    printer.printNewLine();
                    printer.printCustom("Nama: $guessName", 1, 0);
                    printer.printCustom("Jam Masuk: $checkIn", 1, 0);
                    printer.printCustom("Perusahaan: $company", 1, 0);
                    printer.printCustom("Bertemu: $employeName", 1, 0);
                    printer.printCustom("Keperluan: $needfoR", 1, 0);
                    printer.printCustom("Note: $noteS", 1, 0);
                    printer.printNewLine();
                    printer.printCustom("$needfoR", 2, 1);
                    printer.printNewLine();
                    printer.printNewLine();
                    add(GenerateBarcodesOnline(
                        nocode: id, nameguess: employeName, status: 'out'));
                  }
                  //
                }
              }

              //    } else {
              //
              // }

              // add(EventSetStatus(status: PageStatus.loadingclose));
            } catch (e) {
              final String url = 'http://kaka.com';
              Map data = {
                "id_guess": idcode,
                "status": status,
              };
              http.Response response =
                  await http.post(Uri.parse(url), body: data);

              if (response.statusCode == 200) {
                final Map<String, dynamic> responseData =
                    jsonDecode(response.body);

                final List<dynamic> dataList = responseData['data'];
                if (dataList.isNotEmpty) {
                  final Map<String, dynamic> dataEntry = dataList[0];

                  // Extract values
                  String guessName = dataEntry['guess_name'] ?? '';
                  String checkIn = dataEntry['check_in'] ?? '';
                  String company = dataEntry['company'] ?? '';
                  String employeName = dataEntry['employe_name'] ?? '';
                  String needfoR = dataEntry['purpose'] ?? '';
                  String noteS = dataEntry['notes'] ?? '';
                  String id = dataEntry['id'] ?? '';

                  // Print formatted data using printer.printCustom
                  printer.printCustom(
                      "POLO || ROTIO || KEDATON SPA || D'PRIMA || BEARDS PAPA'S || WOO",
                      2,
                      1);
                  printer.printCustom("-------------------", 2, 1);
                  // printer.printCustom(firstName, 2, 1); // Assuming firstName is defined somewhere
                  printer.printNewLine();
                  printer.printNewLine();
                  printer.printCustom("Nama: $guessName", 1, 0);
                  printer.printCustom("Jam Masuk: $checkIn", 1, 0);
                  printer.printCustom("Perusahaan: $company", 1, 0);
                  printer.printCustom("Bertemu: $employeName", 1, 0);
                  printer.printCustom("Keperluan: $needfoR", 1, 0);
                  printer.printCustom("Note: $noteS", 1, 0);
                  printer.printNewLine();
                  printer.printCustom("$needfoR", 2, 1);
                  printer.printNewLine();
                  printer.printNewLine();
                  add(GenerateBarcodesOnline(
                      nocode: id, nameguess: employeName, status: 'out'));
                }
              }
            }
          } else {
            add(EventSetStatus(status: PageStatus.dashboard));

            try {
              final String url = 'http://uhuy.com';
              Map data = {
                "id_guess": idcode,
                "status": status,
              };
              http.Response response =
                  await http.post(Uri.parse(url), body: data);
              if (response.statusCode == 200) {
                final Map<String, dynamic> responseData =
                    jsonDecode(response.body);

                //
                if (responseData['status'] == 'success') {
                  add(EventSetStatus(status: PageStatus.loadingclose));

                  add(EventSetStatus(status: PageStatus.checkpop));
                  // add(EventSetStatus(status: PageStatus.idle));
                  //
                } else if (responseData['status'] == 'finish') {
                  add(EventSetStatus(status: PageStatus.loadingclose));
                  add(EventSetStatus(status: PageStatus.checkpop));
                  // add(EventSetStatus(status: PageStatus.idle));
                } else {}
              } else {}
            } catch (e) {
              final String url = 'http://kaka.com';
              Map data = {
                "id_guess": idcode,
                "status": status,
              };

              http.Response response =
                  await http.post(Uri.parse(url), body: data);
              if (response.statusCode == 200) {
                final Map<String, dynamic> responseData =
                    jsonDecode(response.body);

                //
                if (responseData['status'] == 'success') {
                  add(EventSetStatus(status: PageStatus.loadingclose));
                  add(EventSetStatus(status: PageStatus.checkpop));
                } else if (responseData['status'] == 'finish') {
                  add(EventSetStatus(status: PageStatus.loadingclose));
                  add(EventSetStatus(status: PageStatus.checkpop));
                } else {}
              } else {}
            }
          }
        } else {
          Map<String, dynamic>? findcode = await dbGuess.fetchguess(device);
        }

        // if (findcode == null) {
        //   if(event.code.toString() == ''){
        //
        //   add(EventSetStatus(status: PageStatus.checkoutCompleted));
        //   add(EventSetStatus(status: PageStatus.idle));
        //   }else{
        //
        //   add(EventSetStatus(status: PageStatus.gagal));
        //   }
        //   // add(EventSetStatus(status: PageStatus.dashboard));
        // } else {
        //
        //   if (findcode['check_out'] == 0) {
        //     add(EventSetStatus(status: PageStatus.checkoutready));
        //     add(EventSetStatus(status: PageStatus.idle));
        //   } else {
        //      await Future.delayed(Duration.zero, () async {
        //         add(CheckOuts(id_guess: event.code.toString()));
        //       });
        //     add(EventSetStatus(status: PageStatus.checkout));
        //     add(EventSetStatus(status: PageStatus.idle));
        //   }
        //     emit(state.copyWith(findcode: findcode));
        // }

        //
      } catch (e) {
        add(EventSetStatus(status: PageStatus.gagal));
      }
    } else if (event is CheckOuts) {
      int lastInsertedId = await dbGuess.checkOut(event.id_guess.toString());

      // add(EventSetStatus(status: PageStatus.checkoutCompleted));
      // add(EventSetStatus(status: PageStatus.idle));
    } else if (event is ConnectBlue) {
      BluetoothDevice device = event.perangkat;

      try {
        await BlueThermalPrinter.instance.connect(device);

        emit(state.copyWith(connected: true));
      } catch (e) {
        emit(state.copyWith(connected: false));
      }
    } else if (event is pickImage) {
      final ImagePicker _picker = ImagePicker();
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 50,
      );

      if (image != null) {
        final String imagePath = image.path; // Get the path of the image
        final File file = File(imagePath);

///////------

        final inputImage = InputImage.fromFile(file);

        try {
          final recognizedText = await textRecognizer.processImage(inputImage);
          List<String> lines = recognizedText.text.split('\n');

          add(UpdateSuggestionsEvent(lines, file));
        } catch (e) {
          // Handle text recognition errors
        }
      } else {}
    } else if (event is DisconnectBlue) {
      try {
        await BlueThermalPrinter.instance.disconnect();

        emit(state.copyWith(connected: false));
      } catch (e) {}
    } else if (event is ContainerText) {
      emit((state as DashboardPageState).copyWith(resultText: event.data));
    } else if (event is RadioOptionChanged) {
      emit(state.copyWith(selectedOption: event.selectedOption));
    } else if (event is PickImage) {
      final ImagePicker _picker = ImagePicker();
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        final String appDocPath = appDocDir.path;
        final String fileName = basename(pickedFile.path);
        final File localImage =
            await File(pickedFile.path).copy('$appDocPath/$fileName');

        emit(state.copyWith(image: localImage));
      }
    } else if (event is guessNameEvents) {
      final currentSelection = state.guessName.selection;

      final newGuessNameText = event.guessNameVar ?? state.guessName.text;
      emit(state.copyWith(guessNameVar: newGuessNameText));
      state.guessName.selection = currentSelection;
    } else if (event is plateNumberEvents) {
      final newPlateNumberText = event.plateNumberVar ?? state.plateNumber.text;
      emit(state.copyWith(plateNumberVar: newPlateNumberText));
    } else if (event is needForEvents) {
      final newNeedForText = event.needForVar ?? state.needfoR.text;
      emit(state.copyWith(needForVar: newNeedForText));
    } else if (event is employeNameEvents) {
      //
      final currentSelection = state.employeName.selection;

      // final newGuessNameText = event.guessNameVar ?? state.guessName.text;
      // emit(state.copyWith(guessNameVar: newGuessNameText));
      // state.guessName.selection = currentSelection;
      //
      //  final currentSelection = state.guessName.selection;

      final newEmployeNameText = event.employeNameVar ?? state.employeName.text;
      emit(state.copyWith(employeNameVar: newEmployeNameText));
      state.employeName.selection = currentSelection;
    } else if (event is companyEvents) {
      final currentSelection = state.companY.selection;
      final newCompanyText = event.companyVar ?? state.companY.text;
      emit(state.copyWith(companyVar: newCompanyText));
      state.companY.selection = currentSelection;
    } else if (event is notesEvents) {
      final currentSelection = state.noteS.selection;
      final newNotesText = event.notesVar ?? state.noteS.text;
      emit(state.copyWith(notesVar: newNotesText));
      state.noteS.selection = currentSelection;
    }
  }

  Future<Map<String, dynamic>> pushAllTransaction({
    required List<Map<String, dynamic>> map,
    required List<File> imageFiles, // List of image files to upload
  }) async {
    final String url = 'http://kaka.com';
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Add JSON data as a field
      request.fields['map'] = json.encode({'map': map});

      // Add image files as multipart files
      for (var file in imageFiles) {
        if (file == null || !await file.exists()) {
          continue; // Skip the iteration for null or invalid files
        }

        try {
          var fileStream = http.ByteStream(file.openRead());
          var length = await file.length();
          var multipartFile = http.MultipartFile(
            'path_card[]', // Use 'path_card[]' for multiple files
            fileStream,
            length,
            filename: file.path.split('/').last,
            contentType: MediaType('image', 'jpg'), // Adjust if needed
          );
          request.files.add(multipartFile);
        } catch (e) {}
      }

      // Send the request
      var response = await request.send();

      // Get the response from the server
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode.toString() == '200') {
        await dbGuess.deleteImgData(imageFiles.toString(), map);
        return json.decode(responseBody);

        //sini ya zaa
      } else {
        return {
          'code': 'HTTP ${response.statusCode}',
          'message': 'HTTP Request Error',
        };
      }
    } catch (e) {
      return {
        'code': e.toString(),
      };
    }
  }

  Future<void> printQrCode(String data) async {
    final jsonData = ['offline', 'in', '$data'];

    //    jsonEncode({
    //   'device': 'offline',
    //   'status': 'in',
    //   'id': data,
    // });
    try {
      final qrValidationResult = QrValidator.validate(
        data: jsonData.toString(),
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

  Future<void> printQrCodeOnline(String data) async {
    final jsonData = ['online', 'out', '$data'];
    //    jsonEncode({
    //   'device': 'online',
    //   'status': 'out',
    //   'id':'$data',
    // });

    try {
      final qrValidationResult = QrValidator.validate(
        data: jsonData.toString(),
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

bool _isPotentialName(String field, List<String> exclusionKeywords) {
  // Normalize field for comparison (trim and lowercase)
  String normalizedField = field.trim().toLowerCase();

  // Check if the normalized field is similar to any exclusion keyword
  bool isExcluded = exclusionKeywords.any((keyword) {
    // Normalize the keyword for comparison
    String normalizedKeyword = keyword.toLowerCase();

    // Check for exact match or partial match
    bool isExactMatch = normalizedField.contains(normalizedKeyword);
    bool isSimilar = _isSimilar(normalizedField, normalizedKeyword);

    if (isExactMatch) {}
    if (isSimilar) {}

    return isExactMatch || isSimilar;
  });

  // Check if the field is a valid name
  // - Should be in CAPS LOCK or Properly Capitalized
  // - Should not contain digits
  // - Should have a length greater than 2
  RegExp namePattern =
      RegExp(r'^[A-Z][A-Z\s]*$'); // Pattern for uppercase names
  bool isName = namePattern.hasMatch(field) &&
      field.length > 2 &&
      !_containsNumbers(field);

  return !isExcluded && isName;
}

bool _containsNumbers(String field) {
  // Check if the field contains any digits
  return RegExp(r'\d').hasMatch(field);
}

int _levenshteinDistance(String s1, String s2) {
  if (s1 == s2) return 0;
  final s1Len = s1.length;
  final s2Len = s2.length;
  final matrix =
      List.generate(s1Len + 1, (i) => List<int>.filled(s2Len + 1, 0));

  for (var i = 0; i <= s1Len; i++) matrix[i][0] = i;
  for (var j = 0; j <= s2Len; j++) matrix[0][j] = j;

  for (var i = 1; i <= s1Len; i++) {
    for (var j = 1; j <= s2Len; j++) {
      final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
      matrix[i][j] = [
        matrix[i - 1][j] + 1,
        matrix[i][j - 1] + 1,
        matrix[i - 1][j - 1] + cost,
      ].reduce((a, b) => a < b ? a : b);
    }
  }
  return matrix[s1Len][s2Len];
}

bool _isSimilar(String field, String keyword) {
  // Adjust the threshold as needed
  const threshold = 3;
  return _levenshteinDistance(field.toLowerCase(), keyword.toLowerCase()) <=
      threshold;
}
