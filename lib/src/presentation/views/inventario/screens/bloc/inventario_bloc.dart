import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:wms_app/src/presentation/models/response_ubicaciones_model.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/inventario/data/inventario_repository.dart';
import 'package:wms_app/src/presentation/views/inventario/models/response_products_model.dart';

part 'inventario_event.dart';
part 'inventario_state.dart';

class InventarioBloc extends Bloc<InventarioEvent, InventarioState> {
  TextEditingController searchControllerLocation = TextEditingController();
  TextEditingController searchControllerProducts = TextEditingController();

  final InventarioRepository _inventarioRepository = InventarioRepository();

  String scannedValue1 = '';
  String scannedValue2 = '';
  String scannedValue3 = '';
  String scannedValue4 = '';

  // //*validaciones de campos del estado de la vista
  //*variables para validar
  bool locationIsOk = false;
  bool productIsOk = false;
  bool quantityIsOk = false;
  bool isLocationOk = true;
  bool isProductOk = true;
  bool isQuantityOk = true;
  bool isKeyboardVisible = false;
  bool viewQuantity = false;

  int quantitySelected = 0;

  //*base de datos
  DataBaseSqlite db = DataBaseSqlite();

  //*lista de ubicaciones
  List<ResultUbicaciones> ubicaciones = [];
  List<ResultUbicaciones> ubicacionesFilters = [];

  //lista de productos
  List<Product> productos = [];
  //lista de productos de una ubicacion
  List<Product> productosUbicacion = [];
  List<Product> productosUbicacionFilters = [];

  //producto actual
  Product? currentProduct;
  ResultUbicaciones? currentUbication;

  InventarioBloc() : super(InventarioInitial()) {
    on<InventarioEvent>((event, emit) {});

    //*metodo para cargar las ubicaciones
    on<GetLocationsEvent>(_onLoadLocations);

    //metodo para buscar una ubicacion
    on<SearchLocationEvent>(_onSearchLocationEvent);
    //*metodo para bucar un producto
    on<SearchProductEvent>(_onSearchProductEvent);

    //metodo para mostrar el teclado
    on<ShowKeyboardEvent>(_onShowKeyboardEvent);

    //*evento para actualizar el valor del scan
    on<UpdateScannedValueEvent>(_onUpdateScannedValueEvent);
    on<ClearScannedValueEvent>(_onClearScannedValueEvent);

    on<ValidateFieldsEvent>(_onValidateFields);

    //*cambiar el estado de las variables
    on<ChangeLocationIsOkEvent>(_onChangeLocationIsOkEvent);
    on<ChangeProductIsOkEvent>(_onChangeProductIsOkEvent);
    //traermos todos los productos del inventario
    on<GetProductsEvent>(_onGetProducts);
    //traermos solo los productos de una ubicacion
    on<GetProductsByLocationEvent>(_onGetProductsByLocation);
    //limpiamos los campos y el estado

    on<CleanFieldsEent>(_onCleanFields);
  }



  void _onCleanFields(CleanFieldsEent event, Emitter<InventarioState> emit) {
    try {
      // Reset scanned values
      scannedValue1 = '';
      scannedValue2 = '';
      scannedValue3 = '';
      scannedValue4 = '';

    

      // Reset validation flags
      locationIsOk = false;
      productIsOk = false;
      quantityIsOk = false;

      isLocationOk = true;
      isProductOk = true;
      isQuantityOk = true;

      // Reset quantity
      quantitySelected = 0;

      // Clear search controllers
      searchControllerLocation.clear();
      searchControllerProducts.clear();

      // Clear current product
      currentProduct = null;
      currentUbication = null;


      // Emit clean fields state
      emit(CleanFieldsState());
    } catch (e, s) {
      print("❌ Error in _onCleanFields: $e -> $s");
    }
  }


//* metodo para validar el producto
  void _onChangeProductIsOkEvent(
      ChangeProductIsOkEvent event, Emitter<InventarioState> emit) async {
    try {
      if (isProductOk) {
        currentProduct = event.productSelect;
        productIsOk = true;
        emit(ChangeProductIsOkState(
          productIsOk,
        ));
      }
    } catch (e, s) {
      print("❌ Error en el ChangeProductIsOkEvent $e ->$s");
    }
  }

