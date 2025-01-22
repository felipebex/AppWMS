// ignore_for_file: unnecessary_null_comparison, unnecessary_type_check, avoid_print, prefer_is_empty, use_build_context_synchronously, prefer_if_null_operators

import 'package:device_info_plus/device_info_plus.dart';
import 'package:wms_app/src/presentation/models/novedades_response_model.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/user/domain/models/configuration.dart';
import 'package:wms_app/src/presentation/views/wms_picking/data/wms_picking_repository.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/BatchWithProducts_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/item_picking_request.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/product_template_model.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/submeuelle_model.dart';
import 'package:wms_app/src/utils/formats.dart';
import 'package:wms_app/src/utils/prefs/pref_utils.dart';

part 'batch_event.dart';
part 'batch_state.dart';

class BatchBloc extends Bloc<BatchEvent, BatchState> {
  List<ProductsBatch> listOfProductsBatch = [];
  List<ProductsBatch> filteredProducts = [];
  List<ProductsBatch> listOfProductsBatchDB = [];
  List<Barcodes> listOfBarcodes = [];

  // //*validaciones de campos del estado de la vista
  bool isLocationOk = true;
  bool isProductOk = true;
  bool isLocationDestOk = true;
  bool isQuantityOk = true;

  //variable de apoyo
  bool isSearch = true;

  //*controller para la busqueda
  TextEditingController searchController = TextEditingController();

  //*controller para editarProducto
  TextEditingController editProductController = TextEditingController();

  //*batch con productos
  BatchWithProducts batchWithProducts = BatchWithProducts();

  //*producto en posicion actual
  ProductsBatch currentProduct = ProductsBatch();

  //*variables para validar
  bool locationIsOk = false;
  bool productIsOk = false;
  bool locationDestIsOk = false;
  bool quantityIsOk = false;

  String oldLocation = '';

  DataBaseSqlite db = DataBaseSqlite();
  WmsPickingRepository repository = WmsPickingRepository();

  //*lista de novedades de separacion

  String selectedNovedad = '';

  //configuracion del usuario //permisos
  Configurations configurations = Configurations();

  int quantitySelected = 0;

  //*lista de todas las pocisiones de los productos del batchs
  List<String> positionsOrigen = [];

  //*lista de muelles
  List<String> muelles = [];
  List<String> listOfProductsName = [];
  List<Muelles> submuelles = [];

  Muelles subMuelleSelected = Muelles();

  //*lista de novedades
  List<Novedad> novedades = [];

  bool isPdaZebra = false;
  bool isKeyboardVisible = false;
  bool shouldRunDependencies = true;

  //*indice del producto actual
  int index = 0;

  //* variable de productos del batch completados por el usuario
  // int completedProducts = 0;

  BatchBloc() : super(BatchInitial()) {
    on<LoadConfigurationsUser>(_onLoadConfigurationsUserEvent);

    // //* Buscar un producto en un lote en SQLite
    on<SearchProductsBatchEvent>(_onSearchBacthEvent);
    // //* Limpiar la búsqueda
    on<ClearSearchProudctsBatchEvent>(_onClearSearchEvent);
    // //* Cargar los productos de un batch desde SQLite
    on<FetchBatchWithProductsEvent>(_onFetchBatchWithProductsEvent);

    //*cambiar el estado de las variables
    on<ChangeLocationIsOkEvent>(_onChangeLocationIsOkEvent);
    on<ChangeLocationDestIsOkEvent>(_onChangeLocationDestIsOkEvent);
    on<ChangeProductIsOkEvent>(_onChangeProductIsOkEvent);
    on<ChangeIsOkQuantity>(_onChangeQuantityIsOkEvent);
    //*cambiar el producto actual
    on<ChangeCurrentProduct>(_onChangeCurrentProduct);

    on<SelectNovedadEvent>(_onSelectNovedadEvent);

    on<ValidateFieldsEvent>(_onValidateFields);

    on<LoadDataInfoEvent>(_onLoadDataInfoEvent);

    //*evento para cambiar la cantidad seleccionada
    on<ChangeQuantitySeparate>(_onChangeQuantitySelectedEvent);
    on<AddQuantitySeparate>(_onAddQuantitySeparateEvent);
    //*evento para finalizar la separacion
    on<PickingOkEvent>(_onPickingOkEvent);
    //*evento para dejar pendiente la separacion
    on<ProductPendingEvent>(_onPickingPendingEvent);

    //*evento para actualizar los datos del producto desde odoo
    on<UpdateProductOdooEvent>(_onUpdateProductOdooEvent);
    //*evento para editar un producto
    on<LoadProductEditEvent>(_onEditProductEvent);
    //*evento para enviar un producto a odoo editado
    on<SendProductEditOdooEvent>(_onSendProductEditOdooEvent);

    //*evento para asignar el submuelle
    on<AssignSubmuelleEvent>(_onAssignSubmuelleEvent);

    on<LoadInfoDeviceEvent>(_onLoadInfoDevicesEvent);

    on<ShowKeyboard>(_onShowKeyboardEvent);

    on<IsShouldRunDependencies>(_onIsShouldRunDependenciesEvent);

    on<LoadAllNovedadesEvent>(_onLoadAllNovedadesEvent);
    add(LoadAllNovedadesEvent());

    on<SelectedSubMuelleEvent>(_onSelectecSubMuelle);
  }

