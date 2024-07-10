import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xpenso/screens/otherscreens/aboutscreen.dart';
import 'package:xpenso/services/Provider/themePreference.dart';

class Drawermenu extends StatefulWidget {
  const Drawermenu({super.key});

  @override
  State<Drawermenu> createState() => _DrawermenuState();
}

class _DrawermenuState extends State<Drawermenu> {


   String? _selectedTheme;

  @override
  void initState() {
    super.initState();
    _selectedTheme = Provider.of<ThemeProvider>(context, listen: false)
        .theme
        .toString()
        .split('.')
        .last;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
  
      backgroundColor: Theme.of(context).brightness==Brightness.light?Colors.amberAccent:Color.fromARGB(255, 68, 58, 58),
      body:  ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
           SizedBox(
            height: 180,
           ),
           Padding(
             padding: const EdgeInsets.all(8.0),
             child: Text("  Theme",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
           ),
          
            RadioListTile<String>(
              title: const Text('System Default'),
              value: 'system',
              fillColor:  MaterialStatePropertyAll( Theme.of(context).brightness==Brightness.light?Colors.black:Colors.white,),
              groupValue: _selectedTheme,
              onChanged: (value) {
                setState(() {
                  _selectedTheme = value;
                  Provider.of<ThemeProvider>(context, listen: false)
                      .changeThemeMode(value!);
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('Light Theme'),
              fillColor: MaterialStatePropertyAll( Theme.of(context).brightness==Brightness.light?Colors.black:Colors.white,),
              value: 'light',
              groupValue: _selectedTheme,
              onChanged: (value) {
                setState(() {
                  _selectedTheme = value;
                  Provider.of<ThemeProvider>(context, listen: false)
                      .changeThemeMode(value!);
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('Dark Theme'),
              value: 'dark',
              fillColor:  MaterialStatePropertyAll( Theme.of(context).brightness==Brightness.light?Colors.black:Colors.white,),
              groupValue: _selectedTheme,
              onChanged: (value) {
                setState(() {
                  _selectedTheme = value;
                  Provider.of<ThemeProvider>(context, listen: false)
                      .changeThemeMode(value!);
                });
              },
            ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Divider(),
        ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
               children: [
                 IconButton(onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) =>CreditsPage() ,));

                 }, icon: Icon(Icons.info)),
                 Text("About",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),)
               ],
             ),
          ),
         
         
          ],
        ),
    );
  }
}
