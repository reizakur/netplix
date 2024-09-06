part of 'list_guess_page_bloc.dart';

enum PageStatuslist {
  checkout,
  checkoutready,
  gagal,
  checkoutCompleted
}
 
class ListGuessPageState {
  late List<DataKendaraan> datas;
  final List<DataKendaraan> serchProduk;
  ListGuessPageState({
    this.datas = const [],
    this.serchProduk = const [],
  });
  ListGuessPageState copyWith({
    List<DataKendaraan>? datas,
    // String pencariandata,
    List<DataKendaraan>? serchProduk,
  }) {
    return ListGuessPageState(
      datas: datas ?? this.datas,
      serchProduk: serchProduk ?? this.serchProduk,
    );
  }
}