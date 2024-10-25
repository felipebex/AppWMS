// ignore_for_file: unnecessary_type_check, unnecessary_null_comparison, avoid_print

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/wms_packing/data/wms_packing_api_module.dart';
import 'package:wms_app/src/presentation/views/wms_packing/domain/packing_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/BatchWithProducts_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/product_template_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/products_batch_model.dart';

import '../../domain/product_packing_model.dart';

part 'wms_packing_event.dart';
part 'wms_packing_state.dart';

class WmsPackingBloc extends Bloc<WmsPackingEvent, WmsPackingState> {
  //* lista de bacth para packing
  List<Packing> listPacking = [];
  List<ProductPacking> listProductPacking = [];

  //*lista de todas las pocisiones de los productos del batchs
  List<String> positions = [];

  //*controller para la busqueda
  TextEditingController searchController = TextEditingController();

  //*variables para validar
  bool locationIsOk = false;
  bool productIsOk = false;
  bool locationDestIsOk = false;
  bool quantityIsOk = false;
  String oldLocation = '';

    int completedProducts = 0;

  //*numero de paquetes
  int numPackages = 0;

  //Lista de paquetes
  List<String> packages = [];

  int index = 0;

    //*product.product
  Products product = Products();

  //*batch con productos
  BatchWithProducts batchWithProducts = BatchWithProducts();

  WmsPackingBloc() : super(WmsPackingInitial()) {
    //*obtener todos los batchs para packing de odoo
    on<LoadAllPackingEvent>(_onLoadAllPackingEvent);
    //*obtener todos los productos de un packing
    on<LoadProdcutsPackingEvent>(_onLoadProdcutsPackingEvent);

    //*cambiar el estado de las variables
    on<ChangeLocationIsOkEvent>(_onChangeLocationIsOkEvent);
    on<ChangeLocationDestIsOkEvent>(_onChangeLocationDestIsOkEvent);
    on<ChangeProductIsOkEvent>(_onChangeProductIsOkEvent);
    on<ChangeIsOkQuantity>(_onChangeQuantityIsOkEvent);

    //*agregar un producto a nuevo empaque
    on<AddProductPackingEvent>(_onAddProductPackingEvent);

    // //* Cargar los productos de un batch desde SQLite
    on<FetchBatchWithProductsEvent>(_onFetchBatchWithProductsEvent);

    on<GetProductById>(_onGetProductById);
  }

  void getPosicions() {
    positions.clear();
    for (var i = 0; i < listProductPacking.length; i++) {
      if (listProductPacking[i].locationDestId != false) {
        positions.add(listProductPacking[i].locationDestId[1]);
        print('positions: ${positions[i]}');
      }
    }
  }


   void _onGetProductById(GetProductById event, Emitter<WmsPackingState> emit) async {
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

  void _onFetchBatchWithProductsEvent(
      FetchBatchWithProductsEvent event, Emitter<WmsPackingState> emit) async {
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


  void _onAddProductPackingEvent(
      AddProductPackingEvent event, Emitter<WmsPackingState> emit) async {
    try {} catch (e, s) {
      print('Error en el  _onAddProductPackingEvent: $e, $s');
      emit(WmsPackingError(e.toString()));
    }
  }

  void _onLoadAllPackingEvent(
      LoadAllPackingEvent event, Emitter<WmsPackingState> emit) async {
    emit(WmsPackingLoading());
    try {
      final response = await PackingSApiModule.restAllPacking(event.batchId, event.context);
      if (response != null && response is List) {
        print('response packing : ${response.length}');
        listPacking.clear();
        listPacking.addAll(response);
      }
      emit(WmsPackingLoaded(listPacking));
    } catch (e, s) {
      print('Error en el  _onLoadAllPackingEvent: $e, $s');
      emit(WmsPackingError(e.toString()));
    }
  }

  void _onLoadProdcutsPackingEvent(
      LoadProdcutsPackingEvent event, Emitter<WmsPackingState> emit) async {
    emit(WmsPackingLoadingProducts());
    try {
      final response =
          await PackingSApiModule.resProductsPacking(event.packingId, event.context);
      if (response != null && response is List) {
        print('response products packing : ${response.length}');
        listProductPacking.clear();
        listProductPacking.addAll(response);
      }
      emit(WmsPackingLoadedProducts(listProductPacking));
    } catch (e, s) {
      print('Error en el  _onLoadProdcutsPackingEvent: $e, $s');
      emit(WmsPackingError(e.toString()));
    }
  }

  void _onChangeQuantityIsOkEvent(
      ChangeIsOkQuantity event, Emitter<WmsPackingState> emit) {
    quantityIsOk = event.isOk;
    emit(ChangeIsOkState(
      quantityIsOk,
    ));
  }

  void _onChangeLocationIsOkEvent(
      ChangeLocationIsOkEvent event, Emitter<WmsPackingState> emit) {
    locationIsOk = event.locationIsOk;
    emit(ChangeIsOkState(
      locationIsOk,
    ));
  }

  void _onChangeLocationDestIsOkEvent(
      ChangeLocationDestIsOkEvent event, Emitter<WmsPackingState> emit) {
    locationDestIsOk = event.locationDestIsOk;
    emit(ChangeIsOkState(
      locationDestIsOk,
    ));
  }

  void _onChangeProductIsOkEvent(
      ChangeProductIsOkEvent event, Emitter<WmsPackingState> emit) {
    productIsOk = event.productIsOk;
    emit(ChangeIsOkState(
      productIsOk,
    ));
  }
}
