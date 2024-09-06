import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:visito/system_parameter/system_parameter_cubit.dart';

part 'splash_page_event.dart';
part 'splash_page_state.dart';

class SplashPageBloc extends Bloc<SplashPageEvent, SplashPageState> {
  SplashPageBloc({required BuildContext context}) : super(SplashPageInitial()) {
    // on<SplashPageEvent>((event, emit) {
    //   // TODO: implement event handler
    // });
  systemParameterCubit = context.read<SystemParameterCubit>();
     on(mapEvent);
    add(LoadDBInitial());
  }
late SystemParameterCubit systemParameterCubit;
   Future<void> mapEvent(
      SplashPageEvent event, Emitter<SplashPageState> emit) async {
    if (event is LoadDBInitial) {
     await systemParameterCubit.loadFromPreferences();
    }
  }
}
