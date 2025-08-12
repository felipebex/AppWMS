import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/conteo/data/conteo_repository.dart';
import 'package:wms_app/src/presentation/views/conteo/models/conteo_response_model.dart';
import 'package:wms_app/src/presentation/views/inventario/data/inventario_repository.dart';
import 'package:wms_app/src/presentation/views/recepcion/models/response_lotes_product_model.dart';
import 'package:wms_app/src/presentation/views/user/models/configuration.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';
import 'package:wms_app/src/utils/prefs/pref_utils.dart';

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

  //*valores de scanvalue

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
  }

  void _onChangeLoteIsOkEvent(
      SelectecLoteEvent event, Emitter<ConteoState> emit) async {
    try {
      currentProductLote = event.lote;
      loteIsOk = true;
      // add(ChangeIsOkQuantity(true));
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

      if (event.isManual) {
        // Búsqueda optimizada sin caché - versión eficiente
        LotesProduct? foundLote;
        for (final lote in response) {
          if (lote.id == event.idLote) {
            foundLote = lote;
            break; // Rompe el ciclo al encontrar el lote
          }
        }

        currentProductLote = foundLote ?? LotesProduct();
        loteIsOk = true;
        // add(ChangeIsOkQuantity(true));
      }

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
          userId: await PrefUtils.getUserId(),
          userName: await PrefUtils.getUserName(),
          observation: '');
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
      dateInicio = DateTime.now().toString();
      //actualizmso valor de fecha inicio
      await db.productoOrdenConteoRepository.setFieldTableProductOrdenConteo(
        event.idOrder,
        event.productId,
        'date_start',
        dateInicio,
        event.idMove,
      );

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
          currentProduct.idMove ?? 0);

      //actualizamos el producto a true
      await db.productoOrdenConteoRepository.setFieldTableProductOrdenConteo(
        event.idOrder,
        event.productId,
        "product_is_ok",
        1,
        event.idMove,
      );
      //actualizamos la cantidad separada
      await db.productoOrdenConteoRepository.setFieldTableProductOrdenConteo(
        event.idOrder,
        event.productId,
        "quantity_counted",
        event.quantity,
        event.idMove,
      );

//validamos si el producto tiene lote
      if (currentProduct.productTracking != "lot") {
        add(GetLotesProduct(
          isManual: true,
          idLote: currentProduct?.lotId ?? 0,
        ));
      }
    }
    productIsOk = event.productIsOk;
    if (currentProduct.productTracking != "lot") {
      quantityIsOk = event.productIsOk;
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
            event.idMove);
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
        await db.productoOrdenConteoRepository.setFieldTableProductOrdenConteo(
          event.orden,
          event.productId,
          'is_location_is_ok',
          1,
          event.idMove,
        );
        locationIsOk = true;
        // add(ChangeIsOkQuantity(currentProduct.orderId ?? 0, true,
        //     currentProduct.productId ?? 0, currentProduct.idMove ?? 0));
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
          event.idOrder, event.productId, "is_quantity_is_ok", 1, event.idMove);
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
          print('scannedValue1: $scannedValue1.');
          emit(UpdateScannedValueState(scannedValue1, event.scan));
          break;
        case 'product':
          scannedValue2 += event.scannedValue.trim();
          print('scannedValue2: $scannedValue2');
          emit(UpdateScannedValueState(scannedValue2, event.scan));
          break;
        case 'quantity':
          scannedValue3 += event.scannedValue.trim();
          print('scannedValue3: $scannedValue3');
          emit(UpdateScannedValueState(scannedValue3, event.scan));
          break;

        case 'toProduct':
          print('scannedValue5: $scannedValue5');
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
          event.currentProduct.orderId ?? 0);

      //actualizamos las variables de estado segun el producto actual

      locationIsOk = productBD?.isLocationIsOk == 1 ? true : false;
      productIsOk = productBD?.productIsOk == 1 ? true : false;
      quantityIsOk = productBD?.isQuantityIsOk == 1 ? true : false;

      print('Variable locationIsOk: $locationIsOk');
      print('Variable productIsOk: $productIsOk');
      print('Variable quantityIsOk: $quantityIsOk');

      currentProduct = productBD ?? CountedLine();
      products();
      add(FetchBarcodesProductEvent());
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
          emit(ClearScannedValueState());
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
    );

    print('productBD: ${productBD?.toMap()}');
  }
}
