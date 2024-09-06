import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visito/pages/dashboard_page/ocr/bloc/camera_ocr_widget_bloc.dart';
// import 'package:flutter_vlc_player/flutter_vlc_player.dart';
// import 'package:apptamu/pages/formkendaraan/ocr/camera_ocr_widget_bloc.dart';

class CameraOcrPicker extends StatefulWidget {
  const CameraOcrPicker({super.key});

  @override
  State<CameraOcrPicker> createState() => _CameraOcrPickerState();
}

class _CameraOcrPickerState extends State<CameraOcrPicker>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // context
    //     .read<CameraOcrWidgetBloc>()
    //     .add(const CameraOcrWidgetEventCloseCamera());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      context
          .read<CameraOcrWidgetBloc>()
          .add(CameraOcrWidgetEventRestartCamera());
    } else if (state == AppLifecycleState.inactive) {
      if (context.read<CameraOcrWidgetBloc>().state
          is CameraOcrWidgetStateInternal) {
        CameraOcrWidgetStateInternal widgetState = (context
            .read<CameraOcrWidgetBloc>()
            .state as CameraOcrWidgetStateInternal);
        if (widgetState.cameraController != null) {
          widgetState.cameraController!.dispose();
        }
      }
    }
  }

  Widget cameraInternalWidget(
      BuildContext context, CameraOcrWidgetStateInternal state) {
    if (!state.cameraPermission) {
      return const Center(child: Text('Camera permission denied'));
    }
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Center(child: CameraPreview(state.cameraController!)),
        Text("${state.status}"),
        ElevatedButton(
          onPressed: () {
            context
                .read<CameraOcrWidgetBloc>()
                .add(const CameraOcrWidgetEventIntTakePicture());
          },
          child: const Icon(Icons.camera_alt),
        )
      ],
    );
  }

  // Widget cameraExternalWidget(
  //   BuildContext context,
  //   CameraOcrWidgetStateExternal state,
  // ) {
  //   if (state.videoPlayerController == null) {
  //     return const SizedBox();
  //   }
  //   return Scaffold(
  //     body: Stack(
  //       children: [
  //         // VlcPlayer(
  //         //   controller: state.videoPlayerController!,
  //         //   aspectRatio: 16 / 9,
  //         //   placeholder: const Center(
  //         //     child: CircularProgressIndicator(
  //         //       color: Colors.white,
  //         //     ),
  //         //   ),
  //         // ),
  //         // if (state.isBuffering)
  //         //   const Center(
  //         //     child: CircularProgressIndicator(
  //         //       color: Colors.red,
  //         //     ),
  //         //   ),
  //       ],
  //     ),
  //     floatingActionButton: FloatingActionButton(
  //       onPressed: () {
  //         context
  //             .read<CameraOcrWidgetBloc>()
  //             .add(const CameraOcrWidgetEventExtTakePicture());
  //       },
  //       child: const Icon(Icons.camera_alt),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CameraOcrWidgetBloc, CameraOcrWidgetState>(
      listenWhen: (oldState, newState) => oldState.status != newState.status,
      listener: (context, state) {
        if (state.status) {
          Navigator.pop(context, state.result);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Camera')),
        body: BlocBuilder<CameraOcrWidgetBloc, CameraOcrWidgetState>(
          buildWhen: (oldState, newState) => oldState != newState,
          builder: (context, state) {
             if (state is CameraOcrWidgetStateInternal) {
              return cameraInternalWidget(context, state);
            } else {
              return const Center(child: LinearProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
