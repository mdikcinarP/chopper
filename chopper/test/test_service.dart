import 'dart:async';
import 'dart:convert';

import 'package:chopper/chopper.dart';
import 'package:http/http.dart' show MultipartFile;

part 'test_service.chopper.dart';

@ChopperApi(baseUrl: '/test')
abstract class HttpTestService extends ChopperService {
  static HttpTestService create([ChopperClient? client]) =>
      _$HttpTestService(client);

  @Get(path: 'get/{id}')
  Future<Response<String>> getTest(
    @Path() String id, {
    @Header('test') required String dynamicHeader,
  });

  @Head(path: 'head')
  Future<Response> headTest();

  @Options(path: 'options')
  Future<Response> optionsTest();

  @Get(path: 'get')
  Future<Response<Stream<List<int>>>> getStreamTest();

  @Get(path: '')
  Future<Response> getAll();

  @Get(path: '/')
  Future<Response> getAllWithTrailingSlash();

  @Get(path: 'query')
  Future<Response> getQueryTest({
    @Query('name') String name = '',
    @Query('int') int? number,
    @Query('default_value') int? def = 42,
  });

  @Get(path: 'query_map')
  Future<Response> getQueryMapTest(@QueryMap() Map<String, dynamic> query);

  @Get(path: 'query_map')
  Future<Response> getQueryMapTest2(
    @QueryMap() Map<String, dynamic> query, {
    @Query('test') bool? test,
  });

  @Get(path: 'query_map')
  Future<Response> getQueryMapTest3({
    @Query('name') String name = '',
    @Query('number') int? number,
    @QueryMap() Map<String, dynamic> filters = const {},
  });

  @Get(path: 'query_map')
  Future<Response> getQueryMapTest4({
    @Query('name') String name = '',
    @Query('number') int? number,
    @QueryMap() Map<String, dynamic>? filters,
  });

  @Get(path: 'query_map')
  Future<Response> getQueryMapTest5({
    @QueryMap() Map<String, dynamic>? filters,
  });

  @Get(path: 'get_body')
  Future<Response> getBody(@Body() dynamic body);

  @Post(path: 'post')
  Future<Response> postTest(@Body() String data);

  @Post(path: 'post')
  Future<Response> postStreamTest(@Body() Stream<List<int>> byteStream);

  @Put(path: 'put/{id}')
  Future<Response> putTest(@Path('id') String test, @Body() String data);

  @Delete(path: 'delete/{id}', headers: {'foo': 'bar'})
  Future<Response> deleteTest(@Path() String id);

  @Patch(path: 'patch/{id}')
  Future<Response> patchTest(@Path() String id, @Body() String data);

  @Post(path: 'map')
  Future<Response> mapTest(@Body() Map<String, String> map);

  @FactoryConverter(request: convertForm)
  @Post(path: 'form/body')
  Future<Response> postForm(@Body() Map<String, String> fields);

  @Post(path: 'form/body', headers: {contentTypeKey: formEncodedHeaders})
  Future<Response> postFormUsingHeaders(@Body() Map<String, String> fields);

  @FactoryConverter(request: convertForm)
  @Post(path: 'form/body/fields')
  Future<Response> postFormFields(@Field() String foo, @Field() int bar);

  @Post(path: 'map/json')
  @FactoryConverter(
    request: customConvertRequest,
    response: customConvertResponse,
  )
  Future<Response> forceJsonTest(@Body() Map map);

  @Post(path: 'multi')
  @multipart
  Future<Response> postResources(
    @Part('1') Map a,
    @Part('2') Map b,
  );

  @Post(path: 'file')
  @multipart
  Future<Response> postFile(
    @PartFile('file') List<int> bytes,
  );

  @Post(path: 'image')
  @multipart
  Future<Response> postImage(
    @PartFile('image') List<int> imageData,
  );

  @Post(path: 'file')
  @multipart
  Future<Response> postMultipartFile(
    @PartFile() MultipartFile file, {
    @Part() String? id,
  });

  @Post(path: 'files')
  @multipart
  Future<Response> postListFiles(@PartFile() List<MultipartFile> files);

  @Get(path: 'https://test.com')
  Future fullUrl();

  @Get(path: '/list/string')
  Future<Response<List<String>>> listString();

  @Post(path: 'no-body')
  Future<Response> noBody();

  @Get(path: '/query_param_include_null_query_vars', includeNullQueryVars: true)
  Future<Response<String>> getUsingQueryParamIncludeNullQueryVars({
    @Query('foo') String? foo,
    @Query('bar') String? bar,
    @Query('baz') String? baz,
  });

  @Get(path: '/list_query_param')
  Future<Response<String>> getUsingListQueryParam(
    @Query('value') List<String> value,
  );

  @Get(path: '/list_query_param_with_brackets', useBrackets: true)
  Future<Response<String>> getUsingListQueryParamWithBrackets(
    @Query('value') List<String> value,
  );

  @Get(path: '/map_query_param')
  Future<Response<String>> getUsingMapQueryParam(
    @Query('value') Map<String, dynamic> value,
  );

  @Get(
    path: '/map_query_param_include_null_query_vars',
    includeNullQueryVars: true,
  )
  Future<Response<String>> getUsingMapQueryParamIncludeNullQueryVars(
    @Query('value') Map<String, dynamic> value,
  );

  @Get(path: '/map_query_param_with_brackets', useBrackets: true)
  Future<Response<String>> getUsingMapQueryParamWithBrackets(
    @Query('value') Map<String, dynamic> value,
  );
}

Request customConvertRequest(Request req) {
  final r = JsonConverter().convertRequest(req);

  return applyHeader(r, 'customConverter', 'true');
}

Response<T> customConvertResponse<T>(Response res) =>
    res.copyWith(body: json.decode(res.body));

Request convertForm(Request req) {
  req = applyHeader(req, contentTypeKey, formEncodedHeaders);

  if (req.body is Map) {
    final body = <String, String>{};

    req.body.forEach((key, val) {
      if (val != null) {
        body[key.toString()] = val.toString();
      }
    });

    req = req.copyWith(body: body);
  }

  return req;
}
