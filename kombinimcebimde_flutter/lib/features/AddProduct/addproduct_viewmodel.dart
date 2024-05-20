import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kombinimcebimde_flutter/services/service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddproductViewmodel extends ChangeNotifier {
  Map<String, List<File>> fotoMap = {};
  bool isLoading = false;
  String errorMessage = '';
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> userclothes=[];
  final DjangoService service = DjangoService();
  Map<String, List<File>> _categoryImages = {};
  List<File> allPhotos = [];

  Map<String, List<File>> get categoryImages => _categoryImages; // Map erişimi için getter
  String id="";

    List<File> getAllPhotos() {
    List<File> allPhotos = []; // Tüm dosyaları saklayacak liste
    _categoryImages.forEach((category, files) {
      allPhotos.addAll(files); // Her kategori için dosyaları ekle
    });
    
    return allPhotos; 
    
  }
  void addImageToCategory(String category, File image) {
    if (_categoryImages.containsKey(category)) {
      // Eğer kategori zaten varsa, listeye ekle
      _categoryImages[category]!.add(image);
    } else {
      // Eğer kategori yoksa, yeni bir liste oluştur ve ekle
      _categoryImages[category] = [image];
    }
    
    notifyListeners(); 
  }

void deleteImageFromCategory(String category, File image) {
  if (_categoryImages.containsKey(category)) {
    _categoryImages[category]!.remove(image);  // Dosyayı kategoriden silin

    // Eğer kategori boş kalırsa, ana listeden de kategoriyi silin
    if (_categoryImages[category]!.isEmpty) {
      _categoryImages.remove(category);
    }
    print("Silinen dosya: $image, Kategori: $category");
    notifyListeners();  // Dinleyicilere değişiklikleri bildir
  }
}

  Future<void> uploadimages() async{
   var userid="";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('id') != null) {
        userid=prefs.getString('id')!;
    }
    try{
      final response = await service.uploadFiles(_categoryImages,userid);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        errorMessage = ''; 
        _categoryImages = {};
        await getUserClothes();
      }
    }
    catch(e){
    }
    finally{
    }
  }

  Future<void> deleteimages(String photourl,String id) async{
    try{
      final response = await service.deletePhoto(photourl,id);
      if (response.statusCode == 200) {
        
        await getUserClothes();
      }
    }
    catch(e){
    }
    finally{
    }
  }

  Future<void> getCategories() async {
    
    errorMessage = '';
    isLoading = true;
    notifyListeners();
    await getUserClothes();
    try {
      // await Future.delayed(Duration(seconds: 5));
     
      final response = await service.getCategories();
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        errorMessage = '';
        categories=[];
        categories = List.from(data['categories']);     
        
      } 
      else {
        var data = jsonDecode(response.body);
        errorMessage = data['error'] ?? data['error'];
        throw Exception('Kayıt başarısız: ${data['error']}');
      }
    } catch (e) {
    } finally {
      isLoading = false;
      notifyListeners();
   
    }
  }

  Future<void> getUserClothes() async {
    String userid="";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('id') != null) {
        userid=prefs.getString('id')!;
    }
    try {
    
      final response = await service.getUserClothes(userid);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        errorMessage = '';
        userclothes=[];
        userclothes = List.from(data['clothes']);
        
      } 
      else if(response.statusCode == 404){
        userclothes = [];
      }
      else {
        var data = jsonDecode(response.body);
        errorMessage = data['error'] ?? data['error'];
        throw Exception('Kayıt başarısız: ${data['error']}');
      }
    } catch (e) {
    } finally {
      isLoading = false;
       notifyListeners();
    }

  }
void getUserId() async
{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('id') != null) {
        id=prefs.getString('id')!;
    }
}
}
