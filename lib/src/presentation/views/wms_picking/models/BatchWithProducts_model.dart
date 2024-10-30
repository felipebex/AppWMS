// ignore_for_file: file_names

import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/products_batch_model.dart';

class BatchWithProducts {
  final BatchsModel? batch;
  final List<ProductsBatch>? products;

  BatchWithProducts({ this.batch,  this.products});
}