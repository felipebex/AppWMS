import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/conteo/data/conteo_repository.dart';
import 'package:wms_app/src/presentation/views/conteo/models/conteo_response_model.dart';

part 'conteo_event.dart';
part 'conteo_state.dart';

class ConteoBloc extends Bloc<ConteoEvent, ConteoState> {
  final ConteoRepository _repository = ConteoRepository();
  //*base de datos
  DataBaseSqlite db = DataBaseSqlite();

  DatumConteo ordenConteo = DatumConteo();
  List<DatumConteo> ordenesDeConteo = [];
  List<CountedLine> lineasContadas = [];
  List<Allowed> ubicacionesConteo = [];
  List<Allowed> categoriasConteo = [];

  ConteoBloc() : super(ConteoInitial()) {
    //evento para obtener la lista de conteos
    on<GetConteosEvent>(_onGetConteosEvent);
    //evento para obtener la lista de conteos desde la bd
    on<GetConteosFromDBEvent>(_onGetConteosFromDBEvent);
    //evento para cargar un conteo especifico
    on<LoadConteoAndProductsEvent>(_onLoadConteoEvent);
  }

  void _onGetConteosFromDBEvent(
      GetConteosFromDBEvent event, Emitter<ConteoState> emit) async {
    emit(ConteoFromDBLoading());
    try {
      ordenesDeConteo.clear();
      final response = await db.ordenRepository.getAllOrdenes();

      if (response.isNotEmpty) {
        ordenesDeConteo = response;
        emit(ConteoFromDBLoaded(ordenesDeConteo));
      } else {
        emit(
            ConteoFromDBError("No se encontraron conteos en la base de datos"));
      }
    } catch (e, s) {
      print("Error al obtener los conteos desde la BD: $e, $s");
      emit(ConteoFromDBError("Error al obtener los conteos desde la BD: $e"));
    }
  }

  void _onLoadConteoEvent(
      LoadConteoAndProductsEvent event, Emitter<ConteoState> emit) async {
    try {
      //obtenemos la orden de conteo desde la bd
      ordenConteo =
          await db.ordenRepository.getOrdenById(event.ordenConteoId ?? 0) ??
              DatumConteo();
    
      //obtenemos las lineas contadas de esa orden de conteo
      lineasContadas = await db.productoOrdenConteoRepository.getProductosByOrderId(
          event.ordenConteoId ?? 0);

        
      //obtenemos las ubicaciones de esa orden de conteo
      ubicacionesConteo = await db.ubicacionesConteoRepository
          .getUbicacionesByOrdenId(event.ordenConteoId ?? 0);

      //obtenemos las categorias de esa orden de conteo
      categoriasConteo = await db.categoriasConteoRepository
          .getCategoriasByOrdenId(event.ordenConteoId ?? 0);


      print("Orden de conteo cargada: ${ordenConteo.name}");
      print("Total de lineas contadas: ${lineasContadas.length}");
      print("Total de ubicaciones: ${ubicacionesConteo.length}");
      print("Total de categorias: ${categoriasConteo.length}");

      emit(LoadConteoSuccess(ordenConteo));
    } catch (e, s) {
      print("Error al cargar el conteo: $e, $s");
      emit(ConteoError("Error al cargar el conteo: $e"));
    }
  }

  void _onGetConteosEvent(
      GetConteosEvent event, Emitter<ConteoState> emit) async {
    emit(ConteoLoading());
    try {
      final response = await _repository.fetchAllConteos(true);
      if (response.data?.isNotEmpty ?? false) {
        //agregamos esas ordenes a la bd
        await db.ordenRepository
            .insertOrUpdateOrdenes(response.data as List<DatumConteo>);

        //obtenemos los productos de todas las ordenes de conteo
        final productsToInsert =
            _getAllProducts(response.data as List<DatumConteo>)
                .toList(growable: false);

        await db.productoOrdenConteoRepository
            .upsertProductosOrdenConteo(productsToInsert);

        //obtenemos las ubicaciones de todas las ordenes de conteo
        final ubicacionesToInsert =
            _getAllUbicaciones(response.data as List<DatumConteo>)
                .toList(growable: false);

        await db.ubicacionesConteoRepository
            .upsertUbicacionesConteo(ubicacionesToInsert);  

        //obtenemos las categorias de todas las ordenes de conteo
        final categoriasToInsert =
            _getAllCategories(response.data as List<DatumConteo>)
                .toList(growable: false);

        await db.categoriasConteoRepository
            .upsertCategoriasConteo(categoriasToInsert);

        add(GetConteosFromDBEvent());
        emit(ConteoLoaded(response.data as List<DatumConteo>));
      } else {
        emit(ConteoError("No se encontraron conteos"));
      }
    } catch (e, s) {
      print("Error al obtener los conteos: $e, $s");
      emit(ConteoError("Error al obtener los conteos: $e"));
    }
  }

  Iterable<CountedLine> _getAllProducts(List<DatumConteo> ordenes) sync* {
    for (final orden in ordenes) {
      if (orden.countedLines != null) yield* orden.countedLines!;
    }
  }

  Iterable<Allowed> _getAllUbicaciones(List<DatumConteo> ordenes) sync* {
    for (final orden in ordenes) {
      if (orden.allowedLocations != null) yield* orden.allowedLocations!;
    }
  }
  Iterable<Allowed> _getAllCategories(List<DatumConteo> ordenes) sync* {
    for (final orden in ordenes) {
      if (orden.allowedCategories != null) yield* orden.allowedCategories!;
    }
  }




  
}
