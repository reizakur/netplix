import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'testt_page_event.dart';
part 'testt_page_state.dart';

class TesttPageBloc extends Bloc<TesttPageEvent, TesttPageState> {
  TesttPageBloc() : super(TesttPageInitial()) {
    on<TesttPageEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
