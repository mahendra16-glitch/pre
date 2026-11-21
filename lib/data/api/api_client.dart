import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';
import 'dart:developer';
import 'package:mygenie_restaurant/data/model/response/error_response.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' as Foundation;
import 'package:http/http.dart' as Http;
import 'package:mime/mime.dart';

class ApiClient extends GetxService {
  final String appBaseUrl;
  final SharedPreferences sharedPreferences;
  static const String noInternetMessage = 'No Internet connection';
  final int timeoutInSeconds = 30;

  late String token;
  late Map<String, String> _mainHeaders;

  ApiClient({required this.appBaseUrl, required this.sharedPreferences}) {
    token = sharedPreferences.getString(AppConstants.TOKEN) ?? '';
    debugPrint('Token: $token');
    debugPrint(
        '====> CRM Token: ${sharedPreferences.getString(AppConstants.CRM_TOKEN)}');
    updateHeader(
        token, sharedPreferences.getString(AppConstants.LANGUAGE_CODE));
  }

  void updateHeader(String token, String? languageCode) {
    _mainHeaders = {
      'Content-Type': 'application/json; charset=UTF-8',
      AppConstants.LOCALIZATION_KEY:
          languageCode ?? AppConstants.languages[0].languageCode,
      'Authorization': 'Bearer $token'
    };
  }

  Map<String, String> get _crmHeaders => {
        'X-API-Key': sharedPreferences.getString(AppConstants.CRM_TOKEN) ?? '',
        'Accept': 'application/json',
      };

