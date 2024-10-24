class Packing {
  final dynamic id;
  final dynamic name;
  final dynamic locationId;
  final dynamic locationDestId;
  final dynamic pickingTypeId;
  final dynamic parterId;
  final dynamic batchId;
  final dynamic state;
  final dynamic scheduledDate;
  final dynamic dateDeadline;
  final dynamic origin;
  final dynamic reasonReturn;

  Packing({
     this.id,
     this.name,
     this.locationId,
     this.locationDestId,
     this.pickingTypeId,
     this.parterId,
     this.batchId,
     this.state,
     this.scheduledDate,
     this.dateDeadline,
    this.origin,
    this.reasonReturn,
  });

  factory Packing.fromJson(Map<String, dynamic> json) {
    return Packing(
      id: json['id'],
      name: json['name'],
      locationId: json['location_id'],
      locationDestId: json['location_dest_id'],
      pickingTypeId: json['picking_type_id'],
      parterId: json['partner_id'],
      batchId: json['batch_id'],
      state: json['state'],
      scheduledDate:
          json['scheduled_date'] is String ? json['scheduled_date'] : null, //
      dateDeadline: json['date_deadline'] is String ? json['date_deadline'] : null,
      origin: json['origin'],
      reasonReturn: json['reason_return'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location_id': locationId,
      'location_dest_id': locationDestId,
      'partner_id': parterId,
      'picking_type_id':pickingTypeId,
      'batch_id': batchId,
      'state': state,
      'scheduled_date': scheduledDate ?? false, // Asigna false si es null
      'date_deadline': dateDeadline ?? false,
      'origin': origin,
      'reason_return': reasonReturn,
    };
  }

  factory Packing.fromMap(Map<String, dynamic> map) {
    return Packing(
      id: map['id'],
      name: map['name'],
      locationId: map['location_id'],
      locationDestId: map['location_dest_id'],
      parterId: map['partner_id'],
      pickingTypeId: map['picking_type_id'],
      batchId: map['batch_id'],
      state: map['state'],
      scheduledDate: map['scheduled_date'] is String
          ? map['scheduled_date']
          : null, // o algún

      dateDeadline: map['date_deadline'] is String ? map['date_deadline'] : null,
      origin: map['origin'],
      reasonReturn: map['reason_return'],
    );
  }
}
