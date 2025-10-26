// ignore_for_file: unrelated_type_equality_checks

import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wms_app/src/core/utils/formats_utils.dart';
import 'package:wms_app/src/core/utils/prefs/pref_utils.dart';
import 'package:wms_app/src/presentation/models/novedades_response_model.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/recepcion/models/response_image_send_novedad_model.dart';
import 'package:wms_app/src/presentation/views/recepcion/models/response_temp_ia_model.dart';
import 'package:wms_app/src/presentation/views/user/models/configuration.dart';
import 'package:wms_app/src/presentation/views/wms_packing/data/wms_packing_repository.dart';
import 'package:wms_app/src/presentation/views/wms_packing/models/lista_product_packing.dart';
import 'package:wms_app/src/presentation/views/wms_packing/models/packing_response_model.dart';
import 'package:wms_app/src/presentation/views/wms_packing/models/sen_packing_request.dart';
import 'package:wms_app/src/presentation/views/wms_packing/models/un_packing_request.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/BatchWithProducts_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';

part 'packing_consolidade_event.dart';
part 'packing_consolidade_state.dart';

class PackingConsolidateBloc
    extends Bloc<PackingConsolidateEvent, PackingConsolidateState> {
  //valores de scan
  String scannedValue1 = '';
  String scannedValue2 = '';
  String scannedValue3 = '';
  String scannedValue4 = '';
  String scannedValue5 = '';

  //*controller para la busqueda
  TextEditingController searchController = TextEditingController();
  TextEditingController searchControllerPedido = TextEditingController();
  TextEditingController searchControllerProduct = TextEditingController();
  TextEditingController controllerTemperature = TextEditingController();
  TextEditingController temperatureController = TextEditingController();

  //*repositorio
  WmsPackingRepository wmsPackingRepository = WmsPackingRepository();

//*base de datos
  DataBaseSqlite db = DataBaseSqlite();

  //*batch con productos
  BatchWithProducts batchWithProducts = BatchWithProducts();

  //*configuracion del usuario //permisos
  Configurations configurations = Configurations();

  //*lista de novedades
  List<Novedad> novedades = [];

  //*lista de batchs para packing
  List<BatchPackingModel> listOfBatchs = [];
  List<BatchPackingModel> listOfBatchsDB = [];

  //*listad de pedido de un batch
  List<PedidoPacking> listOfPedidos = [];
  List<PedidoPacking> listOfPedidosFilters = [];

  //*lista de productos de un pedido
  List<ProductoPedido> listOfProductos = []; //lista de productos de un pedido
  List<ProductoPedido> listOfProductosProgress =
      []; //lista de productos sin certificar
  List<ProductoPedido> productsDone = []; //lista de productos ya certificados
  List<ProductoPedido> productsDonePacking =
      []; //lista de productos ya certificados
  List<ProductoPedido> listOfProductsForPacking =
      []; //lista de productos sin certificar seleccionados para empacar
  //*lista de todas las pocisiones de los productos del batchs
  List<String> positions = [];

  //*lista de todos los productos a empacar
  List<ProductoPedido> productsPacking = [];
  //*lista de productos de un pedido
  List<ProductoPedido> listOfProductsName = [];

  //*lista de paquetes
  List<Paquete> packages = [];

  //*lista de barcodes
  List<Barcodes> listOfBarcodes = [];
  List<Barcodes> listAllOfBarcodes = [];

  //*isSticker
  bool isSticker = false;
  // //*validaciones de campos del estado de la vista
  bool isLocationOk = true;
  bool isProductOk = true;
  bool isLocationDestOk = true;
  bool isQuantityOk = true;
  //*variables para validar
  bool locationIsOk = false;
  bool productIsOk = false;
  bool locationDestIsOk = false;
  bool quantityIsOk = false;
  bool isKeyboardVisible = false;
  bool isSearch = false;
  bool viewQuantity = false;
  bool viewDetail = true;

  int completedProducts = 0;
  double quantitySelected = 0;

  //* ultima ubicacion
  String oldLocation = '';

  //*producto actual
  ProductoPedido currentProduct = ProductoPedido();

  TemperatureIa resultTemperature = TemperatureIa();

  List<Origin> listOfOrigins = [];

  PackingConsolidateBloc() : super(PackingConsolidateInitial()) {
    on<PackingConsolidateEvent>((event, emit) {});

    //obtener las configuraciones y permisos del usuario desde la bd
    on<LoadConfigurationsUserPackConsolidate>(_onLoadConfigurationsUserEvent);

    //*obtener todos los batchs para packing de odoo
    on<LoadAllPackingConsolidateEvent>(_onLoadAllPackingEvent);

    //*buscar un batch
    on<SearchBatchPackingEvent>(_onSearchBacthEvent);
    //*buscar un pedido
    on<SearchPedidoPackingEvent>(_onSearchPedidoEvent);
    //evento para mostrar el teclado
    on<ShowKeyboardEvent>(_onShowKeyboardEvent);

    //*evento para actualizar el valor del scan
    on<UpdateScannedValuePackEvent>(_onUpdateScannedValueEvent);
    on<ClearScannedValuePackEvent>(_onClearScannedValueEvent);

    //*obtener todos los batchs para packing de la base de datos
    on<LoadBatchPackingFromDBEvent>(_onLoadBatchsFromDBEvent);

    //* empezar el tiempo de separacion
    on<StartTimePack>(_onStartTimePickEvent);

    //*obtener todos los pedidos de un batch
    on<LoadAllPedidosFromBatchEvent>(_onLoadAllPedidosFromBatchEvent);

    on<LoadDocOriginsEvent>(_onLoadDocOriginsEvent);

    on<ShowDetailvent>(_onShowDetailEvent);

    //*obtener todos los productos de un pedido
    on<LoadAllProductsFromPedidoEvent>(_onLoadAllProductsFromPedidoEvent);

    //*cargamos el producto a certificar
    on<FetchProductEvent>(_onFetchProductEvent);

    //*confirmar el sticker
    on<ChangeStickerEvent>(_onChangeStickerEvent);

    //*evento para seleccionar productos sin certificar
    on<SelectProductPackingEvent>(_onSelectProductPackingEvent);
    //*evento para desseleccionar productos sin certificar
    on<UnSelectProductPackingEvent>(_onUnSelectProductPackingEvent);

    //evento para eliminar un producto del paquete temporal
    on<DeleteProductFromTemporaryPackageEvent>(
        _onDeleteProductFromTemporaryPackageEvent);

    //*Picking
    on<SetPickingsEvent>(_onSetPickingsEvent);

    //*packing
    on<SetPackingsEvent>(_onSetPackingsEvent);

    //*evento para validar los campos de la vista
    on<ValidateFieldsPackingEvent>(_onValidateFieldsPacking);

    //*evento para cambiar la cantidad seleccionada
    on<ChangeQuantitySeparate>(_onChangeQuantitySelectedEvent);

    //*cambiar el estado de las variables
    on<ChangeLocationIsOkEvent>(_onChangeLocationIsOkEvent);
    on<ChangeLocationDestIsOkEvent>(_onChangeLocationDestIsOkEvent);
    on<ChangeProductIsOkEvent>(_onChangeProductIsOkEvent);

    on<SendImageNovedad>(_onSendImageNovedad);

    //*evento para ver la cantidad
    on<ShowQuantityPackEvent>(_onShowQuantityEvent);

    //*metodo para dividir el producto en varios paquetes
    on<SetPickingSplitEvent>(_onSetPickingsSplitEvent);

    //enviar temperatura
    on<GetTemperatureEvent>(_onGetTemperatureEvent);
    on<SendTemperatureEvent>(_onSendTemperatureEvent);
    on<SendTemperaturePackingEvent>(_onSendTemperaturePackingEvent);

    //*metodo para desempacar productos
    on<UnPackingEvent>(_onUnPackingEvent);

    //*cantidad
    on<ChangeIsOkQuantity>(_onChangeQuantityIsOkEvent);
    on<AddQuantitySeparate>(_onAddQuantitySeparateEvent);

    //*evento para obtener las novedades
    on<LoadAllNovedadesPackingConsolidateEvent>(_onLoadAllNovedadesEvent);
    add(LoadAllNovedadesPackingConsolidateEvent());
  }


  //*meotod para cargar todas las novedades
  void _onLoadAllNovedadesEvent(
      LoadAllNovedadesPackingConsolidateEvent event, Emitter<PackingConsolidateState> emit) async {
    try {
      emit(NovedadesPackingLoadingState());
      final response = await db.novedadesRepository.getAllNovedades();
      if (response != null) {
        novedades.clear();
        novedades = response;
        print("novedades: ${novedades.length}");
        emit(NovedadesPackingLoadedState(listOfNovedades: novedades));
      }
    } catch (e, s) {
      print("Error en __onLoadAllNovedadesEvent: $e, $s");
      emit(NovedadesPackingErrorState(e.toString()));
    }
  }

  void _onAddQuantitySeparateEvent(
      AddQuantitySeparate event, Emitter<PackingConsolidateState> emit) async {
    quantitySelected = quantitySelected + event.quantity;
    await db.productosPedidosRepository.incremenQtytProductSeparatePacking(
        event.pedidoId,
        event.productId,
        event.idMove,
        event.quantity,
        'packing-batch');
    emit(ChangeQuantitySeparateState(quantitySelected));
  }

  void _onChangeQuantityIsOkEvent(
      ChangeIsOkQuantity event, Emitter<PackingConsolidateState> emit) async {
    if (event.isOk) {
      //actualizamos la cantidad del producto a true
      await db.productosPedidosRepository.setFieldTableProductosPedidos(
          event.pedidoId,
          event.productId,
          "is_quantity_is_ok",
          1,
          event.idMove,
          'packing-batch');
    }
    quantityIsOk = event.isOk;
    emit(ChangeIsOkState(
      quantityIsOk,
    ));
  }

  void _onChangeLocationDestIsOkEvent(ChangeLocationDestIsOkEvent event,
      Emitter<PackingConsolidateState> emit) {
    locationDestIsOk = event.locationDestIsOk;
    emit(ChangeIsOkState(
      locationDestIsOk,
    ));
  }

  //metodo para desempacar productos
  void _onUnPackingEvent(
      UnPackingEvent event, Emitter<PackingConsolidateState> emit) async {
    try {
      emit(UnPackingLoading());

      final responseUnPacking = await wmsPackingRepository.unPackingConsolidate(
        event.request,
      );

      if (responseUnPacking.result?.code == 200) {
        //si es exitoso procedemos a desemapcar los productos
        //recorremos todo los productos del request
        for (var product in event.request.listItem) {
          //actualizamos el estado del producto como no separado
          await db.productosPedidosRepository
              .setFieldTableProductosPedidosUnPacking(
                  event.pedidoId,
                  product.productId,
                  "is_separate",
                  null,
                  product.idMove,
                  event.request.idPaquete,
                  'packing-batch-consolidate');
          //actualizamso el estado del producto como no empaquetado
          await db.productosPedidosRepository
              .setFieldTableProductosPedidosUnPacking(
                  event.pedidoId,
                  product.productId,
                  "is_package",
                  null,
                  product.idMove,
                  event.request.idPaquete,
                  'packing-batch-consolidate');

          //actualizamos el estado del producto como no dividido
          await db.productosPedidosRepository
              .setFieldTableProductosPedidosUnPacking(
                  event.pedidoId,
                  product.productId,
                  "is_product_split",
                  null,
                  product.idMove,
                  event.request.idPaquete,
                  'packing-batch');
          //actualizamos el estado del producto como no certificado
          await db.productosPedidosRepository
              .setFieldTableProductosPedidosUnPacking(
                  event.pedidoId,
                  product.productId,
                  "is_certificate",
                  null,
                  product.idMove,
                  event.request.idPaquete,
                  'packing-batch-consolidate');

          //actualizamos el valor de is_location
          await db.productosPedidosRepository
              .setFieldTableProductosPedidosUnPacking(
                  event.pedidoId,
                  product.productId,
                  "is_location_is_ok",
                  null,
                  product.idMove,
                  event.request.idPaquete,
                  'packing-batch-consolidate');

          //actualizamos el valor de quantity_separate
          await db.productosPedidosRepository
              .setFieldTableProductosPedidosUnPacking(
                  event.pedidoId,
                  product.productId,
                  "quantity_separate",
                  null,
                  product.idMove,
                  event.request.idPaquete,
                  'packing-batch-consolidate');

          //actualizamos el valor de is_selected
          await db.productosPedidosRepository
              .setFieldTableProductosPedidosUnPacking(
                  event.pedidoId,
                  product.productId,
                  "is_selected",
                  null,
                  product.idMove,
                  event.request.idPaquete,
                  'packing-batch-consolidate');

          //actualizamos el valor de product_is_ok
          await db.productosPedidosRepository
              .setFieldTableProductosPedidosUnPacking(
                  event.pedidoId,
                  product.productId,
                  "product_is_ok",
                  null,
                  product.idMove,
                  event.request.idPaquete,
                  'packing-batch-consolidate');

          //actualzamos el valor de is_quantity_is_ok
          await db.productosPedidosRepository
              .setFieldTableProductosPedidosUnPacking(
                  event.pedidoId,
                  product.productId,
                  "is_quantity_is_ok",
                  null,
                  product.idMove,
                  event.request.idPaquete,
                  'packing-batch-consolidate');

          //actualizamos el valor de package_name
          await db.productosPedidosRepository
              .setFieldTableProductosPedidosUnPacking(
                  event.pedidoId,
                  product.productId,
                  "package_name",
                  null,
                  product.idMove,
                  event.request.idPaquete,
                  'packing-batch-consolidate');

          //acrtualizamos el valor del id_paquete en el producto
          await db.productosPedidosRepository
              .setFieldTableProductosPedidosUnPacking(
                  event.pedidoId,
                  product.productId,
                  "id_package",
                  null,
                  product.idMove,
                  event.request.idPaquete,
                  'packing-batch-consolidate');
        }

        //restamos la cantidad de productos desempacados a un paquete
        await db.packagesRepository.updatePackageCantidad(
          event.request.idPaquete,
          event.request.listItem.length,
        );

        //VERIFICAMOS CUANTOS PRODUCTOS TIENE EL PAQUETE
        final response =
            await db.packagesRepository.getPackageById(event.request.idPaquete);
        if (response != null) {
          if (response.cantidadProductos == 0) {
            await updateConsecutivePackages(
              consecutivoReferencia: response.consecutivo ?? '',
              packages: packages,
            );

            //si la cantidad de productos es 0 eliminamos el paquete
            await db.packagesRepository
                .deletePackageById(event.request.idPaquete);
          }
        }

        //actualizamos la lista de productos
        add(LoadAllProductsFromPedidoEvent(
          event.pedidoId,
        ));
        emit(UnPackignSuccess("Desempaquetado del producto exitoso"));
      } else {
        emit(UnPackignError('Error al desempacar los productos'));
      }
    } catch (e, s) {
      print('Error en el  _onUnPackingEvent: $e, $s');
      emit(UnPackignError(e.toString()));
    }
  }

  Future<void> updateConsecutivePackages({
    required String consecutivoReferencia,
    required List<Paquete> packages,
  }) async {
    final refNum = _extraerNumeroConsecutivo(consecutivoReferencia);
    if (refNum == null) return;

    for (final paquete in packages) {
      final paqueteNum =
          _extraerNumeroConsecutivo(paquete.consecutivo?.toString());

      if (paqueteNum != null && paqueteNum > refNum) {
        final nuevoConsecutivo = 'Caja${paqueteNum - 1}';
        final paqueteActualizado = Paquete(
          id: paquete.id,
          name: paquete.name,
          batchId: paquete.batchId,
          pedidoId: paquete.pedidoId,
          cantidadProductos: paquete.cantidadProductos,
          listaProductosInPacking: paquete.listaProductosInPacking,
          isSticker: paquete.isSticker,
          isCertificate: paquete.isCertificate,
          type: paquete.type,
          consecutivo: nuevoConsecutivo,
        );

        await db.packagesRepository.updatePackageById(paqueteActualizado);
      }
    }
  }

  int? _extraerNumeroConsecutivo(String? consecutivo) {
    if (consecutivo == null) return null;
    final match = RegExp(r'(\d+)$').firstMatch(consecutivo);
    return match != null ? int.parse(match.group(1)!) : null;
  }

  void _onSendTemperaturePackingEvent(
    SendTemperaturePackingEvent event,
    Emitter<PackingConsolidateState> emit,
  ) async {
    try {
      emit(SendTemperatureLoading());

      //validamso que tengamos imagen y temperatura

      print('currentProduct: ${currentProduct.toMap()}');

      //enviamos la temperatura con la imagen
      final response = await wmsPackingRepository.sendTemperatureManual(
        temperatureController.text ?? 0.0,
        event.moveLineId,
        true,
      );

      //esperamos la repuesta y emitimos el estadp
      if (response.code == 200) {
        //actualizamos la temepratura por producto en la bd y la imagen

        await db.productosPedidosRepository.setFieldTableProductosPedidos2(
          currentProduct.pedidoId ?? 0,
          currentProduct.idProduct ?? 0,
          'temperatura',
          temperatureController.text ?? 0.0,
          event.moveLineId,
          'packing-batch-consolidate',
        );

        //limpiamos el dato de temperatura
        temperatureController.clear();
        resultTemperature = TemperatureIa();

        add(LoadAllProductsFromPedidoEvent(currentProduct.pedidoId ?? 0));

        emit(SendTemperatureSuccess(
            response.result ?? 'Temperatura enviada correctamente'));
      } else {
        emit(SendTemperatureFailure(
            response.msg ?? 'Error al enviar la temperatura'));
        return;
      }
    } catch (e, s) {
      print('Error en el _onSendTemperatureEvent: $e, $s');
      emit(SendTemperatureFailure(
          'Ocurrió un error al procesar la imagen y obtener la temperatura'));
    }
  }

  void _onSendTemperatureEvent(
    SendTemperatureEvent event,
    Emitter<PackingConsolidateState> emit,
  ) async {
    try {
      emit(SendTemperatureLoading());

      //validamso que tengamos imagen y temperatura

      if (event.file.path == null || event.file.path.isEmpty) {
        emit(SendTemperatureFailure('No se ha seleccionado una imagen'));
        return;
      }

      print('currentProduct: ${currentProduct.toMap()}');

      //enviamos la temperatura con la imagen
      final response = await wmsPackingRepository.sendTemperature(
        resultTemperature.temperature ?? 0.0,
        event.moveLineId,
        event.file,
        true,
      );

      //esperamos la repuesta y emitimos el estadp
      if (response.code == 200) {
        //actualizamos la temepratura por producto en la bd y la imagen

        await db.productosPedidosRepository.setFieldTableProductosPedidos2(
          currentProduct.pedidoId ?? 0,
          currentProduct.idProduct ?? 0,
          'temperatura',
          resultTemperature.temperature ?? 0.0,
          event.moveLineId,
          'packing-batch-consolidate',
        );

        //agregamos la imagen de temperatura del producto a la bd
        await db.productosPedidosRepository.setFieldTableProductosPedidos2(
          currentProduct.pedidoId ?? 0,
          currentProduct.idProduct ?? 0,
          'image',
          response.imageUrl ?? "",
          event.moveLineId,
          'packing-batch-consolidate',
        );

        //limpiamos el dato de temperatura
        resultTemperature = TemperatureIa();

        add(LoadAllProductsFromPedidoEvent(currentProduct.pedidoId ?? 0));

        emit(SendTemperatureSuccess(
            response.result ?? 'Temperatura enviada correctamente'));
      } else {
        emit(SendTemperatureFailure(
            response.msg ?? 'Error al enviar la temperatura'));
        return;
      }
    } catch (e, s) {
      print('Error en el _onSendTemperatureEvent: $e, $s');
      emit(SendTemperatureFailure(
          'Ocurrió un error al procesar la imagen y obtener la temperatura'));
    }
  }

  void _onGetTemperatureEvent(
    GetTemperatureEvent event,
    Emitter<PackingConsolidateState> emit,
  ) async {
    try {
      emit(GetTemperatureLoading());
      // 1. Llamar al método que analiza la imagen y devuelve la temperatura
      final result =
          await wmsPackingRepository.getTemperatureWithImage(event.file);

      resultTemperature = TemperatureIa();
      if (result.temperature != null) {
        resultTemperature = result;
        emit(GetTemperatureSuccess(resultTemperature));
      } else {
        emit(GetTemperatureFailure(
            result.detail ?? 'Error al obtener la temperatura'));
        return;
      }
    } catch (e, s) {
      print('Error en el _onGetTemperatureEvent: $e, $s');
      emit(GetTemperatureFailure(
          'Ocurrió un error al procesar la imagen y obtener la temperatura'));
    }
  }

  //*metdo para dividir el producto
  void _onSetPickingsSplitEvent(
      SetPickingSplitEvent event, Emitter<PackingConsolidateState> emit) async {
    try {
      emit(SetPickingPackingLoadingState());
      //actualizamos el estado del producto como separado
      await db.productosPedidosRepository.setFieldTableProductosPedidos3(
          event.pedidoId,
          event.productId,
          "is_separate",
          1,
          event.idMove,
          'packing-batch-consolidate');

      //marcamos el producto como producto split
      await db.productosPedidosRepository.setFieldTableProductosPedidos3(
          event.pedidoId,
          event.productId,
          "is_product_split",
          1,
          event.idMove,
          'packing-batch-consolidate');

      await db.productosPedidosRepository.setFieldTableProductosPedidos3(
          event.pedidoId,
          event.productId,
          "is_package",
          0,
          event.idMove,
          'packing-batch-consolidate');
      // actualizamos el estado del producto como certificado
      await db.productosPedidosRepository.setFieldTableProductosPedidos3(
          event.pedidoId,
          event.productId,
          "is_certificate",
          1,
          event.idMove,
          'packing-batch-consolidate');

//calculamos la cantidad pendiente del producto
      var pendingQuantity = (event.producto.quantity - event.quantity);
      //creamos un nuevo producto (duplicado) con la cantidad separada
      await db.productosPedidosRepository.insertDuplicateProductoPedido(
          event.producto, pendingQuantity, event.producto.type ?? "");

      //actualizamos la cantidad separada
      quantitySelected = 0;
      viewQuantity = false;
      //actualizamos la lista de productos
      add(LoadAllProductsFromPedidoEvent(
        event.pedidoId,
      ));
      emit(SetPickingPackingOkState());
    } catch (e, s) {
      print('Error en el  _onSetPickingsSplitEvent: $e, $s');
      emit(SplitProductError(e.toString()));
    }
  }

  //*evento para ver la cantidad
  void _onShowQuantityEvent(
      ShowQuantityPackEvent event, Emitter<PackingConsolidateState> emit) {
    try {
      viewQuantity = !viewQuantity;
      emit(ShowQuantityPackState(viewQuantity));
    } catch (e, s) {
      print("❌ Error en _onShowQuantityEvent: $e, $s");
    }
  }

//metodo para enviar una imagen de novedad
  void _onSendImageNovedad(
      SendImageNovedad event, Emitter<PackingConsolidateState> emit) async {
    try {
      print('------ Enviando imagen de novedad ---');
      print(
          'pedidoId: ${event.pedidoId} moveLineId: ${event.moveLineId} productId: ${event.productId}');
      emit(SendImageNovedadLoading());
      final response = await wmsPackingRepository.sendImageNoved(
        event.moveLineId,
        event.file,
      );
      if (response.code == 200) {
        //actualizamos la imagen de novedad en la bd
        await db.productosPedidosRepository.setFieldTableProductosPedidos3(
          event.pedidoId,
          event.productId,
          "image_novedad",
          response.imageUrl ?? "",
          event.moveLineId,
          'packing-batch-consolidate',
        );

        emit(SendImageNovedadSuccess(response, event.cantidad));
        //  add(GetPorductsToEntrada(event.idRecepcion));
      } else {
        emit(SendImageNovedadFailure(
            response.msg ?? 'Error al enviar la imagen'));
      }
    } catch (e, s) {
      print('Error en el _onSendImageNovedad: $e, $s');
      emit(SendImageNovedadFailure('Ocurrió un error al enviar la imagen'));
    }
  }

  void _onChangeProductIsOkEvent(ChangeProductIsOkEvent event,
      Emitter<PackingConsolidateState> emit) async {
    if (event.productIsOk) {
      await db.productosPedidosRepository.setFieldTableProductosPedidos(
          event.pedidoId,
          event.productId,
          "time_separate_start",
          DateTime.now().toString(),
          event.idMove,
          'packing-batch-consolidate');
      //actualizamos el producto a true
      await db.productosPedidosRepository.setFieldTableProductosPedidos(
          event.pedidoId,
          event.productId,
          "product_is_ok",
          1,
          event.idMove,
          'packing-batch-consolidate');
      //actualizamos la cantidad separada
      await db.productosPedidosRepository.setFieldTableProductosPedidos3(
          event.pedidoId,
          event.productId,
          "quantity_separate",
          event.quantity,
          event.idMove,
          'packing-batch-consolidate');
    }
    productIsOk = event.productIsOk;
    emit(ChangeProductPackingIsOkState(
      productIsOk,
    ));
  }

  //*metodo para cambiar la cantidad seleccionada
  void _onChangeQuantitySelectedEvent(ChangeQuantitySeparate event,
      Emitter<PackingConsolidateState> emit) async {
    print('event.quantity: ${event.quantity}');
    if (event.quantity > 0) {
      quantitySelected = event.quantity;
      await db.productosPedidosRepository.setFieldTableProductosPedidos3(
          event.pedidoId,
          event.productId,
          "quantity_separate",
          event.quantity,
          event.idMove,
          'packing-batch-consolidate');
    }
    emit(ChangeQuantitySeparateState(quantitySelected));
  }

  void _onValidateFieldsPacking(
      ValidateFieldsPackingEvent event, Emitter<PackingConsolidateState> emit) {
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
    emit(ValidateFieldsPackingState(event.isOk));
  }

  void _onSetPackingsEvent(
      SetPackingsEvent event, Emitter<PackingConsolidateState> emit) async {
    try {
      if (event.productos.isEmpty) return;

      emit(SetPackingsLoadingState());

      final idOperario = await PrefUtils.getUserId();
      final fechaTransaccion = DateTime.now();
      final fechaFormateada = formatoFecha(fechaTransaccion);

      List<ListItem> listItems = event.productos.map((producto) {
        return ListItem(
          idMove: producto.idMove ?? 0,
          productId: producto.idProduct,
          lote: producto.loteId.toString(),
          locationId: (producto.idLocation is int) ? producto.idLocation : 0,
          cantidadSeparada: event.isCertificate
              ? producto.quantitySeparate ?? 0
              : producto.quantity ?? 0,
          observacion: producto.observation ?? 'Sin novedad',
          unidadMedida: producto.unidades ?? '',
          idOperario: idOperario,
          fechaTransaccion: fechaFormateada,
          timeLine: producto.timeSeparate ?? 1,
        );
      }).toList();

      final packingRequest = PackingRequest(
        idBatch: event.productos[0].batchId ?? 0,
        isSticker: event.isSticker,
        isCertificate: event.isCertificate,
        pesoTotalPaquete: 34.0, // Considera calcular esto dinámicamente
        listItem: listItems,
      );

      final responsePacking =
          await wmsPackingRepository.sendPackingConsolidateRequest(
        packingRequest,
        true,
      );

      if (responsePacking.result?.code != 200) {
        emit(SetPackingsErrorState(responsePacking.result?.msg ?? ""));
        return;
      }

      final paquete = Paquete(
        id: responsePacking.result?.result?[0].idPaquete ?? 0,
        name: responsePacking.result?.result?[0].namePaquete ?? '',
        batchId: event.productos[0].batchId,
        pedidoId: event.productos[0].pedidoId,
        cantidadProductos: event.productos.length,
        listaProductosInPacking: event.productos,
        isSticker: event.isSticker,
        consecutivo: responsePacking.result?.result?[0].consecutivo ?? '',
      );

      packages.add(paquete);
      await db.packagesRepository
          .insertPackage(paquete, 'packing-batch-consolidate');

      await db.pedidosPackingConsolidateRepository.setFieldTablePedidosPacking(
        event.productos[0].batchId ?? 0,
        event.productos[0].pedidoId ?? 0,
        "is_selected",
        1,
      );

      await db.batchPackingConsolidateRepository.setFieldTableBatchPacking(
        event.productos[0].batchId ?? 0,
        "is_selected",
        1,
      );

      await _actualizarProductoBatch(
        db,
        event.productos,
        paquete,
        event.isCertificate,
      );

      listOfProductsForPacking = [];

      add(LoadAllProductsFromPedidoEvent(event.productos[0].pedidoId ?? 0));

      emit(SetPackingsOkState('Empaquetado exitoso'));
    } catch (e, s) {
      print('Error en _onSetPackingsEvent: $e\n$s');
      emit(SetPackingsErrorState('Ocurrió un error inesperado'));
    }
  }

  Future<void> _actualizarProductoBatch(
    DataBaseSqlite db,
    List<ProductoPedido> productos,
    Paquete paquete,
    bool isCertificate,
  ) async {
    final idPaquete = paquete.id;
    final nombrePaquete = paquete.name;

    final fieldsToUpdate = isCertificate
        ? {
            "package_name": nombrePaquete,
            "is_separate": 1,
            "id_package": idPaquete,
            "is_package": 1,
          }
        : {
            "package_name": nombrePaquete,
            "is_separate": 1,
            "id_package": idPaquete,
            "is_package": 1,
            "is_certificate": 0,
          };

    await db.productosPedidosRepository.updateProductosBatch(
      productos: productos,
      fieldsToUpdate: fieldsToUpdate,
      isCertificate: isCertificate,
    );
  }

  //*metodo que se encarga de hacer el picking
  void _onSetPickingsEvent(
      SetPickingsEvent event, Emitter<PackingConsolidateState> emit) async {
    try {
      emit(SetPickingPackingLoadingState());

      final DateTime dateTimeNow = DateTime.now();

      await db.productosPedidosRepository.setFieldTableProductosPedidos3(
          event.pedidoId,
          event.productId,
          "time_separate_end",
          dateTimeNow.toString(),
          event.idMove,
          'packing-batch-consolidate');

      final productUpdate = await db.productosPedidosRepository
          .getProductoPedidoById(
              event.pedidoId, event.idMove, 'packing-batch-consolidate');

      print('productUpdate :${productUpdate.toMap()}');

      // Calcular la diferencia del producto ya separado
      Duration differenceProduct = dateTimeNow
          .difference(DateTime.parse(productUpdate.timeSeparatStart));

      // Obtener la diferencia en segundos
      double secondsDifferenceProduct =
          differenceProduct.inMilliseconds / 1000.0;

      print('secondsDifferenceProduct: $secondsDifferenceProduct');
      //actualizamos el dato de tiempoSeparado
      await db.productosPedidosRepository.setFieldTableProductosPedidos3(
          event.pedidoId,
          event.productId,
          "time_separate",
          secondsDifferenceProduct,
          event.idMove,
          'packing-batch-consolidate');

      //actualizamos el estado del producto como separado
      await db.productosPedidosRepository.setFieldTableProductosPedidos3(
          event.pedidoId,
          event.productId,
          "is_separate",
          1,
          event.idMove,
          'packing-batch-consolidate');
      await db.productosPedidosRepository.setFieldTableProductosPedidos3(
          event.pedidoId,
          event.productId,
          "is_package",
          0,
          event.idMove,
          'packing-batch-consolidate');
      await db.productosPedidosRepository.setFieldTableProductosPedidos3(
          event.pedidoId,
          event.productId,
          "is_certificate",
          1,
          event.idMove,
          'packing-batch-consolidate');

      //actualizamos la cantidad se mparada
      quantitySelected = 0;
      viewQuantity = false;
      add(LoadAllProductsFromPedidoEvent(event.pedidoId));
      emit(SetPickingPackingOkState());
    } catch (e, s) {
      print('Error en el  _onSetPickingsEvent: $e, $s');
      emit(SetPickingPackingErrorState(e.toString()));
    }
  }

  void _onDeleteProductFromTemporaryPackageEvent(
      DeleteProductFromTemporaryPackageEvent event,
      Emitter<PackingConsolidateState> emit) async {
    try {
      emit(DeleteProductFromTemporaryPackageLoading());

      //tenemos que revertir los valores de is_ok

      //validamos que el producto no este en la lista de producto de por hacer

      if (listOfProductosProgress
          .any((prod) => prod.idMove == event.product.idMove)) {
        emit(DeleteProductFromTemporaryPackageError(
            "No se puede eliminar el producto porque ya está en la lista de por hacer"));
        return;
      }

      //is_package
      await db.productosPedidosRepository.revertProductFields(
          event.product.pedidoId ?? 0,
          event.product.idProduct ?? 0,
          event.product.idMove ?? 0,
          'packing-batch-consolidate');

      //actualizamos todas las listas
      add(LoadAllProductsFromPedidoEvent(event.product.pedidoId ?? 0));

      emit(DeleteProductFromTemporaryPackageOkState());
    } catch (e, s) {
      print('Error en el  _onDeleteProductFromTemporaryPackageEvent: $e, $s');
      emit(DeleteProductFromTemporaryPackageError(e.toString()));
    }
  }

  //*metodo para seleccionar un producto sin certificar
  void _onSelectProductPackingEvent(SelectProductPackingEvent event,
      Emitter<PackingConsolidateState> emit) async {
    try {
      // Verificar si el producto ya está en la lista de productos seleccionados
      if (!listOfProductsForPacking.contains(event.producto)) {
        // Agregar el producto a la lista si no está ya presente
        listOfProductsForPacking.add(event.producto);
        // Emitir un nuevo estado con la lista actualizada
        emit(SelectProductPackingLoadedState(
            listOfProductsForPacking: listOfProductsForPacking));
      }
    } catch (e, s) {
      print('Error en el _onSelectProductPackingEvent: $e, $s');
      emit(SelectProductPackingErrorState(e.toString()));
    }
  }

  //*metodo para deseleccionar un producto sin certificar
  void _onUnSelectProductPackingEvent(UnSelectProductPackingEvent event,
      Emitter<PackingConsolidateState> emit) async {
    try {
      // Verificar si el producto está en la lista antes de intentar eliminarlo
      if (listOfProductsForPacking.contains(event.producto)) {
        // Eliminar el producto de la lista
        listOfProductsForPacking.remove(event.producto);
        // Emitir un nuevo estado con la lista actualizada
        emit(UnSelectProductPackingLoadedState(
            listOfProductsForPacking: listOfProductsForPacking));
      }
    } catch (e, s) {
      print('Error en el _onUnSelectProductPackingEvent: $e, $s');
      emit(UnSelectProductPackingErrorState(e.toString()));
    }
  }

  ///*metodo para cambiar el estado del sticker
  void _onChangeStickerEvent(
      ChangeStickerEvent event, Emitter<PackingConsolidateState> emit) {
    isSticker = event.isSticker;
    emit(ChangeStickerState(isSticker));
  }

  void _onChangeLocationIsOkEvent(ChangeLocationIsOkEvent event,
      Emitter<PackingConsolidateState> emit) async {
    if (isLocationOk) {
      //*actualizamos la seleccion del batch, pedido y producto
      //actualizamos el estado de seleccion de un batch
      await db.batchPackingConsolidateRepository.setFieldTableBatchPacking(
          currentProduct.batchId ?? 0, "is_selected", 1);
      //actualizamos el estado del pedido como seleccionado
      await db.pedidosPackingConsolidateRepository.setFieldTablePedidosPacking(
          currentProduct.batchId ?? 0, event.pedidoId, "is_selected", 1);
      // actualizamo el valor de que he seleccionado el producto
      await db.productosPedidosRepository.setFieldTableProductosPedidos(
          event.pedidoId,
          event.productId,
          "is_selected",
          1,
          currentProduct.idMove ?? 0,
          'packing-batch-consolidate');
      //*actualizamos la ubicacion del producto a true
      await db.productosPedidosRepository.setFieldTableProductosPedidos(
          event.pedidoId,
          event.productId,
          "is_location_is_ok",
          1,
          currentProduct.idMove ?? 0,
          'packing-batch-consolidate');

      locationIsOk = true;
      emit(ChangeLocationPackingIsOkState(
        locationIsOk,
      ));
    }
  }

  void _onFetchProductEvent(
      FetchProductEvent event, Emitter<PackingConsolidateState> emit) async {
    try {
      isLocationOk = true;
      isProductOk = true;
      isLocationDestOk = true;
      isQuantityOk = true;

      emit(ProductInfoLoading());
      listOfBarcodes.clear();
      currentProduct = ProductoPedido();
      currentProduct = event.pedido;
      listOfBarcodes = await db.barcodesPackagesRepository.getBarcodesProduct(
          currentProduct.batchId ?? 0,
          currentProduct.idProduct,
          currentProduct.idMove ?? 0,
          'packing-batch-consolidate');
      print('listOfBarcodes: ${listOfBarcodes.length}');
      locationIsOk = currentProduct.isLocationIsOk == 1 ? true : false;
      productIsOk = currentProduct.productIsOk == 1 ? true : false;
      locationDestIsOk = currentProduct.locationDestIsOk == 1 ? true : false;
      quantityIsOk = currentProduct.isQuantityIsOk == 1 ? true : false;
      quantitySelected = currentProduct.isProductSplit == 1
          ? 0
          : currentProduct.quantitySeparate ?? 0;
      products();

      emit(ProductInfoLoaded());
    } catch (e, s) {
      print('Error en el  _onFetchProductEvent: $e, $s');
      emit(ProductInfoError(e.toString()));
    }
  }

  void products() {
    // Limpiamos la lista 'listOfProductsName' para asegurarnos que no haya duplicados de iteraciones anteriores
    listOfProductsName.clear();

    // Recorremos los productos del batch
    for (var i = 0; i < listOfProductosProgress.length; i++) {
      var product = listOfProductosProgress[i];

      // Aseguramos que productId no sea nulo antes de intentar agregarlo
      if (product != null && product != null) {
        // Validamos si el productId ya existe en la lista 'positions'
        if (!listOfProductsName.contains(product.idMove)) {
          listOfProductsName.add(
              product); // Agregamos el productId a la lista 'listOfProductsName'
        }
      }
    }
  }

  void _onSearchPedidoEvent(SearchPedidoPackingEvent event,
      Emitter<PackingConsolidateState> emit) async {
    try {
      final query = event.query.trim();

      if (query.isEmpty) {
        listOfPedidosFilters = listOfPedidos;
      } else {
        final normalizedQuery = normalizeText(query);

        listOfPedidosFilters = listOfPedidos.where((pedido) {
          final name = normalizeText(pedido.name ?? '');
          final referencia = normalizeText(pedido.referencia ?? '');
          final contactoName = normalizeText(pedido.contactoName ?? '');
          final zonaName = normalizeText(pedido.zonaEntrega ?? '');

          return name.contains(normalizedQuery) ||
              referencia.contains(normalizedQuery) ||
              contactoName.contains(normalizedQuery) ||
              zonaName.contains(normalizedQuery);
        }).toList();
      }

      emit(SearchPedidoPackingLoadedState(
        listOfPedidos: listOfPedidosFilters,
      ));
    } catch (e, s) {
      print('Error en el _onSearchPedidoEvent: $e, $s');
      emit(SearPedidoPackingErrorState(e.toString()));
    }
  }

  void _onLoadAllProductsFromPedidoEvent(LoadAllProductsFromPedidoEvent event,
      Emitter<PackingConsolidateState> emit) async {
    try {
      emit(LoadingLoadAllProductsFromPedido());

      add(LoadConfigurationsUserPackConsolidate());

      final response = await DataBaseSqlite()
          .productosPedidosRepository
          .getProductosPedido(event.pedidoId, 'packing-batch-consolidate');

      if (response != null) {
        print('response lista de productos: ${response.length}');
        listOfProductos.clear();
        listOfProductos.addAll(response);
        productsDonePacking.clear();

        //filtramos y creamos la lista de productos listo a empacar
        productsDone = listOfProductos
            .where((product) =>
                (product.isSeparate == true || product.isSeparate == 1) &&
                (product.isCertificate == true || product.isCertificate == 1) &&
                (product.isPackage == false || product.isPackage == 0))
            .toList();

        print('productsDone: ${productsDone.length}');

        productsDonePacking = listOfProductos
            .where(
                (product) => product.isSeparate == 1 && product.isPackage == 1)
            .toList();

        print('productsDonePacking: ${productsDonePacking.length}');

        //filtramos y creamos la lista de productos listo a separar para empaque
        listOfProductosProgress = listOfProductos.where((product) {
          return product.isSeparate == null || product.isSeparate == 0;
        }).toList();

        print(listOfProductosProgress);

        ordenarProducts();

        //despues de obtener los productos vamos a obtener todos los codigos de barras de este pedido
        listAllOfBarcodes.clear();
        if (listOfProductosProgress.isNotEmpty) {
          final responseBarcodes = await db.barcodesPackagesRepository
              .getBarcodesByBatchIdAndType(
                  listOfProductosProgress[0].batchId ?? 0,
                  'packing-batch-consolidate');

          if (responseBarcodes != null) {
            listAllOfBarcodes = responseBarcodes;
          }
        }

        print('listAllOfBarcodes: ${listAllOfBarcodes.length}');

        //traemos todos los paquetes de la base de datos del pedido en cuesiton
        final packagesDB =
            await db.packagesRepository.getPackagesPedido(event.pedidoId);
        packages.clear();
        packages.addAll(packagesDB);
        print('packagesDB: ${packagesDB.length}');

        //obtenemos las posiciones de los productos
        getPosicions();

        emit(LoadAllProductsFromPedidoLoaded(
          listOfProducts: listOfProductos,
        ));
      } else {
        print('Error _onLoadAllProductsFromPedidoEvent: response is null');
      }
    } catch (e, s) {
      print('Error en el  _onLoadAllProductsFromPedidoEvent: $e, $s');
      emit(ErrorLoadAllProductsFromPedido(e.toString()));
    }
  }

  void getPosicions() {
    positions.clear(); // Limpia la lista antes de agregar nuevas posiciones
    for (var product in listOfProductos) {
      if (product.locationId != null) {
        // Verifica si la posición ya existe en la lista
        if (!positions.contains(product.locationId!)) {
          positions
              .add(product.locationId!); // Solo agrega si no está en la lista
        }
      }
    }
    print('positions: ${positions.length}');
  }

  void ordenarProducts() {
    listOfProductosProgress.sort((a, b) {
      return a.locationId!.compareTo(b.locationId!);
    });
  }

  //*evento para ver el detalle
  void _onShowDetailEvent(
      ShowDetailvent event, Emitter<PackingConsolidateState> emit) {
    try {
      viewDetail = !viewDetail;
      emit(ShowDetailState(viewDetail));
    } catch (e, s) {
      print("❌ Error en _onShowQuantityEvent: $e, $s");
    }
  }

  void _onLoadDocOriginsEvent(
      LoadDocOriginsEvent event, Emitter<PackingConsolidateState> emit) async {
    try {
      final batchsFromDB = await db.docOriginRepository
          .getAllOriginsByIdBatch(event.idBatch, 'packing');

      listOfOrigins.clear();

      listOfOrigins = batchsFromDB;
      print('listOfOrigins: ${listOfOrigins.length}');

      emit(LoadDocOriginsState(listOfOrigins: listOfOrigins));
    } catch (e, s) {
      print('Error LoadDocOriginsEvent: $e, $s');
    }
  }

  void _onLoadAllPedidosFromBatchEvent(LoadAllPedidosFromBatchEvent event,
      Emitter<PackingConsolidateState> emit) async {
    try {
      emit(PackingConsolidateLoading());
      final response = await DataBaseSqlite()
          .pedidosPackingConsolidateRepository
          .getAllPedidosBatch(event.batchId);
      if (response != null) {
        print('response pedidos: ${response.length}');
        listOfPedidos.clear();
        listOfPedidosFilters.clear();
        listOfPedidosFilters = response;
        listOfPedidos = response;
        print('pedidosToInsert: ${response.length}');
        emit(LoadAllPedidosFromBatchLoaded(
          listOfPedidos: listOfPedidos,
        ));
      } else {
        print('Error resPedidos: response is null');
      }
    } catch (e, s) {
      print('Error en el  _onLoadAllPedidosFromBatchEvent: $e, $s');
      emit(PackingConsolidateError(e.toString()));
    }
  }

  //*evento para empezar el tiempo de separacion
  void _onStartTimePickEvent(
      StartTimePack event, Emitter<PackingConsolidateState> emit) async {
    try {
      DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      String formattedDate = formatter.format(event.time);
      final userid = await PrefUtils.getUserId();

      await wmsPackingRepository.timePackingUser(
        event.batchId,
        formattedDate,
        'start_time_batch_user',
        'start_time',
        userid,
      );
      final responseTimeBatch = await wmsPackingRepository.timePackingBatch(
          event.batchId,
          formattedDate,
          'update_start_time',
          'start_time_pack',
          'start_time');

      if (responseTimeBatch) {
        await db.batchPackingConsolidateRepository
            .startStopwatchBatch(event.batchId, formattedDate);
        emit(TimeSeparatePackSuccess(formattedDate));
      } else {
        emit(TimeSeparatePackError('Error al iniciar el tiempo de separacion'));
      }
    } catch (e, s) {
      print("❌ Error en _onStartTimePickEvent: $e, $s");
    }
  }

  void _onLoadBatchsFromDBEvent(LoadBatchPackingFromDBEvent event,
      Emitter<PackingConsolidateState> emit) async {
    try {
      emit(BatchsPackingLoadingState());
      final batchsFromDB =
          await db.batchPackingConsolidateRepository.getAllBatchsPacking();
      listOfBatchsDB.clear();
      listOfBatchsDB = batchsFromDB;
      emit(WmsPackingLoadedBD());
    } catch (e, s) {
      print('Error en el  _onLoadBatchsFromDBEvent: $e, $s');
      emit(PackingConsolidateError(e.toString()));
    }
  }

  //*evento para actualizar el valor del scan
  void _onUpdateScannedValueEvent(UpdateScannedValuePackEvent event,
      Emitter<PackingConsolidateState> emit) {
    try {
      switch (event.scan) {
        case 'location':
          // Acumulador de valores escaneados
          scannedValue1 += event.scannedValue.trim();
          print('scannedValue1: $scannedValue1');
          emit(UpdateScannedValuePackState(scannedValue1, event.scan));
          break;
        case 'product':
          scannedValue2 += event.scannedValue.trim();
          print('scannedValue2: $scannedValue2');
          emit(UpdateScannedValuePackState(scannedValue2, event.scan));
          break;
        case 'quantity':
          scannedValue3 += event.scannedValue.trim();
          print('scannedValue3: $scannedValue3');
          emit(UpdateScannedValuePackState(scannedValue3, event.scan));
          break;
        case 'muelle':
          print('scannedValue4: $scannedValue4');
          scannedValue4 += event.scannedValue.trim();
          emit(UpdateScannedValuePackState(scannedValue4, event.scan));
          break;

        case 'toDo':
          print('scannedValue5: $scannedValue5');
          scannedValue5 += event.scannedValue.trim();
          emit(UpdateScannedValuePackState(scannedValue5, event.scan));
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
      ClearScannedValuePackEvent event, Emitter<PackingConsolidateState> emit) {
    try {
      switch (event.scan) {
        case 'location':
          scannedValue1 = '';
          emit(ClearScannedValuePackState());
          break;
        case 'product':
          scannedValue2 = '';
          emit(ClearScannedValuePackState());
          break;
        case 'quantity':
          scannedValue3 = '';
          emit(ClearScannedValuePackState());
          break;
        case 'muelle':
          scannedValue4 = '';
          emit(ClearScannedValuePackState());
          break;

        case 'toDo':
          scannedValue5 = '';
          emit(ClearScannedValuePackState());
          break;

        default:
          print('Scan type not recognized: ${event.scan}');
      }
      emit(ClearScannedValuePackState());
    } catch (e, s) {
      print("❌ Error en _onClearScannedValueEvent: $e, $s");
    }
  }

  void _onShowKeyboardEvent(
      ShowKeyboardEvent event, Emitter<PackingConsolidateState> emit) {
    isKeyboardVisible = event.showKeyboard;
    emit(ShowKeyboardState(showKeyboard: isKeyboardVisible));
  }

  //metodo para buscar un batch de packing
  void _onSearchBacthEvent(SearchBatchPackingEvent event,
      Emitter<PackingConsolidateState> emit) async {
    final query = event.query.toLowerCase();

    if (query.isEmpty) {
      listOfBatchsDB = [];
      listOfBatchsDB = listOfBatchs;
      print('listOfBatchsDB: ${listOfBatchsDB.length}');
      print('listOfBatchs: ${listOfBatchs.length}');
    } else {
      listOfBatchsDB = listOfBatchs.where((batch) {
        return batch.name?.toLowerCase().contains(query) ?? false;
      }).toList();
    }
    emit(PackingConsolidateLoaded(listOfBatchs: listOfBatchsDB));
  }

  String normalizeText(String input) {
    // Normaliza texto: sin tildes, minúsculas, sin espacios a los extremos
    const Map<String, String> accentMap = {
      'á': 'a',
      'é': 'e',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'ü': 'u',
      'ñ': 'n',
    };

    return input
        .trim()
        .toLowerCase()
        .split('')
        .map((char) => accentMap[char] ?? char)
        .join();
  }

  void _onLoadAllPackingEvent(LoadAllPackingConsolidateEvent event,
      Emitter<PackingConsolidateState> emit) async {
    emit(PackingConsolidateLoading());
    try {
      await DataBaseSqlite().delePacking('packing-batch-consolidate');

      final response =
          await wmsPackingRepository.resBatchsPackingConsolidate(true);

      if (response.result != null && response.result is List) {
        listOfBatchs.clear();
        listOfBatchsDB.clear();
        listOfBatchs.addAll(response.result!);
        listOfBatchsDB.addAll(response.result!);

        if ((response.updateVersion ?? false) == true) {
          emit(NeedUpdateVersionState());
        }

        if (listOfBatchs.isNotEmpty) {
          // Guardar los batchs consolidate en la base de datos local
          await DataBaseSqlite()
              .batchPackingConsolidateRepository
              .insertAllBatchPacking(listOfBatchs);
          // Convertir el mapa en una lista de pedido unicos del batch para packing
          List<PedidoPacking> pedidosToInsert =
              listOfBatchs.expand((batch) => batch.listaPedidos!).toList();

          //convertir el mapa en una lista de productos unicos del pedido para packing
          List<ProductoPedido> productsToInsert = pedidosToInsert
              .expand((pedido) => pedido.listaProductos!)
              .toList();

          //Convertir el mapa en una lista los barcodes unicos de cada producto
          List<Barcodes> barcodesToInsert = productsToInsert
              .expand((product) => product.productPacking!)
              .toList();

          //convertir el mapap en una lsita de los otros barcodes de cada producto
          List<Barcodes> otherBarcodesToInsert = productsToInsert
              .expand((product) => product.otherBarcode!)
              .toList();

          //convertir el mapap en una lista de productos unicos de paquetes que se encuentra en un pedido dentro de listado de paquetes y listado de productos
          List<ProductoPedido> productsPackagesToInsert = pedidosToInsert
              .expand((pedido) => pedido.listaPaquetes!)
              .expand((paquete) => paquete.listaProductosInPacking!)
              .toList();

          //covertir el mapa en una lista de los paquetes de un pedido
          List<Paquete> packagesToInsert = pedidosToInsert
              .expand((pedido) => pedido.listaPaquetes!)
              .toList();

          final originsIterable =
              _extractAllOrigins(listOfBatchs).toList(growable: false);
          print(
              'productsPackagesToInsert Packing : ${productsPackagesToInsert.length}');

          print('pedidosToInsert Packing : ${pedidosToInsert.length}');
          print('productsToInsert Packing : ${productsToInsert.length}');
          print('barcode product Packing : ${barcodesToInsert.length}');
          print('otherBarcodes    Packing : ${otherBarcodesToInsert.length}');
          print('packagesToInsert Packing : ${packagesToInsert.length}');
          print('listOfBatchs origin : ${originsIterable.length}');

          // Enviar la lista agrupada de productos de un batch para packing
          await DataBaseSqlite()
              .pedidosPackingConsolidateRepository
              .insertPedidosBatchPacking(
                  pedidosToInsert, 'packing-batch-consolidate');
          // Enviar la lista agrupada de productos de un pedido para packing
          await DataBaseSqlite()
              .productosPedidosRepository
              .insertProductosPedidos(
                  productsToInsert, 'packing-batch-consolidate');
          // Enviar la lista agrupada de barcodes de un producto para packing
          await DataBaseSqlite()
              .barcodesPackagesRepository
              .insertOrUpdateBarcodes(
                  barcodesToInsert, 'packing-batch-consolidate');
          // Enviar la lista agrupada de otros barcodes de un producto para packing
          await DataBaseSqlite()
              .barcodesPackagesRepository
              .insertOrUpdateBarcodes(
                  otherBarcodesToInsert, 'packing-batch-consolidate');
          //guardamos los productos de los paquetes que ya fueron empaquetados
          await DataBaseSqlite()
              .productosPedidosRepository
              .insertProductosOnPackage(
                  productsPackagesToInsert, 'packing-batch-consolidate');
          //enviamos la lista agrupada de los paquetes de un pedido para packing
          await DataBaseSqlite()
              .packagesRepository
              .insertPackages(packagesToInsert, 'packing-batch-consolidate');

          await DataBaseSqlite().docOriginRepository.insertAllDocsOrigins(
              originsIterable, 'packing-batch-consolidate');

          //creamos las cajas que ya estan creadas

          // //* Carga los batches desde la base de datos
          add(LoadBatchPackingFromDBEvent());
        }

        emit(PackingConsolidateLoaded(
          listOfBatchs: listOfBatchs,
        ));
      } else {
        print('Error resBatchs: response is null');
      }
    } catch (e, s) {
      print('Error en el  _onLoadAllPackingEvent: $e, $s');
      emit(PackingConsolidateError(e.toString()));
    }
  }

  Iterable<Origin> _extractAllOrigins(List<BatchPackingModel> batches) {
    return batches.expand((batch) {
      final origins = batch.origin ?? [];
      return origins.where((p) => p.id != null && p.name != null).map((p) {
        return Origin(id: p.id!, name: p.name!, idBatch: batch.id);
      });
    });
  }

//*metodo para cargar la configuracion del usuario
  void _onLoadConfigurationsUserEvent(
      LoadConfigurationsUserPackConsolidate event,
      Emitter<PackingConsolidateState> emit) async {
    try {
      emit(ConfigurationLoadingPack());
      int userId = await PrefUtils.getUserId();
      final response =
          await db.configurationsRepository.getConfiguration(userId);

      if (response != null) {
        configurations = response;
        emit(ConfigurationLoadedPack(response));
      } else {
        emit(ConfigurationErrorPack('Error al cargar configuraciones'));
      }
    } catch (e, s) {
      emit(ConfigurationErrorPack(e.toString()));
      print('Error en LoadConfigurationsUserPack.dart: $e =>$s');
    }
  }

  String formatSecondsToHHMMSS(double secondsDecimal) {
    try {
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
    } catch (e, s) {
      print("❌ Error en el formatSecondsToHHMMSS $e ->$s");
      return "";
    }
  }
}