  void _onSelectecSubMuelle(
      SelectedSubMuelleEvent event, Emitter<BatchState> emit) {
    try {
      subMuelleSelected = Muelles();
      subMuelleSelected = event.subMuelleSlected;
      emit(SelectSubMuelle(subMuelleSelected));
    } catch (e, s) {
      print("Error bloc selectedSubMuelle $e -> $s");
    }
  }

  void _onLoadAllNovedadesEvent(
      LoadAllNovedadesEvent event, Emitter<BatchState> emit) async {
    try {
      final response = await db.getAllNovedades();
      novedades.clear();
      if (response != null) {
        novedades = response;
        print("novedades: ${novedades.length}");
      }
    } catch (e, s) {
      print("Error en __onLoadAllNovedadesEvent: $e, $s");
    }
    emit(NovedadesLoadedState(listOfNovedades: novedades));
  }

  void _onIsShouldRunDependenciesEvent(
      IsShouldRunDependencies event, Emitter<BatchState> emit) {
    shouldRunDependencies = event.shouldRunDependencies;
    print('shouldRunDependencies: $shouldRunDependencies');
    emit(ShouldRunDependenciesState(
        shouldRunDependencies: shouldRunDependencies));
  }

  void _onShowKeyboardEvent(ShowKeyboard event, Emitter<BatchState> emit) {
    isKeyboardVisible = event.showKeyboard;
    emit(ShowKeyboardState(showKeyboard: isKeyboardVisible));
  }

  void _onLoadInfoDevicesEvent(
      LoadInfoDeviceEvent event, Emitter<BatchState> emit) async {
    emit(BatchInitial());
    try {
      String info = '';

      //cargamos la informacion del dispositivo
      DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
      info = '''
        Modelo: ${androidInfo.model}
        Versión: ${androidInfo.version.release}
        Fabricante: ${androidInfo.manufacturer}
      ''';
      isPdaZebra = androidInfo.manufacturer.contains('Zebra');
      print("info device: $info");
    } catch (e, s) {
      print('Error en GetConfigurations.dart: $e =>$s');
    }
  }

  void _onLoadConfigurationsUserEvent(
      LoadConfigurationsUser event, Emitter<BatchState> emit) async {
    try {
      int userId = await PrefUtils.getUserId();
      final response = await db.getConfiguration(userId);

      if (response != null) {
        emit(ConfigurationLoaded(response));
        configurations = response;
      } else {
        emit(ConfigurationError('Error al cargar configuraciones'));
      }
    } catch (e, s) {
      print('Error en GetConfigurations.dart: $e =>$s');
    }
  }

//*evento para asignar el submuelle
  void _onAssignSubmuelleEvent(
      AssignSubmuelleEvent event, Emitter<BatchState> emit) async {
    for (var i = 0; i < event.productsSeparate.length; i++) {
      //actualizamos el valor de que se le asigno un submuelle
      await db.setFieldTableBatchProducts(
          event.productsSeparate[i].batchId ?? 0,
          event.productsSeparate[i].idProduct ?? 0,
          'is_muelle',
          'true',
          event.productsSeparate[i].idMove ?? 0);

      //actualziamos el muelle del producto
      await db.setFieldTableBatchProducts(
          event.productsSeparate[i].batchId ?? 0,
          event.productsSeparate[i].idProduct ?? 0,
          'muelle_id',
          event.muelle.id ?? 0,
          event.productsSeparate[i].idMove ?? 0);

      //actualizamos el nombre del muelle del producto
      await db.setFieldStringTableBatchProducts(
          event.productsSeparate[i].batchId ?? 0,
          event.productsSeparate[i].idProduct ?? 0,
          'location_dest_id',
          event.muelle.completeName ?? '',
          event.productsSeparate[i].idMove ?? 0);

      //enviamos el producto a odoo

      DateTime dateTimeActuality = DateTime.parse(DateTime.now().toString());
      //traemos un producto de la base de datos  ya anteriormente guardado

      //todo: tiempor por batch
      //tiempo de separacion del producto, lo traemos de la bd
      final starTime = await db.getFieldTableBtach(
          event.productsSeparate[i].batchId ?? 0, 'time_separate_start');
      DateTime dateTimeStart = DateTime.parse(starTime);
      // Calcular la diferencia
      Duration difference = dateTimeActuality.difference(dateTimeStart);
      // Obtener la diferencia en segundos
      double secondsDifference = difference.inMilliseconds / 1000.0;

      final userid = await PrefUtils.getUserId();

      final response = await repository.sendPicking(
          context: event.context,
          idBatch: event.productsSeparate[i].batchId ?? 0,
          timeTotal: secondsDifference,
          cantItemsSeparados: batchWithProducts.batch?.productSeparateQty ?? 0,
          listItem: [
            Item(
              idMove: event.productsSeparate[i].idMove ?? 0,
              productId: event.productsSeparate[i].idProduct ?? 0,
              lote: event.productsSeparate[i].lotId ?? '',
              cantidad: event.productsSeparate[i].quantitySeparate ?? 0,
              novedad: event.productsSeparate[i].observation ?? 'Sin novedad',
              timeLine: event.productsSeparate[i].timeSeparate ?? 0,
              muelle: event.muelle.id ?? 0,
              idOperario: userid,
              fechaTransaccion:
                  event.productsSeparate[i].fechaTransaccion ?? '',
            ),
          ]);

      if (response.result?.code == 200) {
        emit(SubMuelleEditSusses('Submuelle asignado correctamente'));
        add(FetchBatchWithProductsEvent(
            event.productsSeparate[i].batchId ?? 0));
      } else {
        emit(SubMuelleEditFail('Error al asignar el submuelle'));
      }

      //emitimos el estado
    }
  }

