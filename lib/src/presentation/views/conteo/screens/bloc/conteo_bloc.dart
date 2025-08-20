// ignore_for_file: unrelated_type_equality_checks

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wms_app/src/core/utils/prefs/pref_utils.dart';
import 'package:wms_app/src/presentation/models/response_ubicaciones_model.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/conteo/data/conteo_repository.dart';
import 'package:wms_app/src/presentation/views/conteo/models/conteo_response_model.dart';
import 'package:wms_app/src/presentation/views/conteo/models/request_send_product_model.dart';
import 'package:wms_app/src/presentation/views/conteo/models/response_send_product_model.dart';
import 'package:wms_app/src/presentation/views/inventario/data/inventario_repository.dart';
import 'package:wms_app/src/presentation/views/inventario/models/response_products_model.dart';
import 'package:wms_app/src/presentation/views/recepcion/models/response_lotes_product_model.dart';
import 'package:wms_app/src/presentation/views/user/models/configuration.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';

part 'conteo_event.dart';
part 'conteo_state.dart';

class ConteoBloc extends Bloc<ConteoEvent, ConteoState> {
  final ConteoRepository _repository = ConteoRepository();
  //*base de datos
  DataBaseSqlite db = DataBaseSqlite();

  DatumConteo ordenConteo = DatumConteo();
  List<DatumConteo> ordenesDeConteo = [];
  List<CountedLine> lineasContadas = [];
  List<Allowed> ubicacionesConteo = [];
  List<Allowed> categoriasConteo = [];
  List<Barcodes> listOfBarcodes = [];
  //lista de lotes de un producto
  List<LotesProduct> listLotesProduct = [];
  List<LotesProduct> listLotesProductFilters = [];
  //*lista de todas las pocisiones de los productos del batchs
  List<String> positionsOrigen = [];

  //configuracion del usuario //permisos
  Configurations configurations = Configurations();

  TextEditingController newLoteController = TextEditingController();
  TextEditingController searchControllerLote = TextEditingController();
  TextEditingController dateLoteController = TextEditingController();
  TextEditingController searchControllerLocation = TextEditingController();
  TextEditingController searchControllerProducts = TextEditingController();

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

  // //*validaciones de campos del estado de la vista
  bool loteIsOk = false;
  bool isLocationOk = true;
  bool isProductOk = true;
  bool isLocationDestOk = true;
  bool isQuantityOk = true;
  bool isKeyboardVisible = false;
  bool isLoteOk = true;

  bool viewQuantity = false;

  //*variables para validar
  bool locationIsOk = false;
  bool productIsOk = false;
  bool locationDestIsOk = false;
  bool quantityIsOk = false;

  String ubicacionExpanded = '';

  dynamic quantitySelected = 0;

  List<String> listOfProductsName = [];

  LotesProduct? currentProductLote;
  //*lista de ubicaciones maestra
  List<ResultUbicaciones> ubicaciones = [];
  List<ResultUbicaciones> ubicacionesFilters = [];
  List<ResultUbicaciones> ubicacionesFiltersSearch = [];

  //lista de productos maestra
  List<Product> productos = [];
  List<Product> productosFilters = [];
  List<Product> productosFiltersSearch = [];

  //producto actual
  Product? currentNewProduct;
  ResultUbicaciones? currentUbication;

  final InventarioRepository _inventarioRepository = InventarioRepository();

  //*producto en posicion actual
  CountedLine currentProduct = CountedLine();

