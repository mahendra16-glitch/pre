class RoleDataModel {
  final List<RoleType> roleTypes;
  final RoleModules roleModules;

  RoleDataModel({
    required this.roleTypes,
    required this.roleModules,
  });

  factory RoleDataModel.fromJson(Map<String, dynamic> json) {
    return RoleDataModel(
      roleTypes: (json['role_types'] as List)
          .map((e) => RoleType.fromJson(e))
          .toList(),
      roleModules: RoleModules.fromJson(json['role_modules']),
    );
  }
}

class RoleType {
  final int id;
  final String name;
  final String roleTypeValue;
  final String? description;
  final String createdAt;

  RoleType({
    required this.id,
    required this.name,
    required this.roleTypeValue,
    this.description,
    required this.createdAt,
  });

  factory RoleType.fromJson(Map<String, dynamic> json) {
    return RoleType(
      id: json['id'],
      name: json['name'],
      roleTypeValue: json['role_type_value'],
      description: json['description'],
      createdAt: json['created_at'],
    );
  }
}

class RoleModules {
  // final List<RoleModule>? defaultModules;
  final List<RoleModule>? reportModules;
  final List<RoleModule>? frontendModules;
  final List<RoleModule>? backendModules;

  RoleModules({
    // this.defaultModules,
    this.reportModules,
    this.frontendModules,
    this.backendModules,
  });

  factory RoleModules.fromJson(Map<String, dynamic> json) {
    return RoleModules(
      // defaultModules:
      //     (json['default'] as List).map((e) => RoleModule.fromJson(e)).toList(),
      reportModules:
          (json['report'] as List).map((e) => RoleModule.fromJson(e)).toList(),
      frontendModules:
          (json['frontend'] as List).map((e) => RoleModule.fromJson(e)).toList(),
      backendModules:
          (json['backend'] as List).map((e) => RoleModule.fromJson(e)).toList(),
    );
  }
}

class RoleModule {
  final int id;
  final int? roleId;
  final String roleFor;
  final String name;
  final String rolePassValue;
  final String description;
  final String createdAt;

  RoleModule({
    required this.id,
    this.roleId,
    required this.roleFor,
    required this.name,
    required this.rolePassValue,
    required this.description,
    required this.createdAt,
  });

  factory RoleModule.fromJson(Map<String, dynamic> json) {
    return RoleModule(
      id: json['id'],
      roleId: json['role_id'],
      roleFor: json['role_for'],
      name: json['name'],
      rolePassValue: json['role_pass_value'],
      description: json['description'],
      createdAt: json['created_at'],
    );
  }
}
