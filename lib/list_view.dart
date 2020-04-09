import 'package:flutter/material.dart';
import 'leaf_details.dart';
import 'dart:convert';

class PlantListView extends StatefulWidget {
  @override
  _ListView createState() => _ListView();
}

class _ListView extends State<PlantListView> {
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: FutureBuilder(
          future:
              DefaultAssetBundle.of(context).loadString('leaf_species.json'),
          builder: (context, snapshot) {
            var data = json.decode(snapshot.data.toString());
            return ListView.builder(
              itemCount: data == null ? 0 : data.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    contentPadding: EdgeInsets.all(20),
                    leading: CircleAvatar(
                        backgroundImage: NetworkImage(data[index]['image'])),
                    title: Container(
                      child: Text(
                        data[index]['name'][0].toString().toUpperCase() +
                            data[index]['name']
                                .toString()
                                .substring(1)
                                .replaceAll('_', ' '),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      padding: EdgeInsets.only(bottom: 8),
                    ),
                    subtitle: Text(
                      data[index]['description'].toString().substring(0, 60) +
                          "....",
                      style:
                          TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                    ),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                LeafDetails(data[index]['name'])),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
