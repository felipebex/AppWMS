// ignore_for_file: file_names

import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Pick/models/response_pick_model.dart';

class PickWithProducts {
  late  ResultPick? pick;
  late  List<ProductsBatch>? products;

  PickWithProducts({ this.pick,  this.products});
}