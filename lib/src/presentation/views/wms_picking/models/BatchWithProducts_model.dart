// ignore_for_file: file_names

import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';

class BatchWithProducts {
  late final BatchsModel? batch;
  final List<ProductsBatch>? products;

  BatchWithProducts({ this.batch,  this.products});
}