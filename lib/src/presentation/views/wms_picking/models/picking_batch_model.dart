class BatchsModel {
  final int? id;
  final String? name;
  final String? scheduledDate; // Cambiado a String?
  final dynamic pickingTypeId; // Esto puede permanecer como dynamic o cambiar a int si estás seguro
  final String state;
  final dynamic userId;

  BatchsModel({
    required this.id,
    required this.name,
    required this.scheduledDate,
    required this.pickingTypeId,
    required this.state,
    required this.userId,
  });

  factory BatchsModel.fromJson(Map<String, dynamic> json) {
    return BatchsModel(
      id: json['id'],
      name: json['name'].toString(),
      scheduledDate: json['scheduled_date'] is String 
        ? json['scheduled_date'] 
        : null, // o 'no scheduled'
      pickingTypeId: json['picking_type_id'] is List ? json['picking_type_id'][0] : null,
      state: json['state'],
      userId: json['user_id'] is List ? json['user_id'][0] : null,
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
    };
  }

  factory BatchsModel.fromMap(Map<String, dynamic> map) {
  return BatchsModel(
    id: map['id'],
    name: map['name'].toString(),
    scheduledDate: map['scheduled_date'] is String 
        ? map['scheduled_date'] 
        : null, // o algún valor predeterminado como 'no scheduled'
    pickingTypeId: map['picking_type_id'], // Asegúrate de que sea de tipo esperado
    state: map['state'],
    userId: map['user_id'],
  );
}
}
