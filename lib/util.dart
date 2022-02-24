import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tuple/tuple.dart';

import 'character_model.dart';

const url = 'https://rickandmortyapi.com/graphql/';
var dio = Dio();

Future<Tuple2<List<Character>, int>> loadPersonList(int page) async {
  final response = await dio.post(url, data: {
    'query': await rootBundle.loadString('graphql/character_result.gql'),
    'variables': {'page': page},
  });

  if (response.data['data']['characters']['info'] == null ||
      response.data['data']['characters']['results'] == null) {
    throw Exception('Failed to load');
  }

  List<Character> results = [];
  for (final item in response.data['data']['characters']['results']) {
    Character person = Character();
    person.id = item['id'];
    person.name = item['name'];
    person.status = item['status'];
    person.species =item['species'];
    person.gender = item['gender'];
    person.type = item ['type'];
    person.origin = item['origin']['name'];
    person.location = item['location']['name'];
    person.image = item['image'];
    results.add(person);
  }

  return Tuple2(
      results, response.data['data']['characters']['info']['next'] ?? -1);
}
