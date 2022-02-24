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
    Character character = Character();
    character.id = item['id'];
    character.name = item['name'];
    character.status = item['status'];
    character.species =item['species'];
    character.gender = item['gender'];
    character.type = item ['type'];
    character.origin = item['origin']['name'];
    character.location = item['location']['name'];
    character.image = item['image'];
    results.add(character);
  }

  return Tuple2(
      results, response.data['data']['characters']['info']['next'] ?? -1);
}
