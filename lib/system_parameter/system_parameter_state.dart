part of 'system_parameter_cubit.dart';

abstract class SystemParameterState {
  const SystemParameterState();
}

class SystemParameterInitial extends SystemParameterState {
  // final String
  // final String databasePath;
}

class SystemParameterConfigured extends SystemParameterState {
  final String databasePath;
  SystemParameterConfigured({required this.databasePath});
}

class SystemParameterNotConfigured extends SystemParameterState {}
