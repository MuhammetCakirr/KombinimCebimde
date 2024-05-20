import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/service.dart';
import '../models/combin.dart';

class FavoriteViewModel extends ChangeNotifier{
  bool isLoading = false;
  String errorMessage = '';
  final DjangoService service = DjangoService();
  List<Combin> favoritelist = [];


  Future<void> getfavorites() async {
    print("get favoritese girdi");
    errorMessage = '';
    isLoading = true;
    notifyListeners();
    String userId = "";
    SharedPreferences prefs = await SharedPreferences.getInstance();  // Kullanıcı kimliğini almak için
    if (prefs.getString('id') != null) {
      userId = prefs.getString('id')!;
    }
    try{
      final response = await service.getfavorites(userId);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data is Map && data.containsKey("favorite_combinations")) {
          var favListesi = data["favorite_combinations"];
          if (favListesi is List) {
            List<Combin> clothesList = [];

            try {
              for (var item in favListesi) {
                // Clothes nesnesi oluştururken Null kontrolü yapın
                var clothes = Combin.fromJson(item);
                clothesList.add(clothes);  // Listeye ekleyin
              }
              favoritelist=clothesList;
              // Listeyi yazdırın
              for (var clothes in favoritelist) {
                print("favoritelist: ${clothes.lowerWearUrl}, ${clothes.upperWearUrl1}, ${clothes.id}");
              }
            } catch (e) {
              print("Bir hata oluştu: $e");
            }

          } else {
            print("Beklenmeyen veri türü: ${favListesi.runtimeType}");
          }
        } else {
          print("Eksik anahtar: 'kombin_listesi'");
        }
      }
    }
    catch(e){
      errorMessage = "İstek sırasında bir hata oluştu: $e";  // Hata durumunda
    }
    finally{
      isLoading = false;  // Yükleme bayrağını sıfırlayın
      notifyListeners();  // Değişiklikleri bildirin
    }

  }


  Future<void> addfavorite(String id) async {
    String userId = "";
    SharedPreferences prefs = await SharedPreferences.getInstance();  // Kullanıcı kimliğini almak için
    if (prefs.getString('id') != null) {
      userId = prefs.getString('id')!;
    }

    try{
      final response = await service.addFavoriteDb(userId,id);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        await getfavorites();
        print("Favorileme işlemi başarılı şekilde yapıdı");
      }
    }
    catch(e){

    }
    finally{

    }
  }
}