  //*metodo para validar la ubicacion
  void _onChangeLocationIsOkEvent(
      ChangeLocationIsOkEvent event, Emitter<InventarioState> emit) async {
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

  void _onGetProductsByLocation(
      GetProductsByLocationEvent event, Emitter<InventarioState> emit) async {
    try {
      emit(GetProductsLoading());
      final response =
          await db.productoInventarioRepository.getAllProductsByLocation(
        event.locationId,
      );
      if (response.isNotEmpty) {
        productosUbicacionFilters.clear();
        productosUbicacion.clear();
        productosUbicacion = response;
        productosUbicacionFilters = response;
        print("Products = ${response.length}");
        emit(GetProductsSuccess(response));
      } else {
        emit(GetProductsFailure('No se encontraron productos'));
      }
    } catch (e, s) {
      emit(GetProductsFailure('Error al cargar los productos'));
      print('Error en el fetch de productos: $e=>$s');
    }
  }

  void _onGetProducts(
      GetProductsEvent event, Emitter<InventarioState> emit) async {
    try {
      emit(GetProductsLoading());

      final response =
          await _inventarioRepository.fetAllProducts(false, event.warehouseId);

      // final response = await db.productoInventarioRepository.insertProductosInventario(productosList);
      if (response.isNotEmpty) {
        print("Products = ${response.length}");

        await db.productoInventarioRepository
            .insertProductosInventario(response);
        productos.clear();
        productos = response;

        emit(GetProductsSuccess(response));
      } else {
        emit(GetProductsFailure('No se encontraron productos'));
      }
    } catch (e, s) {
      emit(GetProductsFailure('Error al cargar los productos'));
      print('Error en el fetch de productos: $e=>$s');
    }
  }

  void _onValidateFields(
      ValidateFieldsEvent event, Emitter<InventarioState> emit) {
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

  //*evento para actualizar el valor del scan
  void _onUpdateScannedValueEvent(
      UpdateScannedValueEvent event, Emitter<InventarioState> emit) {
    try {
      switch (event.scan) {
        case 'location':
          // Acumulador de valores escaneados
          scannedValue1 += event.scannedValue;
          print('scannedValue1: $scannedValue1');
          emit(UpdateScannedValueState(scannedValue1, event.scan));
          break;
        case 'product':
          scannedValue2 += event.scannedValue;
          print('scannedValue2: $scannedValue2');
          emit(UpdateScannedValueState(scannedValue2, event.scan));
          break;
        case 'quantity':
          scannedValue3 += event.scannedValue;
          print('scannedValue3: $scannedValue3');
          emit(UpdateScannedValueState(scannedValue3, event.scan));
          break;
        case 'muelle':
          print('scannedValue4: $scannedValue4');
          scannedValue4 += event.scannedValue;
          emit(UpdateScannedValueState(scannedValue4, event.scan));
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
      ClearScannedValueEvent event, Emitter<InventarioState> emit) {
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
      ShowKeyboardEvent event, Emitter<InventarioState> emit) {
    isKeyboardVisible = event.showKeyboard;
    emit(ShowKeyboardState(showKeyboard: isKeyboardVisible));
  }

  void _onSearchLocationEvent(
      SearchLocationEvent event, Emitter<InventarioState> emit) async {
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
      SearchProductEvent event, Emitter<InventarioState> emit) async {
    try {
      emit(SearchLoading());
      productosUbicacionFilters = [];
      productosUbicacionFilters = productosUbicacion;
      final query = event.query.toLowerCase();
      if (query.isEmpty) {
        productosUbicacionFilters = productosUbicacion;
      } else {
        productosUbicacionFilters = productosUbicacion.where((product) {
          return product.productName?.toLowerCase().contains(query) ?? false;
        }).toList();
      }
      emit(SearchProductSuccess(productosUbicacionFilters));
    } catch (e, s) {
      print('Error en el SearchLocationEvent: $e, $s');
      emit(SearchFailure(e.toString()));
    }
  }

  void _onLoadLocations(
      GetLocationsEvent event, Emitter<InventarioState> emit) async {
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
}
