import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:wms_app/src/presentation/models/response_ubicaciones_model.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/info%20rapida/data/info_rapida_repository.dart';
import 'package:wms_app/src/presentation/views/info%20rapida/models/info_rapida_model.dart';
import 'package:wms_app/src/presentation/views/inventario/models/response_products_model.dart';

part 'info_rapida_event.dart';
part 'info_rapida_state.dart';

class InfoRapidaBloc extends Bloc<InfoRapidaEvent, InfoRapidaState> {
  final InfoRapidaRepository _infoRapidaRepository = InfoRapidaRepository();

  InfoRapidaResult infoRapidaResult = InfoRapidaResult();

  String scannedValue1 = '';

  //controller
  TextEditingController searchControllerLocation = TextEditingController();
  TextEditingController searchControllerProducts = TextEditingController();

  //*lista de ubicaciones
  List<ResultUbicaciones> ubicaciones = [];
  List<ResultUbicaciones> ubicacionesFilters = [];

  //*lista de productos
  List<Product> productos = [];
  List<Product> productosFilters = [];

  //*base de datos
  DataBaseSqlite db = DataBaseSqlite();

  bool isKeyboardVisible = false;

  InfoRapidaBloc() : super(InfoRapidaInitial()) {
    on<InfoRapidaEvent>((event, emit) {});

    //*evento para actualizar el valor del scan
    on<UpdateScannedValueEvent>(_onUpdateScannedValueEvent);
    on<ClearScannedValueEvent>(_onClearScannedValueEvent);

    on<GetInfoRapida>(_onGetInfoRapida);

    //metodo para buscar una ubicacion
    on<SearchLocationEvent>(_onSearchLocationEvent);

    //*activar el teclado
    on<ShowKeyboardEvent>(_onShowKeyboardEvent);

    //*metodo para cargar las ubicaciones
    on<GetListLocationsEvent>(_onLoadLocations);

    //*metodo para bucar un producto
    on<SearchProductEvent>(_onSearchProductEvent);

    on<GetProductsList>(_onGetProductsBD);
  }

  void _onGetProductsBD(
      GetProductsList event, Emitter<InfoRapidaState> emit) async {
    try {
      emit(GetProductsLoading());
      final response = await db.productoInventarioRepository.getAllProducts();
      productos.clear();
      productosFilters.clear();
      print('productos: ${response.length}');
      if (response.isNotEmpty) {
        productos = response;
        productosFilters = productos;

        emit(GetProductsSuccess(response));
      } else {
        emit(GetProductsFailure('No se encontraron productos'));
      }
    } catch (e, s) {
      emit(GetProductsFailure('Error al cargar los productos'));
      print('Error en el fetch de productos: $e=>$s');
    }
  }

  void _onSearchProductEvent(
      SearchProductEvent event, Emitter<InfoRapidaState> emit) async {
    try {
      emit(SearchLoading());
      productosFilters = [];
      productosFilters = productos;
      final query = event.query.toLowerCase();
      if (query.isEmpty) {
        productosFilters = productos;
      } else {
        productosFilters = productos.where((product) {
          return product.name?.toLowerCase().contains(query) ?? false;
        }).toList();
      }
      emit(SearchProductSuccess(productosFilters));
    } catch (e, s) {
      print('Error en el SearchLocationEvent: $e, $s');
      emit(SearchFailure(e.toString()));
    }
  }

  void _onLoadLocations(
      GetListLocationsEvent event, Emitter<InfoRapidaState> emit) async {
    try {
      emit(LoadLocationsLoading());
      final response = await db.ubicacionesRepository.getAllUbicaciones();
      ubicaciones.clear();
      ubicacionesFilters.clear();
      print('ubicaciones length: ${ubicaciones.length}');
      if (response.isNotEmpty) {
        ubicaciones = response;
        ubicacionesFilters = ubicaciones;
        print('ubicaciones length: ${ubicaciones.length}');
        emit(LoadLocationsSuccess(ubicaciones));
      } else {
        print('No se encontraron ubicaciones');
        emit(LoadLocationsFailure('No se encontraron ubicaciones'));
      }
    } catch (e, s) {
      emit(LoadLocationsFailure('Error al cargar las ubicaciones'));
      print('Error en el fetch de ubicaciones: $e=>$s');
    }
  }

  void _onShowKeyboardEvent(
      ShowKeyboardEvent event, Emitter<InfoRapidaState> emit) {
    isKeyboardVisible = event.showKeyboard;
    emit(ShowKeyboardState(showKeyboard: isKeyboardVisible));
  }

  void _onSearchLocationEvent(
      SearchLocationEvent event, Emitter<InfoRapidaState> emit) async {
    try {
      emit(SearchLoading());
      ubicacionesFilters = [];
      ubicacionesFilters = ubicaciones;
      final query = event.query.toLowerCase();
      if (query.isEmpty) {
        ubicacionesFilters = ubicaciones;
      } else {
        ubicacionesFilters = ubicaciones.where((location) {
          return location.name?.toLowerCase().contains(query) ?? false;
        }).toList();
      }
      emit(SearchLocationSuccess(ubicacionesFilters));
    } catch (e, s) {
      print('Error en el SearchLocationEvent: $e, $s');
      emit(SearchFailure(e.toString()));
    }
  }

  void _onGetInfoRapida(
      GetInfoRapida event, Emitter<InfoRapidaState> emit) async {
    emit(InfoRapidaLoading());
    try {
      infoRapidaResult = InfoRapidaResult();
      InfoRapida infoRapida =
          await _infoRapidaRepository.getInfoQuick(false, event.barcode.trim());
      if (infoRapida.result?.code == 200) {
        infoRapidaResult = infoRapida.result!;
        emit(InfoRapidaLoaded(infoRapidaResult, infoRapida.result!.type!));
      } else {
        emit(InfoRapidaError());
      }
      add(ClearScannedValueEvent());
    } catch (e) {
      emit(InfoRapidaError());
    }
  }

  void _onUpdateScannedValueEvent(
      UpdateScannedValueEvent event, Emitter<InfoRapidaState> emit) {
    scannedValue1 += event.scannedValue.trim();
    print('scannedValue1: $scannedValue1');
    emit(UpdateScannedValueState(scannedValue1));
  }

  void _onClearScannedValueEvent(
      ClearScannedValueEvent event, Emitter<InfoRapidaState> emit) {
    scannedValue1 = '';
    emit(ClearScannedValueState());
  }
}
