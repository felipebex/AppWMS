// ignore_for_file: unnecessary_null_comparison

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:wms_app/src/presentation/models/response_ubicaciones_model.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/inventario/data/inventario_repository.dart';
import 'package:wms_app/src/presentation/views/inventario/models/request_sendProducr_model.dart';
import 'package:wms_app/src/presentation/views/inventario/models/response_products_model.dart';
import 'package:wms_app/src/presentation/views/recepcion/models/response_lotes_product_model.dart';
import 'package:wms_app/src/presentation/views/user/models/configuration.dart';
import 'package:wms_app/src/utils/prefs/pref_utils.dart';

part 'inventario_event.dart';
part 'inventario_state.dart';

class InventarioBloc extends Bloc<InventarioEvent, InventarioState> {
  TextEditingController searchControllerLocation = TextEditingController();
  TextEditingController searchControllerProducts = TextEditingController();
  TextEditingController searchControllerLote = TextEditingController();

  TextEditingController newLoteController = TextEditingController();
  TextEditingController dateLoteController = TextEditingController();

  final InventarioRepository _inventarioRepository = InventarioRepository();

  String scannedValue1 = '';
  String scannedValue2 = '';
  String scannedValue3 = '';
  String scannedValue4 = '';

  List<BarcodeInventario> barcodeInventario = [];

  // //*validaciones de campos del estado de la vista
  //*variables para validar
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

  //lista de lotes de un producto
  List<LotesProduct> listLotesProduct = [];
  List<LotesProduct> listLotesProductFilters = [];

  //producto actual
  Product? currentProduct;
  ResultUbicaciones? currentUbication;
  LotesProduct? currentProductLote;

  //*configuracion del usuario //permisos
  Configurations configurations = Configurations();

  InventarioBloc() : super(InventarioInitial()) {
    on<InventarioEvent>((event, emit) {});

    //*metodo para cargar las ubicaciones
    on<GetLocationsEvent>(_onLoadLocations);
    //metodo para buscar una ubicacion
    on<SearchLocationEvent>(_onSearchLocationEvent);
    //metodo para buscar un lote
    on<SearchLotevent>(_onSearchLoteEvent);
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
    on<ChangeIsOkQuantity>(_onChangeQuantityIsOkEvent);
    //*traermos todos los productos del inventario
    on<GetProductsEvent>(_onGetProducts);
    on<GetProductsForDB>(_onGetProductsBD);

    //*traermos solo los productos de una ubicacion
    on<GetProductsByLocationEvent>(_onGetProductsByLocation);
    //*limpiamos los campos y el estado
    on<CleanFieldsEent>(_onCleanFields);

    //*metodo para obtener todos los lotes de un producto
    on<GetLotesProduct>(_onGetLotesProduct);
    on<SelectecLoteEvent>(_onChangeLoteIsOkEvent);

    //*evento para ver la cantidad
    on<ShowQuantityEvent>(_onShowQuantityEvent);

    //*evento para obtener los barcodes de un producto por paquete
    on<FetchBarcodesProductEvent>(_onFetchBarcodesProductEvent);

    //*evento para cambiar la cantidad seleccionada
    on<ChangeQuantitySeparate>(_onChangeQuantitySelectedEvent);
    on<AddQuantitySeparate>(_onAddQuantitySeparateEvent);

    on<SendProductInventarioEnvet>(_onSendProductInventarioEvent);

    //*metodo para crear un lote a un producto
    on<CreateLoteProduct>(_onCreateLoteProduct);

    //metodo para cargar la oncfiguracion del usuario
    //*obtener las configuraciones y permisos del usuario desde la bd
    on<LoadConfigurationsUserInventory>(_onLoadConfigurationsUserEvent);
  }

  //*metodo para cargar la configuracion del usuario
  void _onLoadConfigurationsUserEvent(LoadConfigurationsUserInventory event,
      Emitter<InventarioState> emit) async {
    try {
      int userId = await PrefUtils.getUserId();
      final response =
          await db.configurationsRepository.getConfiguration(userId);

      if (response != null) {
        configurations = response;
        emit(ConfigurationLoadedInventory(response));
      } else {
        emit(ConfigurationErrorInventory('Error al cargar configuraciones'));
      }
    } catch (e, s) {
      emit(ConfigurationErrorInventory(e.toString()));
      print('Error en LoadConfigurationsUserPack.dart: $e =>$s');
    }
  }

