import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:xpenso/Data/colors.dart';


class ThemeClass {
  // Light theme
  static final lightTheme = ThemeData(
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: Colors.black
    ),
    
     textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        backgroundColor: Color.fromARGB(255, 224, 169, 233),
         foregroundColor:  Colors.black
      ),
      
      
    ),
     elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor:   Color.fromARGB(255, 224, 169, 233), 
        foregroundColor: Colors.black
        // Button text color
      ),
      
    ),
    
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.blue,
      inputDecorationTheme: InputDecorationTheme(

        
     labelStyle: TextStyle(color: Colors.black),
          // Apply the custom color to the border and filled background
       
          border: OutlineInputBorder(
               borderRadius: BorderRadius.circular(20),


                         borderSide: BorderSide(color: Colors.black)
          ),
          focusedBorder:  OutlineInputBorder(
               borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.purple)
          )

          
        ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blue,
    ),
    
    colorScheme: ColorScheme.light(
      primary: Colors.white,
      background: Colors.white,
    ),
     dialogTheme: DialogTheme(
      backgroundColor: Colors.blue.shade100, // Dialog background color
      titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
      contentTextStyle: TextStyle(color: Colors.black, fontSize: 16),
    ),
    chipTheme: ChipThemeData(
          backgroundColor: Colors.yellow,
          selectedColor:Colors.orange,
        
          padding: EdgeInsets.all(8.0),
          labelStyle: TextStyle(
            color: Colors.black,
          ),
          
          
        ),
  );

  // Dark theme
  static final darkTheme = ThemeData(
    
     textSelectionTheme: TextSelectionThemeData(
      cursorColor: Colors.white
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        backgroundColor: Colors.grey,
         foregroundColor:  Colors.black
      )
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor:  Colors.grey,
        foregroundColor:  Colors.white// Button text color
      ),
    ),
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
   inputDecorationTheme: InputDecorationTheme(
     labelStyle: TextStyle(color: Colors.white),
          // Apply the custom color to the border and filled background
       
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.white,
            
            )
          ),
          focusedBorder:  OutlineInputBorder(
             borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.white)
          )

          
        ),
   
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.black,
    ),
    colorScheme: ColorScheme.dark(
      primary: Colors.blueGrey.shade900,
      background: Colors.white,
    ),
     dialogTheme: DialogTheme(
      backgroundColor: Colors.grey[800], // Dialog background color
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
      contentTextStyle: TextStyle(color: Colors.white70, fontSize: 16),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Colors.blueGrey.shade300
    ),
    chipTheme: ChipThemeData(
          backgroundColor: owlpink,
          selectedColor:blueshade1,
        
          padding: EdgeInsets.all(8.0),
          labelStyle: TextStyle(
            color: Colors.white,
          ),
          
          
        ),
    
     
  );
}