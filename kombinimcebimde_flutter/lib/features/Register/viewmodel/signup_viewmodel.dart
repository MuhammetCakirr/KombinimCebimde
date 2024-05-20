import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:kombinimcebimde_flutter/services/service.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Service sınıfının tanımı

class SignupViewmodel extends ChangeNotifier {
  String name = '';
  String email = '';
  String phone = '';
  String password = '';
  String errorMessage = ''; 
  bool isLoading = false; 
  final DjangoService service = DjangoService(); 


  Future<void> signup() async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await service.signup(
        fname: name,
        email: email,
        phone: phone,
        password: password,
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        errorMessage = '';
        var id= data['user']['id'];
        var email= data['user']['email'];
        var password= data['user']['password'];
            await SharedPreferences.getInstance().then((prefs) async {
            prefs.setString('id', id.toString());
            prefs.setString('email', email);
            prefs.setString('password', password);
        });
        print('Başarılı: ${data['user']}');
      } 
      else {
        var data = jsonDecode(response.body);
        errorMessage = data['error'] ?? data['error'];
        print('Kayıt başarısız: ${data['error']}');
        throw Exception('Kayıt başarısız: ${data['error']}');
      }
    } catch (e) {
      print('Bir hata oluştu: $e');
    }
    finally{
      isLoading = false;
      notifyListeners(); 
    }
  }
}