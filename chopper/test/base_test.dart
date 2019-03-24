import 'package:chopper/chopper.dart';
import 'package:test/test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'test_service.dart';

const baseUrl = 'http://localhost:8000';

void main() {
  final buildClient = ([http.Client httpClient]) => ChopperClient(
        baseUrl: baseUrl,
        services: [
          // the generated service
          HttpTestService.create(),
        ],
        client: httpClient,
      );
  group('Base', () {
    test('get service', () async {
      final chopper = buildClient();
      final service = chopper.getService<HttpTestService>();

      expect(service is HttpTestService, isTrue);
    });

    test('get service not found', () async {
      final chopper = ChopperClient(
        baseUrl: baseUrl,
      );

      try {
        chopper.getService<HttpTestService>();
      } catch (e) {
        expect(e is Exception, isTrue);
        expect(
          e.message,
          equals("Service of type 'HttpTestService' not found."),
        );
      }
    });
    test('GET', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('$baseUrl/test/get/1234'),
        );
        expect(request.method, equals('GET'));

        return http.Response('get response', 200);
      });

      final chopper = buildClient(httpClient);
      final service = chopper.getService<HttpTestService>();

      final response = await service.getTest('1234');

      expect(response.body, equals('get response'));
      expect(response.statusCode, equals(200));

      httpClient.close();
    });

    test('GET with query params, null value', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('$baseUrl/test/query'),
        );
        expect(request.method, equals('GET'));

        return http.Response('get response', 200);
      });

      final chopper = buildClient(httpClient);
      final service = chopper.getService<HttpTestService>();

      final response = await service.getQueryTest(def: null);

      expect(response.body, equals('get response'));
      expect(response.statusCode, equals(200));

      httpClient.close();
    });

    test('GET with query params, default value', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('$baseUrl/test/query?default_value=42'),
        );
        expect(request.method, equals('GET'));

        return http.Response('get response', 200);
      });

      final chopper = buildClient(httpClient);
      final service = chopper.getService<HttpTestService>();

      final response = await service.getQueryTest();

      expect(response.body, equals('get response'));
      expect(response.statusCode, equals(200));

      httpClient.close();
    });

    test('GET with query params', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('$baseUrl/test/query?name=Foo&int=18&default_value=40'),
        );
        expect(request.method, equals('GET'));

        return http.Response('get response', 200);
      });

      final chopper = buildClient(httpClient);
      final service = chopper.getService<HttpTestService>();

      final response =
          await service.getQueryTest(name: "Foo", def: 40, number: 18);

      expect(response.body, equals('get response'));
      expect(response.statusCode, equals(200));

      httpClient.close();
    });

    test('POST', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('$baseUrl/test/post'),
        );
        expect(request.method, equals('POST'));
        expect(request.body, equals('post body'));

        return http.Response('post response', 200);
      });

      final chopper = buildClient(httpClient);
      final service = chopper.getService<HttpTestService>();

      final response = await service.postTest('post body');

      expect(response.body, equals('post response'));
      expect(response.statusCode, equals(200));

      httpClient.close();
    });

    test('PUT', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('$baseUrl/test/put/1234'),
        );
        expect(request.method, equals('PUT'));
        expect(request.body, equals('put body'));

        return http.Response('put response', 200);
      });

      final chopper = buildClient(httpClient);
      final service = chopper.getService<HttpTestService>();

      final response = await service.putTest('1234', 'put body');

      expect(response.body, equals('put response'));
      expect(response.statusCode, equals(200));

      httpClient.close();
    });

    test('PATCH', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('$baseUrl/test/patch/1234'),
        );
        expect(request.method, equals('PATCH'));
        expect(request.body, equals('patch body'));

        return http.Response('patch response', 200);
      });

      final chopper = buildClient(httpClient);
      final service = chopper.getService<HttpTestService>();

      final response = await service.patchTest('1234', 'patch body');

      expect(response.body, equals('patch response'));
      expect(response.statusCode, equals(200));

      httpClient.close();
    });

    test('DELETE', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('$baseUrl/test/delete/1234'),
        );
        expect(request.method, equals('DELETE'));

        return http.Response('delete response', 200);
      });

      final chopper = buildClient(httpClient);
      final service = chopper.getService<HttpTestService>();

      final response = await service.deleteTest('1234');

      expect(response.body, equals('delete response'));
      expect(response.statusCode, equals(200));

      httpClient.close();
    });

    test('const headers', () async {
      final client = MockClient((http.Request req) async {
        expect(req.headers.containsKey('foo'), isTrue);
        expect(req.headers['foo'], equals('bar'));
        return http.Response('', 200);
      });

      final chopper = ChopperClient(
        services: [
          HttpTestService.create(),
        ],
        client: client,
      );

      await chopper.getService<HttpTestService>().deleteTest('1234');

      client.close();
    });

    test('runtime headers', () async {
      final client = MockClient((http.Request req) async {
        expect(req.headers.containsKey('test'), isTrue);
        expect(req.headers['test'], equals('42'));
        return http.Response('', 200);
      });

      final chopper = ChopperClient(
        services: [
          HttpTestService.create(),
        ],
        client: client,
      );

      await chopper.getService<HttpTestService>().getTest(
            '1234',
            dynamicHeader: '42',
          );

      client.close();
    });

    test('factory', () async {
      final client = MockClient((http.Request req) async {
        expect(
          req.url.toString(),
          equals('$baseUrl/test/get/1234'),
        );
        return http.Response('', 200);
      });

      final chopper = ChopperClient(
        baseUrl: baseUrl,
        client: client,
      );

      final service = HttpTestService.create(chopper);

      await service.getTest('1234');

      client.close();
    });

    test('applyHeader', () {
      final req1 = applyHeader(
          Request(
            'GET',
            '/',
            baseUrl,
          ),
          'foo',
          'bar');

      expect(req1.headers, equals({'foo': 'bar'}));

      final req2 = applyHeader(
        Request('GET', '/', baseUrl, headers: {'foo': 'bar'}),
        'bar',
        'foo',
      );

      expect(req2.headers, equals({'foo': 'bar', 'bar': 'foo'}));

      final req3 = applyHeader(
        Request('GET', '/', baseUrl, headers: {'foo': 'bar'}),
        'foo',
        'foo',
      );

      expect(req3.headers, equals({'foo': 'foo'}));
    });

    test('applyHeaders', () {
      final req1 = applyHeaders(Request('GET', '/', baseUrl), {'foo': 'bar'});

      expect(req1.headers, equals({'foo': 'bar'}));

      final req2 = applyHeaders(
        Request('GET', '/', baseUrl, headers: {'foo': 'bar'}),
        {'bar': 'foo'},
      );

      expect(req2.headers, equals({'foo': 'bar', 'bar': 'foo'}));

      final req3 = applyHeaders(
        Request('GET', '/', baseUrl, headers: {'foo': 'bar'}),
        {'foo': 'foo'},
      );

      expect(req3.headers, equals({'foo': 'foo'}));
    });

    test('fullUrl', () async {
      final client = MockClient((http.Request req) async {
        return http.Response('ok', 200);
      });

      final chopper = buildClient(client);

      chopper.onRequest.listen((request) {
        expect(
          request.url.toString(),
          equals('https://test.com'),
        );
      });

      final service = HttpTestService.create(chopper);
      await service.fullUrl();

      client.close();
      chopper.dispose();
    });

    test('url concatenation', () async {
      final url1 = buildUri('foo', 'bar', {});
      expect(url1.toString(), equals('foo/bar'));

      final url2 = buildUri('foo/', 'bar', {});
      expect(url2.toString(), equals('foo/bar'));

      final url3 = buildUri('foo', '/bar', {});
      expect(url3.toString(), equals('foo/bar'));

      final url4 = buildUri('foo/', '/bar', {});
      expect(url4.toString(), equals('foo//bar'));

      final url5 = buildUri('http://foo', '/bar', {});
      expect(url5.toString(), equals('http://foo/bar'));

      final url6 = buildUri('https://foo', '/bar', {});
      expect(url6.toString(), equals('https://foo/bar'));

      final url7 = buildUri('https://foo/', '/bar', {});
      expect(url7.toString(), equals('https://foo//bar'));
    });

    test('BodyBytes', () async {
      final request = await toHttpRequest(
        [1, 2, 3],
        HttpMethod.Post,
        Uri.parse('/foo'),
        {},
      );

      expect(request.bodyBytes, equals([1, 2, 3]));
    });

    test('BodyFields', () async {
      final request = await toHttpRequest(
        {"foo": "bar"},
        HttpMethod.Post,
        Uri.parse('/foo'),
        {},
      );

      expect(request.bodyFields, equals({"foo": "bar"}));
    });

    test("Wrong body", () async {
      try {
        await toHttpRequest(
          {"foo": 42},
          HttpMethod.Post,
          Uri.parse('/foo'),
          {},
        );
      } on ArgumentError catch (e) {
        expect(e.toString(), equals('Invalid argument (body): "{foo: 42}"'));
      }
    });

    test('constants', () {
      expect(contentTypeKey, equals('content-type'));
      expect(jsonHeaders, equals('application/json'));
      expect(formEncodedHeaders, equals('application/x-www-form-urlencoded'));
    });

    test('Query Map 1', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('$baseUrl/test/query_map?foo=bar&list=1&list=2&inner.test=42'),
        );
        expect(request.method, equals('GET'));

        return http.Response('get response', 200);
      });

      final chopper = buildClient(httpClient);
      final service = chopper.getService<HttpTestService>();

      final response = await service.getQueryMapTest({
        "foo": "bar",
        "list": [1, 2],
        "inner": {"test": 42},
      });

      expect(response.body, equals('get response'));
      expect(response.statusCode, equals(200));

      httpClient.close();
    });

    test('Query Map 2', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals(
              '$baseUrl/test/query_map?test=true&foo=bar&list=1&list=2&inner.test=42'),
        );
        expect(request.method, equals('GET'));

        return http.Response('get response', 200);
      });

      final chopper = buildClient(httpClient);
      final service = chopper.getService<HttpTestService>();

      final response = await service.getQueryMapTest2(
        {
          "foo": "bar",
          "list": [1, 2],
          "inner": {"test": 42},
        },
        test: true,
      );

      expect(response.body, equals('get response'));
      expect(response.statusCode, equals(200));

      httpClient.close();
    });
  });

  group('Streams', () {
    test('request', () async {
      final client = MockClient((http.Request req) async {
        return http.Response('ok', 200);
      });

      final chopper = buildClient(client);

      chopper.onRequest.listen((request) {
        expect(
          request.url.toString(),
          equals('/test/get/1234'),
        );
      });

      final service = HttpTestService.create(chopper);
      await service.getTest('1234');

      client.close();
      chopper.dispose();
    });

    test('response', () async {
      final client = MockClient((http.Request req) async {
        return http.Response('ok', 200);
      });

      final chopper = buildClient(client);

      chopper.onResponse.listen((response) {
        expect(response.statusCode, equals(200));
        expect(response.body, equals('ok'));
      });

      final service = HttpTestService.create(chopper);
      await service.getTest('1234');

      client.close();
      chopper.dispose();
    });

    test('error', () async {
      final client = MockClient((http.Request req) async {
        return http.Response('error', 400);
      });

      final chopper = buildClient(client);

      chopper.onError.listen((response) {
        expect(response.statusCode, equals(400));
        expect(response.body, equals('error'));
      });

      final service = HttpTestService.create(chopper);
      try {
        await service.getTest('1234');
      } catch (e) {
        expect(e is Response, isTrue);
      }

      client.close();
      chopper.dispose();
    });
  });
}
