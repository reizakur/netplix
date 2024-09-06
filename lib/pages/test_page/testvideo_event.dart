part of 'testvideo_bloc.dart';

@immutable
abstract class TestvideoEvent {
  const TestvideoEvent();
}

class fetchdataall extends TestvideoEvent {}

class FetchdataGuess extends TestvideoEvent {}