  ConteoBloc() : super(ConteoInitial()) {
    //evento para obtener la lista de conteos
    on<GetConteosEvent>(_onGetConteosEvent);
    //evento para obtener la lista de conteos desde la bd
    on<GetConteosFromDBEvent>(_onGetConteosFromDBEvent);
    //evento para cargar un conteo especifico
    on<LoadConteoAndProductsEvent>(_onLoadConteoEvent);

    on<ValidateFieldsEvent>(_onValidateFields);

    //metodo para cargar el producto actual
    on<LoadCurrentProductEvent>(_onLoadCurrentProductEvent);

    //*evento para actualizar el valor del scan
    on<UpdateScannedValueEvent>(_onUpdateScannedValueEvent);
    on<ClearScannedValueEvent>(_onClearScannedValueEvent);
    on<LoadConfigurationsUserConteo>(_onLoadConfigurationsUserEvent);

    //*cambiar el estado de las variables
    on<ChangeLocationIsOkEvent>(_onChangeLocationIsOkEvent);

    //*cantidad
    on<ChangeIsOkQuantity>(_onChangeQuantityIsOkEvent);
    //*evento para cambiar la cantidad seleccionada
    on<ChangeQuantitySeparate>(_onChangeQuantitySelectedEvent);

    //*cambiar el estado de las variables
    on<ChangeProductIsOkEvent>(_onChangeProductIsOkEvent);

    //metodo para expandeir ubicacion
    on<ExpandLocationEvent>(_onExpandLocationEvent);

    //*evento para reiniciar los valores
    on<ResetValuesEvent>(_onResetValuesEvent);

    //*evento para ver la cantidad
    on<ShowQuantityEvent>(_onShowQuantityEvent);

    on<AddQuantitySeparate>(_onAddQuantitySeparateEvent);

    //evento para limpiar las ubicaciones expandidas
    on<ClearExpandedLocationEvent>((event, emit) {
      ubicacionExpanded = '';
      scannedValue6 = '';
      emit(ClearExpandedLocationState());
    });

    //*evento para obtener los barcodes de un producto por paquete
    on<FetchBarcodesProductEvent>(_onFetchBarcodesProductEvent);

    //*metodo para obtener todos los lotes de un producto
    on<GetLotesProduct>(_onGetLotesProduct);
    on<SelectecLoteEvent>(_onChangeLoteIsOkEvent);

    //metodo para mostrar el teclado
    on<ShowKeyboardEvent>(_onShowKeyboardEvent);

    //*metodo para crear un lote a un producto
    on<CreateLoteProduct>(_onCreateLoteProduct);
    on<SearchLotevent>(_onSearchLoteEvent);

    //metodo para enviar un producto contado al wms
    on<SendProductConteoEvent>(_onSendProductConteoEvent);
    //metodo para borrar un producto ya enviado
    on<DeleteProductConteoEvent>(_onDeleteProductConteoEvent);

    //*metodo para cargar las ubicaciones
    on<GetLocationsConteoEvent>(_onLoadLocations);

    //todo estados para un new product
    //Metodo para cargar informacion pa crear un nuevo producto
    on<LoadNewProductEvent>(_onLoadNewProductEvent);
    //metodo para buscar una ubicacion
    on<SearchLocationEvent>(_onSearchLocationEvent);
    //*metodo para bucar un producto
    on<SearchProductEvent>(_onSearchProductEvent);
  }

  void _onSearchProductEvent(
    SearchProductEvent event,
    Emitter<ConteoState> emit,
  ) async {
    try {
      print('🔍 Buscando productos con query: "${event.query}"');
      emit(SearchLoading());

      final query = event.query.trim();

      final List<Product> filtrados = productosFilters.where((product) {
        final name = (product.name ?? '').toLowerCase();
        final code = (product.code ?? '').toString().trim();
        final barcode = (product.barcode ?? '').toString().trim();

        return name.contains(query.toLowerCase()) ||
            code.contains(query) ||
            barcode.contains(query);
      }).toList();

      productosFiltersSearch = filtrados;

      emit(SearchProductSuccess(filtrados));
    } catch (e, s) {
      print('❌ Error en SearchProductEvent: $e\n$s');
      emit(SearchFailure(e.toString()));
    }
  }

  void _onSearchLocationEvent(
      SearchLocationEvent event, Emitter<ConteoState> emit) async {
    try {
      emit(SearchLoading());
      ubicacionesFiltersSearch = [];
      ubicacionesFiltersSearch = ubicacionesFilters;
      final query = event.query.toLowerCase();
      if (query.isEmpty) {
        ubicacionesFiltersSearch = ubicacionesFilters;
      } else {
        ubicacionesFiltersSearch = ubicacionesFilters.where((location) {
          return location.name?.toLowerCase().contains(query) ?? false;
        }).toList();
      }
      emit(SearchLocationSuccess(ubicacionesFiltersSearch));
    } catch (e, s) {
      print('Error en el SearchLocationEvent: $e, $s');
      emit(SearchFailure(e.toString()));
    }
  }

