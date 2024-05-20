// JSON işlemleri için gerekli
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class DjangoService {
  static const String baseUrl =
      'http://172.20.10.4:8000'; // Django server'ınızın base URL'i

  // Mevcut tarih ve saat için formatter
  final DateFormat formatter =
      DateFormat('yyyy-MM-dd HH:mm:ss'); // Örneğin, '2024-04-25 10:15:30'

  Future<http.Response> signup({
    required String fname,
    required String email,
    required String phone,
    required String password,
  }) async {
    // Mevcut tarihi formatlayın
    final String formattedDate = formatter.format(DateTime.now());

    final response = await http.post(
      Uri.parse('$baseUrl/adduser'), // Django'da POST isteği gönderme
      headers: {'Content-Type': 'application/json'}, // JSON türünde içerik
      body: jsonEncode({
        'fname': fname,
        'email': email,
        'phone': phone,
        'password': password,
        'is_active': "1",
        'date_joined': formattedDate, // Date formatı
      }),
    );

    return response;
  }

  Future<http.Response> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    return response;
  }

  Future<http.Response> getCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/getCategories'),
      headers: {'Content-Type': 'application/json'},
    );
    return response;
  }

  Future<http.Response> get_weather() async {
    final response = await http.get(
      Uri.parse('$baseUrl/get_weather'),
      headers: {'Content-Type': 'application/json'},
    );
    return response;
  }


String appendUserCategoryToFilename(String filePath, String categoryId, String userId) {
  var fileName = filePath.split('/').last;  // Dosya adını alın
  var fileExtension = fileName.split('.').last;  // Dosya uzantısını alın
  
  // Kullanıcı kimliği ve kategori kimliği ile yeni dosya adını oluşturun
  var newFileName = "${fileName.replaceAll('.$fileExtension', '')}_user_${userId}_category_$categoryId.$fileExtension";
  return newFileName;
}

Future<http.Response> uploadFiles(Map<String, List<File>> categoryImages, String userId) async {
  print("categoryImages");
  print( categoryImages);
 
  print("userid"+userId);
  var request = http.MultipartRequest("POST", Uri.parse('$baseUrl/uploadimages'));

  categoryImages.forEach((categoryId, files) {
    files.forEach((file) async {
      var newFilePath = appendUserCategoryToFilename(file.path, categoryId, userId);  // Dosya adını güncelleyin

      var multipartFile = await http.MultipartFile.fromPath(
        'file',  // Dosya için anahtar
        file.path,
        filename: newFilePath,  // Güncellenmiş dosya adı
      );

      request.files.add(multipartFile);  // Dosyayı isteğe ekleyin

      print("Kategori: $categoryId, Kullanıcı: $userId, Yeni Dosya Adı: $newFilePath");  // Kontrol edin
    });
  });

  // İsteği göndermeden önce kontrol edin
  print("Gönderilen dosyalar: ${request.files}");

  var response = await request.send();  // İsteği gönderin

  // Yanıtı tam olarak alın
  var fullResponse = await http.Response.fromStream(response);

  if (fullResponse.statusCode == 200) {
    print("Dosyalar başarıyla yüklendi.");
  } else {
    print("Dosya yükleme başarısız oldu: ${fullResponse.statusCode}");
  }

  return fullResponse;  // Yanıtı döndür
}

Future<http.Response> getUserClothes(String userId) async {
  var url = Uri.parse('$baseUrl/getUserClothes');  // Django fonksiyonunun URL'si

  print(userId);
  // POST isteği ile kullanıcı kimliğini gönderin
  var response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',  // JSON formatında veri gönderiyoruz
    },
    body: json.encode({"user_id": userId}),  // Kullanıcı kimliğini JSON olarak gönderin
  );

  if (response.statusCode == 200) {  // Başarılı yanıt
    var data = json.decode(response.body);
    // print("Kullanıcı kıyafetleri: ${data['clothes']}");
  } else {
    print("Kıyafetleri alırken hata: ${response.statusCode}");
  }
  return response;
}

  Future<http.Response> getweeklyrecommendation(String userId) async {
    var url = Uri.parse('$baseUrl/weeklyrecommendation');  // Django fonksiyonunun URL'si
    print("userId"+ userId);
    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({"user_id": userId}),
    );

    if (response.statusCode == 200) {  // Başarılı yanıt
      var data = json.decode(response.body);

    } else {
      print("haftalık önerileri  alırken hata: ${response.statusCode}");
    }
    return response;
  }