  //*evento para enviar un producto a odoo editado
  void _onSendProductEditOdooEvent(
      SendProductEditOdooEvent event, Emitter<BatchState> emit) async {
    emit(LoadingSendProductEdit());
    sendProuctEditOdoo(event.product, event.cantidad, event.context);

    final response = await DataBaseSqlite()
        .getBatchWithProducts(batchWithProducts.batch?.id ?? 0);

    print("response: $response");

    final List<ProductsBatch> products = response!.products!
        .where((product) => product.quantitySeparate != product.quantity)
        .toList();
    batchWithProducts.products = response.products;
    filteredProducts.clear();
    filteredProducts.addAll(products);
    emit(ProductEditOk());
  }

  //*evento para editar un producto
  void _onEditProductEvent(
      LoadProductEditEvent event, Emitter<BatchState> emit) async {
    //filtramos la lista de producto para mostrar solo los productos que estan separados en cantidad incompletas

    final response = await DataBaseSqlite()
        .getBatchWithProducts(batchWithProducts.batch?.id ?? 0);

    final List<ProductsBatch> products = response!.products!
        .where((product) => product.quantitySeparate != product.quantity)
        .toList();
    filteredProducts.clear();
    filteredProducts.addAll(products);
    emit(LoadProductsBatchSuccesStateBD(listOfProductsBatch: filteredProducts));
  }

  //*metodo para actualizar los datos del producto desde odoo
  void _onUpdateProductOdooEvent(
      UpdateProductOdooEvent event, Emitter<BatchState> emit) async {
    final response =
        await repository.getBatchById(true, event.context, event.batchId);

    if (response != null && response.isNotEmpty) {
      //actualizar la informacion del batch
      await db.updateBatch(response[0]);
      //actualizamos el batch
      batchWithProducts.batch == response[0];

      //actualizamos la lista de productos
      List<ProductsBatch> productsToInsert =
          response.expand((batch) => batch.listItems!).toList();
      //actualizamos la lista de productos   en la bd
      await DataBaseSqlite().insertBatchProducts(productsToInsert);
      //actualizamos la lista de productos
      await sortProductsByLocationId();
      add(FetchBatchWithProductsEvent(batchWithProducts.batch?.id ?? 0));
    } else {
      print('No se encontró el batch con ID: ${event.batchId}');
    }
  }

  //*evento para dejar pendiente la separacion
  void _onPickingPendingEvent(
      ProductPendingEvent event, Emitter<BatchState> emit) async {
    try {
      if (filteredProducts.isEmpty) {
        return;
      }
      print("event current product: ${event.product.toMap()}");
      //cambiamos el estado del producto a pendiente
      await db.setFieldTableBatchProducts(
          batchWithProducts.batch?.id ?? 0,
          event.product.idProduct ?? 0,
          'is_pending',
          'true',
          event.product.idMove ?? 0);

      //deseleccionamos el producto actual
      if (event.product.productIsOk == 1) {
        await db.setFieldTableBatchProducts(
            batchWithProducts.batch?.id ?? 0,
            event.product.idProduct ?? 0,
            'product_is_ok',
            'false',
            event.product.idMove ?? 0);
      }

      //ordenamos los productos por ubicacion
      await sortProductsByLocationId();
      add(FetchBatchWithProductsEvent(batchWithProducts.batch?.id ?? 0));
    } catch (e, s) {
      print('Error _onPickingPendingEvent: $e, $s');
    }
  }

