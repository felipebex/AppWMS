// ignore_for_file: unnecessary_null_comparison, unnecessary_type_check, avoid_print

import 'dart:math';

import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/wms_picking/data/wms_picking_api_module.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/BatchWithProducts_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/product_template_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/products_batch_model.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

part 'batch_event.dart';
part 'batch_state.dart';

class BatchBloc extends Bloc<BatchEvent, BatchState> {
  List<ProductsBatch> listOfProductsBatch = [];
  List<ProductsBatch> filteredProducts = [];
  List<ProductsBatch> listOfProductsBatchDB = [];

  //*validaciones de campos
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

  //*lista de novedades de separacion
  List<String> novedades = [
    'Producto dañado',
    'Producto vencido',
    'Producto en mal estado',
    'Producto no corresponde',
    'Producto no solicitado',
    'Producto no encontrado',
    'Producto no existe',
    'Producto no registrado'
        'Producto sin existencia',
  ];

  String selectedNovedad = '';

  //*lista de todas las pocisiones de los productos del batchs
  List<String> positions = [];

  //*indice del producto actual
  int index = 0;

  //* variable de productos del batch completados por el usuario
  int completedProducts = 0;

  BatchBloc() : super(BatchInitial()) {
    //* Cargar todos los productos de un batch desde Odoo
    on<LoadAllProductsBatchsEvent>(_onLoadAllProductsBatchsEvent);

    // //* Buscar un producto en un lote en SQLite
    on<SearchProductsBatchEvent>(_onSearchBacthEvent);
    // //* Limpiar la búsqueda
    on<ClearSearchProudctsBatchEvent>(_onClearSearchEvent);
    // //* Cargar los productos de un batch desde SQLite
    on<FetchBatchWithProductsEvent>(_onFetchBatchWithProductsEvent);
    //*metodo para traer el producto de product.product
    on<GetProductById>(_onGetProductById);

    //*cambiar el estado de las variables
    on<ChangeLocationIsOkEvent>(_onChangeLocationIsOkEvent);
    on<ChangeLocationDestIsOkEvent>(_onChangeLocationDestIsOkEvent);
    on<ChangeProductIsOkEvent>(_onChangeProductIsOkEvent);
    on<ChangeIsOkQuantity>(_onChangeQuantityIsOkEvent);
    //*cambiar el producto actual
    on<ChangeCurrentProduct>(_onChangeCurrentProduct);

    on<SelectNovedadEvent>(_onSelectNovedadEvent);

    on<ValidateFieldsEvent>(_onValidateFields);
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
    print('event.novedad: ${event.novedad}');
    // selectedNovedad = event.novedad;
    emit(SelectNovedadState(event.novedad));
  }

  void getPosicions() {
    positions.clear();
    for (var i = 0; i < batchWithProducts.products!.length; i++) {
      if (batchWithProducts.products![i].locationId != false) {
        positions.add(batchWithProducts.products![i].locationId);
        print('positions: ${positions[i]}');
      }
    }
  }

  void _onChangeCurrentProduct(
      ChangeCurrentProduct event, Emitter<BatchState> emit) {
    // Aumentar el índice solo si está dentro de los límites
    if (batchWithProducts.products != null &&
        index < batchWithProducts.products!.length - 1) {
      if (event.currentProduct.locationId != oldLocation) {
        locationIsOk = false;
      }
      productIsOk = false;
      locationDestIsOk = false;
      quantityIsOk = false;
      index++;
      completedProducts++;
    } else {}

    // Obtener el producto actual basado en el índice
    if (batchWithProducts.products != null &&
        batchWithProducts.products!.isNotEmpty) {
      currentProduct = batchWithProducts.products![index];

      // Emitir el nuevo estado con el producto actual
      emit(CurrentProductChangedState(
          currentProduct: currentProduct, index: index));
    }
  }

  void _onChangeQuantityIsOkEvent(
      ChangeIsOkQuantity event, Emitter<BatchState> emit) {
    quantityIsOk = event.isOk;
    emit(ChangeIsOkState(
      quantityIsOk,
    ));
  }

  void _onChangeLocationIsOkEvent(
      ChangeLocationIsOkEvent event, Emitter<BatchState> emit) {
    locationIsOk = event.locationIsOk;
    emit(ChangeIsOkState(
      locationIsOk,
    ));
  }

