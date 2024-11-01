// ignore_for_file: unnecessary_null_comparison, unnecessary_type_check, avoid_print, prefer_is_empty

import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/BatchWithProducts_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/product_template_model.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

part 'batch_event.dart';
part 'batch_state.dart';

class BatchBloc extends Bloc<BatchEvent, BatchState> {
  List<ProductsBatch> listOfProductsBatch = [];
  List<ProductsBatch> filteredProducts = [];
  List<ProductsBatch> listOfProductsBatchDB = [];

  // //*validaciones de campos del estado de la vista
  bool isLocationOk = true;
  bool isProductOk = true;
  bool isLocationDestOk = true;
  bool isQuantityOk = true;

  //*controller para la busqueda
  TextEditingController searchController = TextEditingController();

  //*batch con productos
  BatchWithProducts batchWithProducts = BatchWithProducts();

  //*producto en posicion actual
  ProductsBatch currentProduct = ProductsBatch();

  //*product.product
  Products product = Products();

  //*variables para validar
  bool locationIsOk = false;
  bool productIsOk = false;
  bool locationDestIsOk = false;
  bool quantityIsOk = false;

  String oldLocation = '';

  DataBaseSqlite db = DataBaseSqlite();

  //*lista de novedades de separacion
  List<String> novedades = [
    'Producto dañado',
    'Producto vencido',
    'Producto en mal estado',
    'Producto no corresponde',
    'Producto no solicitado',
    'Producto no encontrado',
    'Producto no existe',
    'Producto no registrado',
    'Producto sin existencia',
  ];

  String selectedNovedad = '';

  int quantitySelected = 0;

  //*lista de todas las pocisiones de los productos del batchs
  List<String> positions = [];

  //*lista de muelles
  List<String> muelles = [];

  //*indice del producto actual
  int index = 0;

  //* variable de productos del batch completados por el usuario
  int completedProducts = 0;

  BatchBloc() : super(BatchInitial()) {

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
  }

  ///* evento para finalizar la separacion
  void _onPickingOkEvent(PickingOkEvent event, Emitter<BatchState> emit) async {
    await db.isPickingBatch(event.batchId);
    DateTime dateTimeEnd = DateTime.parse(DateTime.now().toString());
    await db.endStopwatchBatch(event.batchId, dateTimeEnd.toString());
    final starTime =
        await db.getFieldTableBtach(event.batchId, 'time_separate_start');
    DateTime dateTimeStart = DateTime.parse(starTime);
    // Calcular la diferencia
    Duration difference = dateTimeEnd.difference(dateTimeStart);
    // Obtener la diferencia en segundos
    double secondsDifference = difference.inMilliseconds / 1000.0;
    print('Diferencia en segundos: $secondsDifference');

    await db.totalStopwatchBatch(event.batchId, secondsDifference);

    //enviamos el pciking a odoo
    emit(PickingOkState());
  }

  //*metodo para cambiar la cantidad seleccionada
  void _onChangeQuantitySelectedEvent(
      ChangeQuantitySeparate event, Emitter<BatchState> emit) async {
    if (event.quantity > 0) {
      quantitySelected = event.quantity;
      await db.updateQtyProductSeparate(
          batchWithProducts.batch?.id ?? 0, event.productId, event.quantity);
    }
    emit(ChangeQuantitySeparateState(quantitySelected));
  }

  //*evento para aumentar la cantidad

