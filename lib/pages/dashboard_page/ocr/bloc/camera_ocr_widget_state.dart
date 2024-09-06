part of 'camera_ocr_widget_bloc.dart';

abstract class CameraOcrWidgetState {
  TextRecognizer textRecognizer = TextRecognizer();
  bool status = false;
  String result = '';
}

// class CameraOcrWidgetStateExternal extends CameraOcrWidgetState {
//   late bool cameraPermission;
//   VlcPlayerController? videoPlayerController;
//   bool isBuffering = false;

//   CameraOcrWidgetStateExternal({
//     this.cameraPermission = false,
//     this.videoPlayerController,
//     this.isBuffering = false,
//     bool status = false,
//     String result = '',
//   }) {
//     super.status = status;
//     super.result = result;
//   }

//   CameraOcrWidgetStateExternal copyWith({
//     bool? cameraPermission,
//     VlcPlayerController? videoController,
//     bool? isBuffering,
//     bool? status,
//     String? result,
//   }) {
//     VlcPlayerController? controller;
//     if (videoController != null) {
//       print('rezagg ${videoController}');
//       controller = videoController;
//     } else {
//       print('reza44 ${videoPlayerController}');
//       controller = videoPlayerController;
//     }
//     return CameraOcrWidgetStateExternal(
//         cameraPermission: cameraPermission ?? this.cameraPermission,
//         videoPlayerController: controller,
//         isBuffering: isBuffering ?? this.isBuffering,
//         status: status ?? this.status,
//         result: result ?? this.result);
//   }
// }

class CameraOcrWidgetStateInternal extends CameraOcrWidgetState {
  late bool cameraPermission;
  CameraController? cameraController;
  CameraOcrWidgetStateInternal(
      {this.cameraPermission = false,
      this.cameraController,
      bool status = false,
      String result = ''}) {
    super.status = status;
    super.result = result;
  }
  CameraOcrWidgetStateInternal copyWith({
    bool? cameraPermission,
    CameraController? cameraController,
    bool? status,
    String? result,
  }) {
    return CameraOcrWidgetStateInternal(
        cameraPermission: cameraPermission ?? this.cameraPermission,
        cameraController: cameraController ?? this.cameraController,
        status: status ?? this.status,
        result: result ?? this.result);
  }
}
