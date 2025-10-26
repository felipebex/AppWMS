// ignore_for_file: unrelated_type_equality_checks

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wms_app/src/core/utils/prefs/pref_utils.dart';
import 'package:wms_app/src/presentation/models/novedades_response_model.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/user/models/configuration.dart';
import 'package:wms_app/src/presentation/views/wms_packing/data/wms_packing_repository.dart';
import 'package:wms_app/src/presentation/views/wms_packing/models/lista_product_packing.dart';
import 'package:wms_app/src/presentation/views/wms_packing/models/packing_response_model.dart';
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
                  listOfProductosProgress[0].batchId ?? 0, 'packing-batch');

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
          .pedidosPackingRepository
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

      // await wmsPackingRepository.timePackingUser(
      //   event.batchId,
      //   formattedDate,
      //   'start_time_batch_user',
      //   'start_time',
      //   userid,
      // );
      // final responseTimeBatch = await wmsPackingRepository.timePackingBatch(
      //     event.batchId,
      //     formattedDate,
      //     'update_start_time',
      //     'start_time_pack',
      //     'start_time');

      // if (responseTimeBatch) {
      //   await db.batchPackingRepository
      //       .startStopwatchBatch(event.batchId, formattedDate);
      emit(TimeSeparatePackSuccess(formattedDate));
      // } else {
      //   emit(TimeSeparatePackError('Error al iniciar el tiempo de separacion'));
      // }
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
}
