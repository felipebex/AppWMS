import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/devoluciones/models/product_devolucion_model.dart';
import 'package:wms_app/src/presentation/views/inventario/models/response_products_model.dart';
import 'package:wms_app/src/presentation/views/recepcion/models/response_lotes_product_model.dart';

part 'devoluciones_event.dart';
part 'devoluciones_state.dart';

class DevolucionesBloc extends Bloc<DevolucionesEvent, DevolucionesState> {
  //controller
  TextEditingController searchControllerLocation = TextEditingController();
  TextEditingController searchControllerProducts = TextEditingController();
  String scannedValue1 = '';
  String scannedValue2 = '';

  //*lista de productos
  List<Product> productos = [];
  List<Product> productosFilters = [];

  List<ProductDevolucion> productosDevolucion = [];

  Product currentProduct = Product();

  LotesProduct lotesProductCurrent = LotesProduct();

  //*base de datos
  DataBaseSqlite db = DataBaseSqlite();

  dynamic quantitySelected = 0;

  bool viewQuantity = false;
  bool isLoading = false;

  DevolucionesBloc() : super(DevolucionesInitial()) {
    on<DevolucionesEvent>((event, emit) {});

    //*evento para actualizar el valor del scan
    on<UpdateScannedValueEvent>(_onUpdateScannedValueEvent);
    on<ClearScannedValueEvent>(_onClearScannedValueEvent);
    on<GetProductEvent>(_onGetProductEvent);

    on<GetProductsList>(_onGetProductsBD);
    //evento para añadir un producto a la lista de devoluciones
    on<Addproduct>(_onAddProductEvent);
    //evento para eliminar un producto de la lista de devoluciones
    on<RemoveProduct>(_onRemoveProductEvent);
    //evento para pedir la cantidad del producto
    on<SetQuantityEvent>(_onSetQuantityEvent);

    ///evento para pedir el lote del producto
    on<SetLoteEvent>(_onSetLoteEvent);
    //*evento para ver la cantidad
    on<ShowQuantityEvent>(_onShowQuantityEvent);

    on<LoadCurrentProductEvent>(_onLoaadCurrentProductEvent);
    //evento para actualizar el producto
    on<UpdateProductInfoEvent>(_onUpdateProductInfoEvent);
  }

  void _onUpdateProductInfoEvent(
      UpdateProductInfoEvent event, Emitter<DevolucionesState> emit) async {
    try {
      //actualizamso el producto actual en la bd
      await db.devolucionRepository.updateProductoDevolucion(
        ProductDevolucion(
          productId: currentProduct.productId,
          barcode: currentProduct.barcode,
          name: currentProduct.name,
          quantity: quantitySelected,
          code: currentProduct.code,
          category: currentProduct.category,
          lotId: lotesProductCurrent.id ?? 0,
          lotName: lotesProductCurrent.name ?? "",
          otherBarcodes: currentProduct.otherBarcodes,
          productPacking: currentProduct.productPacking,
          tracking: currentProduct.tracking,
          useExpirationDate: currentProduct.useExpirationDate,
          expirationTime: currentProduct.expirationTime,
          weight: currentProduct.weight,
          weightUomName: currentProduct.weightUomName,
          volume: currentProduct.volume,
          volumeUomName: currentProduct.volumeUomName,
          uom: currentProduct.uom,
          locationId: currentProduct.locationId,
          locationName: currentProduct.locationName,
        ),
      );
      //acutalizamos el producto actual en la lista de devoluciones
      final index = productosDevolucion
          .indexWhere((p) => p.productId == currentProduct.productId);
      if (index != -1) {
        productosDevolucion[index] = ProductDevolucion(
          productId: currentProduct.productId,
          barcode: currentProduct.barcode,
          name: currentProduct.name,
          quantity: quantitySelected,
          code: currentProduct.code,
          category: currentProduct.category,
          lotId: lotesProductCurrent.id ?? 0,
          lotName: lotesProductCurrent.name ?? "",
          otherBarcodes: currentProduct.otherBarcodes,
          productPacking: currentProduct.productPacking,
          tracking: currentProduct.tracking,
          useExpirationDate: currentProduct.useExpirationDate,
          expirationTime: currentProduct.expirationTime,
          weight: currentProduct.weight,
          weightUomName: currentProduct.weightUomName,
          volume: currentProduct.volume,
          volumeUomName: currentProduct.volumeUomName,
          uom: currentProduct.uom,
          locationId: currentProduct.locationId,
          locationName: currentProduct.locationName,
        );
      }

      emit(UpdateProductInfoState());
    } catch (e, s) {
      print("❌ Error en _onUpdateProductInfoEvent: $e, $s");
    }
  }

  void _onLoaadCurrentProductEvent(
      LoadCurrentProductEvent event, Emitter<DevolucionesState> emit) {
    try {
      currentProduct = event.product;
      quantitySelected = event.product.quantity ?? 0;
      print('Producto actual cargado: ${currentProduct.toMap()}');
      emit(LoadCurrentProductState(currentProduct));
    } catch (e, s) {
      print("❌ Error en _onLoaadCurrentProductEvent: $e, $s");
    }
  }

