import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:wms_app/src/core/utils/prefs/pref_utils.dart';
import 'package:wms_app/src/presentation/models/response_ubicaciones_model.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/inventario/data/inventario_repository.dart';
import 'package:wms_app/src/presentation/views/inventario/models/response_products_model.dart';
import 'package:wms_app/src/presentation/views/recepcion/models/response_lotes_product_model.dart';
import 'package:wms_app/src/presentation/views/user/models/configuration.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';

part 'crate_transfer_event.dart';
part 'crate_transfer_state.dart';

class CreateTransferBloc
    extends Bloc<CreateTransferEvent, CreateTransferState> {
  // //*validaciones de campos del estado de la vista
  bool loteIsOk = false;
  bool isLocationOk = true;
  bool isProductOk = true;
  bool isLocationDestOk = true;
  bool isQuantityOk = true;
  bool isKeyboardVisible = false;
  bool isLoteOk = true;

  //*variables para validar
  bool locationIsOk = false;
  bool productIsOk = false;
  bool locationDestIsOk = false;
  bool quantityIsOk = false;
  bool viewQuantity = false;
  //*valores de scanvalueS

  String scannedValue1 = '';
  String scannedValue2 = '';
  String scannedValue3 = '';
  String scannedValue4 = '';
  String scannedValue5 = '';
  String scannedValue6 = '';

  String oldLocation = '';
  String dateInicio = '';
  String dateFin = "";

  //*lista de ubicaciones
  List<ResultUbicaciones> ubicaciones = [];
  List<ResultUbicaciones> ubicacionesFilters = [];

  //*lista de productos
  List<Product> productos = [];
  List<Product> productosFilters = [];

  List<Barcodes> listOfBarcodes = [];
  List<Barcodes> listAllOfBarcodes = [];

  //lista de lotes de un producto
  List<LotesProduct> listLotesProduct = [];
  List<LotesProduct> listLotesProductFilters = [];

  TextEditingController newLoteController = TextEditingController();
  TextEditingController searchControllerLote = TextEditingController();
  TextEditingController dateLoteController = TextEditingController();
  TextEditingController searchControllerLocation = TextEditingController();
  TextEditingController searchControllerProducts = TextEditingController();

  //*configuracion del usuario //permisos
  Configurations configurations = Configurations();

  //*variables de modelos actuales
  ResultUbicaciones? currentUbication;
  Product? currentProduct;
  LotesProduct? currentProductLote;

  //*base de datos
  DataBaseSqlite db = DataBaseSqlite();

  //repositorios
  final InventarioRepository _inventarioRepository = InventarioRepository();

  CreateTransferBloc() : super(CrateTransferInitial()) {
    on<CreateTransferEvent>((event, emit) {});

    //*evento para actualizar el valor del scan
    on<UpdateScannedValueTransferEvent>(_onUpdateScannedValueEvent);
    on<ClearScannedValueTransferEvent>(_onClearScannedValueEvent);
    on<LoadConfigurationsUserCreateTransferEvent>(
        _onLoadConfigurationsUserEvent);

    on<ValidateFieldsEvent>(_onValidateFields);

    //*metodo para cargar las ubicaciones
    on<GetLocationsEvent>(_onLoadLocations);
    //*metodo para obtener los productos de la bd
    on<GetProductsFromDBEvent>(_onGetProductsFromDBEvent);

    //*metodo para mostrar el teclado
    on<ShowKeyboardCreateTransferEvent>(_onShowKeyboardEvent);

    //metodo para buscar una ubicacion
    on<SearchLocationEvent>(_onSearchLocationEvent);
    //*metodo para bucar un producto
    on<SearchProductEvent>(_onSearchProductEvent);
    //*metodo para validar la ubicacion
    on<ChangeLocationIsOkEvent>(_onChangeLocationIsOkEvent);
    //*metodo para validar el producto
    on<ChangeProductIsOkEvent>(_onChangeProductIsOkEvent);

    //*metodo para crear un lote a un producto
    on<CreateLoteProduct>(_onCreateLoteProduct);
    on<SearchLotevent>(_onSearchLoteEvent);
    //*metodo para obtener todos los lotes de un producto
    on<GetLotesProduct>(_onGetLotesProduct);
    on<SelectecLoteEvent>(_onChangeLoteIsOkEvent);

    //*cantidad
    on<ChangeIsOkQuantity>(_onChangeQuantityIsOkEvent);
  }

  void _onChangeQuantityIsOkEvent(
      ChangeIsOkQuantity event, Emitter<CreateTransferState> emit) async {
    if (event.isOk) {
      //todo actualizamos el valor de la cantidad en el producto seleccionado
      // await db.productoOrdenConteoRepository.setFieldTableProductOrdenConteo(
      //   event.idOrder,
      //   event.productId,
      //   "is_quantity_is_ok",
      //   1,
      //   event.idMove.toString(),
      //   currentProduct.locationId.toString(),
      // );
    }
    quantityIsOk = event.isOk;
    emit(ChangeIsOkState(
      event.isOk,
    ));
  }

  void _onChangeLoteIsOkEvent(
      SelectecLoteEvent event, Emitter<CreateTransferState> emit) async {
    try {
      currentProductLote = event.lote;
      loteIsOk = true;
      add(ChangeIsOkQuantity(true, currentProduct?.productId ?? 0));
      quantityIsOk = true;

      emit(ChangeLoteIsOkState(
        loteIsOk,
      ));
    } catch (e, s) {
      print('Error en el SelectecLoteEvent de inventario $s ->$e');
    }
  }

  //*metodo para obtener todos los lotes de un producto
  void _onGetLotesProduct(
      GetLotesProduct event, Emitter<CreateTransferState> emit) async {
    try {
      emit(GetLotesProductLoading());

      // Siempre obtener los lotes frescos del servidor
      final response = await _inventarioRepository.fetchAllLotesProduct(
          false, currentProduct?.productId ?? 0);

      listLotesProduct = response;
      listLotesProductFilters = response;
      emit(GetLotesProductSuccess(response));
    } catch (e, s) {
      emit(GetLotesProductFailure('Error al obtener los lotes del producto'));
      print('Error en _onGetLotesProduct: $e\n$s');
    }
  }

//metodo pea crar un lote a un producto
  void _onCreateLoteProduct(
      CreateLoteProduct event, Emitter<CreateTransferState> emit) async {
    try {
      emit(CreateLoteProductLoading());
      final response = await _inventarioRepository.createLote(
        false,
        currentProduct?.productId ?? 0,
        event.nameLote,
        event.fechaCaducidad,
      );

      if (response.result?.code == 200) {
        //agregamos el nuevo lote a la lista de lotes
        listLotesProduct.add(response.result?.result ?? LotesProduct());
        listLotesProductFilters.add(response.result?.result ?? LotesProduct());
        currentProductLote = response.result?.result;
        loteIsOk = true;
        dateLoteController.clear();
        newLoteController.clear();
        add(SelectecLoteEvent(currentProductLote!));
        emit(CreateLoteProductSuccess());
      } else {
        emit(CreateLoteProductFailure(response.result?.msg ??
            'Error al crear el lote concactarse con el administrador'));
      }
    } catch (e, s) {
      emit(CreateLoteProductFailure('Error al crear el lote'));
      print('Error en el _onCreateLoteProduct: $e, $s');
    }
  }

  void _onSearchLoteEvent(
      SearchLotevent event, Emitter<CreateTransferState> emit) async {
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

  void _onChangeProductIsOkEvent(
      ChangeProductIsOkEvent event, Emitter<CreateTransferState> emit) async {
    if (event.productIsOk) {
      currentProduct = event.productSelect;
      //todo guardamos el producto en la lista de productos seleccionados

      //todo guardamos su tiempo de inicio del producto
      dateInicio = DateTime.now().toString();

      productIsOk = event.productIsOk;
      if (currentProduct?.tracking == "lot") {
        add(GetLotesProduct(
          isManual: true,
          idLote: currentProduct?.lotId ?? 0,
        ));
      } else {
        //todo si el producto no tiene lote pasamos directo a la cantidad
        add(ChangeIsOkQuantity(
          true,
          event.productSelect.productId ?? 0,
        ));
      }
      //todo emitimos el estado
      emit(ChangeProductOrderIsOkState(
        productIsOk,
      ));
    }
  }

  void _onChangeLocationIsOkEvent(
      ChangeLocationIsOkEvent event, Emitter<CreateTransferState> emit) async {
    try {
      if (isLocationOk) {
        //todo asignamos tiempo de inicio
        dateInicio = DateTime.now().toString();

        //todo asignamos este tiempo para la transferencia

        //todo guardamos en la bd la ubicacion de origen de la transferencia

        //*cambiamos la variable de la ubicacion actual
        currentUbication = event.locationSelect;
        locationIsOk = true;
        emit(ChangeLocationIsOkState(
          locationIsOk,
        ));
      }
    } catch (e, s) {
      print("❌ Error en el ChangeLocationIsOkEvent $e ->$s");
    }
  }

  void _onSearchLocationEvent(
      SearchLocationEvent event, Emitter<CreateTransferState> emit) async {
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
    SearchProductEvent event,
    Emitter<CreateTransferState> emit,
  ) async {
    try {
      print('🔍 Buscando productos con query: "${event.query}"');
      emit(SearchLoading());

      productosFilters = [];
      productosFilters = productos;
      final query = event.query.toLowerCase();
      if (query.isEmpty) {
        productosFilters = productos;
      } else {
        final List<Product> filtrados = productos.where((product) {
          final name = (product.name ?? '').toLowerCase();
          final code = (product.code ?? '').toString().trim();
          final barcode = (product.barcode ?? '').toString().trim();

          return name.contains(query.toLowerCase()) ||
              code.contains(query) ||
              barcode.contains(query);
        }).toList();
        productosFilters = filtrados;
      }
      emit(SearchProductSuccess(productosFilters));
    } catch (e, s) {
      print('❌ Error en SearchProductEvent: $e\n$s');
      emit(SearchFailure(e.toString()));
    }
  }

  void _onGetProductsFromDBEvent(
      GetProductsFromDBEvent event, Emitter<CreateTransferState> emit) async {
    try {
      emit(GetProductsLoadingBD());
      final response = await db.productoInventarioRepository.getAllProducts();
      productos.clear();
      productosFilters.clear();
      if (response.isNotEmpty) {
        productos = response;
        productosFilters = response;
        print('productos de la bd::::: ${productos.length}');
        emit(GetProductsSuccessBD(response));
      } else {
        emit(GetProductsFailure('No se encontraron productos'));
      }
    } catch (e, s) {
      emit(GetProductsFailure('Error al cargar los productos'));
      print('Error en el fetch de productos: $e=>$s');
    }
  }

  void _onShowKeyboardEvent(ShowKeyboardCreateTransferEvent event,
      Emitter<CreateTransferState> emit) {
    isKeyboardVisible = event.showKeyboard;
    emit(ShowKeyboardState(showKeyboard: isKeyboardVisible));
  }

  void _onLoadLocations(
      GetLocationsEvent event, Emitter<CreateTransferState> emit) async {
    try {
      emit(LoadLocationsLoading());
      final response = await db.ubicacionesRepository.getAllUbicaciones();
      ubicaciones.clear();
      ubicacionesFilters.clear();
      print('ubicaciones: ${response.length}');
      if (response.isNotEmpty) {
        ubicaciones = response;
        ubicacionesFilters = ubicaciones;
        emit(LoadLocationsSuccess(ubicaciones));
      } else {
        emit(LoadLocationsFailure('No se encontraron ubicaciones'));
      }
    } catch (e, s) {
      emit(LoadLocationsFailure('Error al cargar las ubicaciones'));
      print('Error en el fetch de ubicaciones: $e=>$s');
    }
  }

  void _onValidateFields(
      ValidateFieldsEvent event, Emitter<CreateTransferState> emit) {
    try {
      switch (event.field) {
        case 'location':
          isLocationOk = event.isOk;
          break;
        case 'product':
          isProductOk = event.isOk;
          break;
        case 'locationDest':
          isLocationDestOk = event.isOk;
          break;
        case 'quantity':
          isQuantityOk = event.isOk;
          break;
        case 'lote':
          scannedValue4 = '';
          isLoteOk = event.isOk;
          break;
      }
      emit(ValidateFieldsStateSuccess(event.isOk));
    } catch (e, s) {
      emit(ValidateFieldsStateError('Error al validar campos'));
      print("❌ Error en el ValidateFieldsEvent $e ->$s");
    }
  }

  //* evento para cargar la configuracion del usuario
  void _onLoadConfigurationsUserEvent(
      LoadConfigurationsUserCreateTransferEvent event,
      Emitter<CreateTransferState> emit) async {
    try {
      int userId = await PrefUtils.getUserId();
      final response =
          await db.configurationsRepository.getConfiguration(userId);

      if (response != null) {
        emit(ConfigurationLoaded(response));
        configurations = response;
      } else {
        emit(ConfigurationError('Error al cargar LoadConfigurationsUser'));
      }
    } catch (e, s) {
      print('❌ Error en LoadConfigurationsUser $e =>$s');
    }
  }

//*evento para limpiar el valor del scan
  void _onClearScannedValueEvent(
      ClearScannedValueTransferEvent event, Emitter<CreateTransferState> emit) {
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

        case 'toProduct':
          scannedValue5 = '';
          emit(ClearScannedValueState());
          break;
        case 'toLocation':
          scannedValue6 = '';
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

  //*evento para actualizar el valor del scan
  void _onUpdateScannedValueEvent(UpdateScannedValueTransferEvent event,
      Emitter<CreateTransferState> emit) {
    try {
      print('scannedValue: ${event.scannedValue}');
      switch (event.scan) {
        case 'location':
          // Acumulador de valores escaneados
          scannedValue1 += event.scannedValue.trim();
          emit(UpdateScannedValueState(scannedValue1, event.scan));
          break;
        case 'product':
          scannedValue2 += event.scannedValue.trim();
          emit(UpdateScannedValueState(scannedValue2, event.scan));
          break;
        case 'quantity':
          scannedValue3 += event.scannedValue.trim();
          emit(UpdateScannedValueState(scannedValue3, event.scan));
          break;

        // case 'toProduct':
        //   scannedValue5 += event.scannedValue.trim();
        //   emit(UpdateScannedValueState(scannedValue5, event.scan));
        //   break;

        // case 'toLocation':
        //   scannedValue6 += event.scannedValue.trim();
        //   emit(UpdateScannedValueState(scannedValue6, event.scan));
        //   break;

        case 'lote':
          scannedValue4 += event.scannedValue.trim();
          print('scannedValue4: $scannedValue4');
          emit(UpdateScannedValueState(scannedValue4, event.scan));
          break;

        default:
          print('Scan type not recognized: ${event.scan}');
      }
    } catch (e, s) {
      print("❌ Error en _onUpdateScannedValueEvent: $e, $s");
    }
  }
}