  void _onAddQuantitySeparateEvent(
      AddQuantitySeparate event, Emitter<BatchState> emit) async {
    quantitySelected = quantitySelected + event.quantity;

    if (event.quantity > 0) {
      quantitySelected = quantitySelected + event.quantity;
      await db.incremenQtytProductSeparate(
          batchWithProducts.batch?.id ?? 0, event.productId);
    }
    emit(ChangeQuantitySeparateState(quantitySelected));
  }

//* metodo para cargar las variables de la vista dependiendo del estado de los productos y del batch
  void _onLoadDataInfoEvent(LoadDataInfoEvent event, Emitter<BatchState> emit) {
    isLocationOk = true;
    isProductOk = true;
    isLocationDestOk = true;
    isQuantityOk = true;
    index = 0;

    locationIsOk = currentProduct.isLocationIsOk == 1 ? true : false;
    productIsOk = currentProduct.productIsOk == 1 ? true : false;
    locationDestIsOk = currentProduct.locationDestIsOk == 1 ? true : false;
    quantityIsOk = currentProduct.isQuantityIsOk == 1 ? true : false;
    index = batchWithProducts.batch?.indexList ?? 0;
    quantitySelected = currentProduct.quantitySeparate ?? 0;
    completedProducts = batchWithProducts.batch?.productSeparateQty ?? 0;

    print("-------------------------------------");
    print("batchWithProducts : ${batchWithProducts.batch?.toMap()}");
    print("Products : ${batchWithProducts.products?.length}");
    print("currentProduct : ${currentProduct.toMap()}");
    print('index: $index');
    print("-------------------------------------");

    emit(LoadDataInfoState());
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
    emit(ValidateFieldsState(event.isOk));
  }

  void _onSelectNovedadEvent(
      SelectNovedadEvent event, Emitter<BatchState> emit) {
    selectedNovedad = event.novedad;
    emit(SelectNovedadState(event.novedad));
  }

  void getPosicions() {
    positions.clear();
    print('batchWithProducts.products!.length: ${batchWithProducts.products!.length}');
    for (var i = 0; i < batchWithProducts.products!.length; i++) {
      if (batchWithProducts.products![i].locationId != false) {
        positions.add(batchWithProducts.products?[i].locationId[0] ?? '');
        print('positions: ${positions[i]}');
      }
    }
  }

  void getMuelles() {
    muelles.clear();
    if (batchWithProducts.batch?.muelle?.isNotEmpty == true) {
      muelles.add(batchWithProducts.batch?.muelle ?? '');
    }
  }

  void _onChangeCurrentProduct(
      ChangeCurrentProduct event, Emitter<BatchState> emit) async {
    //desseleccionamos el producto actual
    await db.deselectProduct(
        batchWithProducts.batch?.id ?? 0, event.currentProduct.idProduct ?? 0);
    //validamos si es el ultimo producto
    if (batchWithProducts.products?.length == index + 1) {
      //actualizamos el index de la lista de productos
      await db.updateIndexList(batchWithProducts.batch?.id ?? 0, index);
      //emitimos el estado de productos completados
      emit(CurrentProductChangedState(
          currentProduct: currentProduct, index: index));
      return;
    } else {
      //validamos la ultima ubicacion
      productIsOk = false;
      quantityIsOk = false;
      index++;
      if (event.currentProduct.locationId != oldLocation) {
        locationIsOk = false;
      }

      //actualizamos el index de la lista de productos
      await db.updateIndexList(batchWithProducts.batch?.id ?? 0, index);
      //actualizamos el producto actual
      currentProduct = batchWithProducts.products![index];
      //seleccionamos el producto actual
      await db.selectProduct(
          batchWithProducts.batch?.id ?? 0, currentProduct.idProduct ?? 0);
      // Emitir el nuevo estado con el producto actual
      print("currentProduct: ${event.currentProduct.toMap()}");
      await db.updateIsLocationIsOk(
          batchWithProducts.batch?.id ?? 0, currentProduct.idProduct ?? 0);

      emit(CurrentProductChangedState(
          currentProduct: currentProduct, index: index));
      return;
    }
  }

  void _onChangeQuantityIsOkEvent(
      ChangeIsOkQuantity event, Emitter<BatchState> emit) async {
    if (event.isOk) {
      await db.updateIsQuantityIsOk(event.batchId, event.productId);
    }
    quantityIsOk = event.isOk;
    emit(ChangeIsOkState(
      quantityIsOk,
    ));
  }

