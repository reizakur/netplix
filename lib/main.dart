import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visito/pages/dashboard_page/dashboard_page_bloc.dart';
import 'package:visito/pages/list_guess_page/list_guess_page_bloc.dart';
import 'package:visito/pages/pages.dart';
import 'package:visito/pages/test_page/testvideo_bloc.dart';
import 'package:visito/system_parameter/system_parameter_cubit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // Correct the typo
    DeviceOrientation.portraitUp, //
  ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => SystemParameterCubit()),
        BlocProvider(create: (context) => DashboardPageBloc(context: context)),
        BlocProvider(create: (context) => ListGuessPageBloc(context: context)),
        BlocProvider(create: (context) => TestvideoBloc(context: context)),
      ],
      child: MaterialApp(
        initialRoute: '/SplashScreen',
        routes: {
          '/SplashScreen': (context) => const SplashPage(),
        },
        theme: ThemeData(primarySwatch: Colors.blue),
        builder: (context, child) {
          final mediaQueryData = MediaQuery.of(context);
          final scale = mediaQueryData.textScaleFactor.clamp(0.8, 0.8);
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: scale),
            child: child!,
          );
        },
        title: 'POS Rotio',
      ),
    );
  }
}