  ///* evento para finalizar la separacion
  void _onPickingOkEvent(PickingOkEvent event, Emitter<BatchState> emit) async {
    await db.setFieldTableBatch(event.batchId, 'is_separate', 'true');
    DateTime dateTimeEnd = DateTime.parse(DateTime.now().toString());
    await db.endStopwatchBatch(event.batchId, dateTimeEnd.toString());
    final starTime =
        await db.getFieldTableBtach(event.batchId, 'time_separate_start');
    DateTime dateTimeStart = DateTime.parse(starTime);
    // Calcular la diferencia
    Duration difference = dateTimeEnd.difference(dateTimeStart);
    // Obtener la diferencia en segundos
    double secondsDifference = difference.inMilliseconds / 1000.0;

    await db.totalStopwatchBatch(event.batchId, secondsDifference);

    print("el tiempo total de separacion es: $secondsDifference");
    emit(PickingOkState());
  }

  //*metodo para cambiar la cantidad seleccionada
  void _onChangeQuantitySelectedEvent(
      ChangeQuantitySeparate event, Emitter<BatchState> emit) async {
    if (event.quantity > 0) {
      quantitySelected = event.quantity;
      await db.setFieldTableBatchProducts(batchWithProducts.batch?.id ?? 0,
          event.productId, 'quantity_separate', event.quantity, event.idMove);
    }
    emit(ChangeQuantitySeparateState(quantitySelected));
  }

  //*evento para aumentar la cantidad

  void _onAddQuantitySeparateEvent(
      AddQuantitySeparate event, Emitter<BatchState> emit) async {
    quantitySelected = quantitySelected + event.quantity;
    await db.incremenQtytProductSeparate(batchWithProducts.batch?.id ?? 0,
        event.productId, event.idMove, event.quantity);
    emit(ChangeQuantitySeparateState(quantitySelected));
  }

//* metodo para cargar las variables de la vista dependiendo del estado de los productos y del batch
  void _onLoadDataInfoEvent(LoadDataInfoEvent event, Emitter<BatchState> emit) {
    print("entro al evento de cargar datos");

    //*validamso que el indice no este fuera de rango, si lo esta restamos 1
    currentProduct = filteredProducts[batchWithProducts.batch?.indexList ?? 0];
   

    if (currentProduct.locationId == oldLocation) {
      locationIsOk = true;
    } else {
      locationIsOk = currentProduct.isLocationIsOk == 1 ? true : false;
    }

    print(locationIsOk);

    productIsOk = currentProduct.productIsOk == false
        ? false
        : currentProduct.productIsOk == 1
            ? true
            : false;
    locationDestIsOk = currentProduct.locationDestIsOk == 1 ? true : false;
    quantityIsOk = currentProduct.isQuantityIsOk == 1 ? true : false;
    index = (batchWithProducts.batch?.indexList ?? 0);
    quantitySelected = currentProduct.quantitySeparate ?? 0;

    print("🎽current product: ${currentProduct.toMap()}");
    print("🎽index: $index");
    print("🎽batchWithProducts.batch${batchWithProducts.batch?.toMap()}");
    print("🎽filteredProducts: ${filteredProducts.length}");

    emit(LoadDataInfoState());
  }

