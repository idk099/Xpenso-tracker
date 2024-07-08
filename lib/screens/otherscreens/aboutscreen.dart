import 'package:flutter/material.dart';

class CreditsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      

      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text('About',style: TextStyle(fontSize: 30,color: Colors.white),),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Text(" By group 14",style: TextStyle(fontSize: 20,color: Colors.white),),
          SizedBox(height: 10,),
             _buildMemberCard('Sayooj VP',"VDA21CS057"),
              _buildMemberCard('Anujith K',"VDA21CS013"),
          _buildMemberCard('Sreeraj VV',"VDA21CS061"),
        
       
         
            _buildMemberCard('Sreehari P',"VDA21CS059"),
        ],
      ),
    );
  }

  Widget _buildMemberCard(String name,String id) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:  Colors.red,
          child: Text(name[0]),
        ),
        title: Text(name,style: TextStyle(fontWeight: FontWeight.bold),),
        subtitle: Text(id),
       
      ),
    );
  }
}
