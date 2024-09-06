part of 'camera_ocr_widget_bloc.dart';

abstract class CameraOcrWidgetEvent {
  const CameraOcrWidgetEvent();
}
// EVENT FOR INTERNAL CAMERA

class CameraOcrWidgetEventInitialInternalCamera extends CameraOcrWidgetEvent {
  const CameraOcrWidgetEventInitialInternalCamera();
}

class CameraOcrWidgetEventIntAskPermission extends CameraOcrWidgetEvent {
  const CameraOcrWidgetEventIntAskPermission();
}

class CameraOcrWidgetEventIntTakePicture extends CameraOcrWidgetEvent {
  const CameraOcrWidgetEventIntTakePicture();
}

class CameraOcrWidgetEventExtTakePicture extends CameraOcrWidgetEvent {
  const CameraOcrWidgetEventExtTakePicture();
}

class CameraOcrWidgetEventIntSetCameraController extends CameraOcrWidgetEvent {
  CameraController controller;
  CameraOcrWidgetEventIntSetCameraController({required this.controller});
}

// EVENT FOR EXTERNAL CAMERA

class CameraOcrWidgetEventInitialExternalCamera extends CameraOcrWidgetEvent {
  const CameraOcrWidgetEventInitialExternalCamera();
}

class CameraOcrWidgetEventCloseCamera extends CameraOcrWidgetEvent {
  const CameraOcrWidgetEventCloseCamera();
}

class CameraOcrWidgetEventToogleBuffering extends CameraOcrWidgetEvent {
  late bool value;
  CameraOcrWidgetEventToogleBuffering({required this.value});
}

class CameraOcrWidgetEventRestartCamera extends CameraOcrWidgetEvent {
  CameraOcrWidgetEventRestartCamera();
}

// GENERAL USE
class CameraOcrWidgetEventGetValue extends CameraOcrWidgetEvent {
  String value;
  CameraOcrWidgetEventGetValue({required this.value});
}

class CameraOcrWidgetEventGetValueExt extends CameraOcrWidgetEvent {
  String value;
  CameraOcrWidgetEventGetValueExt({required this.value});
}