  void sendProuctOdoo(BuildContext context) async {
    DateTime dateTimeActuality = DateTime.parse(DateTime.now().toString());
    //traemos un producto de la base de datos  ya anteriormente guardado
    final product = await db.getProductBatch(batchWithProducts.batch?.id ?? 0,
        currentProduct.idProduct ?? 0, currentProduct.idMove ?? 0);

    //todo: tiempor por batch
    //tiempo de separacion del producto, lo traemos de la bd
    final starTime = await db.getFieldTableBtach(
        product?.batchId ?? 0, 'time_separate_start');

    String? startTime; // Suponiendo que `startTime` es de tipo String o null
    double secondsDifference = 0.0;
// Verificación si la fecha de inicio es nula o vacía
    if (startTime == null || startTime.isEmpty) {
      // Si está vacía o es nula, puedes manejar el caso aquí
      print("La fecha de inicio no es válida.");
    } else {
      // Si `startTime` tiene un valor, continúa con el cálculo
      try {
        DateTime dateTimeStart =
            DateTime.parse(startTime); // Parsear el String a DateTime
        // Calcular la diferencia entre la fecha actual y la fecha de inicio
        Duration difference = dateTimeActuality.difference(dateTimeStart);
        // Obtener la diferencia en segundos
        secondsDifference = difference.inMilliseconds / 1000.0;
        print("Diferencia en segundos: $secondsDifference");
      } catch (e) {
        // Si ocurre algún error durante el parseo (por ejemplo, formato incorrecto)
        print("Error al parsear la fecha: $e");
      }
    }

    final userid = await PrefUtils.getUserId();

    //enviamos el producto a odoo
    final response = await repository.sendPicking(
        context: context,
        idBatch: product?.batchId ?? 0,
        timeTotal: secondsDifference,
        cantItemsSeparados: batchWithProducts.batch?.productSeparateQty ?? 0,
        listItem: [
          Item(
              idMove: product?.idMove ?? 0,
              productId: product?.idProduct ?? 0,
              lote: product?.lotId ?? '',
              cantidad: product?.quantitySeparate ?? 0,
              novedad: product?.observation ?? 'Sin novedad',
              timeLine: product?.timeSeparate ?? 0,
              muelle: product?.muelleId ?? 0,
              idOperario: userid,
              fechaTransaccion: product?.fechaTransaccion ?? ''),
        ]);

    if (response.result?.code == 200) {
      //recorremos todos los resultados de la respuesta
      for (var resultProduct in response.result!.result!) {
        await db.setFieldTableBatchProducts(
          resultProduct.idBatch ?? 0,
          resultProduct.idProduct ?? 0,
          'is_send_odoo',
          'true',
          resultProduct.idMove ?? 0,
        );
      }
    } else {
      //elementos que no se pudieron enviar a odoo
      await db.setFieldTableBatchProducts(
        product?.batchId ?? 0,
        product?.idProduct ?? 0,
        'is_send_odoo',
        'false',
        product?.idMove ?? 0,
      );
    }
  }

  Future<bool> sendProuctEditOdoo(
      ProductsBatch productEdit, int cantidad, BuildContext context) async {
    DateTime dateTimeActuality = DateTime.parse(DateTime.now().toString());
    //traemos un producto de la base de datos  ya anteriormente guardado
    final product = await db.getProductBatch(productEdit.batchId ?? 0,
        productEdit.idProduct ?? 0, productEdit.idMove ?? 0);

    //todo: tiempor por batch
    //tiempo de separacion del producto, lo traemos de la bd
    final starTime = await db.getFieldTableBtach(
        productEdit.batchId ?? 0, 'time_separate_start');
    DateTime dateTimeStart = DateTime.parse(starTime);
    // Calcular la diferencia
    Duration difference = dateTimeActuality.difference(dateTimeStart);
    // Obtener la diferencia en segundos
    double secondsDifference = difference.inMilliseconds / 1000.0;
    final userid = await PrefUtils.getUserId();

    //enviamos el producto a odoo
    final response = await repository.sendPicking(
        context: context,
        idBatch: product?.batchId ?? 0,
        timeTotal: secondsDifference,
        cantItemsSeparados: batchWithProducts.batch?.productSeparateQty ?? 0,
        listItem: [
          Item(
              idMove: product?.idMove ?? 0,
              productId: product?.idProduct ?? 0,
              lote: product?.lotId ?? '',
              cantidad: cantidad,
              novedad: (cantidad == product?.quantity)
                  ? 'Sin novedad'
                  : product?.observation ?? 'Sin novedad',
              timeLine: product?.timeSeparate ?? 0,
              muelle: product?.muelleId ?? 0,
              idOperario: userid,
              fechaTransaccion: product?.fechaTransaccion ?? ''),
        ]);

    if (response.result?.code == 200) {
      //recorremos todos los resultados de la respuesta
      for (var resultProduct in response.result!.result!) {
        await db.setFieldTableBatchProducts(
          resultProduct.idBatch ?? 0,
          resultProduct.idProduct ?? 0,
          'is_send_odoo',
          'true',
          resultProduct.idMove ?? 0,
        );
      }
      // filteredProducts = b

      return true;
    } else {
      //elementos que no se pudieron enviar a odoo
      await db.setFieldTableBatchProducts(
        product?.batchId ?? 0,
        product?.idProduct ?? 0,
        'is_send_odoo',
        'false',
        product?.idMove ?? 0,
      );
      return false;
    }
  }