  Future<Response> getData(String uri,
      {Map<String, dynamic>? query, Map<String, String>? headers}) async {
    try {
      debugPrint('====> API Base URL: $appBaseUrl');
      debugPrint('====> API Call: $uri\nHeader: ${headers ?? _mainHeaders}');
      Uri url = Uri.parse(appBaseUrl + uri);
      if (query != null && query.isNotEmpty) {
        url = url.replace(queryParameters: {
          ...url.queryParameters,
          ...query.map((k, v) => MapEntry(k, v.toString()))
        });
      }
      Http.Response _response = await Http.get(
        url,
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));

      return handleResponse(_response, uri);
    } on TimeoutException catch (_) {
      try {
        debugPrint('====> Retry API Call after Timeout: $uri');
        Get.snackbar('Retry', 'Retry API Call after Timeout: $uri',
            colorText: Colors.white, backgroundColor: Colors.red);
        Uri url = Uri.parse(appBaseUrl + uri);
        if (query != null && query.isNotEmpty) {
          url = url.replace(queryParameters: {
            ...url.queryParameters,
            ...query.map((k, v) => MapEntry(k, v.toString()))
          });
        }
        Http.Response _retryResponse = await Http.get(
          url,
          headers: headers ?? _mainHeaders,
        ).timeout(Duration(seconds: timeoutInSeconds));

        return handleResponse(_retryResponse, uri);
      } catch (e) {
        return Response(
            statusCode: 1, statusText: 'Retry failed: ${e.toString()}');
      }
    } catch (e) {
      return Response(statusCode: 1, statusText: e.toString());
    }
  }

  Future<Response> postData(String uri, dynamic body,
      {Map<String, String>? headers, int? timeout}) async {
    try {
      debugPrint('====> API Base URL: $appBaseUrl');
      debugPrint('====> API Call: $uri\nHeader: $_mainHeaders');
      debugPrint('====> API Body: $body');
      Http.Response _response = await Http.post(
        Uri.parse(appBaseUrl + uri),
        body: jsonEncode(body),
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeout ?? timeoutInSeconds));

      return handleResponse(_response, uri);
    } on TimeoutException catch (_) {
      try {
        debugPrint('====> Retry API Call after Timeout: $uri');
        Get.snackbar(
            'Retry', 'Retry API Call after Timeout $timeoutInSeconds sec: $uri',
            colorText: Colors.white, backgroundColor: Colors.red);

        Http.Response _retryResponse = await Http.post(
          Uri.parse(appBaseUrl + uri),
          body: jsonEncode(body),
          headers: headers ?? _mainHeaders,
        ).timeout(Duration(seconds: timeoutInSeconds));

        return handleResponse(_retryResponse, uri);
      } catch (e) {
        return Response(
            statusCode: 1, statusText: 'Retry failed: ${e.toString()}');
      }
    } catch (e) {
      return Response(statusCode: 1, statusText: e.toString());
    }
  }

  Future<Response> postMultipartData(
      String uri, Map<String, String> body, List<MultipartBody> multipartBody,
      {Map<String, String>? headers}) async {
    try {
      debugPrint('====> API Base URL: $appBaseUrl');
      debugPrint('====> API Call: $uri\nHeader: $_mainHeaders');
      debugPrint('====> API Body: $body');
      var request = Http.MultipartRequest('POST', Uri.parse(appBaseUrl + uri));
      request.headers.addAll(headers ?? _mainHeaders);

      for (MultipartBody multipart in multipartBody) {
        if (multipart.file != null && multipart.file!.path.isNotEmpty) {
          if (Foundation.kIsWeb) {
            Uint8List bytes = await multipart.file!.readAsBytes();
            var multipartFile = Http.MultipartFile.fromBytes(
              multipart.key!,
              bytes,
              filename: basename(multipart.file!.path),
              contentType: MediaType('image', 'jpg'),
            );
            request.files.add(multipartFile);
          } else {
            var file = File(multipart.file!.path);
            var multipartFile = await Http.MultipartFile.fromPath(
              multipart.key!,
              file.path,
              contentType: MediaType('image', 'jpg'),
            );
            request.files.add(multipartFile);
          }
        } else if (multipart.audioFile != null &&
            multipart.audioFile!.path.isNotEmpty) {
          var audioFile = multipart.audioFile;
          var multipartFile = await Http.MultipartFile.fromPath(
            multipart.key!,
            audioFile!.path,
            contentType: MediaType('audio', 'mpeg'),
          );
          request.files.add(multipartFile);
        }
      }

      request.fields.addAll(body);
      log('====> API Call: $uri\nHeader: $body');
      var streamedResponse = await request.send();
      var response = await Http.Response.fromStream(streamedResponse);
      return handleResponse(response, uri);
    } catch (e) {
      return Response(statusCode: 1, statusText: e.toString());
    }
  }

  Future<Response> putData(String uri, dynamic body,
      {Map<String, String>? headers}) async {
    try {
      debugPrint('====> API Base URL: $appBaseUrl');
      debugPrint('====> API Call: $uri\nHeader: $_mainHeaders');
      debugPrint('====> API Body: $body');
      Http.Response response = await Http.put(
        Uri.parse(appBaseUrl + uri),
        body: jsonEncode(body),
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri);
    } catch (e) {
      // Optionally show error toast here
      return Response(statusCode: 1, statusText: e.toString());
    }
  }

  Future<Response> deleteData(String uri,
      {Map<String, String>? headers}) async {
    try {
      debugPrint('====> API Base URL: $appBaseUrl');
      debugPrint('====> API Call: $uri\nHeader: $_mainHeaders');
      Http.Response _response = await Http.delete(
        Uri.parse(appBaseUrl + uri),
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(_response, uri);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> deleteWData(String uri,
      {Map<String, String>? headers, dynamic body}) async {
    try {
      debugPrint('====> API Base URL: $appBaseUrl');
      log('Token :$token');
      debugPrint('====> API Call: $uri\nHeader: $_mainHeaders');
      Http.Response _response = await Http.delete(Uri.parse(appBaseUrl + uri),
              headers: headers ?? _mainHeaders, body: jsonEncode(body))
          .timeout(Duration(seconds: timeoutInSeconds ?? 0));
      return handleResponse(_response, uri);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Response handleResponse(Http.Response response, String uri) {
    dynamic _body;
    try {
      _body = jsonDecode(response.body);
    } catch (e) {}
    Response _response = Response(
      body: _body ?? response.body,
      bodyString: response.body.toString(),
      headers: response.headers,
      statusCode: response.statusCode,
      statusText: response.reasonPhrase,
    );
    if (_response.statusCode != 200 &&
        _response.body != null &&
        _response.body is! String) {
      if (_response.body.toString().startsWith('{errors: [{code:')) {
        ErrorResponse _errorResponse = ErrorResponse.fromJson(_response.body);
        _response = Response(
            statusCode: _response.statusCode,
            body: _response.body,
            statusText: _errorResponse.errors[0].message);
      } else if (_response.body.toString().startsWith('{message')) {
        _response = Response(
            statusCode: _response.statusCode,
            body: _response.body,
            statusText: _response.body['message']);
      } else if (_response.body.toString().startsWith('{errors: {message:')) {
        _response = Response(
            statusCode: _response.statusCode,
            body: _response.body,
            statusText: _response.body['errors']['message']);
      } else if (_response.body.toString().startsWith('{error:')) {
        _response = Response(
            statusCode: _response.statusCode,
            body: _response.body,
            statusText: _response.body['error']);
      }
    } else if (_response.statusCode != 200 && _response.body == null) {
      _response = Response(statusCode: 0, statusText: noInternetMessage);
    }
    debugPrint(
        '====> API Response: [${_response.statusCode}] $uri\n${_response.body}');
    return _response;
  }

  Future<Response> postFromData(
    String uri,
    Map<String, String> body,
    String keyFileName,
    String? filePath, {
    Map<String, String>? headers,
  }) async {
    try {
      log('Token :$token');
      final request =
          Http.MultipartRequest('POST', Uri.parse(appBaseUrl + uri));

      // Merge headers and remove content-type
      final Map<String, String> finalHeaders =
          Map.from(headers ?? _mainHeaders);
      finalHeaders.remove('Content-Type'); // Let MultipartRequest handle it
      request.headers.addAll(finalHeaders);

      // Check file path
      if (filePath == null || filePath.isEmpty) {
        throw Exception('File path is required for uploading.');
      }

      // Add PDF file
      final file = File(filePath);
      final pdfFile = await Http.MultipartFile.fromPath(
        keyFileName,
        filePath,
        contentType: MediaType('application', 'pdf'),
        filename: basename(file.path),
      );
      request.files.add(pdfFile);

      // Add form fields
      request.fields.addAll(body);

      // Send and get response
      final streamResponse = await request.send();
      final response = await Http.Response.fromStream(streamResponse);

      return handleResponse(response, uri);
    } catch (e) {
      debugPrint('====> postFromData error: $e');
      return Response(statusCode: -1, statusText: e.toString());
    }
  }

  Future<Response> postFoodInfoWithImage(
    String uri,
    Map<String, String> body,
    XFile? imageFile,
  ) async {
    try {
      log('Token : $token');
      log('API URI: $uri');
      log('Request Body: $body');

      final request =
          Http.MultipartRequest('POST', Uri.parse(appBaseUrl + uri));

      final headers = Map<String, String>.from(_mainHeaders);
      headers.remove('Content-Type');
      request.headers.addAll(headers);

      request.fields.addAll(body);

      if (imageFile != null &&
          imageFile.path.isNotEmpty &&
          await File(imageFile.path).exists()) {
        final imageMultipart = Http.MultipartFile(
          'image',
          File(imageFile.path).readAsBytes().asStream(),
          await File(imageFile.path).length(),
          filename: imageFile.path.split('/').last,
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(imageMultipart);
      }

      final streamResponse = await request.send();
      final response = await Http.Response.fromStream(streamResponse);

      return handleResponse(response, uri);
    } catch (e) {
      debugPrint('postFoodInfoWithImage error: $e');
      return Response(statusCode: -1, statusText: e.toString());
    }
  }

  Future<Response> postAggrFoodInfoWithImage(
    String uri,
    Map<String, String> body,
    XFile? imageFile1,
    XFile? imageFile2,
  ) async {
    try {
      log('Token : $token');
      log('API URI: $uri');
      log('Request Body: $body');

      final request =
          Http.MultipartRequest('POST', Uri.parse(appBaseUrl + uri));

      final headers = Map<String, String>.from(_mainHeaders);
      headers.remove('Content-Type');
      request.headers.addAll(headers);

      request.fields.addAll(body);

      if (imageFile1 != null &&
          imageFile1.path.isNotEmpty &&
          await File(imageFile1.path).exists()) {
        final imageMultipart = Http.MultipartFile(
          'image',
          File(imageFile1.path).readAsBytes().asStream(),
          await File(imageFile1.path).length(),
          filename: imageFile1.path.split('/').last,
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(imageMultipart);
      }
      if (imageFile2 != null &&
          imageFile2.path.isNotEmpty &&
          await File(imageFile2.path).exists()) {
        final mimeType = lookupMimeType(imageFile2.path); // e.g., "image/png"
        final mimeSplit = mimeType?.split('/') ?? ['image', 'jpeg'];

        final imageMultipart = Http.MultipartFile(
          'swiggy_image',
          File(imageFile2.path).readAsBytes().asStream(),
          await File(imageFile2.path).length(),
          filename: imageFile2.path.split('/').last,
          contentType: MediaType(mimeSplit[0], mimeSplit[1]),
        );

        request.files.add(imageMultipart);
      }

      final streamResponse = await request.send();
      final response = await Http.Response.fromStream(streamResponse);

      return handleResponse(response, uri);
    } catch (e) {
      debugPrint('postFoodInfoWithImage error: $e');
      return Response(statusCode: -1, statusText: e.toString());
    }
  }

  Future<Response> updateFoodInfoWithImage(
    String uri,
    Map<String, String> body,
    XFile? imageFile1,
    XFile? imageFile2,
  ) async {
    try {
      log('Token : $token');
      log('API URI: $uri');
      log('Request Body: $body');

      final request =
          Http.MultipartRequest('POST', Uri.parse(appBaseUrl + uri));

      final headers = Map<String, String>.from(_mainHeaders);
      headers.remove('Content-Type');
      request.headers.addAll(headers);

      request.fields.addAll(body);

      if (imageFile1 != null &&
          imageFile1.path.isNotEmpty &&
          await File(imageFile1.path).exists()) {
        final imageMultipart = Http.MultipartFile(
          'image',
          File(imageFile1.path).readAsBytes().asStream(),
          await File(imageFile1.path).length(),
          filename: imageFile1.path.split('/').last,
          contentType: MediaType('image', 'jepg'),
        );
        request.files.add(imageMultipart);
      }
      if (imageFile2 != null &&
          imageFile2.path.isNotEmpty &&
          await File(imageFile2.path).exists()) {
        final imageMultipart = Http.MultipartFile(
          'swiggy_image',
          File(imageFile2.path).readAsBytes().asStream(),
          await File(imageFile2.path).length(),
          filename: imageFile2.path.split('/').last,
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(imageMultipart);
      }

      // log("🚀 Sending multipart with fields: ${request.fields}");
      // log("🚀 Sending file: ${imageFile!.path}");
      final streamResponse = await request.send();
      final response = await Http.Response.fromStream(streamResponse);

      return handleResponse(response, uri);
    } catch (e) {
      debugPrint('postFoodInfoWithImage error: $e');
      return Response(statusCode: -1, statusText: e.toString());
    }
  }

  Future<Response> postRestaurantSetting(
    String uri,
    Map<String, String> body,
    XFile? image,
    XFile? pdf,
  ) async {
    try {
      log('API URI: $uri');
      log('Request Body: $body');

      final request = Http.MultipartRequest(
        'POST',
        Uri.parse(appBaseUrl + uri),
      );

      // ---- Headers ----
      final headers = Map<String, String>.from(_mainHeaders);
      headers.remove('Content-Type');
      request.headers.addAll(headers);

      // ---- Fields ----
      request.fields.addAll(body);

      // ---- Image file ----
      if (image != null && image.path.isNotEmpty) {
        final file = File(image.path);
        if (await file.exists()) {
          request.files.add(
            Http.MultipartFile(
              'image',
              file.readAsBytes().asStream(),
              await file.length(),
              filename: file.uri.pathSegments.last,
              contentType: MediaType('image', 'jpeg'),
            ),
          );
        }
      }

      // ---- PDF file ----
      if (pdf != null && pdf.path.isNotEmpty) {
        final file = File(pdf.path);
        if (await file.exists()) {
          final mimeType = lookupMimeType(pdf.path) ?? 'application/pdf';
          final mimeSplit = mimeType.split('/');
          request.files.add(
            Http.MultipartFile(
              'pdf_menu',
              file.readAsBytes().asStream(),
              await file.length(),
              filename: file.uri.pathSegments.last,
              contentType: MediaType(mimeSplit[0], mimeSplit[1]),
            ),
          );
        }
      }

      // ---- Send ----
      final streamed = await request.send();
      final response = await Http.Response.fromStream(streamed);

      // Handle your API’s Response (GetX Response wrapper)
      return handleResponse(response, uri);
    } catch (e, st) {
      debugPrint('postRestaurantSetting error: $e\n$st');
      return Response(statusCode: -1, statusText: e.toString());
    }
  }

  Future<Response> postCategoryWithImage(
    String uri,
    Map<String, String> body,
    XFile? image,
  ) async {
    try {
      log('API URI: $uri');
      log('Request Body: $body');

      final request = Http.MultipartRequest(
        'POST',
        Uri.parse(appBaseUrl + uri),
      );

      // Headers
      final headers = Map<String, String>.from(_mainHeaders);
      headers.remove('Content-Type');
      request.headers.addAll(headers);

      // Fields
      request.fields.addAll(body);

      // Image file (optional)
      if (image != null && image.path.isNotEmpty) {
        final file = File(image.path);
        if (await file.exists()) {
          final mimeType = lookupMimeType(image.path) ?? 'image/jpeg';
          final mimeSplit = mimeType.split('/');

          request.files.add(
            Http.MultipartFile(
              'image', // API field name
              file.readAsBytes().asStream(),
              await file.length(),
              filename: file.uri.pathSegments.last,
              contentType: MediaType(mimeSplit[0], mimeSplit[1]),
            ),
          );
        }
      }

      // Send
      final streamed = await request.send();
      final response = await Http.Response.fromStream(streamed);

      return handleResponse(response, uri);
    } catch (e, st) {
      debugPrint('postCategoryWithImage error: $e\n$st');
      return Response(statusCode: -1, statusText: e.toString());
    }
  }

  Future<Response> crmGetData(String uri, {Map<String, dynamic>? query}) async {
    try {
      Uri url = Uri.parse(AppConstants.CRM_BASE_URL + uri);
      if (query != null && query.isNotEmpty) {
        url = url.replace(queryParameters: {
          ...url.queryParameters,
          ...query.map((k, v) => MapEntry(k, v.toString()))
        });
      }

      debugPrint('====> CRM API Call: $uri\nHeader: $_crmHeaders');
      Http.Response _response = await Http.get(url, headers: _crmHeaders)
          .timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(_response, uri);
    } catch (e) {
      return Response(statusCode: 1, statusText: e.toString());
    }
  }

  Future<Response> crmPostData(String uri, dynamic body) async {
    try {
      debugPrint('====> CRM API Call: $uri\nBody: $body');
      Http.Response _response = await Http.post(
        Uri.parse(AppConstants.CRM_BASE_URL + uri),
        body: jsonEncode(body),
        headers: {
          ..._crmHeaders,
          'Content-Type': 'application/json; charset=UTF-8'
        },
      ).timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(_response, uri);
    } catch (e) {
      return Response(statusCode: 1, statusText: e.toString());
    }
  }

  Future<Response> crmPostMultipartData(
    String uri,
    Map<String, String> body,
    List<MultipartBody> multipartBody,
  ) async {
    try {
      debugPrint('====> CRM Multipart API Call: $uri\nFields: $body');
      var request = Http.MultipartRequest(
        'POST',
        Uri.parse(AppConstants.CRM_BASE_URL + uri),
      );
      request.headers.addAll(_crmHeaders);

      for (MultipartBody multipart in multipartBody) {
        if (multipart.file != null && multipart.file!.path.isNotEmpty) {
          final mimeType =
              lookupMimeType(multipart.file!.path) ?? 'image/jpeg';
          final mimeParts = mimeType.split('/');
          if (Foundation.kIsWeb) {
            Uint8List bytes = await multipart.file!.readAsBytes();
            var multipartFile = Http.MultipartFile.fromBytes(
              multipart.key!,
              bytes,
              filename: basename(multipart.file!.path),
              contentType: MediaType(mimeParts[0], mimeParts[1]),
            );
            request.files.add(multipartFile);
          } else {
            var file = File(multipart.file!.path);
            var multipartFile = await Http.MultipartFile.fromPath(
              multipart.key!,
              file.path,
              filename: basename(file.path),
              contentType: MediaType(mimeParts[0], mimeParts[1]),
            );
            request.files.add(multipartFile);
          }
        }
      }

      request.fields.addAll(body);
      var streamedResponse = await request.send();
      var response = await Http.Response.fromStream(streamedResponse);
      return handleResponse(response, uri);
    } catch (e) {
      return Response(statusCode: 1, statusText: e.toString());
    }
  }

  Future<Response> crmDeleteData(String uri) async {
    try {
      debugPrint('====> CRM API Call: $uri\nHeader: $_crmHeaders');
      Http.Response _response = await Http.delete(
        Uri.parse(AppConstants.CRM_BASE_URL + uri),
        headers: _crmHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(_response, uri);
    } catch (e) {
      return Response(statusCode: 1, statusText: e.toString());
    }
  }

  Future<Response> crmPutData(String uri, dynamic body) async {
    try {
      debugPrint('====> CRM API Call: $uri\nBody: $body');
      Http.Response _response = await Http.put(
        Uri.parse(AppConstants.CRM_BASE_URL + uri),
        body: jsonEncode(body),
        headers: {
          ..._crmHeaders,
          'Content-Type': 'application/json; charset=UTF-8'
        },
      ).timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(_response, uri);
    } catch (e) {
      return Response(statusCode: 1, statusText: e.toString());
    }
  }
}

class MultipartBody {
  String? key;
  XFile? file;
  File? audioFile;

  MultipartBody(this.key, this.file, this.audioFile);
}