  void _onChangeLocationDestIsOkEvent(
      ChangeLocationDestIsOkEvent event, Emitter<BatchState> emit) {
    locationDestIsOk = event.locationDestIsOk;
    emit(ChangeIsOkState(
      locationDestIsOk,
    ));
  }

  void _onChangeProductIsOkEvent(
      ChangeProductIsOkEvent event, Emitter<BatchState> emit) {
    productIsOk = event.productIsOk;
    emit(ChangeIsOkState(
      productIsOk,
    ));
  }

  void _onGetProductById(GetProductById event, Emitter<BatchState> emit) async {
    try {
      final response = await DataBaseSqlite().getProductById(event.productId);
      if (response != null) {
        product = response;
      } else {
        print('Error GetProductById: response is null');
      }
    } catch (e, s) {
      print('Error GetProductById: $e, $s');
      emit(BatchErrorState(e.toString()));
    }
  }

  void _onLoadAllProductsBatchsEvent(
      LoadAllProductsBatchsEvent event, Emitter<BatchState> emit) async {
    try {
      emit(ProductsBatchLoadingState());
      final response =
          await PickingApiModule.resProductsBatchApi(event.batchId);
      if (response != null && response is List) {
        listOfProductsBatch.clear();
        listOfProductsBatch.addAll(response);

        // Ordenar la lista de productos por location_id
        listOfProductsBatch.sort((a, b) {
          String locationIdA = a.locationId[1];
          String locationIdB = b.locationId[1];
          return locationIdA.compareTo(locationIdB);
        });

        for (var i = 0; i < listOfProductsBatch.length; i++) {
          for (var j = i + 1; j < listOfProductsBatch.length; j++) {
            //compramos cada producto con los demas
            if (listOfProductsBatch[i].locationId[1] ==
                    listOfProductsBatch[j].locationId[1] &&
                listOfProductsBatch[i].productId?[1] ==
                    listOfProductsBatch[j].productId?[1]) {
              //si son iguales sumamos las cantidades
              listOfProductsBatch[i].quantity +=
                  listOfProductsBatch[j].quantity;
              listOfProductsBatch.removeAt(j);
              j--;
            }
          }
        }

        print('listOfProductsBatch: ${listOfProductsBatch.length}');

        List<ProductsBatch> productsToInsert = [];

        for (var product in listOfProductsBatch) {
          print("product 🍉: ${product.toMap()}");

          productsToInsert.add(ProductsBatch(
            idProduct: product.idProduct,
            batchId: event.batchId,
            productId: product.productId?[1],
            pickingId: product.pickingId[1],
            lotId: product.lotId,
            locationId:
                product.locationId.isNotEmpty ? product.locationId[1] : null,
            locationDestId: product.locationDestId.isNotEmpty
                ? product.locationDestId[1]
                : null,
            quantity: product.quantity.toInt(),
          ));
        }

// Llamar al método de inserción masiva
        await DataBaseSqlite().insertBatchProducts(productsToInsert);

        add(FetchBatchWithProductsEvent(event.batchId));
        emit(LoadProductsBatchSuccesState(
            listOfProductsBatch: listOfProductsBatch));
      } else {
        emit(BatchErrorState('Error resProductsBatchApi: response is null'));
      }
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
        return batch.productId?.toLowerCase().contains(query) ?? false;
      }).toList();
    }
    emit(LoadProductsBatchSuccesState(
        listOfProductsBatch: filteredProducts)); // Emitir la lista filtrada
  }

  void _onFetchBatchWithProductsEvent(
      FetchBatchWithProductsEvent event, Emitter<BatchState> emit) async {
    batchWithProducts = BatchWithProducts();

    print('FetchBatchWithProductsEvent: ${event.batchId}');

    final response = await DataBaseSqlite().getBatchWithProducts(event.batchId);
    print('BatchWithProducts: ${response?.products?.length}');

    if (response != null) {
      batchWithProducts = response;

      if (batchWithProducts.products!.isEmpty) {
        print('No hay productos en el batch');
        emit(EmptyroductsBatch());
        return;
      }

      sortProductsByLocationId(batchWithProducts.products!);
      getPosicions();
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
      return a.locationId.compareTo(b.locationId);
    });
  }
}
