import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:splashscreen/splashscreen.dart';
import 'leaf_details.dart';
import 'list_view.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(new MaterialApp(
    home: new MyApp(),
  ));
}

Dio dio = new Dio(BaseOptions(
  connectTimeout: 60000,
  receiveTimeout: 60000,
  contentType: ContentType.json,
  responseType: ResponseType.json,
));
// Dio dio = new Dio();
// var url = 'http://192.168.1.107:5000/api/predict?base=ffh';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget build(BuildContext context) {
    return new SplashScreen(
      seconds: 6,
      navigateAfterSeconds: new AfterSplash(),
      image: new Image.asset(
        'images/leaf_set.jpg',
      ),
      backgroundColor: Colors.white,
      photoSize: MediaQuery.of(context).size.height / 5, //200,
      loaderColor: Colors.lightBlue,
      title: Text("\n\nExtreme Leaf",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 26,
              fontStyle: FontStyle.italic)),
    );
  }
}

class AfterSplash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ExtremeLeaf',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      home: MyHomePage(title: 'Leaf Classification'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  final _tabPages = <Widget>[
    Center(child: CameraPage()),
    // LeafList()
    PlantListView(),
  ];

  final List<Tab> _tabs = <Tab>[
    Tab(icon: Icon(Icons.add_a_photo), text: 'Take Photo'),
    Tab(icon: Icon(Icons.list), text: 'Plants')
  ];

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: new Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            centerTitle: true,
          ),
          body: TabBarView(
            children: _tabPages,
            controller: _tabController,
          ),
          bottomNavigationBar: Material(
            color: Colors.lightGreen,
            child: TabBar(
              tabs: _tabs,
              controller: _tabController,
            ),
          ),
        ));
  }
}

class CameraPage extends StatefulWidget {
  CameraPage() : super();

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  File _image;
  bool sending = false;
  Future getImage(ImageSource source) async {
    try {
      var image = await ImagePicker.pickImage(source: source);
      setState(() {
        _image = image;
      });
    } catch (error) {}
  }

  Future<dynamic> post(String url, var body) async {
    return await http.post(Uri.encodeFull(url),
        body: body,
        headers: {"Accept": "application/json"}).then((http.Response response) {
      print(response.body);
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Error while fetching data");
      }
      return jsonDecode(response.body);
    });
  }

  Future<String> getData(base64Image) async {
    //we have to wait to get the data so we use 'await'
    http.Response response = await http.get(
        //Uri.encodeFull removes all the dashes or extra characters present in our Uri
        Uri.encodeFull("http://localhost:5000/api/predict?base=" + base64Image),
        headers: {
          //if your api require key then pass your key here as well e.g "key": "my-long-key"
          "Accept": "application/json"
        });

    //print(data[1]["title"]); // it will print => title: "qui est esse"
  }

  void sendImage() async {
    if (sending) {
      return;
    }
    setState(() {
      sending = true;
    });
    List<int> imageBytes = _image.readAsBytesSync();
    print(imageBytes);
    String base64Image = base64Encode(imageBytes);
    print(base64Image);
    try {
      //var res = await http.post(url, body: {'data': base64Image});
      // Response res = await http
      //     .get("http://localhost:5000/api/predict?base=" + base64Image);
      // print(res.toString());
      // await getData(base64Image);
      //var res = await post(url, {'data': base64Image});
      // var res = await dio.get(url);
      FormData formData = new FormData.from({
        "base": base64Image,
      });
      Response res =
          await dio.post("http://35.223.100.13/api/predict", data: formData);
      Map<String, dynamic> parsedJson = json.decode(res.toString());
      bool status = parsedJson['status'];
      String plant_name = parsedJson['plant_name'];

      // Response res = await dio.get("http://www.google.com");

      //print(res);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LeafDetails(plant_name)),
      );
    } catch (err) {
      print(err);
    } finally {
      setState(() {
        sending = false;
        _image = null;
      });
    }
  }

  void showImageOption(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(Icons.add_a_photo),
                    title: new Text('Camera'),
                    onTap: () => {getImage(ImageSource.camera)}),
                new ListTile(
                  leading: new Icon(Icons.photo_album),
                  title: new Text('Gallery'),
                  onTap: () => {getImage(ImageSource.gallery)},
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: sending
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.blue)),
                      height: 100.0,
                      width: 100.0,
                    ),
                    SizedBox(
                      height: 50.0,
                      width: 50.0,
                    ),
                    Text(
                      "Recognizing",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              )
            : _image == null
                ? Center(
                    child: Image.asset(
                    'images/leaf_logo.png',
                    fit: BoxFit.contain,
                    width: 200,
                  ))
                : Center(child: Image.file(_image, fit: BoxFit.fill)),
        floatingActionButton: FloatingActionButton(
          onPressed:
              _image == null ? () => {showImageOption(context)} : sendImage,
          tooltip: 'Pick Image',
          child: Icon(_image == null ? Icons.add_a_photo : Icons.send),
        ));
  }
}