  void _onChangeLocationIsOkEvent(
      ChangeLocationIsOkEvent event, Emitter<BatchState> emit) async {
    if (event.locationIsOk) {
      await db.updateIsLocationIsOk(event.batchId, event.productId);
      //empezamos el tiempo de separacion del batch y del producto
      await db.startStopwatch(
          event.batchId, event.productId, DateTime.now().toString());
      await db.startStopwatchBatch(event.batchId, DateTime.now().toString());
      //cuando se lea la ubicacion se selecciona el batch y el producto
      await db.selectBatch(event.batchId);
      await db.selectProduct(event.batchId, event.productId);
      locationIsOk = event.locationIsOk;



     print(currentProduct = batchWithProducts.products![index]);
      emit(ChangeIsOkState(
        locationIsOk,
      ));
    }
  }

  void _onChangeLocationDestIsOkEvent(
      ChangeLocationDestIsOkEvent event, Emitter<BatchState> emit) async {
    if (event.locationDestIsOk) {
      await db.updateLocationDestIsOk(event.batchId, event.productId);
    }
    locationDestIsOk = event.locationDestIsOk;
    emit(ChangeIsOkState(
      locationDestIsOk,
    ));
  }

  void _onChangeProductIsOkEvent(
      ChangeProductIsOkEvent event, Emitter<BatchState> emit) async {
    if (event.productIsOk) {
      await db.updateIsProductIsOk(event.batchId, event.productId);
      await db.updateProductQuantitySeparate(
          event.batchId, event.productId, event.quantity);
    }
    productIsOk = event.productIsOk;
    emit(ChangeIsOkState(
      productIsOk,
    ));
  }


  void _onLoadAllProductsBatchsEvent(
      LoadAllProductsBatchsEvent event, Emitter<BatchState> emit) async {
    try {
      emit(ProductsBatchLoadingState());

//       final response = await PickingApiModule.resProductsBatchApi(
//           event.batchId, event.context);

          final response = await db.getBatchWithProducts(event.batchId);

          print('response: $response');
        

//       if (response != null && response is List) {
//         listOfProductsBatch.clear();
//         listOfProductsBatch.addAll(response);

//         // Ordenar la lista de productos por location_id
//         listOfProductsBatch.sort((a, b) {
//           String locationIdA = a.locationId[1];
//           String locationIdB = b.locationId[1];
//           return locationIdA.compareTo(locationIdB);
//         });

//         for (var i = 0; i < listOfProductsBatch.length; i++) {
//           for (var j = i + 1; j < listOfProductsBatch.length; j++) {
//             //compramos cada producto con los demas
//             if (listOfProductsBatch[i].locationId[1] ==
//                     listOfProductsBatch[j].locationId[1] &&
//                 listOfProductsBatch[i].productId?[1] ==
//                     listOfProductsBatch[j].productId?[1]) {
//               //si son iguales sumamos las cantidades
//               listOfProductsBatch[i].quantity +=
//                   listOfProductsBatch[j].quantity;
//               listOfProductsBatch.removeAt(j);
//               j--;
//             }
//           }
//         }

//         print('listOfProductsBatch: ${listOfProductsBatch.length}');

//         List<ProductsBatch> productsToInsert = [];

//         for (var product in listOfProductsBatch) {
//           print("product 🍉: ${product.toMap()}");

//           productsToInsert.add(ProductsBatch(
//             idProduct: product.idProduct,
//             batchId: event.batchId,
//             productId: product.productId?[1],
//             pickingId: product.pickingId[1],
//             lotId: product.lotId,
//             locationId:
//                 product.locationId.isNotEmpty ? product.locationId[1] : null,
//             locationDestId: product.locationDestId.isNotEmpty
//                 ? product.locationDestId[1]
//                 : null,
//             quantity: product.quantity.toInt(),
//           ));
//         }

// // Llamar al método de inserción masiva
//         await DataBaseSqlite().insertBatchProducts(productsToInsert);

//         add(FetchBatchWithProductsEvent(event.batchId));
//         emit(LoadProductsBatchSuccesState(
//             listOfProductsBatch: listOfProductsBatch));
      // } else {
      //   emit(BatchErrorState('Error resProductsBatchApi: response is null'));
      // }
    } catch (e, s) {
      print('Error LoadAllProductsBatchsEvent: $e, $s');
      emit(BatchErrorState(e.toString()));
    }
  }

