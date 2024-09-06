import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// import 'package:flutter_vlc_player/flutter_vlc_player.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart'; // Add this import
part 'camera_ocr_widget_event.dart';
part 'camera_ocr_widget_state.dart';

class CameraOcrWidgetBloc
    extends Bloc<CameraOcrWidgetEvent, CameraOcrWidgetState> {
  // CameraOcrWidgetBloc.openExternalCamera()
  //     : super(CameraOcrWidgetStateExternal()) {
  //   on(mapEvent);
  //   add(const CameraOcrWidgetEventInitialExternalCamera());
  // }

  CameraOcrWidgetBloc.openInternalCamera()
      : super(CameraOcrWidgetStateInternal()) {
    on(mapEvent);
    add(const CameraOcrWidgetEventInitialInternalCamera());
  }

  void dispose({required CameraOcrWidgetState state}) {
    // if (state is CameraOcrWidgetStateExternal) {
    //   state.videoPlayerController!.pause();
    //   state.videoPlayerController!.dispose();
    // } 
     if (state is CameraOcrWidgetStateInternal) {
      if (state.cameraController != null) {
        state.cameraController!.dispose();
      }
    }
    // state.textRecognizer.close();
  }

  Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status == PermissionStatus.granted;
  }

  Future<void> initialInternalCameraProcess() async {
    CameraDescription? camera;
    List<CameraDescription> cameras = await availableCameras();
    for (var i = 0; i < cameras.length; i++) {
      final CameraDescription current = cameras[i];
      if (current.lensDirection == CameraLensDirection.back) {
        camera = current;
        break;
      }
    }
    if (camera != null) {
      add(CameraOcrWidgetEventIntSetCameraController(
          controller: CameraController(
        camera,
        ResolutionPreset.max,
        enableAudio: false,
      )));
    }
  }

  Future<void> mapEvent(
      CameraOcrWidgetEvent event, Emitter<CameraOcrWidgetState> emit) async {
    // void checkVideoState() {
    //   final controllerState = (state as CameraOcrWidgetStateExternal)
    //       .videoPlayerController!
    //       .value
    //       .playingState;
    //   add(CameraOcrWidgetEventToogleBuffering(
    //       value: controllerState == PlayingState.buffering));
    //   if (controllerState == PlayingState.stopped ||
    //       controllerState == PlayingState.error) {
    //     add(CameraOcrWidgetEventRestartCamera());
    //   }
    // }

    Future<void> takePic(CameraOcrWidgetStateInternal state) async {
      final pictureFile = await (state).cameraController!.takePicture();
      final file = File(pictureFile.path);
      final inputImage = InputImage.fromFile(file);
      final recognizedText =
          await state.textRecognizer.processImage(inputImage);
          print('cekdeh ${recognizedText}');
      // TODO Please check the result
      add(CameraOcrWidgetEventGetValue(value: recognizedText.text));
    }

    switch (event.runtimeType) {
      // Event Map for Internal Camera
      case CameraOcrWidgetEventInitialInternalCamera:
        emit(CameraOcrWidgetStateInternal());
        if (!await _requestCameraPermission()) {
          emit((state as CameraOcrWidgetStateInternal)
              .copyWith(cameraPermission: false));
        } else {
          await initialInternalCameraProcess();
        }
      case CameraOcrWidgetEventIntAskPermission:
        emit((state as CameraOcrWidgetStateInternal)
            .copyWith(cameraPermission: await _requestCameraPermission()));
      case CameraOcrWidgetEventIntSetCameraController:
        (event as CameraOcrWidgetEventIntSetCameraController);
        await (event).controller.initialize();
        await (event).controller.setFlashMode(FlashMode.off);
        emit((state as CameraOcrWidgetStateInternal).copyWith(
            cameraController: (event).controller, cameraPermission: true));

      case CameraOcrWidgetEventIntTakePicture:
        await takePic((state as CameraOcrWidgetStateInternal));

      // case CameraOcrWidgetEventExtTakePicture:
      //   await takePicEx((state as CameraOcrWidgetStateExternal));

      // case CameraOcrWidgetEventInitialExternalCamera:
      //   VlcPlayerController controller = VlcPlayerController.network(
      //     "rtsp://192.168.59.1:7070/webcam",
      //     autoInitialize: true,
      //     hwAcc: HwAcc.full,
      //     autoPlay: true,
      //     options: VlcPlayerOptions(),
      //   );
      //   print('air55 ${controller}');
      //   emit(CameraOcrWidgetStateExternal(videoPlayerController: controller));
      //   print('air44 $checkVideoState');
      //   controller.addListener(checkVideoState);
      //   print('air21 ${controller}');
      //   return;

      case CameraOcrWidgetEventCloseCamera:
        print('hallo ${state}');
        dispose(state: state);
        return;

      // case CameraOcrWidgetEventToogleBuffering:
        // emit((state as CameraOcrWidgetStateExternal).copyWith(
        //     isBuffering: (event as CameraOcrWidgetEventToogleBuffering).value));
      // case CameraOcrWidgetEventRestartCamera:
      //   if (state is! CameraOcrWidgetStateExternal) {
      //     return;
      //   }

      //   (state as CameraOcrWidgetStateExternal)
      //       .videoPlayerController!
      //       .setMediaFromNetwork("rtsp://192.168.59.1:7070/webcam")
      //       .then((_) {
      //     (state as CameraOcrWidgetStateExternal).videoPlayerController!.play();
      //   });

      case CameraOcrWidgetEventGetValue:
        if (state is CameraOcrWidgetStateInternal) {
          emit((state as CameraOcrWidgetStateInternal).copyWith(
              status: true,
              result: (event as CameraOcrWidgetEventGetValue).value));
        }

        // if (state is CameraOcrWidgetStateExternal) {
        //   final value = (event as CameraOcrWidgetEventGetValue).value;
        //   emit((state as CameraOcrWidgetStateExternal)
        //       .copyWith(status: true, result: value));
        // }
      default:
        return;
    }
  }
}