Future<http.Response> deletePhoto(String photoName,String Id) async {
  var response = await http.post(
    Uri.parse('$baseUrl/delete_photo'),  // Silme için endpoint
    body: {'photo_name': photoName,'id':Id},  // Fotoğraf adını gönderin
  );

  if (response.statusCode == 200) {
    print("Fotoğraf başarıyla silindi.");
  } else {
    print("Fotoğraf silinemedi: ${response.statusCode}");
  }
  return response;
}


  Future<http.Response> getDailyCombinations(String userId) async {
    var response = await http.post(
      Uri.parse('$baseUrl/daily_combinations'),
      headers: {
        'Content-Type': 'application/json',  // JSON formatında gönderilecek
      },
      body: jsonEncode({'user_id': userId}),  // JSON formatına dönüştürün
    );

    if (response.statusCode == 200) {
      print("Günlük kombinler başarıyla geldi.");
      var data=jsonDecode(response.body);
      print(data['kombin_listesi']);
    } else {
      print("Günlük kombinler getirelemedi: ${response.statusCode}");
      var data=jsonDecode(response.body);
      print(data['error']);
    }
    return response;
  }

  Future<http.Response> addFavoriteDb(String userId, String kombinId) async {
    var response = await http.post(
      Uri.parse('$baseUrl/add_favorite'),
      headers: {
        'Content-Type': 'application/json',  // JSON formatında gönderilecek
      },
      body: jsonEncode({'user_id': userId,'kombin_id':kombinId}),  // JSON formatına dönüştürün
    );

    if (response.statusCode == 200) {
      var data=jsonDecode(response.body);

    } else {
      print("Kombin Favorilere eklenemedi: ${response.statusCode}");
      var data=jsonDecode(response.body);
      print(data['error']);
    }

    return response;
  }

  Future<http.Response> getfavorites(String userId) async {
    var response = await http.post(
      Uri.parse('$baseUrl/get_favorites'),
      headers: {
        'Content-Type': 'application/json',  // JSON formatında gönderilecek
      },
      body: jsonEncode({'user_id': userId,}),  // JSON formatına dönüştürün
    );

    if (response.statusCode == 200) {
      var data=jsonDecode(response.body);

    } else {
      print("Favori listesi getirilemedi: ${response.statusCode}");
      var data=jsonDecode(response.body);
      print(data['error']);
    }
    return response;
  }

  Future<http.Response> getUserInfo(String userId) async {
    var response = await http.post(
      Uri.parse('$baseUrl/get_user_info'),
      headers: {
        'Content-Type': 'application/json',  // JSON formatında gönderilecek
      },
      body: jsonEncode({'user_id': userId,}),  // JSON formatına dönüştürün
    );

    if (response.statusCode == 200) {
      var data=jsonDecode(response.body);

    } else {
      print("Favori listesi getirilemedi: ${response.statusCode}");
      var data=jsonDecode(response.body);
      print(data['error']);
    }
    return response;
  }

  Future<http.Response> updateUserFromDb(String userId,String fname,String email,String phone,String password) async {
    var response = await http.post(
      Uri.parse('$baseUrl/update_user_info'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'user_id': userId,'fname':fname,'email':email,'phone':phone,'password':password}),  // JSON formatına dönüştürün
    );

    if (response.statusCode == 200) {
      var data=jsonDecode(response.body);

    } else {
      print("Favori listesi getirilemedi: ${response.statusCode}");
      var data=jsonDecode(response.body);
      print(data['error']);
    }
    return response;
  }



}
