import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/transferencias/data/transferencias_repository.dart';
import 'package:wms_app/src/presentation/views/transferencias/models/response_transferencias.dart';
import 'package:wms_app/src/presentation/views/user/models/configuration.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';
import 'package:wms_app/src/utils/prefs/pref_utils.dart';

part 'transferencia_event.dart';
part 'transferencia_state.dart';

class TransferenciaBloc extends Bloc<TransferenciaEvent, TransferenciaState> {
  //*controller de busqueda
  TextEditingController searchControllerTransfer = TextEditingController();
  //*variables para validar
  bool isKeyboardVisible = false;

  //*repositorio
  final TransferenciasRepository _transferenciasRepository =
      TransferenciasRepository();

  //*base de datos
  DataBaseSqlite db = DataBaseSqlite();

  //*configuracion del usuario //permisos
  Configurations configurations = Configurations();

  //lista de transferencias
  List<ResultTransFerencias> transferencias = [];
  List<ResultTransFerencias> transferenciasDB = [];
  List<ResultTransFerencias> transferenciasDbFilters = [];


  List<LineasTransferenciaTrans> listProductsTransfer = [];


  //tranferencia actual
  ResultTransFerencias currentTransferencia = ResultTransFerencias();

  TransferenciaBloc() : super(TransferenciaInitial()) {
    on<TransferenciaEvent>((event, emit) {});
    //metodo para obtener todas las transferencias
    on<FetchAllTransferencias>(_onfetchTransferencias);
    //metodo para obtener todas las transferencias de la base de datos
    on<FetchAllTransferenciasDB>(_onfetchTransferenciasDB);
    //metodo para cargar la transferencia actual
    on<CurrentTransferencia>(_oncurrentTransferencia);

    // buscar una orden de compra
    on<SearchTransferEvent>(_onSearchOrderEvent);

    //activar el teclado
    on<ShowKeyboardEvent>(_onShowKeyboardEvent);

    //*obtener las configuraciones y permisos del usuario desde la bd
    on<LoadConfigurationsUserTransfer>(_onLoadConfigurationsUserEvent);

       //*obtener todos los productos de una transferencia
    on<GetPorductsToTransfer>(_onGetProductsToTransfer);
  }




  //*metodo para obtener los productos de una entrada por id
  void _onGetProductsToTransfer(
      GetPorductsToTransfer event, Emitter<TransferenciaState> emit) async {
    try {
      emit(GetProductsToTransferLoading());
      final response = await db.productTransferenciaRepository
          .getProductsByTrasnferId(event.idTransfer);

      listProductsTransfer = [];
      listProductsTransfer = response;
      print('listProductsTransfer: ${listProductsTransfer.length}');
      emit(GetProductsToTransferSuccess(listProductsTransfer));
        } catch (e, s) {
      print('Error en el _onGetProductsToTrasnfer: $e, $s');
    }
  }



  void _onLoadConfigurationsUserEvent(LoadConfigurationsUserTransfer event,
      Emitter<TransferenciaState> emit) async {
    try {
      int userId = await PrefUtils.getUserId();
      final response =
          await db.configurationsRepository.getConfiguration(userId);

      if (response != null) {
        configurations = response;
        emit(ConfigurationLoadedOrder(response));
      } else {
        emit(ConfigurationErrorOrder('Error al cargar configuraciones'));
      }
    } catch (e, s) {
      emit(ConfigurationErrorOrder(e.toString()));
      print('Error en LoadConfigurationsUserPack.dart: $e =>$s');
    }
  }

  //metodo para buscar una transferencia
  void _onSearchOrderEvent(
      SearchTransferEvent event, Emitter<TransferenciaState> emit) async {
    try {
      transferenciasDbFilters = [];
      transferenciasDbFilters = transferencias;

      final query = event.query.toLowerCase();

      if (query.isNotEmpty) {
        transferenciasDbFilters = transferenciasDbFilters
            .where((element) => element.name!.contains(query))
            .toList();
      } else {
        transferenciasDbFilters = transferencias;
      }
      emit(SearchTransferenciasSuccess(transferenciasDbFilters));
    } catch (e, s) {
      print('Error en el fetch de transferencias: $e=>$s');
    }
  }