  void _onValidateFields(ValidateFieldsEvent event, Emitter<BatchState> emit) {
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
    }
    print(
        'Location: $isLocationOk, Product: $isProductOk, LocationDest: $isLocationDestOk, Quantity: $isQuantityOk');
    emit(ValidateFieldsState(event.isOk));
  }

  void _onSelectNovedadEvent(
      SelectNovedadEvent event, Emitter<BatchState> emit) {
    selectedNovedad = event.novedad;
    emit(SelectNovedadState(event.novedad));
  }

  void getPosicions() {
    positionsOrigen.clear();
    for (var i = 0; i < filteredProducts.length; i++) {
      if (filteredProducts[i].locationId != false) {
        if (positionsOrigen.contains(filteredProducts[i].locationId ?? '')) {
          continue;
        }
        positionsOrigen.add(filteredProducts[i].locationId ?? '');
      }
    }
  }

  void getMuelles() {
    muelles.clear();
    if (batchWithProducts.batch?.muelle?.isNotEmpty == true) {
      // if (positions.contains(batchWithProducts.batch?.muelle)) {
      muelles.add(batchWithProducts.batch?.muelle ?? '');
      // }
    }
  }

  void getSubmuelles() async {
    print("id del muelle ${batchWithProducts.batch?.idMuelle}");
    submuelles.clear();
    final muellesdb =
        //todo cambiar al id de idMuelle
        await db
            .getSubmuellesByLocationId(batchWithProducts.batch?.idMuelle ?? 0
                // 92265,
                );
    if (muellesdb.isNotEmpty) {
      submuelles.addAll(muellesdb);
    }
  }

  void products() {
    // Limpiamos la lista 'listOfProductsName' para asegurarnos que no haya duplicados de iteraciones anteriores
    listOfProductsName.clear();

    // Recorremos los productos del batch
    for (var i = 0; i < filteredProducts.length; i++) {
      var product = filteredProducts[i];

      // Aseguramos que productId no sea nulo antes de intentar agregarlo
      if (product != null && product.productId != null) {
        var productIdString =
            product.productId.toString(); // Convertimos a String

        // Validamos si el productId ya existe en la lista 'positions'
        if (!listOfProductsName.contains(productIdString)) {
          listOfProductsName.add(
              productIdString); // Agregamos el productId a la lista 'listOfProductsName'
        }
      }
    }
  }

  void _onChangeCurrentProduct(
      ChangeCurrentProduct event, Emitter<BatchState> emit) async {
    print("entro al evento de cambiar producto");
    //desseleccionamos el producto actual
    await db.setFieldTableBatchProducts(
        batchWithProducts.batch?.id ?? 0,
        event.currentProduct.idProduct ?? 0,
        'is_selected',
        'false',
        currentProduct.idMove ?? 0);

    DateTime dateTimeActuality = DateTime.parse(DateTime.now().toString());

    print("current product: ${currentProduct.toMap()}");

    //actualizamos el tiempo total del producto
    await db.endStopwatchProduct(
        batchWithProducts.batch?.id ?? 0,
        dateTimeActuality.toString(),
        currentProduct.idProduct ?? 0,
        currentProduct.idMove ?? 0);

    final starTimeProduct = await db.getFieldTableProducts(
        currentProduct.batchId ?? 0,
        currentProduct.idProduct ?? 0,
        currentProduct.idMove ?? 0,
        "time_separate_start");

    DateTime dateTimeStartProduct =
        starTimeProduct == "null" || starTimeProduct.isEmpty
            ? DateTime.parse(DateTime.now().toString())
            : DateTime.parse(starTimeProduct);
    // Calcular la diferencia
    Duration differenceProduct =
        dateTimeActuality.difference(dateTimeStartProduct);
    // Obtener la diferencia en segundos
    double secondsDifferenceProduct = differenceProduct.inMilliseconds / 1000.0;

    await db.totalStopwatchProduct(
        batchWithProducts.batch?.id ?? 0,
        currentProduct.idProduct ?? 0,
        currentProduct.idMove ?? 0,
        secondsDifferenceProduct);

    sendProuctOdoo(event.context);
    //validamos si es el ultimo producto
    if (filteredProducts.length == index + 1) {
      //actualizamos el index de la lista de productos
      await db.setFieldTableBatch(
          batchWithProducts.batch?.id ?? 0, 'index_list', index);
      //emitimos el estado de productos completados
      emit(CurrentProductChangedState(
          currentProduct: currentProduct, index: index));
      if (currentProduct.locationId == oldLocation) {
        locationIsOk = true;
      } else {
        locationIsOk = false;
      }
      return;
    } else {
      //validamos la ultima ubicacion
      productIsOk = false;
      quantityIsOk = false;
      index++;

      //actualizamos el index de la lista de productos
      await db.setFieldTableBatch(
          batchWithProducts.batch?.id ?? 0, 'index_list', index);
      //actualizamos el producto actual
      //*validamso que el indice no este fuera de rango, si lo esta restamos 1
      // if (batchWithProducts.batch?.indexList == null) {
      //   currentProduct = filteredProducts[index];
      // } else {
      //   if (batchWithProducts.batch!.indexList! > filteredProducts.length - 1) {
      //     currentProduct = filteredProducts[(index) - 1];
      //   } else {
      currentProduct = filteredProducts[index];
      // }
      // }

      if (currentProduct.locationId == oldLocation) {
        print('La ubicacion es igual');
        locationIsOk = true;
      } else {
        locationIsOk = false;
        print('La ubicacion es diferente');
      }

      await db.startStopwatch(
        batchWithProducts.batch?.id ?? 0,
        currentProduct.idProduct ?? 0,
        currentProduct.idMove ?? 0,
        DateTime.now().toString(),
      );

      listOfBarcodes.clear();

      listOfBarcodes = await db.getBarcodesProduct(
        batchWithProducts.batch?.id ?? 0,
        currentProduct.idProduct ?? 0,
        currentProduct.idMove ?? 0,
      );

      emit(CurrentProductChangedState(
          currentProduct: currentProduct, index: index));
      add(FetchBatchWithProductsEvent(batchWithProducts.batch?.id ?? 0));
      return;
    }
  }

  void _onChangeQuantityIsOkEvent(
      ChangeIsOkQuantity event, Emitter<BatchState> emit) async {
    if (event.isOk) {
      await db.setFieldTableBatchProducts(event.batchId, event.productId,
          'is_quantity_is_ok', 'true', event.idMove);
    }
    quantityIsOk = event.isOk;
    emit(ChangeIsOkState(
      quantityIsOk,
    ));
  }

  void _onChangeLocationIsOkEvent(
      ChangeLocationIsOkEvent event, Emitter<BatchState> emit) async {
    if (isLocationOk) {
      await db.setFieldTableBatchProducts(
        event.batchId,
        event.productId,
        'is_location_is_ok',
        'true',
        event.idMove,
      );

      if (index == 0) {
        await db.startStopwatchBatch(event.batchId, DateTime.now().toString());
      }
      //cuando se lea la ubicacion se selecciona el batch
      await db.setFieldTableBatch(event.batchId, 'is_selected', 'true');

      locationIsOk = true;

      emit(ChangeLocationIsOkState(
        locationIsOk,
      ));
    }
  }

  void _onChangeLocationDestIsOkEvent(
      ChangeLocationDestIsOkEvent event, Emitter<BatchState> emit) async {
    if (event.locationDestIsOk) {
      await db.setFieldTableBatchProducts(event.batchId, event.productId,
          'location_dest_is_ok', 'true', event.idMove);
    }
    locationDestIsOk = event.locationDestIsOk;
    emit(ChangeIsOkState(
      locationDestIsOk,
    ));
  }

  void _onChangeProductIsOkEvent(
      ChangeProductIsOkEvent event, Emitter<BatchState> emit) async {
    if (event.productIsOk) {
      //empezamos el tiempo de separacion del batch y del producto
      await db.startStopwatch(
        event.batchId,
        event.productId,
        event.idMove,
        DateTime.now().toString(),
      );

      //calculamos la fecha de transaccion
      DateTime fechaTransaccion = DateTime.now();
      String fechaFormateada = formatoFecha(fechaTransaccion);
      //agregamos la fecha de transaccion
      await db.dateTransaccionProduct(
        event.batchId,
        fechaFormateada,
        event.productId,
        event.idMove,
      );

      await db.setFieldTableBatchProducts(
          event.batchId, event.productId, 'is_selected', 'true', event.idMove);
      await db.setFieldTableBatchProducts(event.batchId, event.productId,
          'product_is_ok', 'true', event.idMove);
      await db.setFieldTableBatchProducts(event.batchId, event.productId,
          'quantity_separate', event.quantity, event.idMove);
    }
    productIsOk = event.productIsOk;
    emit(ChangeProductIsOkState(
      productIsOk,
    ));
  }

  void _onClearSearchEvent(
      ClearSearchProudctsBatchEvent event, Emitter<BatchState> emit) async {
    searchController.clear();
    filteredProducts.clear();
    filteredProducts.addAll(batchWithProducts.products!);
    await sortProductsByLocationId();
    emit(LoadProductsBatchSuccesState(listOfProductsBatch: filteredProducts));
  }

  void _onSearchBacthEvent(
      SearchProductsBatchEvent event, Emitter<BatchState> emit) async {
    final query = event.query.toLowerCase();

    if (query.isEmpty) {
      filteredProducts.clear();
      filteredProducts = batchWithProducts
          .products!; // Si la búsqueda está vacía, mostrar todos los productos
      await sortProductsByLocationId();
    } else {
      filteredProducts = batchWithProducts.products!.where((batch) {
        return batch.productId?.toLowerCase().contains(query) ?? false;
      }).toList();
    }
    emit(LoadProductsBatchSuccesState(
        listOfProductsBatch: filteredProducts)); // Emitir la lista filtrada
  }

  void _onFetchBatchWithProductsEvent(
      FetchBatchWithProductsEvent event, Emitter<BatchState> emit) async {
    batchWithProducts = BatchWithProducts();

    add(LoadConfigurationsUser());

    final response = await DataBaseSqlite().getBatchWithProducts(event.batchId);

    if (response != null) {
      batchWithProducts = response;

      if (batchWithProducts.products!.isEmpty) {
        print('No hay productos en el batch');
        emit(EmptyroductsBatch());
        return;
      }

      filteredProducts.clear();
      filteredProducts.addAll(batchWithProducts.products!);

      await sortProductsByLocationId();

      print('Productos cargados: ${filteredProducts.length}');
      add(LoadDataInfoEvent());
      getSubmuelles();
      getPosicions();
      getMuelles();

      int indexToAccess = batchWithProducts.batch?.indexList ?? index;
      if (indexToAccess >= 0 && indexToAccess < filteredProducts.length) {
        currentProduct = filteredProducts[indexToAccess];
        //agregamos la lista de barcodes al producto actual
        listOfBarcodes.clear();

        listOfBarcodes = await db.getBarcodesProduct(
          batchWithProducts.batch?.id ?? 0,
          currentProduct.idProduct ?? 0,
          currentProduct.idMove ?? 0,
        );
      }
      products();

      emit(LoadProductsBatchSuccesStateBD(
          listOfProductsBatch: filteredProducts));
    } else {
      batchWithProducts = BatchWithProducts();
      print('No se encontró el batch con ID: ${event.batchId}');
    }
  }



