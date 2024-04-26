import 'package:flutter/material.dart';

class Records extends StatefulWidget {
  const Records({super.key});

  @override
  State<Records> createState() => _RecordsState();
}

class _RecordsState extends State<Records> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            flexibleSpace: Center(
                child: Padding(
              padding: const EdgeInsets.only(
                top: 30,
              ),
              child: SizedBox(
                  height: 120,
                  child: Image.asset(
                    'assets/images/appbarlogo.png',
                    fit: BoxFit.cover,
                  )),
            )),
            backgroundColor: Colors.blue,
            actions: <Widget>[
              IconButton(
                  icon: Icon(
                    Icons.ac_unit,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    Navigator.push(context, MaterialPageRoute(builder: (context) =>ListViewPage() ,));
                  
                  })
            ]),
        body: ListView(
          children: [
            
            Container(
              height: 200,
              width: 200,
              color: Colors.black,
            ),
            Container(
              height: 200,
              width: 200,
              color: Colors.red,
            ),
            Container(
              height: 200,
              width: 200,
              color: Colors.green,
            ),
            Container(
              height: 200,
              width: 200,
              color: Colors.yellow,
            )
          ],
        ));
  }

 
  }
  class ListViewPage extends StatelessWidget {
  const ListViewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Infinite List"),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return ListTile(
              leading: Text("$index"), title: Text("Number $index"));
        },
      ),
    );
  }
}
  
