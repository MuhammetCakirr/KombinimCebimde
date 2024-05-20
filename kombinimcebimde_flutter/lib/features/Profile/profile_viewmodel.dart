import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:kombinimcebimde_flutter/features/models/user_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/service.dart';

class ProfileViewModel extends ChangeNotifier
{
  bool isLoading = false;
  String errorMessage = '';
  final DjangoService service = DjangoService();
    String kiyafetsayisi="1";
    String kombinonerisi="1";
    String favorikombinsayisi="";
    String fname=" ";
    String email="";
    String phone="";
    String sifre="";

    Future<void> updateuserinfo(String fname,String email,String phone,String password)async{
      String userId = "";
      SharedPreferences prefs = await SharedPreferences.getInstance();  // Kullanıcı kimliğini almak için
      if (prefs.getString('id') != null) {
        userId = prefs.getString('id')!;
      }
      try{
        final response = await service.updateUserFromDb(userId,fname,email,phone,password,);
        if (response.statusCode == 200) {
          SharedPreferences prefs= await SharedPreferences.getInstance();
            prefs.setString('email', email);
            prefs.setString('password', password);
          await getuserinfo();
        }
      }
      catch(e){
        errorMessage = "İstek sırasında bir hata oluştu: $e";  // Hata durumunda
      }
      finally{
        isLoading = false;  // Yükleme bayrağını sıfırlayın
        notifyListeners();
      }
    }

  Future<void> getuserinfo() async {
    print("getuserinfo çallıştı");
    errorMessage = '';
    isLoading = true;
    notifyListeners();
    String userId = "";
    SharedPreferences prefs = await SharedPreferences.getInstance();  // Kullanıcı kimliğini almak için
    if (prefs.getString('id') != null) {
      userId = prefs.getString('id')!;
    }
    try{
      final response = await service.getUserInfo(userId);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print(data['user_info']);
        favorikombinsayisi=data['user_info'].containsKey('favorite_count') ? data['user_info']['favorite_count'].toString() : 'unknown';
        kombinonerisi=data['user_info'].containsKey('kombin_count') ? data['user_info']['kombin_count'].toString() : 'unknown';
        kiyafetsayisi=data['user_info'].containsKey('clothes_count') ? data['user_info']['clothes_count'].toString() : 'unknown';
        fname=data['user_info'].containsKey('fname') ? data['user_info']['fname'].toString() : 'unknown';
        sifre=data['user_info'].containsKey('sifre') ? data['user_info']['sifre'].toString() : 'unknown';
        email=data['user_info'].containsKey('email') ? data['user_info']['email'].toString() : 'unknown';
        phone=data['user_info'].containsKey('phone') ? data['user_info']['phone'].toString() : 'unknown';
      }
    }
    catch(e){
      errorMessage = "İstek sırasında bir hata oluştu: $e";  // Hata durumunda
    }
    finally{
      isLoading = false;  // Yükleme bayrağını sıfırlayın
      notifyListeners();
    }
  }
}