import 'dart:async';

import 'package:get/get_connect/http/src/request/request.dart';

FutureOr<Request> authInterceptor(request) async {
  // final token = StorageService.box.pull(StorageItems.accessToken);

  // request.headers['X-Requested-With'] = 'XMLHttpRequest';
  // request.headers['Content-Type'] = 'application/json';
  // request.headers['Token'] =
  //     'eyJhbGciOiAiSG1hY1NIQTI1NiIsICJ0eXAiOiAiTWVkT24ifQ.eyJ1cyI6ImFkbWluaXN0cmF0b3IiLCJjciI6MTYyNjk1NTM5NTg1NCwiZXgiOjE2NTg0OTEzOTU4NjAsInVuIjoibWVkb24ifQ.dc9c22643b19fcaaebe14a10bd269d2eab4b6e74702ebf938cd1d3fa01dbdc66';

  return request;
}