//*metodo para ordenar los productos por ubicacion
  Future<List<ProductsBatch>> sortProductsByLocationId() async {
    final products = filteredProducts;
    final batch = batchWithProducts.batch;

    //traemos el batch actualizado
    final batchUpdated = await db.getBatchById(batch?.id ?? 0);

    //ORDENAMOS LOS PRODUCTOS SEGUN EL ORDENAMIENTO QUE DIGA EL BATCH
    switch (batchUpdated?.orderBy) {
      case "removal_priority":
        {
          if (batchUpdated?.orderPicking == "asc") {
            products.sort((a, b) {
              return a.rimovalPriority!.compareTo(b.rimovalPriority!);
            });
          } else {
            products.sort((a, b) {
              return b.rimovalPriority!.compareTo(a.rimovalPriority!);
            });
          }
        }
        break;
      case "location_name":
        {
          if (batchUpdated?.orderPicking == "asc") {
            products.sort((a, b) {
              return a.locationId!.compareTo(b.locationId!);
            });
          } else {
            products.sort((a, b) {
              return b.locationId!.compareTo(a.locationId!);
            });
          }
        }
        break;
      case "product_name":
        {
          if (batchUpdated?.orderPicking == "asc") {
            products.sort((a, b) {
              return a.productId!.compareTo(b.productId!);
            });
          } else {
            products.sort((a, b) {
              return b.productId!.compareTo(a.productId!);
            });
          }
        }
        break;
    }

    // Filtrar los productos con isPending == 1
    List<ProductsBatch> pendingProducts =
        products.where((product) => product.isPending == 1).toList();

    // Filtrar los productos que no están pendientes
    List<ProductsBatch> nonPendingProducts =
        products.where((product) => product.isPending != 1).toList();

    // Concatenar los productos no pendientes con los productos pendientes al final
    filteredProducts.clear();
    filteredProducts.addAll(nonPendingProducts);
    filteredProducts.addAll(pendingProducts);

    return filteredProducts;
  }

  String calculateProgress() {
    final totalItems = batchWithProducts.products?.length ?? 0;
    final separatedItems = batchWithProducts.batch?.productSeparateQty ?? 0;

    // Evitar división por cero
    if (totalItems == 0) return "0.0";

    final progress = (separatedItems / totalItems) * 100;
    return progress.toStringAsFixed(1); // Redondear a un decimal
  }

  String calcularUnidadesSeparadas() {
    // Si no hay productos, devuelve "0.0"
    if (batchWithProducts.products == null ||
        batchWithProducts.products!.isEmpty) {
      return "0.0";
    }

    int totalSeparadas = 0;
    int totalCantidades = 0;

    for (var product in batchWithProducts.products!) {
      totalSeparadas += product.quantitySeparate ?? 0;
      totalCantidades +=
          (product.quantity as int?) ?? 0; // Aseguramos que sea int
    }

    // Evitar división por cero
    if (totalCantidades == 0) {
      return "0.0";
    }

    final progress = (totalSeparadas / totalCantidades) * 100;
    return progress.toStringAsFixed(1);
  }

  String formatSecondsToHHMMSS(double secondsDecimal) {
    // Redondear a los segundos más cercanos
    int totalSeconds = secondsDecimal.round();

    // Calcular horas, minutos y segundos
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;

    // Formatear en 00:00:00
    String formattedTime = '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';

    return formattedTime;
  }
}
