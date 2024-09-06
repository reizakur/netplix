import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'guess_page_event.dart';
part 'guess_page_state.dart';

class GuessPageBloc extends Bloc<GuessPageEvent, GuessPageState> {
  GuessPageBloc() : super(GuessPageInitial()) {
    on<GuessPageEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
