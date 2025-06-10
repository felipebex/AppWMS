import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/user/models/configuration.dart';
import 'package:wms_app/src/presentation/views/wms_packing/data/wms_packing_repository.dart';
import 'package:wms_app/src/presentation/views/wms_packing/models/response_packing_pedido_model.dart';
import 'package:wms_app/src/utils/prefs/pref_utils.dart';

part 'packing_pedido_event.dart';
part 'packing_pedido_state.dart';

class PackingPedidoBloc extends Bloc<PackingPedidoEvent, PackingPedidoState> {
  //*variables para validar
  bool locationIsOk = false;
  bool productIsOk = false;
  bool locationDestIsOk = false;
  bool quantityIsOk = false;
  bool isKeyboardVisible = false;

  //*controller para la busqueda
  TextEditingController searchController = TextEditingController();
  TextEditingController searchControllerPedido = TextEditingController();
  TextEditingController searchControllerProduct = TextEditingController();
  TextEditingController controllerTemperature = TextEditingController();

  //lista de pedidos
  List<PedidoPackingResult> listOfPedidos = [];
  List<PedidoPackingResult> listOfPedidosBD = [];
  List<PedidoPackingResult> listOfPedidosFilters = [];

  bool viewDetail = true;

  PedidoPackingResult currentPedidoPack = PedidoPackingResult();

  //configuracion del usuario //permisos
  Configurations configurations = Configurations();

//*base de datos
  DataBaseSqlite db = DataBaseSqlite();
  //*repositorio
  WmsPackingRepository wmsPackingRepository = WmsPackingRepository();

  PackingPedidoBloc() : super(PackingPedidoInitial()) {
    on<PackingPedidoEvent>((event, emit) {});
    //evento para mostrar el teclado
    on<ShowKeyboardEvent>(_onShowKeyboardEvent);
    //*obtener todos los pedidos para packing de odoo
    on<LoadAllPackingPedidoEvent>(_onLoadAllPackingEvent);
    //*cargar los pedidos de packing desde la base de datos
    on<LoadPackingPedidoFromDBEvent>(_onLoadPackingPedidoFromDBEvent);

    //*buscar un pedido
    on<SearchPedidoEvent>(_onSearchPedidoEvent);
    //*asignar un usuario a una orden de compra
    on<AssignUserToPedido>(_onAssignUserToPedido);
    //* evento para empezar o terminar el tiempo
    on<StartOrStopTimePedido>(_onStartOrStopTimePedido);

    //*evento para obtener la configuracion del usuario
    on<LoadConfigurationsUser>(_onLoadConfigurationsUserEvent);

    //cargar pedido y productos
    on<LoadPedidoAndProductsEvent>(_onLoadPedidoAndProductsEvent);
    on<ShowDetailvent>(_onShowDetailEvent);
  }

  //*evento para ver el detalle
  void _onShowDetailEvent(ShowDetailvent event, Emitter<PackingPedidoState> emit) {
    try {
      viewDetail = !viewDetail;
      emit(ShowDetailPackState(viewDetail));
    } catch (e, s) {
      print("❌ Error en _onShowQuantityEvent: $e, $s");
    }
  }

  //*metodo para cargar el pedido actual y sus productos:
  void _onLoadPedidoAndProductsEvent(LoadPedidoAndProductsEvent event,
      Emitter<PackingPedidoState> emit) async {
    try {
      emit(LoadPedidoAndProductsLoading());
      //cargamos el pedido actual
      final response =
          await db.pedidoPackRepository.getPedidoPackById(event.idPedido);

      if (response != null) {
        currentPedidoPack = response;
        emit(LoadPedidoAndProductsLoaded(
          currentPedidoPack,
        ));
      } else {
        emit(LoadPedidoAndProductsError('No se encontró el pedido'));
      }
    } catch (e, s) {
      print('Error en el _onLoadPedidoAndProductsEvent: $e, $s');
      emit(LoadPedidoAndProductsError(e.toString()));
    }
  }