  //metodo pea crar un lote a un producto
  void _onCreateLoteProduct(
      CreateLoteProduct event, Emitter<InventarioState> emit) async {
    try {
      emit(CreateLoteProductLoading());
      final response = await _inventarioRepository.createLote(
        false,
        currentProduct?.productId ?? 0,
        event.nameLote,
        event.fechaCaducidad,
      );

      if (response != null) {
        //agregamos el nuevo lote a la lista de lotes
        listLotesProduct.add(response.result?.result ?? LotesProduct());
        listLotesProductFilters.add(response.result?.result ?? LotesProduct());
        currentProductLote = response.result?.result;
        loteIsOk = true;
        dateLoteController.clear();
        newLoteController.clear();
        emit(CreateLoteProductSuccess());
      } else {
        emit(CreateLoteProductFailure('Error al crear el lote'));
      }
    } catch (e, s) {
      emit(CreateLoteProductFailure('Error al crear el lote'));
      print('Error en el _onCreateLoteProduct: $e, $s');
    }
  }

  void _onSendProductInventarioEvent(
      SendProductInventarioEnvet event, Emitter<InventarioState> emit) async {
    try {
      emit(SendProductLoading());

      final response = await _inventarioRepository.sendProduct(
        SendProductInventario(
          locationId: currentUbication?.id ?? 0, //currentUbication?.id ?? 0,
          productId: currentProduct?.productId ?? 0,
          lotId: currentProductLote?.id ?? 0,
          quantity: event.cantidad,
        ),
        false,
      );

      if (response.result?.status == 'success') {
        emit(SendProductSuccess());
      } else {
        emit(SendProductFailure(response.result?.message ?? ""));
      }
    } catch (e, s) {
      emit(SendProductFailure('Error al enviar el producto'));
      print('Error en el _onSendProductInventarioEvent: $e, $s');
    }
  }

  //*metodo para cambiar la cantidad seleccionada
  void _onChangeQuantitySelectedEvent(
      ChangeQuantitySeparate event, Emitter<InventarioState> emit) async {
    try {
      if (event.quantity > 0) {
        quantitySelected = event.quantity;
      }
      emit(ChangeQuantitySeparateStateSuccess(quantitySelected));
    } catch (e, s) {
      emit(ChangeQuantitySeparateStateError('Error al separar cantidad'));
      print('❌ Error en ChangeQuantitySeparate: $e -> $s ');
    }
  }

  //*evento para aumentar la cantidad
  void _onAddQuantitySeparateEvent(
      AddQuantitySeparate event, Emitter<InventarioState> emit) async {
    try {
      if (quantitySelected > (currentProduct?.quantity ?? 0)) {
        return;
      } else {
        quantitySelected = quantitySelected + event.quantity;
        emit(ChangeQuantitySeparateStateSuccess(quantitySelected));
      }
    } catch (e, s) {
      emit(ChangeQuantitySeparateStateError('Error al aumentar cantidad'));
      print("❌ Error en el AddQuantitySeparate $e ->$s");
    }
  }

  //*evento para obtener los barcodes de un producto por paquete
  void _onFetchBarcodesProductEvent(
      FetchBarcodesProductEvent event, Emitter<InventarioState> emit) async {
    try {
      barcodeInventario.clear();

      barcodeInventario =
          await db.barcodesInventarioRepository.getBarcodesProduct(
        currentProduct?.productId ?? 0,
        currentProduct?.quantId ?? 0,
      );
      print("barcodeInventario: ${barcodeInventario.length}");
    } catch (e, s) {
      print("❌ Error en _onFetchBarcodesProductEvent: $e, $s");
    }
    emit(BarcodesProductLoadedState(listOfBarcodes: barcodeInventario));
  }

  //*evento para ver la cantidad
  void _onShowQuantityEvent(
      ShowQuantityEvent event, Emitter<InventarioState> emit) {
    try {
      viewQuantity = !viewQuantity;
      emit(ShowQuantityState(viewQuantity));
    } catch (e, s) {
      print("❌ Error en _onShowQuantityEvent: $e, $s");
    }
  }

