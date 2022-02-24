import 'package:flutter/material.dart';
import 'package:rick_and_morty_app_flutter/responsive.dart';
import 'constants.dart';
import 'util.dart';
import 'character_model.dart';
import 'theme.dart';

class CharacterScreen extends StatefulWidget {
  final title = 'Characters';

  CharacterScreen({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<CharacterScreen> {
  List<Character> persons = [];
  var nextPage = 1;
  var loadingError = false;

  void load() async {
    if (nextPage == -1) return;
    try {
      final res = await loadPersonList(nextPage);
      setState(() {
        nextPage = res.item2;
        persons.addAll(res.item1);
        loadingError = false;
      });
    } on Exception {
      setState(() {
        loadingError = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeColors.primary,
        title: Text(widget.title),
      ),
      body: persons.isEmpty
          ? Loader(load: load, loadingError: loadingError)
          : ListView.separated(
              physics: BouncingScrollPhysics(),
              padding: const EdgeInsets.all(8.0),
              itemCount: persons.length + 1,
              itemBuilder: (context, i) {
                if (i == persons.length) {
                  if (nextPage == -1) {
                    return SizedBox.shrink();
                  }
                  load();
                  return Loader(load: load, loadingError: loadingError);
                }
                return showPersonNew(persons[i]);
              },
              separatorBuilder: (context, i) => Divider(),
            ));

  Widget showPersonNew(Character person) {
    return ListTile(
        title: Text(
          person.name,
          style: const TextStyle(fontSize: kNameTextFontSize),
        ),
        subtitle:Column(
          children: [
            CharacterInfo(
                title: 'Status: ',
                information: person.status.toUpperCase(),
                color: person.status == 'Dead'
                    ? Colors.red
                    : person.status == 'unknown'
                        ? Colors.orange
                        : ThemeColors.primary),
            CharacterInfo(
                title: 'Species: ',
                information: person.species,
                color: ThemeColors.informationTextColor),
            CharacterInfo(
                title: 'Gender: ',
                information: person.gender,
                color: ThemeColors.informationTextColor),
            CharacterInfo(
                title: 'Type: ',
                information: person.type == '' ? 'original' : person.type,
                color: ThemeColors.informationTextColor),
            CharacterInfo(
                title: 'Origin Location: ',
                information: person.origin,
                color: ThemeColors.informationTextColor),
            CharacterInfo(
                title: 'Last Know Location: ',
                information: person.location,
                color: ThemeColors.informationTextColor),
          ],
        ),
        leading: CircleAvatar(
          maxRadius:MediaQuery.of(context).orientation == Orientation.portrait ? getScreenHeight(context)/kCircleAvatarMinRadius : getScreenWidth(context)/kCircleAvatarMinRadius,
          backgroundImage: NetworkImage(person.image),
        ),
      );
  }
}

class CharacterInfo extends StatelessWidget {
  String title;

  String information;

  Color color;

  CharacterInfo({
    Key? key,
    required this.title,
    required this.information,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: kInformationTextFontSize,
          ),
        ),
        Text(
          information,
          style: TextStyle(
            fontSize: kInformationTextFontSize,
            color: color,
          ),
        ),
      ],
    );
  }
}

class Loader extends StatelessWidget {
  final void Function() load;
  final bool loadingError;

  const Loader({Key? key, required this.loadingError, required this.load})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return loadingError
      ? Center(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(kLoadDataErrorMessage),
            ElevatedButton(
                onPressed: load,
                child: const Text(kLoadErrorButtonText),
                style: ElevatedButton.styleFrom(primary: ThemeColors.primary)),
          ],
        ))
      : const Center(
          child: CircularProgressIndicator(
            semanticsLabel: kLoadingText,
            valueColor: AlwaysStoppedAnimation(ThemeColors.primary),
          ),
        );
  }
}
