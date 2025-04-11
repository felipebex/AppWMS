import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import 'package:wms_app/src/presentation/models/response_ubicaciones_model.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/inventario/models/response_products_model.dart';

part 'transfer_externa_event.dart';
part 'transfer_externa_state.dart';

class TransferExternaBloc
    extends Bloc<TransferExternaEvent, TransferExternaState> {
  TextEditingController searchControllerLocation = TextEditingController();
  TextEditingController searchControllerProducts = TextEditingController();
  String scannedValue1 = '';
  String scannedValue2 = '';
  String scannedValue3 = '';
  String scannedValue4 = '';

  bool locationIsOk = false;
  bool loteIsOk = false;

  bool productIsOk = false;
  bool quantityIsOk = false;
  bool isLocationOk = true;
  bool isProductOk = true;
  bool isLoteOk = true;

  bool isQuantityOk = true;
  bool isKeyboardVisible = false;
  bool viewQuantity = false;

  // //lista de productos
  // List<Product> productos = [];
  // //lista de productos de una ubicacion
  // List<Product> productosUbicacion = [];
  // List<Product> productosUbicacionFilters = [];

  //*lista de ubicaciones
  List<ResultUbicaciones> ubicaciones = [];
  List<ResultUbicaciones> ubicacionesFilters = [];

  //producto actual
  // Product? currentProduct;
  ResultUbicaciones? currentUbication;

  //*base de datos
  DataBaseSqlite db = DataBaseSqlite();
  int quantitySelected = 0;

  TransferExternaBloc() : super(TransferExternaInitial()) {
    on<TransferExternaEvent>((event, emit) {});

    //*metodo para cargar las ubicaciones
    on<GetLocationsEvent>(_onLoadLocations);
    //*evento para actualizar el valor del scan
    on<UpdateScannedValueEvent>(_onUpdateScannedValueEvent);
    on<ClearScannedValueEvent>(_onClearScannedValueEvent);
    //metodo para mostrar el teclado
    on<ShowKeyboardTransExtEvent>(_onShowKeyboardEvent);

    on<ValidateFieldsEvent>(_onValidateFields);

    //*cambiar el estado de las variables
    on<ChangeLocationIsOkEvent>(_onChangeLocationIsOkEvent);
    on<ChangeProductIsOkEvent>(_onChangeProductIsOkEvent);
    on<ChangeIsOkQuantity>(_onChangeQuantityIsOkEvent);

    //*traermos solo los productos de una ubicacion
    on<GetProductsByLocationEvent>(_onGetProductsByLocation);
    //metodo para buscar una ubicacion
    on<SearchLocationEvent>(_onSearchLocationEvent);
  }

  void _onSearchLocationEvent(
      SearchLocationEvent event, Emitter<TransferExternaState> emit) async {
    try {
      emit(SearchLoading());
      ubicacionesFilters = [];
      ubicacionesFilters = ubicaciones;
      final query = event.query.toLowerCase();
      if (query.isEmpty) {
        ubicacionesFilters = ubicaciones;
      } else {
        ubicacionesFilters = ubicaciones.where((location) {
          return location.name?.toLowerCase().contains(query) ?? false;
        }).toList();
      }
      emit(SearchLocationSuccess(ubicacionesFilters));
    } catch (e, s) {
      print('Error en el SearchLocationEvent: $e, $s');
      emit(SearchFailure(e.toString()));
    }
  }


    void _onSearchProductEvent(
      SearchProductEvent event, Emitter<TransferExternaState> emit) async {
    // try {
    //   emit(SearchLoading());
    //   productosUbicacionFilters = [];
    //   productosUbicacionFilters = productosUbicacion;
    //   final query = event.query.toLowerCase();
    //   if (query.isEmpty) {
    //     productosUbicacionFilters = productosUbicacion;
    //   } else {
    //     productosUbicacionFilters = productosUbicacion.where((product) {
    //       return product.productName?.toLowerCase().contains(query) ?? false;
    //     }).toList();
    //   }
    //   emit(SearchProductSuccess(productosUbicacionFilters));
    // } catch (e, s) {
    //   print('Error en el SearchLocationEvent: $e, $s');
    //   emit(SearchFailure(e.toString()));
    // }
  }


  void _onChangeQuantityIsOkEvent(
      ChangeIsOkQuantity event, Emitter<TransferExternaState> emit) async {
    try {
      if (event.isQuantity) {
        quantityIsOk = true;
      }
      emit(ChangeQuantityIsOkState(
        quantityIsOk,
      ));
    } catch (e, s) {
      print("❌ Error en el ChangeIsOkQuantity $e ->$s");
    }
  }

//* metodo para validar el producto
  void _onChangeProductIsOkEvent(
      ChangeProductIsOkEvent event, Emitter<TransferExternaState> emit) async {
    try {
      if (isProductOk) {
        // currentProduct = event.productSelect;
        viewQuantity = false;
        productIsOk = true;

        emit(ChangeProductIsOkState(
          productIsOk,
        ));
      }
    } catch (e, s) {
      print("❌ Error en el ChangeProductIsOkEvent $e ->$s");
    }
  }

  void _onGetProductsByLocation(GetProductsByLocationEvent event,
      Emitter<TransferExternaState> emit) async {
    // try {
    //   emit(GetProductsLoading());
    //   final response =
    //       await db.productoInventarioRepository.getAllProductsByLocation(
    //     event.locationId,
    //   );
    //   if (response.isNotEmpty) {
    //     // productosUbicacionFilters.clear();
    //     // productosUbicacion.clear();
    //     // productosUbicacion = response;
    //     // productosUbicacionFilters = response;
    //     print("Products = ${response.length}");
    //     // emit(GetProductsSuccessByLocation(response));
    //   } else {
    //     emit(GetProductsFailureByLocation('No se encontraron productos'));
    //   }
    // } catch (e, s) {
    //   emit(GetProductsFailureByLocation('Error al cargar los productos'));
    //   print('Error en el fetch de _onGetProductsByLocation: $e=>$s');
    // }
  }

  //*metodo para validar la ubicacion
  void _onChangeLocationIsOkEvent(
      ChangeLocationIsOkEvent event, Emitter<TransferExternaState> emit) async {
    try {
      if (isLocationOk) {
        currentUbication = event.locationSelect;
        locationIsOk = true;

        emit(ChangeLocationIsOkState(
          locationIsOk,
        ));
        add(GetProductsByLocationEvent(event.locationSelect.id ?? 0));
      }
    } catch (e, s) {
      print("❌ Error en el ChangeLocationIsOkEvent $e ->$s");
    }
  }

  void _onValidateFields(
      ValidateFieldsEvent event, Emitter<TransferExternaState> emit) {
    try {
      switch (event.field) {
        case 'location':
          isLocationOk = event.isOk;
          break;
        case 'product':
          isProductOk = event.isOk;
          break;
        case 'quantity':
          isQuantityOk = event.isOk;
          break;
      }
      emit(ValidateFieldsStateSuccess(event.isOk));
    } catch (e, s) {
      emit(ValidateFieldsStateError('Error al validar campos'));
      print("❌ Error en el ValidateFieldsEvent $e ->$s");
    }
  }

  void _onLoadLocations(
      GetLocationsEvent event, Emitter<TransferExternaState> emit) async {
    try {
      emit(LoadLocationsLoading());
      final response = await db.ubicacionesRepository.getAllUbicaciones();
      if (response.isNotEmpty) {
        ubicaciones.clear();
        ubicacionesFilters.clear();
        ubicaciones = response;
        ubicacionesFilters = ubicaciones;
        print('ubicaciones length: ${ubicaciones.length}');
        emit(LoadLocationsSuccess(ubicaciones));
      } else {
        emit(LoadLocationsFailure('No se encontraron ubicaciones'));
      }
    } catch (e, s) {
      emit(LoadLocationsFailure('Error al cargar las ubicaciones'));
      print('Error en el fetch de ubicaciones: $e=>$s');
    }
  }

  //*evento para actualizar el valor del scan
  void _onUpdateScannedValueEvent(
      UpdateScannedValueEvent event, Emitter<TransferExternaState> emit) {
    try {
      switch (event.scan) {
        case 'location':
          // Acumulador de valores escaneados
          scannedValue1 += event.scannedValue;
          emit(UpdateScannedValueState(scannedValue1, event.scan));
          break;
        case 'product':
          scannedValue2 += event.scannedValue;
          print('scannedValue2: $scannedValue2');
          emit(UpdateScannedValueState(scannedValue2, event.scan));
          break;
        case 'quantity':
          scannedValue3 += event.scannedValue;
          emit(UpdateScannedValueState(scannedValue3, event.scan));
          break;
        default:
          print('Scan type not recognized: ${event.scan}');
      }
    } catch (e, s) {
      print("❌ Error en _onUpdateScannedValueEvent: $e, $s");
    }
  }

//*evento para limpiar el valor del scan
  void _onClearScannedValueEvent(
      ClearScannedValueEvent event, Emitter<TransferExternaState> emit) {
    try {
      switch (event.scan) {
        case 'location':
          scannedValue1 = '';
          emit(ClearScannedValueState());
          break;
        case 'product':
          scannedValue2 = '';
          emit(ClearScannedValueState());
          break;
        case 'quantity':
          scannedValue3 = '';
          emit(ClearScannedValueState());
          break;
        case 'muelle':
          scannedValue4 = '';
          emit(ClearScannedValueState());
          break;

        default:
          print('Scan type not recognized: ${event.scan}');
      }
      emit(ClearScannedValueState());
    } catch (e, s) {
      print("❌ Error en _onClearScannedValueEvent: $e, $s");
    }
  }

  void _onShowKeyboardEvent(
      ShowKeyboardTransExtEvent event, Emitter<TransferExternaState> emit) {
    isKeyboardVisible = event.showKeyboard;
    emit(ShowKeyboardState(showKeyboard: isKeyboardVisible));
  }
}