  //*evento para ver la cantidad
  void _onShowQuantityEvent(
      ShowQuantityEvent event, Emitter<DevolucionesState> emit) {
    try {
      viewQuantity = !viewQuantity;
      emit(ShowQuantityState(viewQuantity));
    } catch (e, s) {
      print("❌ Error en _onShowQuantityEvent: $e, $s");
    }
  }

  void _onSetQuantityEvent(
      SetQuantityEvent event, Emitter<DevolucionesState> emit) {
    quantitySelected += 1;
    print('Cantidad seleccionada: $quantitySelected');
    emit(SetQuantityState());
  }

  void _onSetLoteEvent(SetLoteEvent event, Emitter<DevolucionesState> emit) {}

  void _onAddProductEvent(
      Addproduct event, Emitter<DevolucionesState> emit) async {
    //verificamos si el producto ya esta en la lista de devoluciones,
    if (productosDevolucion.any((p) => p.barcode == event.product.barcode)) {
      isLoading = false;
      emit(
          AddProductFailure('El producto ya está en la lista de devoluciones'));
    } else {
      isLoading = false;
      //agregamos el producto a la tbl de productos devoluciones
      await db.devolucionRepository.insertProductoDevolucion(event.product);
      productosDevolucion.add(event.product);
      print('Producto añadido: ${event.product.toMap()}');
      emit(AddProductSuccess(event.product));
    }
  }

  void _onRemoveProductEvent(
      RemoveProduct event, Emitter<DevolucionesState> emit) async {
    try {
      await db.devolucionRepository
          .deleteProductoDevolucion(event.product.productId ?? 0);
      productosDevolucion
          .removeWhere((p) => p.productId == event.product.productId);
      //eliminamos el producto de la base de datos
      print('Producto eliminado: ${event.product.toMap()}');
      emit(RemoveProductSuccess());
    } catch (e, s) {
      print("❌ Error en _onRemoveProductEvent: $e, $s");
    }
  }

  void _onGetProductEvent(
      GetProductEvent event, Emitter<DevolucionesState> emit) {
    print('isLoading: $isLoading');
    if (!isLoading) {
      emit(GetProductLoading());
      //buscamos en la lista de productos que tenemos si el barcode coincide
      final product = productos.firstWhere(
        (p) => p.barcode == event.barcode,
        orElse: () => Product(),
      );
      //mostramos el producto encontrado
      if (product.barcode.isNotEmpty) {
        print('Producto encontrado: ${product.toMap()}');
        currentProduct = Product();
        //actualimos el producto actual
        currentProduct = product;
        viewQuantity = false;
        quantitySelected = 0;
        //enviamos el estado de prodcuto encontrado correctamente
        isLoading = true;
        emit(GetProductSuccess(currentProduct));
      } else {
        emit(GetProductFailure('Producto no encontrado'));
      }
    }
  }

  void _onGetProductsBD(
      GetProductsList event, Emitter<DevolucionesState> emit) async {
    try {
      emit(GetProductsLoading());
      final response =
          await db.productoInventarioRepository.getAllUniqueProducts();
      productos.clear();
      productosFilters.clear();
      print('productos: ${response.length}');
      if (response.isNotEmpty) {
        productos = response;
        productosFilters = productos;

        //mandamos a traer los producto que tenemos listo para la devolucion guardados en la base de datos
        productosDevolucion =
            await db.devolucionRepository.getAllProductosDevoluciones();

        print('productosDevolucion: ${productosDevolucion.length}');

        emit(GetProductsSuccess(response));
      } else {
        emit(GetProductsFailure('No se encontraron productos'));
      }
    } catch (e, s) {
      emit(GetProductsFailure('Error al cargar los productos'));
      print('Error en el fetch de productos: $e=>$s');
    }
  }

  void _onUpdateScannedValueEvent(
      UpdateScannedValueEvent event, Emitter<DevolucionesState> emit) {
    print('scannedValue1: $scannedValue1');
    switch (event.scan) {
      case 'product':
        scannedValue1 += event.scannedValue.trim();
        print('scannedValue1: $scannedValue1');
        emit(UpdateScannedValueState(scannedValue1, event.scan));
        break;
      case 'quantity':
        scannedValue2 += event.scannedValue.trim();
        print('scannedValue2: $scannedValue2');
        emit(UpdateScannedValueState(scannedValue2, event.scan));
        break;
      default:
        print('Scan type not recognized: ${event.scan}');
    }
  }

  void _onClearScannedValueEvent(
      ClearScannedValueEvent event, Emitter<DevolucionesState> emit) {
    try {
      switch (event.scan) {
        case 'location':
          scannedValue1 = '';
          isLoading = false;
          emit(ClearScannedValueState());
          break;
        case 'product':
          isLoading = false;
          scannedValue2 = '';
          emit(ClearScannedValueState());
          break;
        default:
          print('Scan type not recognized: ${event.scan}');
      }
    } catch (e, s) {
      print("❌ Error en _onClearScannedValueEvent: $e, $s");
    }
  }
}
