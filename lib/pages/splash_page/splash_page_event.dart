part of 'splash_page_bloc.dart';

@immutable
abstract class SplashPageEvent {
    const SplashPageEvent();
}

class LoadDBInitial extends SplashPageEvent {
  const LoadDBInitial();
}
