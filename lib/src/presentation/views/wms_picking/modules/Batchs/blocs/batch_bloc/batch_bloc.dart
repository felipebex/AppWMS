// ignore_for_file: unnecessary_null_comparison, unnecessary_type_check, avoid_print

import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/wms_picking/data/wms_picking_api_module.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/BatchWithProducts_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/products_batch_model.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

part 'batch_event.dart';
part 'batch_state.dart';

class BatchBloc extends Bloc<BatchEvent, BatchState> {
  List<ProductsBatch> listOfProductsBatch = [];
  List<ProductsBatch> filteredProducts = [];

  List<ProductsBatch> listOfProductsBatchDB = [];

  //*controller para la busqueda
  TextEditingController searchController = TextEditingController();

  //*batch con productos
  BatchWithProducts batchWithProducts = BatchWithProducts();

  //*producto en posicion actual
  ProductsBatch currentProduct = ProductsBatch();

  BatchBloc() : super(BatchInitial()) {
    //* Cargar todos los productos de un lote desde Odoo
    on<LoadAllProductsBatchsEvent>(_onLoadAllProductsBatchsEvent);
    //* Cargar todos los productos de un lote desde SQLite
    on<LoadProductsBatchFromDBEvent>(_onLoadProductsBatchFromDBEvent);

    //todo estos no se estan usando
    // //* Buscar un producto en un lote en SQLite
    on<SearchProductsBatchEvent>(_onSearchBacthEvent);
    // //* Limpiar la búsqueda
    on<ClearSearchProudctsBatchEvent>(_onClearSearchEvent);

//* pasar al siguiente producto
    on<NextProductEvent>(_onNextProductEvent);

    on<FetchBatchWithProductsEvent>(_onFetchBatchWithProductsEvent);
  }

  void _onNextProductEvent(NextProductEvent event, Emitter<BatchState> emit) {
    if (batchWithProducts.products!.isNotEmpty) {
      int currentIndex = batchWithProducts.products!
          .indexWhere((product) => product.isSelected);

      // Desmarcar el producto actual
      if (currentIndex >= 0) {
        batchWithProducts.products![currentIndex].isSelected = false;

        // Avanzar al siguiente, si existe
        if (currentIndex < batchWithProducts.products!.length - 1) {
          batchWithProducts.products![currentIndex + 1].isSelected = true;
        } else {
          // Si estamos en el último, puedes volver al primero o manejar como desees
          batchWithProducts.products![0].isSelected = true;
        }
      } else {
        // Si no hay seleccionado, selecciona el primero
        batchWithProducts.products![0].isSelected = true;
      }
      emit(LoadProductsBatchSuccesState(
          listOfProductsBatch: batchWithProducts.products!));
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
        // Guardamos los productos en la base de datos
        for (var product in listOfProductsBatch) {
          //dejamos el isSelected en true al primer producto
          if (listOfProductsBatch.indexOf(product) == 0) {
            print("posicion 0 ");
            await DataBaseSqlite().insertBatchProduct(
              batchId: event.batchId,
              productId: product.productId?[1],
              pickingId: product.pickingId[1],
              lotId: product.lotId,
              locationId: product.locationId[1],
              locationDestId: product.locationDestId[1],
              quantity: product.quantity.toInt(),
              isSelected: 'true',
            );
          } else {
            await DataBaseSqlite().insertBatchProduct(
              batchId: event.batchId,
              productId: product.productId?[1],
              pickingId: product.pickingId[1],
              lotId: product.lotId,
              locationId: product.locationId[1],
              locationDestId: product.locationDestId[1],
              quantity: product.quantity.toInt(),
              isSelected: 'false',
            );
          }
        }

        add(LoadProductsBatchFromDBEvent(batchId: event.batchId));
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

  void _onLoadProductsBatchFromDBEvent(
      LoadProductsBatchFromDBEvent event, Emitter<BatchState> emit) async {
    try {
      emit(ProductsBatchLoadingState());

      // Obtener la lista de productos desde la base de datos
      final productsFromDB =
          await DataBaseSqlite().getBatchProducts(event.batchId);

      // // Aquí marcamos el primer producto como seleccionado
      // for (int i = 0; i < productsFromDB.length; i++) {
      //   if (i == 0) {
      //     print("------------------------");
      //     print("primer producto seleccionado");
      //     print("event.batchId: ${event.batchId}");
      //     print("------------------------");
      //     productsFromDB[0].isSelected = true;
      //     await DataBaseSqlite().updateBatchProduct(
      //       batchId: event.batchId,
      //       productId: productsFromDB[0].productId,
      //       isSelected: true,
      //     );
      //   }
      // }

      print('productsFromDB: ${productsFromDB[0].toMap()}');

      // filteredProducts.addAll(productsFromDB);
      // listOfProductsBatchDB.addAll(productsFromDB);
      add(FetchBatchWithProductsEvent(event.batchId));

      emit(LoadProductsBatchSuccesState(listOfProductsBatch: productsFromDB));
    } catch (e, s) {
      print('Error loading products from DB: $e, ==>$s');
      emit(BatchErrorState(e.toString()));
    }
  }

  // //todo no se estan usando
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
    final response = await DataBaseSqlite().getBatchWithProducts(event.batchId);

    if (batchWithProducts != null) {
      batchWithProducts = response!;
      print('Batch: ${batchWithProducts.batch?.name}');
      print('Productos: ${batchWithProducts.products?.length}');

      // Buscar el producto seleccionado
      // currentProduct = batchWithProducts.products!.firstWhere(
      //     (product) => product.isSelected,
      //     orElse: () => ProductsBatch());

      currentProduct = batchWithProducts.products!.firstWhere(
        (product) => product.isSelectedBool, // Usa el método para la validación
        orElse: () => ProductsBatch(productId: '', isSelected: "false"),
      );

      print("batchWithProducts: ${batchWithProducts.products!.length}");
      print("batchWithProducts: ${batchWithProducts.products?[0].toMap()}");

      print('currentProduct: ${currentProduct.productId}');

      emit(LoadProductsBatchSuccesStateBD(
          listOfProductsBatch: batchWithProducts.products!));
    } else {
      batchWithProducts = BatchWithProducts();
      print('No se encontró el batch con ID: ${event.batchId}');
    }
  }
}
