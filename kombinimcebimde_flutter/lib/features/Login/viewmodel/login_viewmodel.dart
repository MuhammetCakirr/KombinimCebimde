import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kombinimcebimde_flutter/services/service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginViewmodel extends ChangeNotifier{
  String password = '';
  String email = '';
  String errorMessage = ''; 
  bool isLoading = false; 
  final DjangoService service = DjangoService(); 
  Future<void> signup() async {
    print("viewmodel"+ errorMessage);
    print("viewmodel"+password);
    print("viewmodel"+email);
    errorMessage = '';
    isLoading = true;
    notifyListeners();
    try {
      final response = await service.login(
        email: email,
        password: password,
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
         var id= data['user']['id'];
            await SharedPreferences.getInstance().then((prefs) async {
            prefs.setString('id', id.toString());
            prefs.setString('email', email);
            prefs.setString('password', password);
        });
        errorMessage = '';
       
      } 
      else {
        var data = jsonDecode(response.body);
        errorMessage = data['error'] ?? data['error'];
       
        throw Exception('Kayıt başarısız: ${data['error']}');
      }
    } catch (e) {
      
    }
    finally{
      isLoading = false;
      notifyListeners(); 
    print("finally"+ errorMessage);
    print("finally"+password);
    print("finally"+email);
    }
  }


}