  //* metodo para cargar la configuracion del usuario
  void _onLoadConfigurationsUserEvent(
      LoadConfigurationsUser event, Emitter<PackingPedidoState> emit) async {
    try {
      emit(ConfigurationLoading());
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

  //metodo para empezar o terminar el tiempo
  void _onStartOrStopTimePedido(
      StartOrStopTimePedido event, Emitter<PackingPedidoState> emit) async {
    try {
      final time = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      print("time : $time");
      if (event.value == "start_time_transfer") {
        await db.pedidoPackRepository.updatePedidoPackField(
          event.id,
          "start_time_transfer",
          time,
        );
        await db.pedidoPackRepository.updatePedidoPackField(
          event.id,
          "is_selected",
          1,
        );
      } else if (event.value == "end_time_transfer") {
        await db.pedidoPackRepository.updatePedidoPackField(
          event.id,
          "end_time_transfer",
          time,
        );
      }
      //hacemos la peticion de mandar el tiempo
      final response = await wmsPackingRepository.sendTime(
        event.id,
        event.value,
        time,
        false,
      );

      if (response) {
        emit(StartOrStopTimeTransferSuccess(event.value));
      } else {
        emit(StartOrStopTimeTransferFailure('Error al enviar el tiempo'));
      }
    } catch (e, s) {
      print('Error en el _onStartOrStopTimeOrder: $e, $s');
    }
  }

  //*metodo para obtener los permisos del usuario
  void _onAssignUserToPedido(
      AssignUserToPedido event, Emitter<PackingPedidoState> emit) async {
    try {
      int userId = await PrefUtils.getUserId();
      String nameUser = await PrefUtils.getUserName();

      emit(AssignUserToPedidoLoading());
      final response = await wmsPackingRepository.assignUserToTransfer(
        false,
        userId,
        event.id,
      );

      if (response) {
        //actualizamos la tabla entrada:
        await db.pedidoPackRepository.updatePedidoPackField(
          event.id,
          "responsable_id",
          userId,
        );

        await db.pedidoPackRepository.updatePedidoPackField(
          event.id,
          "responsable",
          nameUser,
        );
        await db.pedidoPackRepository.updatePedidoPackField(
          event.id,
          "is_selected",
          1,
        );

        add(StartOrStopTimePedido(
          event.id,
          "start_time_transfer",
        ));

        emit(AssignUserToPedidoLoaded(
          id: event.id,
        ));
      } else {
        emit(AssignUserToPedidoError(
            "La recepción ya tiene un responsable asignado"));
      }
    } catch (e, s) {
      emit(AssignUserToPedidoError('Error al asignar el usuario'));
      print('Error en el _onAssignUserToOrder: $e, $s');
    }
  }

  void _onSearchPedidoEvent(
    SearchPedidoEvent event,
    Emitter<PackingPedidoState> emit,
  ) async {
    try {
      final query =
          event.query.trim(); // Elimina espacios en blanco al inicio/final

      if (query.isEmpty) {
        // Si la consulta está vacía, muestra la lista completa de la DB
        listOfPedidosFilters = listOfPedidosBD;
      } else {
        // Normaliza la consulta una sola vez para eficiencia
        final normalizedQuery = normalizeText(query);

        // Filtra la lista de pedidos de la base de datos (la fuente de verdad)
        listOfPedidosFilters = listOfPedidosBD.where((pedido) {
          // Normaliza los campos de cada pedido para la comparación
          final name = normalizeText(pedido.name ?? '');
          final referencia = normalizeText(pedido.referencia ?? '');
          final contactoName = normalizeText(pedido.contactoName ?? '');

          // Realiza la búsqueda en los campos relevantes
          // Si alguno de los campos contiene la consulta normalizada, se incluye el pedido
          return name.contains(normalizedQuery) ||
              referencia.contains(normalizedQuery) ||
              contactoName.contains(normalizedQuery);
        }).toList();
      }

      // Emite el nuevo estado con la lista filtrada
      emit(PackingPedidoLoadedFromDBState(listOfPedidos: listOfPedidosBD));
    } catch (e, s) {
      print('Error en el _onSearchPedidoEvent: $e, $s');
      // Emite un estado de error si algo sale mal durante la búsqueda
      emit(PackingPedidoError(e.toString()));
    }
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

  void _onShowKeyboardEvent(
      ShowKeyboardEvent event, Emitter<PackingPedidoState> emit) {
    isKeyboardVisible = event.showKeyboard;
    emit(ShowKeyboardState(showKeyboard: isKeyboardVisible));
  }

  void _onLoadAllPackingEvent(
      LoadAllPackingPedidoEvent event, Emitter<PackingPedidoState> emit) async {
    emit(WmsPackingPedidoWMSLoading());
    try {
      final response =
          await wmsPackingRepository.resPackingPedido(event.isLoadinDialog);

      if (response != null && response is List) {
        listOfPedidos.clear();
        listOfPedidosBD.clear();
        listOfPedidos.addAll(response);
        listOfPedidosBD.addAll(response);

        if (listOfPedidos.isNotEmpty) {
          await DataBaseSqlite()
              .pedidoPackRepository
              .insertPedidosPack(listOfPedidos);

          // //convertir el mapa en una lista de productos unicos del pedido para packing
          // List<ProductoPedido> productsToInsert = pedidosToInsert
          //     .expand((pedido) => pedido.listaProductos!)
          //     .toList();

          // //Convertir el mapa en una lista los barcodes unicos de cada producto
          // List<Barcodes> barcodesToInsert = productsToInsert
          //     .expand((product) => product.productPacking!)
          //     .toList();

          // //convertir el mapap en una lsita de los otros barcodes de cada producto
          // List<Barcodes> otherBarcodesToInsert = productsToInsert
          //     .expand((product) => product.otherBarcode!)
          //     .toList();

          // //convertir el mapap en una lista de productos unicos de paquetes que se encuentra en un pedido dentro de listado de paquetes y listado de productos
          // List<ProductoPedido> productsPackagesToInsert = pedidosToInsert
          //     .expand((pedido) => pedido.listaPaquetes!)
          //     .expand((paquete) => paquete.listaProductosInPacking!)
          //     .toList();

          // //covertir el mapa en una lista de los paquetes de un pedido
          // List<Paquete> packagesToInsert = pedidosToInsert
          //     .expand((pedido) => pedido.listaPaquetes!)
          //     .toList();

          // // Enviar la lista agrupada de productos de un batch para packing
          // await DataBaseSqlite()
          //     .pedidosPackingRepository
          //     .insertPedidosBatchPacking(pedidosToInsert, 'packing-batch');
          // // Enviar la lista agrupada de productos de un pedido para packing
          // await DataBaseSqlite()
          //     .productosPedidosRepository
          //     .insertProductosPedidos(productsToInsert, 'packing-batch');
          // // Enviar la lista agrupada de barcodes de un producto para packing
          // await DataBaseSqlite()
          //     .barcodesPackagesRepository
          //     .insertOrUpdateBarcodes(barcodesToInsert, 'packing-batch');
          // // Enviar la lista agrupada de otros barcodes de un producto para packing
          // await DataBaseSqlite()
          //     .barcodesPackagesRepository
          //     .insertOrUpdateBarcodes(otherBarcodesToInsert, 'packing-batch');
          // //guardamos los productos de los paquetes que ya fueron empaquetados
          // await DataBaseSqlite()
          //     .productosPedidosRepository
          //     .insertProductosOnPackage(
          //         productsPackagesToInsert, 'packing-batch');
          // //enviamos la lista agrupada de los paquetes de un pedido para packing
          // await DataBaseSqlite()
          //     .packagesRepository
          //     .insertPackages(packagesToInsert, 'packing-batch');

          //creamos las cajas que ya estan creadas

          // //* Carga los batches desde la base de datos
          add(LoadPackingPedidoFromDBEvent());
        }

        emit(WmsPackingPedidoWMSLoaded(
          listOfPedidos: listOfPedidos,
        ));
      } else {
        print('Error resBatchs: response is null');
      }
    } catch (e, s) {
      print('Error en el  _onLoadAllPackingEvent: $e, $s');
      emit(PackingPedidoError(e.toString()));
    }
  }

  void _onLoadPackingPedidoFromDBEvent(LoadPackingPedidoFromDBEvent event,
      Emitter<PackingPedidoState> emit) async {
    try {
      emit(PackingPedidoLoadingState());
      final batchsFromDB = await db.pedidoPackRepository.getAllPedidosPack();
      listOfPedidosBD.clear();
      listOfPedidosBD = batchsFromDB;
      listOfPedidosFilters.clear();
      listOfPedidosFilters = List.from(listOfPedidosBD);
      emit(PackingPedidoLoadedFromDBState(listOfPedidos: listOfPedidosBD));
    } catch (e, s) {
      print('Error en el  _onLoadBatchsFromDBEvent: $e, $s');
      emit(PackingPedidoError(e.toString()));
    }
  }
}
