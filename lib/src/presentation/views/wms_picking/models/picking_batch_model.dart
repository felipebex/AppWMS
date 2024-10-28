class BatchsModel {
  final int? id;
  final String? name;
  final String? scheduledDate; // Cambiado a String?
  final dynamic
      pickingTypeId; // Esto puede permanecer como dynamic o cambiar a int si estás seguro
  final String? state;
  final dynamic userId;
  final int? indexList;
  final dynamic isWave;
  final dynamic isSeparate;
  final dynamic isSelected;

  final int? productSeparateQty; //cantidad que se lleva separada
  final int? productQty; //cantidad total del producto separada
  final String? timeSeparateTotal;
  final String? timeSeparateStart;

  final String? isSendOdoo;
  final String? isSendOdooDate;
  final String? observation;

  BatchsModel({
    this.id,
    this.name,
    this.scheduledDate,
    this.pickingTypeId,
    this.state,
    this.userId,
    this.indexList,
    this.isWave,
    this.isSeparate,
    this.isSelected,
    this.productSeparateQty,
    this.productQty,
    this.timeSeparateTotal,
    this.timeSeparateStart,
    this.isSendOdoo,
    this.isSendOdooDate,
    this.observation,
  });

  factory BatchsModel.fromJson(Map<String, dynamic> json) {
    return BatchsModel(
      id: json['id'],
      name: json['name'].toString(),
      scheduledDate: json['scheduled_date'] is String
          ? json['scheduled_date']
          : null, // o 'no scheduled'
      pickingTypeId:
          json['picking_type_id'] is List ? json['picking_type_id'][0] : null,
      state: json['state'],
      userId: json['user_id'] is List ? json['user_id'][0] : null,
      indexList: json['index_list'],
      isWave: json['is_wave'],
      isSeparate: json['is_separate'],
      isSelected: json['is_selected'],
      productSeparateQty: json['product_separate_qty'],
      productQty: json['product_qty'],
      timeSeparateTotal: json['time_separate_total'],
      timeSeparateStart: json['time_separate_start'],
      isSendOdoo: json['is_send_oddo'],
      isSendOdooDate: json['is_send_oddo_date'],
      observation: json['observation'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'scheduled_date': scheduledDate ?? false, // Asigna false si es null
      'picking_type_id': pickingTypeId,
      'state': state,
      'user_id': userId,
      'is_wave': isWave,
      'index_list': indexList,
      'is_separate': isSeparate,
      'is_selected': isSelected,
      'product_separate_qty': productSeparateQty,
      'product_qty': productQty,
      'time_separate_total': timeSeparateTotal,
      'time_separate_start': timeSeparateStart,
      'is_send_oddo': isSendOdoo,
      'is_send_oddo_date': isSendOdooDate,
      'observation': observation,
    };
  }

  factory BatchsModel.fromMap(Map<String, dynamic> map) {
    return BatchsModel(
      id: map['id'],
      name: map['name'].toString(),
      scheduledDate: map['scheduled_date'] is String
          ? map['scheduled_date']
          : null, // o algún valor predeterminado como 'no scheduled'
      pickingTypeId:
          map['picking_type_id'], // Asegúrate de que sea de tipo esperado
      state: map['state'],
      userId: map['user_id'],
      indexList: map['index_list'],
      isWave: map['is_wave'],
      isSeparate: map['is_separate'],
      isSelected: map['is_selected'],
      productSeparateQty: map['product_separate_qty'],
      productQty: map['product_qty'],
      timeSeparateTotal: map['time_separate_total'],
      timeSeparateStart: map['time_separate_start'],
      isSendOdoo: map['is_send_oddo'],
      isSendOdooDate: map['is_send_oddo_date'],
      observation: map['observation'],
    );
  }
}
