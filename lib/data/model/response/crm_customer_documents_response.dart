class CrmCustomerDocument {
  String? id;
  String? fileName;
  String? contentType;
  String? url;
  String? type;

  CrmCustomerDocument();

  CrmCustomerDocument.fromJson(Map<String, dynamic> json, {String? type}) {
    id = json['id']?.toString();
    fileName = json['file_name']?.toString();
    contentType = json['content_type']?.toString();
    url = json['url']?.toString();
    this.type = type;
  }

  String get displayType {
    final value = type?.trim() ?? '';
    if (value.isEmpty) return '';
    return value[0].toUpperCase() + value.substring(1);
  }
}

class CrmCustomerDocumentsResponse {
  List<CrmCustomerDocument> documents = [];

  CrmCustomerDocumentsResponse();

  CrmCustomerDocumentsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final rawDocs = data is Map<String, dynamic> ? data['documents'] : null;
    if (rawDocs is Map<String, dynamic>) {
      rawDocs.forEach((key, value) {
        if (value is List) {
          for (final item in value) {
            if (item is Map<String, dynamic>) {
              documents.add(CrmCustomerDocument.fromJson(item, type: key));
            }
          }
        }
      });
    }
  }
}
