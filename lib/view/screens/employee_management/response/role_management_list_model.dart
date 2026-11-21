// class RoleMnmgtListodel {
//   RoleMnmgtListodel({
//     required this.message,
//     required this.roles,
//   });

//   final String? message;
//   final List<Role> roles;

//   factory RoleMnmgtListodel.fromJson(Map<String, dynamic> json) {
//     return RoleMnmgtListodel(
//       message: json["message"],
//       roles: json["roles"] == null
//           ? []
//           : List<Role>.from(json["roles"]!.map((x) => Role.fromJson(x))),
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         "message": message,
//         "roles": roles.map((x) => x.toJson()).toList(),
//       };
// }

// class Role {
//   final int? id;
//   final String? name;
//   String parentRole;
//   final List<String> modules;
//   final int? status;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;

//   Role({
//     required this.id,
//     required this.name,
//     required this.parentRole,
//     required this.modules,
//     required this.status,
//     required this.createdAt,
//     required this.updatedAt,
//   });

//   factory Role.fromJson(Map<String, dynamic> json) {
//     return Role(
//       id: json["id"] ?? '',
//       name: json["name"] ?? '',
//       parentRole: json['parent_role'] ?? '',
//       modules: json["modules"] == null
//           ? []
//           : List<String>.from(json["modules"]!.map((x) => x)),
//       status: json["status"] ?? 0,
//       createdAt: json["created_at"] == null
//           ? null
//           : DateTime.parse(json["created_at"]),
//           updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "name": name,
//         "parent_role": parentRole,
//         "modules": modules.map((x) => x).toList(),
//         "status": status,
//       };
// }

class RoleMnmgtListodel {
  RoleMnmgtListodel({
    required this.message,
    required this.roles,
  });

  final String? message;
  final List<Role> roles;

  factory RoleMnmgtListodel.fromJson(Map<String, dynamic> json) {
    return RoleMnmgtListodel(
      message: json["message"],
      roles: json["roles"] == null
          ? []
          : List<Role>.from(json["roles"]!.map((x) => Role.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "message": message,
        "roles": roles.map((x) => x.toJson()).toList(),
      };
}

class Role {
  final int? id;
  final String? name;
  String parentRole;
  String roleMasterName;
  final int? roleMasterId;
  final int? totalModules;

  final List<String> modules;
  final int? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Newly added fields
  final List<String> coreModules;
  final Map<String, dynamic> additionalModules;
  final bool? isSystemRole;
  final bool? isEditable;
  final String? protectionLevel;

  Role({
    required this.id,
    required this.name,
    required this.parentRole,
    required this.roleMasterName,
    required this.roleMasterId,
    required this.totalModules,
    required this.modules,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.coreModules,
    required this.additionalModules,
    required this.isSystemRole,
    required this.isEditable,
    required this.protectionLevel,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json["id"] ?? 0,
      name: json["name"] ?? '',
      parentRole: json["parent_role"] ?? '',
      roleMasterName: json["role_master_name"] ?? '',
      roleMasterId: json["role_master_id"] ?? null,
      totalModules: json["total_modules"] ?? null,
      modules: json["modules"] == null
          ? []
          : List<String>.from(json["modules"]!.map((x) => x)),
      status: json["status"] ?? 0,
      createdAt: json["created_at"] == null
          ? null
          : DateTime.tryParse(json["created_at"]),
      updatedAt: json["updated_at"] == null
          ? null
          : DateTime.tryParse(json["updated_at"]),

      /// New fields parsing
      coreModules: json["core_modules"] == null
          ? []
          : List<String>.from(json["core_modules"]!.map((x) => x)),

      /// FIX: handle both {} and []
      additionalModules: (json["additional_modules"] != null &&
              json["additional_modules"] is Map)
          ? Map<String, dynamic>.from(json["additional_modules"])
          : <String, dynamic>{},

      isSystemRole: json["is_system_role"] ?? false,
      isEditable: json["is_editable"] ?? false,
      protectionLevel: json["protection_level"] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "parent_role": parentRole,
        "role_master_name": roleMasterName,
        "role_master_id": roleMasterId,
        "total_modules": totalModules,
        "modules": modules.map((x) => x).toList(),
        "status": status,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),

        /// New fields serialization
        "core_modules": coreModules.map((x) => x).toList(),
        "additional_modules": additionalModules,
        "is_system_role": isSystemRole,
        "is_editable": isEditable,
        "protection_level": protectionLevel,
      };
}