  void _onLoadNewProductEvent(
      LoadNewProductEvent event, Emitter<ConteoState> emit) async {
    try {
      //vamos a cargar la informacion pa crear un nuevo producto

      //todo: para este filtro solo podemos crear un producto con las ubicaciones de la orden de conteo y los productos de la orden
      if (ordenConteo.filterType == 'combined') {
        //llenamos el listado de ubicacioones
        ubicacionesFilters.clear();
        ubicacionesFiltersSearch.clear();
        ubicacionesFilters = ubicacionesConteo.map((allowed) {
          return ResultUbicaciones(
            id: allowed.id ?? 0,
            name: allowed.name ?? '',
            barcode: allowed.barcode ?? '',
            locationId: allowed.id ?? 0,
            locationName: allowed.name ?? '',
            idWarehouse: 0,
            warehouseName: '',
          );
        }).toList();
        ubicacionesFiltersSearch = ubicacionesFilters;
        //llenamos la lista de productos
        productosFilters.clear();
        productosFiltersSearch.clear();

        final productsOrder = await db.productoOrdenConteoRepository
            .getProductosByOrderId(ordenConteo.id ?? 0);

        productosFilters = productsOrder.map((product) {
          return Product(
            productId: product.productId,
            name: product.productName,
            code: product.productCode,
            category: product.categoryName,
            lotId: product.lotId,
            lotName: product.lotName,
            barcode: product.productBarcode,
            otherBarcodes: [],
            productPacking: [],
            tracking: product.productTracking,
            useExpirationDate:
                product.fechaVencimiento?.isNotEmpty ?? true ? true : false,
            expirationTime: "",
            weight: product.weight,
            weightUomName: "",
            volume: 0,
            volumeUomName: '',
            expirationDate: product.fechaVencimiento,
            uom: product.uom,
            locationId: product.locationId ?? 0,
            locationName: product.locationName ?? '',
            quantity: 0, // Inicializamos la cantidad en 0
          );
        }).toList();
        productosFiltersSearch = productosFilters;

        print("productosFilters :${productosFilters.length}");
      } else if (ordenConteo.filterType == "location") {
        //las ubicaciones que llegan en la orden
        ubicacionesFilters.clear();
        ubicacionesFiltersSearch.clear();
        ubicacionesFilters = ubicacionesConteo.map((allowed) {
          return ResultUbicaciones(
            id: allowed.id ?? 0,
            name: allowed.name ?? '',
            barcode: allowed.barcode ?? '',
            locationId: allowed.id ?? 0,
            locationName: allowed.name ?? '',
            idWarehouse: 0,
            warehouseName: '',
          );
        }).toList();
        ubicacionesFiltersSearch = ubicacionesFilters;

        //filtro por ubicacion
      } else if (ordenConteo.filterType == "category" ||
          ordenConteo.filterType == "product") {
        //filtro por categoria o producto
      }

      print("ubicacionesFilters: ${ubicacionesFilters.length}");

      emit(LoadNewProductSuccess());
    } catch (e) {
      emit(LoadNewProductFailure(
          'Error al cargar los datos para el nuevo producto'));
    }
  }

