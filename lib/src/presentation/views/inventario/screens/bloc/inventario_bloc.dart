import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'inventario_event.dart';
part 'inventario_state.dart';

class InventarioBloc extends Bloc<InventarioEvent, InventarioState> {
  //*variables para validar
  bool locationIsOk = false;
  bool productIsOk = false;
  bool quantityIsOk = false;

  String scannedValue1 = '';
  String scannedValue2 = '';
  String scannedValue3 = '';
  String scannedValue4 = '';

  String selectedLocation = '';
  String selectedProduct = '';

  // //*validaciones de campos del estado de la vista
  bool isLocationOk = true;
  bool isProductOk = true;
  bool isQuantityOk = true;

  bool viewQuantity = false;

  int quantitySelected = 0;

  InventarioBloc() : super(InventarioInitial()) {
    on<InventarioEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