  void _onChangeQuantityIsOkEvent(
      ChangeIsOkQuantity event, Emitter<InventarioState> emit) async {
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

  void _onChangeLoteIsOkEvent(
      SelectecLoteEvent event, Emitter<InventarioState> emit) async {
    try {
      currentProductLote = event.lote;
      loteIsOk = true;
      emit(ChangeLoteIsOkState(
        loteIsOk,
      ));
    } catch (e, s) {
      print('Error en el SelectecLoteEvent de inventario $s ->$e');
    }
  }

  //*metodo para obtener todos los lotes de un producto
  void _onGetLotesProduct(
      GetLotesProduct event, Emitter<InventarioState> emit) async {
    try {
      emit(GetLotesProductLoading());
      final response = await _inventarioRepository.fetchAllLotesProduct(
          false, currentProduct?.productId ?? 0);
      listLotesProduct = response;
      emit(GetLotesProductSuccess(response));
    } catch (e, s) {
      emit(GetLotesProductFailure('Error al obtener los lotes del producto'));
      print('Error en el _onGetLotesProduct: $e, $s');
    }
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
      viewQuantity = false;

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
      currentProductLote = null;

      listLotesProduct.clear();
      barcodeInventario.clear();

      loteIsOk = false;

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
        add(FetchBarcodesProductEvent());
        if (currentProduct?.productTracking == 'lot') {
          add(GetLotesProduct());
        }
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

  //*metodo para validar la ubicacion
  void _onChangeLocationIsOkEvent(
      ChangeLocationIsOkEvent event, Emitter<InventarioState> emit) async {
    try {
      if (isLocationOk) {
        currentUbication = event.locationSelect;
        locationIsOk = true;

        add(GetProductsByLocationEvent(event.locationSelect.id ?? 0));
        emit(ChangeLocationIsOkState(
          locationIsOk,
        ));
      }
    } catch (e, s) {
      print("❌ Error en el ChangeLocationIsOkEvent $e ->$s");
    }
  }

  void _onGetProductsByLocation(
      GetProductsByLocationEvent event, Emitter<InventarioState> emit) async {
    try {
      print('TRAEMOS LOS PRODUCTOS DEL INVENTARIO DE LA UBICACION');
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
        emit(GetProductsSuccessByLocation(response));
      } else {
        emit(GetProductsFailureByLocation('No se encontraron productos'));
      }
    } catch (e, s) {
      emit(GetProductsFailureByLocation('Error al cargar los productos'));
      print('Error en el fetch de _onGetProductsByLocation: $e=>$s');
    }
  }

  void _onGetProducts(
      GetProductsEvent event, Emitter<InventarioState> emit) async {
    try {
      emit(GetProductsLoading());

      await db.deleInventario();

      final response =
          await _inventarioRepository.fetAllProducts(false, event.warehouseId);

      // final response = await db.productoInventarioRepository.insertProductosInventario(productosList);
      if (response.isNotEmpty) {
        await db.productoInventarioRepository
            .insertProductosInventario(response);
        //Convertir el mapa en una lista los barcodes unicos de cada producto
        List<BarcodeInventario> barcodesToInsert =
            productos.expand((product) => product.otherBarcodes!).toList();

        List<BarcodeInventario> barcodesPackingToInsert =
            productos.expand((product) => product.productPacking!).toList();
        print("Products = ${response.length}");
        print('otherBarcodes: ${barcodesToInsert.length}');
        print('productPacking: ${barcodesPackingToInsert.length}');
        if (barcodesToInsert.isNotEmpty) {
          await db.barcodesInventarioRepository
              .insertOrUpdateBarcodes(barcodesToInsert);
        }
        if (barcodesPackingToInsert.isNotEmpty) {
          await db.barcodesInventarioRepository
              .insertOrUpdateBarcodes(barcodesPackingToInsert);
        }
        emit(GetProductsSuccess(response));
        add(GetProductsForDB());
      } else {
        emit(GetProductsFailure('No se encontraron productos'));
      }
    } catch (e, s) {
      emit(GetProductsFailure('Error al cargar los productos'));
      print('Error en el fetch de productos: $e=>$s');
    }
  }


  void getPordutbyid()async{
     final response = await db.productoInventarioRepository.getProductById(33132);
     print('response: ${response?.toMap()}');
  }

  void _onGetProductsBD(
      GetProductsForDB event, Emitter<InventarioState> emit) async {
    try {
      emit(GetProductsLoadingBD());
      final response = await db.productoInventarioRepository.getAllProducts();
      if (response.isNotEmpty) {
        productos.clear();
        productos = response;
        emit(GetProductsSuccessBD(response));
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
  void _onSearchLoteEvent(
      SearchLotevent event, Emitter<InventarioState> emit) async {
    try {
      emit(SearchLoading());
      listLotesProductFilters = [];
      listLotesProductFilters = listLotesProduct;
      final query = event.query.toLowerCase();
      if (query.isEmpty) {
        listLotesProductFilters = listLotesProduct;
      } else {
        listLotesProductFilters = listLotesProduct.where((lotes) {
          return lotes.name?.toLowerCase().contains(query) ?? false;
        }).toList();
      }
      emit(SearchLoteSuccess(listLotesProductFilters));
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