  //*metodo para ocultar y mostrar el teclado
  void _onShowKeyboardEvent(
      ShowKeyboardEvent event, Emitter<TransferenciaState> emit) {
    isKeyboardVisible = event.showKeyboard;
    emit(ShowKeyboardState(showKeyboard: isKeyboardVisible));
  }

  //metodo para obtener todas las transferencias de la base de datos

  void _onfetchTransferenciasDB(
      FetchAllTransferenciasDB event, Emitter<TransferenciaState> emit) async {
    try {
      emit(TransferenciaLoading());

      transferenciasDB.clear();
      transferenciasDbFilters.clear();
      final response = await db.transferenciaRepository.getAllTransferencias();
      if (response.isNotEmpty) {
        transferenciasDB = response;
        transferenciasDbFilters = response;
        emit(TransferenciaBDLoaded(transferenciasDB));
      } else {
        emit(TransferenciaError('No se encontraron transferencias'));
      }
    } catch (e, s) {
      print('Error en el fetch de transferencias: $e=>$s');
    }
  }

  //metodo para cargar la transferencia actual
  _oncurrentTransferencia(
      CurrentTransferencia event, Emitter<TransferenciaState> emit) async {
    try {
      emit(CurrentTransferenciaLoading());
      currentTransferencia = ResultTransFerencias();

      final responseTransfer = await db.transferenciaRepository
          .getTransferenciaById(event.trasnferencia.id ?? 0);
      currentTransferencia = responseTransfer ?? ResultTransFerencias();

      print("-----------------");
      print(currentTransferencia.toMap());
      print("-----------------");
      emit(CurrentTransferenciaLoaded());
    } catch (e, s) {
      print('Error en el fetch de transferencias: $e=>$s');
    }
  }

  //metodo para traer todas las transferencias
  _onfetchTransferencias(
      FetchAllTransferencias event, Emitter<TransferenciaState> emit) async {
    try {
      emit(TransferenciaLoading());
      transferencias.clear();
      final response =
          await _transferenciasRepository.fetAllTransferencias(true);
      if (response.isNotEmpty) {
        await db.transferenciaRepository.insertEntrada(response);

        // Convertir el mapa en una lista de productos únicos con cantidades sumadas
        List<LineasTransferenciaTrans> productsToInsert =
            response.expand((batch) => batch.lineasTransferencia!).toList();
        //Convertir el mapa en una lista los productos ya enviados
        List<LineasTransferenciaTrans> productsSedToInsert = response
            .expand((batch) => batch.lineasTransferenciaEnviadas!)
            .toList();
        //Convertir el mapa en una lista los barcodes unicos de cada producto
        List<Barcodes> barcodesToInsert = productsToInsert
            .expand((product) => product.otherBarcodes!)
            .toList();
        //convertir el mapap en una lsita de los otros barcodes de cada producto
        List<Barcodes> otherBarcodesToInsert = productsToInsert
            .expand((product) => product.productPacking!)
            .toList();

        print('trasnfer productsToInsert: ${productsToInsert.length}');
        print('trasnfer productsSedToInsert: ${productsSedToInsert.length}');
        print('trasnfer barcodesToInsert: ${barcodesToInsert.length}');
        print(
            'trasnfer otherBarcodesToInsert: ${otherBarcodesToInsert.length}');

        // Enviar la lista agrupada a insertBatchProducts
        await db.productTransferenciaRepository
            .insertarProductoEntrada(productsToInsert);
        //productos de la transferencia enviados
        await db.productTransferenciaRepository
            .insertarProductoEntrada(productsSedToInsert);

        // Enviar la lista agrupada de barcodes de un producto para packing
        await db.barcodesPackagesRepository
            .insertOrUpdateBarcodes(barcodesToInsert);
        // Enviar la lista agrupada de otros barcodes de un producto para packing
        await db.barcodesPackagesRepository
            .insertOrUpdateBarcodes(otherBarcodesToInsert);

        transferencias = response;
        emit(TransferenciaLoaded(transferencias));
      } else {
        emit(TransferenciaError('No se encontraron transferencias'));
      }
    } catch (e, s) {
      print('Error en el fetch de transferencias: $e=>$s');
    }
  }
}
