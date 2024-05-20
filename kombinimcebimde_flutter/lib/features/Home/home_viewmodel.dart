import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/service.dart';
import '../models/combin.dart';

class HomeViewModel extends ChangeNotifier{
  bool isLoading = false;
  String errorMessage = '';
  final DjangoService service = DjangoService();
  List<Combin> dailyCombinations = [];
  List<Combin> favoritelist = [];
  List<String> favoriteIdlist = [];
  String derece="";
  String havadurumu=" ";
  String fname=" ";
  String email=" ";

  Future<void> getDailyCombination() async {
    print("getDailyCombination çağrıldı");
    errorMessage = '';
    isLoading = true;
    notifyListeners();

    String userId = "";
    SharedPreferences prefs = await SharedPreferences.getInstance();  // Kullanıcı kimliğini almak için
    if (prefs.getString('id') != null) {
      userId = prefs.getString('id')!;
    }
    await getfavorites();
    await getweather();
    await getuserinfo();
    try {
      final response = await service.getDailyCombinations(userId);  // HTTP isteği
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);  // JSON verisini çözümle
        if (data is Map && data.containsKey("kombin_listesi")) {
          var kombinListesi = data["kombin_listesi"];
          if (kombinListesi is List) {
            List<Combin> clothesList = [];
            try {
              for (var item in kombinListesi) {
                // Clothes nesnesi oluştururken Null kontrolü yapın
                var clothes = Combin.fromJson(item);
                clothesList.add(clothes);  // Listeye ekleyin
              }
              dailyCombinations=clothesList;
              // Listeyi yazdırın
              for (var clothes in clothesList) {

              }
            } catch (e) {
              print("Bir hata oluştu: $e");
            }

          } else {
            print("Beklenmeyen veri türü: ${kombinListesi.runtimeType}");
          }
        } else {
          print("Eksik anahtar: 'kombin_listesi'");
        }
        errorMessage = '';  // Hata mesajını temizleyin
      } else {
        var data = jsonDecode(response.body);  // Hata yanıtını çözümleyin
        errorMessage = data['error'] ?? 'Bilinmeyen hata';
        throw Exception('Günlük kombinler alınamadı: ${data['error']}');
      }
    } catch (e) {
      errorMessage = "İstek sırasında bir hata oluştu: $e";  // Hata durumunda
    } finally {
      isLoading = false;  // Yükleme bayrağını sıfırlayın
      notifyListeners();  // Değişiklikleri bildirin
    }
  }

  Future<void> addfavorite(String id) async {
    errorMessage = '';
    isLoading = true;
    notifyListeners();

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
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getfavorites() async {
    print("get favoritese girdi");
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
            favoriteIdlist = favListesi.map((item) {
              return item['id'].toString();  // ID'leri alın
            }).toList();
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

    }
    finally{

    }

  }

  Future<void> getweather() async {
    try{
      final response = await service.get_weather();
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        derece=data['temperature'].toString();
        print(data['weather_code'].toString());
        havadurumu= getWeatherStatus(data['weather_code']);
      }
    }catch(e){
    }
    finally{
    }
  }
  String getWeatherStatus(int weatherCode) {
    String weatherStatus = "Unknown";
    switch (weatherCode) {
      case 1:
        weatherStatus = "Güneşli";
        break;
      case 2:
      case 3:
        weatherStatus = "Çoğunlukla Güneşli";
        break;
      case 45:
      case 48:
        weatherStatus = "Sisli";
        break;
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
      case 61:
      case 63:
      case 65:
      case 66:
      case 67:
      case 71:
      case 73:
      case 75:
      case 77:
      case 80:
      case 81:
      case 82:
      case 85:
      case 86:
        weatherStatus = "Yağmurlu";
        break;
      case 95:
      case 96:
      case 99:
        weatherStatus = "Fırtınalı";
        break;
      default:
        weatherStatus = "Unknown";
    }

    return weatherStatus; // Hava durumu açıklamasını döndür
  }

  Future<void> getuserinfo() async {
    print("getuserinfo çallıştı");
    errorMessage = '';
    isLoading = true;

    String userId = "";
    SharedPreferences prefs = await SharedPreferences.getInstance();  // Kullanıcı kimliğini almak için
    if (prefs.getString('id') != null) {
      userId = prefs.getString('id')!;
    }
    try{
      final response = await service.getUserInfo(userId);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        fname=data['user_info'].containsKey('fname') ? data['user_info']['fname'].toString() : 'unknown';
        email=data['user_info'].containsKey('email') ? data['user_info']['email'].toString() : 'unknown';

      }
    }
    catch(e){
      errorMessage = "İstek sırasında bir hata oluştu: $e";  // Hata durumunda
    }
    finally{
      isLoading = false;  // Yükleme bayrağını sıfırlayın

    }
  }
}