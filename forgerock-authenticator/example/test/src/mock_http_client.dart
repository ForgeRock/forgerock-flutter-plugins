/*
 * Copyright (c) 2022 ForgeRock. All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

import 'dart:async';
import 'dart:io';

import 'package:mockito/mockito.dart';

/// Runs [body] in separate [Zone] with [MockHttpClient].
R mockNetworkImagesFor<R>(R Function() body) {
  return HttpOverrides.runZoned(
    body,
    createHttpClient: (_) => createMockImageHttpClient(),
  );
}

class MockHttpClient extends Mock implements HttpClient {}

class MockHttpClientRequest extends Mock implements HttpClientRequest {}

class MockHttpClientResponse extends Mock implements HttpClientResponse {}

class MockHttpHeaders extends Mock implements HttpHeaders {}

/// Returns a [MockHttpClient] that responds with demo image to all requests.
MockHttpClient createMockImageHttpClient() {
  final MockHttpClient client = MockHttpClient();
  final MockHttpClientRequest request = MockHttpClientRequest();
  final MockHttpClientResponse response = MockHttpClientResponse();
  final MockHttpHeaders headers = MockHttpHeaders();

  when(client.getUrl(any))
      .thenAnswer((_) => Future<HttpClientRequest>.value(request));
  when(request.headers).thenReturn(headers);
  when(request.close())
      .thenAnswer((_) => Future<HttpClientResponse>.value(response));
  when(response.compressionState)
      .thenReturn(HttpClientResponseCompressionState.notCompressed);
  when(response.contentLength).thenReturn(image.length);
  when(response.statusCode).thenReturn(HttpStatus.ok);
  when(response.listen(any)).thenAnswer((Invocation invocation) {
    final void Function(List<int>) onData = invocation.positionalArguments[0] as void Function(List<int>);
    final void Function() onDone = invocation.namedArguments[#onDone] as void Function();
    final void Function(Object, [StackTrace]) onError =
    invocation.namedArguments[#onError] as void Function(Object, [StackTrace]);
    final bool cancelOnError = invocation.namedArguments[#cancelOnError] as bool;

    return Stream<List<int>>.fromIterable(<List<int>>[image]).listen(onData,
        onDone: onDone, onError: onError, cancelOnError: cancelOnError);
  });

  return client;
}

const List<int> image = <int>[0x00, 0x00, 0x00, 0x00];