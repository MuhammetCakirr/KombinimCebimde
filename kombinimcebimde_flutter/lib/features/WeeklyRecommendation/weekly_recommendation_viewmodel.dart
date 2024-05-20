import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/service.dart';

class WeeklyRecommendationViewModel extends ChangeNotifier {
  bool isLoading = false;
  String errorMessage = '';
  List<Map<String, dynamic>> weeklyRecommendations = [];

  final DjangoService service = DjangoService(); // API servisi

  Future<void> getWeeklyRecommendation() async {
    isLoading = true;
    notifyListeners();
    String userId = '';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('id') != null) {
      userId = prefs.getString('id')!;
    }

    try {
      final response = await service.getweeklyrecommendation(userId);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        errorMessage = '';
        weeklyRecommendations = processData(data);
        print(weeklyRecommendations);
      } else if (response.statusCode == 404) {
        // Veri bulunamadı durumunu işle
      } else {
        var data = jsonDecode(response.body);
        errorMessage = data['error'] ?? data['error'];
        throw Exception('Haftalık verileri alırken hata: ${data['error']}');
      }
    } catch (e) {
      // Hata durumunu işle
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> processData(dynamic data) {
    List<Map<String, dynamic>> result = [];
    data.forEach((dayData) {
      Map<String, dynamic> resultItem = {
        "Tarih": dayData["Tarih"],
        "Derece": dayData["Derece"],
        "Gunlukoneri": dayData["Gunlukoneri"]
      };
      result.add(resultItem);
    });
    return result;
  }
}