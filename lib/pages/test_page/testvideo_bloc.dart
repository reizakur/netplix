import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:path/path.dart';
import 'package:visito/models/datatamu.dart';
import 'package:visito/system_parameter/system_parameter_cubit.dart';
import 'package:visito/system_parameter/tamu_controller/tamu_controller_cubit.dart';

import 'package:path/path.dart' as path;
import 'package:flutter_bloc/flutter_bloc.dart';
part 'testvideo_event.dart';
part 'testvideo_state.dart';

class TestvideoBloc extends Bloc<TestvideoEvent, TestvideoState> {
  TestvideoBloc({required BuildContext context}) : super(TestvideoState()) {
    systemParameterCubit = context.read<SystemParameterCubit>();

    on(mapEvent);

    add(FetchdataGuess());
    dbGuess = TamuControllerCubit(systemParameterCubit: systemParameterCubit);
  }

  late TamuControllerCubit dbGuess;
  late SystemParameterCubit systemParameterCubit;

  Future<void> mapEvent(
      TestvideoEvent event, Emitter<TestvideoState> emit) async {
    if (event is FetchdataGuess) {
      try {
        // Replace API call with hardcoded JSON data
        const jsonString = '''
    {
      "status": "success",
      "data": [
        {
          "id_guess": "",
          "check_in": "2024-09-04 16:34:26.868185",
          "check_out": null,
          "guess_name": "https://www.youtube.com/watch?v=kn6-c223DUU&list=RD8PTDv_szmL0&index=4",
          "company": "https://pbs.twimg.com/media/ERsp6V1VUAAgkJp.jpg",
          "plate_number": "",
          "employe_name": "BUCIN",
          "permission": "",
          "notes": "082264732324",
          "path_card": "",
          "created_at": "2024-09-04 16:34:26.868185",
          "id": "1797",
          "purpose": "INTERVIEW",
          "path_guess": "gambar/66d829a2d69ad0.24078978.png"
        },
        {
          "id_guess": "",
          "check_in": "2024-09-04 16:31:41.853413",
          "check_out": null,
          "guess_name": "https://www.youtube.com/watch?v=oysxI1GLF4g&list=RDoysxI1GLF4g&start_radio=1",
          "company": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRYdhQbGglSYtuMRgHdKxFRzkKkZcHIlDu8-Q&s",
          "plate_number": "",
          "employe_name": "PELANGI TANPA WARNA",
          "permission": "",
          "notes": "082264732492",
          "path_card": "",
          "created_at": "2024-09-04 16:31:41.853413",
          "id": "1795",
          "purpose": "INTERVIEW",
          "path_guess": "gambar/66d828fdd30a03.23008830.png"
        },
        {
          "id_guess": "",
          "check_in": "2024-09-04 16:31:56.859025",
          "check_out": null,
          "guess_name": "https://www.youtube.com/watch?v=5JzoGCFYf04",
          "company": "https://i.pinimg.com/originals/e8/15/a0/e815a09ba462af1f26bacf363843f37f.jpg",
          "plate_number": "",
          "employe_name": "MERINDU CAHAYA",
          "permission": "",
          "notes": "08226473249222",
          "path_card": "",
          "created_at": "2024-09-04 16:31:56.859025",
          "id": "1796",
          "purpose": "INTERVIEW",
          "path_guess": "gambar/66d8290cd43886.44335381.png"
        },
        {
          "id_guess": "",
          "check_in": "2024-09-04 16:30:14.475473",
          "check_out": null,
          "guess_name": "https://www.youtube.com/watch?v=sU6wC6FC72U",
          "company": "https://i.pinimg.com/736x/49/99/77/4999779e55537d809b0d8e6fde804c34.jpg",
          "plate_number": "",
          "employe_name": "Bulan Diatas Kuuran",
          "permission": "",
          "notes": "082260802616",
          "path_card": "",
          "created_at": "2024-09-04 16:30:14.475473",
          "id": "1792",
          "purpose": "INTERVIEW",
          "path_guess": "gambar/66d828a676dfa3.21187762.png"
        },
        {
"id_guess":"",
"check_in":"2024-09-04 16:31:06.063635",
"check_out":null,
"guess_name":"https:\/\/www.youtube.com\/watch?v=am5py-Eu03s",
"company":"https:\/\/encrypted-tbn0.gstatic.com\/images?q=tbn:ANd9GcRWjIdADhRPlL8SQvc7IUCEUzFr4H3csoqF7w&s",
"plate_number":"",
"employe_name":"GALAKSI",
"permission":"",
"notes":"08226473242",
"path_card":"",
"created_at":"2024-09-04 16:31:06.063635",
"id":"1793",
"purpose":"INTERVIEW",
"path_guess":"gambar\/66d828da1231c8.11291606.png"
},
{
"id_guess":"",
"check_in":"2024-09-04 16:31:24.4936",
"check_out":null,
"guess_name":"https:\/\/www.youtube.com\/watch?v=wVRnxFITGK0",
"company":"https:\/\/cinemags.org\/wp-content\/uploads\/2023\/11\/JCSDFF_Main-Poster_IG-Rev-1.jpeg",
"plate_number":"",
"employe_name":"JATUH CINTA SEPERTI DI FILM FILM",
"permission":"",
"notes":"082264732499",
"path_card":"",
"created_at":"2024-09-04 16:31:24.4936",
"id":"1794",
"purpose":"INTERVIEW",
"path_guess":"gambar\/66d828ec7b35c2.03455000.png"
}
      ]
    }
    ''';

        // Decode the JSON response
        Map<String, dynamic> jsonData = json.decode(jsonString);

        // Check if the JSON has a 'data' key and is a list
        if (jsonData.containsKey('data') && jsonData['data'] is List) {
          // Convert the list of JSON objects to List<DataKendaraan>
          List<DataKendaraan> data = (jsonData['data'] as List)
              .map((item) => DataKendaraan.fromJson(item))
              .toList();

          emit(state.copyWith(datas: data));
        } else {
          print(
              'Unexpected JSON format: Missing "data" key or data is not a list');
        }
      } catch (e) {
        print('Error parsing JSON: $e');
      }
    }
  }
}