  void _onLoadLocations(
      GetLocationsConteoEvent event, Emitter<ConteoState> emit) async {
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

  void _onDeleteProductConteoEvent(
      DeleteProductConteoEvent event, Emitter<ConteoState> emit) async {
    try {
      emit(DeleteProductConteoLoading());
      final response = await _repository.deleteProductConteo(
          false, event.currentProduct.idMove ?? 0);

      if (response.result?.code == 200) {
        await db.productoOrdenConteoRepository
            .deleteProductConteo(event.currentProduct);
        //actualizamos la lista de productos contados
        add(LoadConteoAndProductsEvent(
            ordenConteoId: event.currentProduct.orderId ?? 0));

        emit(DeleteProductConteoSuccess());
        //borramos el producto de la base de datos
      } else {
        emit(DeleteProductConteoFailure(
            response.result?.msg ?? 'Error al eliminar el producto'));
      }
    } catch (e, s) {
      print('Error al eliminar el producto: $e, $s');
      emit(DeleteProductConteoFailure('Error al eliminar el producto'));
    }
  }

  void _onSendProductConteoEvent(
      SendProductConteoEvent event, Emitter<ConteoState> emit) async {
    try {
      emit(SendProductConteoLoading());

      int userId = await PrefUtils.getUserId();
      //verificamos si el producto actual tiene lote
      if (event.currentProduct.productTracking == "lot" &&
          currentProductLote == null) {
        emit(SendProductConteoFailure('Debe seleccionar un lote para enviar'));
        return;
      }

      DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      String formattedDate = formatter.format(DateTime.now());

      //calculamos la diferencia de tiempo
      if (dateInicio == "" || dateInicio == null) {
        dateInicio = DateTime.now().toString();
      }
      if (dateFin == "" || dateFin == null) {
        dateFin = DateTime.now().toString();
      }
      DateTime dateStart = DateTime.parse(dateInicio);
      DateTime dateEnd = DateTime.parse(dateFin);

      var difference = dateEnd.difference(dateStart);
      int time = difference.inSeconds;

//construimos el producto a enviar
      final productSend = ConteoItem(
        lineId: event.currentProduct.idMove.toString(),
        orderId: event.currentProduct.orderId ?? 0,
        productId: event.currentProduct.productId ?? 0,
        quantityCounted: event.cantidad,
        observation: 'Sin novedad',
        timeLine: time,
        fechaTransaccion: formattedDate,
        idOperario: userId,
        locationId: event.currentProduct.locationId ?? 0,
        loteId: event.currentProduct.lotId.toString(),
      );

      //lo convertimos en entero
      //actualizamos el tiempo del producto
      await db.productoOrdenConteoRepository.setFieldTableProductOrdenConteo(
        productSend.orderId,
        productSend.productId,
        'time',
        time,
        productSend.lineId.toString(),
        productSend.locationId.toString(),
      );

      //mostramos el productSend
      print("---------");
      print("Producto a enviar: ${productSend.toJson()}");
      print("---------");
      print('event currentProduct: ${event.currentProduct.toJson()}');
      print("---------");

      //enviamos el producto al wms
      final response = await _repository.sendProductConteo(true, productSend);

      if (response.result?.code == 200) {
        //actualzamos la cantidad del producto en la bd
        await db.productoOrdenConteoRepository.setFieldTableProductOrdenConteo(
          productSend.orderId,
          productSend.productId,
          "quantity_counted",
          productSend.quantityCounted ?? 0,
          productSend.lineId.toString(),
          currentProduct.locationId.toString(),
        );

        // actualizamos el estado del producto en la bd
        await db.productoOrdenConteoRepository.setFieldTableProductOrdenConteo(
          productSend.orderId,
          productSend.productId,
          'is_done_item',
          1,
          productSend.lineId.toString(),
          productSend.locationId.toString(),
        );

        emit(SendProductConteoSuccess(response));
      } else {
        emit(SendProductConteoFailure(
            response.result?.msg ?? 'Error al enviar el producto'));
      }
    } catch (e, s) {
      print('Error al enviar el producto: $e, $s');
      emit(SendProductConteoFailure('Error al enviar el producto'));
    }
  }

  //metodo pea crar un lote a un producto
  void _onCreateLoteProduct(
      CreateLoteProduct event, Emitter<ConteoState> emit) async {
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
      SearchLotevent event, Emitter<ConteoState> emit) async {
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

  void _onShowKeyboardEvent(
      ShowKeyboardEvent event, Emitter<ConteoState> emit) {
    isKeyboardVisible = event.showKeyboard;
    emit(ShowKeyboardState(showKeyboard: isKeyboardVisible));
  }

  void _onChangeLoteIsOkEvent(
      SelectecLoteEvent event, Emitter<ConteoState> emit) async {
    try {
      currentProductLote = event.lote;
      loteIsOk = true;
      add(ChangeIsOkQuantity(currentProduct.orderId ?? 0, true,
          currentProduct.productId ?? 0, currentProduct.idMove ?? 0));
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
      GetLotesProduct event, Emitter<ConteoState> emit) async {
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

  //*evento para obtener los barcodes de un producto por paquete
  void _onFetchBarcodesProductEvent(
      FetchBarcodesProductEvent event, Emitter<ConteoState> emit) async {
    try {
      listOfBarcodes.clear();

      final responseList = await db.barcodesPackagesRepository.getAllBarcodes();

      print("responseList: ${responseList.length}");

      listOfBarcodes = await db.barcodesPackagesRepository.getBarcodesProduct(
          currentProduct.orderId ?? 0,
          currentProduct.productId ?? 0,
          currentProduct.idMove ?? 0,
          'orden');
      print("listOfBarcodes: ${listOfBarcodes.length}");
    } catch (e, s) {
      print("❌ Error en _onFetchBarcodesProductEvent: $e, $s");
    }
    emit(BarcodesProductLoadedState(listOfBarcodes: listOfBarcodes));
  }

  //*evento para aumentar la cantidad
  void _onAddQuantitySeparateEvent(
      AddQuantitySeparate event, Emitter<ConteoState> emit) async {
    try {
      quantitySelected = quantitySelected + event.quantity;
      await db.productoOrdenConteoRepository.updateCantidadContada(
          productId: event.productId,
          orderId: event.idOrder,
          cantidad: quantitySelected,
          idMove: currentProduct.idMove.toString());
      emit(ChangeQuantitySeparateStateSuccess(quantitySelected));
    } catch (e, s) {
      emit(ChangeQuantitySeparateStateError('Error al aumentar cantidad'));
      print("❌ Error en el AddQuantitySeparate $e ->$s");
    }
  }

  //*evento para ver la cantidad
  void _onShowQuantityEvent(
      ShowQuantityEvent event, Emitter<ConteoState> emit) {
    try {
      viewQuantity = !viewQuantity;
      emit(ShowQuantityState(viewQuantity));
    } catch (e, s) {
      print("❌ Error en _onShowQuantityEvent: $e, $s");
    }
  }

  void products() {
    try {
      //metodo para obtener todos los productos similares que estan en la misma ubicacion del producto actual y hacerlo con un set para que no se repitan y luego convertirlo en una lista
      Set<String> productsSet = {};
      for (var product in lineasContadas) {
        if (product.locationId == currentProduct.locationId) {
          productsSet.add(product.productName ?? '');
        }
      }
      listOfProductsName = productsSet.toList();
    } catch (e, s) {
      print("❌ Error en el products $e ->$s");
    }
  }

  //*evento para reiniciar los valores
  void _onResetValuesEvent(ResetValuesEvent event, Emitter<ConteoState> emit) {
    scannedValue1 = '';
    scannedValue2 = '';
    scannedValue3 = '';
    scannedValue5 = '';
    scannedValue6 = '';

    isLocationOk = true;
    isProductOk = true;
    isLocationDestOk = true;
    isQuantityOk = true;

    locationIsOk = false;
    productIsOk = false;
    locationDestIsOk = false;
    quantityIsOk = false;
    ubicacionExpanded = '';
    currentProduct = CountedLine();
    oldLocation = '';

    listOfProductsName = [];
    quantitySelected = 0;

    loteIsOk = false;
    currentProductLote = null;
    listLotesProduct.clear();
    listLotesProductFilters.clear();
    dateInicio = '';
    dateFin = '';
    scannedValue4 = '';
    viewQuantity = false;
    listOfBarcodes.clear();

    //variables de new product
    ubicacionesFiltersSearch = [];
    ubicacionesFilters.clear();
    searchControllerLocation.clear();
    currentUbication = null;
    currentNewProduct = null;
    productosFilters.clear();

    emit(ConteoInitial());
  }

  void _onExpandLocationEvent(
      ExpandLocationEvent event, Emitter<ConteoState> emit) {
    ubicacionExpanded = event.ubicacion;
    print('Ubicacion expandida: $ubicacionExpanded');
    emit(ExpandLocationState(ubicacionExpanded));
  }

  void _onChangeProductIsOkEvent(
      ChangeProductIsOkEvent event, Emitter<ConteoState> emit) async {
    if (event.productIsOk) {
      //si el producto es nuevo entonces no guardamos registros
      if (event.isNewProduct == false) {
        //todo actualizamos la entrada a true
        await db.ordenRepository.updateField(
          event.idOrder,
          "is_selected",
          1,
        );

        await db.productoOrdenConteoRepository.setFieldTableProductOrdenConteo(
          event.idOrder,
          event.productId,
          "is_selected",
          1,
          currentProduct.idMove.toString(),
          currentProduct.locationId.toString(),
        );

        //actualizamos el producto a true
        await db.productoOrdenConteoRepository.setFieldTableProductOrdenConteo(
          event.idOrder,
          event.productId,
          "product_is_ok",
          1,
          event.idMove.toString(),
          currentProduct.locationId.toString(),
        );
        //actualizamos la cantidad separada
        await db.productoOrdenConteoRepository.setFieldTableProductOrdenConteo(
          event.idOrder,
          event.productId,
          "quantity_counted",
          event.quantity,
          event.idMove.toString(),
          currentProduct.locationId.toString(),
        );
      } else {
        currentProduct = CountedLine();
        currentProduct ==
            CountedLine(
              productId: event.productSelect.productId,
              orderId: ordenConteo.id,
              idMove: event.idMove,
              locationId: event.productSelect.locationId,
              locationName: event.productSelect.locationName,
              productTracking: event.productSelect.tracking,
              productName: event.productSelect.name,
              productCode: event.productSelect.code,
              productBarcode: event.productSelect.barcode,
              lotId: event.productSelect.lotId,
              lotName: event.productSelect.lotName,
              uom: event.productSelect.uom,
              fechaVencimiento: event.productSelect.expirationDate,
              weight: event.productSelect.weight,
              categoryName: event.productSelect.category,
            );
            
      }
    }
    productIsOk = event.productIsOk;
    if (currentProduct.productTracking != "lot") {
      add(ChangeIsOkQuantity(
        event.idOrder,
        true,
        event.productId,
        event.idMove,
      ));
    }
    emit(ChangeProductOrderIsOkState(
      productIsOk,
    ));
  }

  void _onChangeQuantitySelectedEvent(
      ChangeQuantitySeparate event, Emitter<ConteoState> emit) async {
    try {
      if (event.quantity > 0.0) {
        quantitySelected = event.quantity;
        await db.productoOrdenConteoRepository.setFieldTableProductOrdenConteo(
          event.idOrder,
          event.productId,
          "quantity_counted",
          event.quantity,
          event.idMove.toString(),
          currentProduct.locationId.toString(),
        );
      }
      emit(ChangeQuantitySeparateState(quantitySelected));
    } catch (e, s) {
      print('Error en _onChangeQuantitySelectedEvent: $e, $s');
    }
  }

  void _onChangeLocationIsOkEvent(
      ChangeLocationIsOkEvent event, Emitter<ConteoState> emit) async {
    try {
      if (isLocationOk) {
        //si el producto es nuevo entonces no guardamos registros
        if (event.isNewProduct == false) {
          dateInicio = DateTime.now().toString();
          //actualizmso valor de fecha inicio
          await db.productoOrdenConteoRepository
              .setFieldTableProductOrdenConteo(
            event.orden,
            event.productId,
            'date_start',
            dateInicio,
            event.idMove.toString(),
            currentProduct.locationId.toString(),
          );

          await db.productoOrdenConteoRepository
              .setFieldTableProductOrdenConteo(
            event.orden,
            event.productId,
            'is_location_is_ok',
            1,
            event.idMove.toString(),
            currentProduct.locationId.toString(),
          );
        } else {
          //asignamos el valor de la ubicacion actual cuando el producto es nuevo
          currentUbication = ResultUbicaciones();
          currentUbication = event.locationSelect;
        }

        locationIsOk = true;
        emit(ChangeLocationIsOkState(
          locationIsOk,
        ));
      }
    } catch (e, s) {
      print("❌ Error en el ChangeLocationIsOkEvent $e ->$s");
    }
  }

  void _onChangeQuantityIsOkEvent(
      ChangeIsOkQuantity event, Emitter<ConteoState> emit) async {
    if (event.isOk) {
      await db.productoOrdenConteoRepository.setFieldTableProductOrdenConteo(
        event.idOrder,
        event.productId,
        "is_quantity_is_ok",
        1,
        event.idMove.toString(),
        currentProduct.locationId.toString(),
      );
    }
    quantityIsOk = event.isOk;
    emit(ChangeIsOkState(
      event.isOk,
    ));
  }

  //* evento para cargar la configuracion del usuario
  void _onLoadConfigurationsUserEvent(
      LoadConfigurationsUserConteo event, Emitter<ConteoState> emit) async {
    try {
      int userId = await PrefUtils.getUserId();
      final response =
          await db.configurationsRepository.getConfiguration(userId);

      if (response != null) {
        emit(ConfigurationPickingLoaded(response));
        configurations = response;
      } else {
        emit(ConfigurationError('Error al cargar LoadConfigurationsUser'));
      }
    } catch (e, s) {
      print('❌ Error en LoadConfigurationsUser $e =>$s');
    }
  }

  void getPosicions() {
    try {
      // Usar un Set para evitar duplicados automáticamente
      Set<String> positionsSet = {};
      // Usamos un filtro para no tener que comprobar locationId en cada iteración
      for (var product in lineasContadas) {
        // Solo añadimos locationId si no es nulo ni vacío
        String locationName = product.locationName ?? '';
        if (locationName.isNotEmpty) {
          positionsSet.add(locationName);
        }
      }

      // Convertimos el Set a lista si es necesario
      positionsOrigen = positionsSet.toList();
    } catch (e, s) {
      print("❌ Error en getPosicions: $e -> $s");
    }
  }

//*evento para limpiar el valor del scan
  void _onClearScannedValueEvent(
      ClearScannedValueEvent event, Emitter<ConteoState> emit) {
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
  void _onUpdateScannedValueEvent(
      UpdateScannedValueEvent event, Emitter<ConteoState> emit) {
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

        case 'toProduct':
          scannedValue5 += event.scannedValue.trim();
          emit(UpdateScannedValueState(scannedValue5, event.scan));
          break;

        case 'toLocation':
          scannedValue6 += event.scannedValue.trim();
          emit(UpdateScannedValueState(scannedValue6, event.scan));
          break;

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

  //metodo para cargar el producto actual
  void _onLoadCurrentProductEvent(
      LoadCurrentProductEvent event, Emitter<ConteoState> emit) async {
    try {
      currentProduct = CountedLine();

      ///mandamos a traer el producto actual de la bd para cargarlo
      final productBD = await db.productoOrdenConteoRepository.getProductoById(
        event.currentProduct.productId ?? 0,
        event.currentProduct.idMove,
        event.currentProduct.orderId ?? 0,
        event.currentProduct.locationId ?? 0,
      );

      //actualizamos las variables de estado segun el producto actual

      locationIsOk = productBD?.isLocationIsOk == 1 ? true : false;
      productIsOk = productBD?.productIsOk == 1 ? true : false;

      print('Variable locationIsOk: $locationIsOk');
      print('Variable productIsOk: $productIsOk');
      print('Variable quantityIsOk: $quantityIsOk');

      currentProduct = productBD ?? CountedLine();
      print('Producto actual db: ${currentProduct.productName}');
      products();
      add(FetchBarcodesProductEvent());
      //validamos si el producto tiene lote
      if (currentProduct.productTracking == "lot") {
        add(GetLotesProduct(
          isManual: true,
          idLote: currentProduct?.lotId ?? 0,
        ));
      } else {
        if (productIsOk && locationIsOk && loteIsOk) {
          quantityIsOk = true;
        } else {
          // quantityIsOk = false;
          quantityIsOk = productBD?.isQuantityIsOk == 1 ? true : false;
        }
      }
      emit(LoadCurrentProductSuccess(currentProduct));
    } catch (e, s) {
      emit(LoadCurrentProductError('Error al cargar el producto actual'));
      print("❌ Error en el LoadCurrentProductEvent $e ->$s");
    }
  }

  void _onValidateFields(ValidateFieldsEvent event, Emitter<ConteoState> emit) {
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

  void _onGetConteosFromDBEvent(
      GetConteosFromDBEvent event, Emitter<ConteoState> emit) async {
    emit(ConteoFromDBLoading());
    try {
      ordenesDeConteo.clear();
      final response = await db.ordenRepository.getAllOrdenes();

      if (response.isNotEmpty) {
        ordenesDeConteo = response;
        emit(ConteoFromDBLoaded(ordenesDeConteo));
      } else {
        emit(
            ConteoFromDBError("No se encontraron conteos en la base de datos"));
      }
    } catch (e, s) {
      print("Error al obtener los conteos desde la BD: $e, $s");
      emit(ConteoFromDBError("Error al obtener los conteos desde la BD: $e"));
    }
  }

  void _onLoadConteoEvent(
      LoadConteoAndProductsEvent event, Emitter<ConteoState> emit) async {
    try {
      //obtenemos la orden de conteo desde la bd
      ordenConteo =
          await db.ordenRepository.getOrdenById(event.ordenConteoId ?? 0) ??
              DatumConteo();

      //obtenemos las lineas contadas de esa orden de conteo
      lineasContadas = await db.productoOrdenConteoRepository
          .getProductosByOrderId(event.ordenConteoId ?? 0);

      //obtenemos las ubicaciones de esa orden de conteo
      ubicacionesConteo = await db.ubicacionesConteoRepository
          .getUbicacionesByOrdenId(event.ordenConteoId ?? 0);

      //obtenemos las categorias de esa orden de conteo
      categoriasConteo = await db.categoriasConteoRepository
          .getCategoriasByOrdenId(event.ordenConteoId ?? 0);

      getPosicions();

      emit(LoadConteoSuccess(ordenConteo));
    } catch (e, s) {
      print("Error al cargar el conteo: $e, $s");
      emit(ConteoError("Error al cargar el conteo: $e"));
    }
  }

  void _onGetConteosEvent(
      GetConteosEvent event, Emitter<ConteoState> emit) async {
    emit(ConteoLoading());
    try {
      //borramos todos los registros de losc conteos

      await DataBaseSqlite().deleConteo();
      final response = await _repository.fetchAllConteos(true);
      if (response.data?.isNotEmpty ?? false) {
        //agregamos esas ordenes a la bd
        await db.ordenRepository
            .insertOrUpdateOrdenes(response.data as List<DatumConteo>);

        //obtenemos los productos de todas las ordenes de conteo
        final productsToInsert =
            _getAllProducts(response.data as List<DatumConteo>)
                .toList(growable: false);

        await db.productoOrdenConteoRepository
            .upsertProductosOrdenConteo(productsToInsert);

        //obtenemos los ptoducto de ordenes de conteos que ya fueron contados
        final productsToInsertDone =
            _getAllProductsDone(response.data as List<DatumConteo>)
                .toList(growable: false);

        await db.productoOrdenConteoRepository
            .upsertProductosOrdenConteo(productsToInsertDone);
        //obtenemos las ubicaciones de todas las ordenes de conteo
        final ubicacionesToInsert =
            _getAllUbicaciones(response.data as List<DatumConteo>)
                .toList(growable: false);

        await db.ubicacionesConteoRepository
            .upsertUbicacionesConteo(ubicacionesToInsert);

        //obtenemos las categorias de todas las ordenes de conteo
        final categoriasToInsert =
            _getAllCategories(response.data as List<DatumConteo>)
                .toList(growable: false);

        await db.categoriasConteoRepository
            .upsertCategoriasConteo(categoriasToInsert);

        //obtenemos los barcodes de todas las ordenes de conteo
        final allBarcodes =
            _extractAllBarcodes(response.data as List<DatumConteo>)
                .toList(growable: false);

        if (allBarcodes.isNotEmpty) {
          // Enviar la lista agrupada a insertBarcodesPackageProduct
          await DataBaseSqlite()
              .barcodesPackagesRepository
              .insertOrUpdateBarcodes(allBarcodes, 'orden');
        }

        add(GetConteosFromDBEvent());
        emit(ConteoLoaded(response.data as List<DatumConteo>));
      } else {
        emit(ConteoError("No se encontraron conteos"));
      }
    } catch (e, s) {
      print("Error al obtener los conteos: $e, $s");
      emit(ConteoError("Error al obtener los conteos: $e"));
    }
  }

  Iterable<Barcodes> _extractAllBarcodes(List<DatumConteo> batches) sync* {
    for (final batch in batches) {
      if (batch.countedLines == null) continue;

      for (final product in batch.countedLines!) {
        if (product.productPacking != null) {
          yield* product.productPacking!;
        }
        if (product.otherBarcodes != null) {
          yield* product.otherBarcodes!;
        }
      }
    }
  }

  Iterable<CountedLine> _getAllProducts(List<DatumConteo> ordenes) sync* {
    for (final orden in ordenes) {
      if (orden.countedLines != null) yield* orden.countedLines!;
    }
  }

  Iterable<CountedLine> _getAllProductsDone(List<DatumConteo> ordenes) sync* {
    for (final orden in ordenes) {
      if (orden.countedLinesDone != null) yield* orden.countedLinesDone!;
    }
  }

  Iterable<Allowed> _getAllUbicaciones(List<DatumConteo> ordenes) sync* {
    for (final orden in ordenes) {
      if (orden.allowedLocations != null) yield* orden.allowedLocations!;
    }
  }

  Iterable<Allowed> _getAllCategories(List<DatumConteo> ordenes) sync* {
    for (final orden in ordenes) {
      if (orden.allowedCategories != null) yield* orden.allowedCategories!;
    }
  }

  getProduct() async {
    final productBD = await db.productoOrdenConteoRepository.getProductoById(
      currentProduct.productId ?? 0,
      currentProduct.idMove,
      currentProduct.orderId ?? 0,
      currentProduct.locationId ?? 0,
    );

    print('productBD: ${productBD?.toMap()}');
  }
}
