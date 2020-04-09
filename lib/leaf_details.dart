import 'package:flutter/material.dart';
import 'dart:convert';

class LeafDetails extends StatefulWidget {
  final String name;
  LeafDetails(this.name, {Key key}) : super(key: key);

  @override
  _LeafDetails createState() {
    return new _LeafDetails();
  }
}

class _LeafDetails extends State<LeafDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Leaf Details"),
          centerTitle: true,
        ),
        body: Container(
          child: FutureBuilder(
              future: DefaultAssetBundle.of(context)
                  .loadString('leaf_species.json'),
              builder: (context, snapshot) {
                var data = json.decode(snapshot.data.toString());
                int i = 0;
                if (data != null) {
                  for (; i < data.length; i++) {
                    if (data[i]['name'] == widget.name) break;
                  }
                  if (i == data.length) i = 0;
                }
                return data != null
                    ? Container(
                        child: ListView(
                          children: <Widget>[
                            ConstrainedBox(
                              child: Image.network(data[i]['image'],
                                  fit: BoxFit.fill),
                              constraints: BoxConstraints(maxHeight: 200),
                            ),
                            titleSection(
                                "${data[i]['name'][0].toString().toUpperCase()}${data[i]['name'].toString().substring(1).replaceAll('_', ' ')}"),
                            textSection(data[i]['description'])
                          ],
                        ),
                      )
                    : Center(child: Icon(Icons.cancel));
              }),
        ));
  }
}

class FavoriteWidget extends StatefulWidget {
  @override
  _FavoriteWidgetState createState() => _FavoriteWidgetState();
}

class _FavoriteWidgetState extends State<FavoriteWidget> {
  bool _isFavorited = false;

  void _toggleFavorite() {
    this.setState(() {
      _isFavorited = !_isFavorited;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(0),
          child: IconButton(
            iconSize: 50,
            icon: (_isFavorited ? Icon(Icons.star) : Icon(Icons.star_border)),
            color: Colors.red[500],
            onPressed: _toggleFavorite,
          ),
        ),
      ],
    );
  }
}

Widget titleSection(plantName) => Container(
      padding: const EdgeInsets.all(32),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '$plantName',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

Widget textSection(plantDescription) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Text(
        '$plantDescription',
        style: TextStyle(fontSize: 15),
      ),
    );
