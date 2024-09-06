part of 'testvideo_bloc.dart';

@immutable
class TestvideoState {
  late List<DataKendaraan> datas;

  TestvideoState({
    this.datas = const [],
  });

  TestvideoState copyWith({
    List<DataKendaraan>? datas,
  }) {
    return TestvideoState(
      datas: datas ?? this.datas,
    );
  }
}
