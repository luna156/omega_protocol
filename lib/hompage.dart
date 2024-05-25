import 'package:flutter/material.dart';
import 'package:omega_protocol/omega.dart';
import 'package:omega_protocol/sigma.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("시그마 징찍기 연습"),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: <Widget>[
            ElevatedButton(onPressed: () {
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => Sigma())
              );
            }, child: Text("시그마 phase",
            style: TextStyle(fontSize: 30),)
            ),
            SizedBox(
                height: 300
            ),
            ElevatedButton(onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Omega())
              );
            }, child: Text("오메가 phase",
              style: TextStyle(fontSize: 30),))

          ],
        ),
      ),

    );
  }
}
