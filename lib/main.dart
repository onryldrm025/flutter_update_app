import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Update App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String versionNumber = 'Loading...';
  String dowloand = '0';
  bool isdowloand = false;
  @override
  void initState() {
    getVersion();
    super.initState();
  }

  getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      versionNumber = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Version : ${versionNumber.toString()}'),
            if (!isdowloand)
              ElevatedButton(
                onPressed: () async {
                  Permission.requestInstallPackages;
                  Permission.storage;
                  Dio dio = Dio();
                  var url = 'your version get url'; // apk version control url
                  var response = await dio.get(url);
                  var version = Version.fromMap(response.data);
                  if (version.versionNumber != versionNumber) {
                    // you need update app
                    print('please update new version ${version.versionNumber}');
                    showDialog(
                      context: context,
                      builder: (builder) {
                        return AlertDialog(
                          content: Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: MediaQuery.of(context).size.height * 0.3,
                            child: Column(
                              children: [
                                const Text('You need update app please'),
                                Text('Current version:' +
                                    versionNumber.toString()),
                                Text('New version:' +
                                    version.versionNumber.toString()),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                var dir = await getExternalStorageDirectory();
                                isdowloand = true;
                                Navigator.pop(context);
                                dio.download(
                                    'your dowland url', //apk dowland url
                                    '${dir!.path}/newapk.apk', //path
                                    onReceiveProgress: (a, b) {
                                  setState(() {
                                    dowloand = (a / b * 100).floor().toString();
                                  });
                                }).then((value) {
                                  OpenFile.open(
                                      '${dir.path}/newapk.apk'); //apk open
                                  setState(() {
                                    isdowloand = false;
                                  });
                                });
                              },
                              child: const Text('Update now'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Later update'),
                            )
                          ],
                        );
                      },
                    );
                  } else {}
                },
                child: const Text('Get Update control'),
              ),
            if (isdowloand) Text(dowloand + '%'),
            if (isdowloand)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: LinearProgressIndicator(
                    value: double.parse(dowloand) / 100),
              ),
          ],
        ),
      ),
    );
  }
}

class Version {
  String? versionNumber;
  Version({
    this.versionNumber,
  });

  factory Version.fromMap(var map) {
    return Version(
      versionNumber: map['version'],
    );
  }
}