  void _onClearSearchEvent(
      ClearSearchProudctsBatchEvent event, Emitter<BatchState> emit) {
    searchController.clear();
    filteredProducts.clear();
    print('listOfProductsBatchDB: ${listOfProductsBatchDB.length}');
    filteredProducts.addAll(listOfProductsBatchDB);
    emit(LoadProductsBatchSuccesState(listOfProductsBatch: filteredProducts));
  }

  void _onSearchBacthEvent(
      SearchProductsBatchEvent event, Emitter<BatchState> emit) {
    final query = event.query.toLowerCase();

    if (query.isEmpty) {
      filteredProducts.clear();
      filteredProducts =
          listOfProductsBatchDB; // Si la búsqueda está vacía, mostrar todos los productos
    } else {
      filteredProducts = listOfProductsBatchDB.where((batch) {
        return batch.productId?[1]?.toLowerCase().contains(query) ?? false;
      }).toList();
    }
    emit(LoadProductsBatchSuccesState(
        listOfProductsBatch: filteredProducts)); // Emitir la lista filtrada
  }

  void _onFetchBatchWithProductsEvent(
      FetchBatchWithProductsEvent event, Emitter<BatchState> emit) async {
    batchWithProducts = BatchWithProducts();

    final response = await DataBaseSqlite().getBatchWithProducts(event.batchId);

    if (response != null) {
      batchWithProducts = response;

      if (batchWithProducts.products!.isEmpty) {
        print('No hay productos en el batch');
        emit(EmptyroductsBatch());
        return;
      }


      add(LoadDataInfoEvent());

      sortProductsByLocationId(batchWithProducts.products!);
      getPosicions();
      getMuelles();

      int indexToAccess = batchWithProducts.batch!.indexList ?? index;
      if (indexToAccess >= 0 &&
          indexToAccess < batchWithProducts.products!.length) {
        currentProduct = batchWithProducts.products![indexToAccess];
      }

      emit(LoadProductsBatchSuccesStateBD(
          listOfProductsBatch: batchWithProducts.products!));
    } else {
      batchWithProducts = BatchWithProducts();
      print('No se encontró el batch con ID: ${event.batchId}');
    }
  }

  void sortProductsByLocationId(List<ProductsBatch> products) {
    products.sort((a, b) {
      // Comparamos los locationId
      return a.locationId?[1].compareTo(b.locationId?[1]??"");
    });
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

    print('totalSeparadas: $totalSeparadas');

    // Evitar división por cero
    if (totalCantidades == 0) {
      return "0.0";
    }

    final progress = (totalSeparadas / totalCantidades) * 100;
    return progress.toStringAsFixed(1);
  }

  Future<String> calcularTiempoTotalPicking(int batchId) async {
    final starTime =
        await db.getFieldTableBtach(batchId, 'time_separate_start');
    final endTime = await db.getFieldTableBtach(batchId, 'time_separate_end');

    DateTime dateTimeStart = DateTime.parse(starTime);
    DateTime dateTimeEnd = DateTime.parse(endTime);

    // Calcular la diferencia
    Duration difference = dateTimeEnd.difference(dateTimeStart);

    // Obtener horas, minutos y segundos
    int hours = difference.inHours;
    int minutes = difference.inMinutes.remainder(60);
    int seconds = difference.inSeconds.remainder(60);

    // Formatear como 00:00:00
    String formattedTime = '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';

    print('Diferencia en formato 00:00:00: $formattedTime');

    return formattedTime;
  }
}
