class Combin {
  final String id;
  final String lowerWearUrl;
  final String upperWearUrl1;
  final String upperWearUrl2;
  final String outerWearUrl;
  final String outerWearUrl2;
  final String warning;

  Combin({
    required this.id,
    required this.lowerWearUrl,
    required this.upperWearUrl1,
    this.upperWearUrl2 = '',
    this.outerWearUrl = '',
    this.outerWearUrl2 = '',
    this.warning = '',
  });

  factory Combin.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      throw Exception("Geçersiz veri: JSON null olamaz.");
    }

    // Alt Giyim kontrolü
    if (!json.containsKey('Alt Giyim') || json['Alt Giyim'] == null) {
      throw Exception("Eksik veya geçersiz Alt Giyim bilgisi.");
    }

    // Üst Giyim kontrolü
    if (!json.containsKey('Ust Giyim') || json['Ust Giyim'] == null) {
      throw Exception("Eksik veya geçersiz Ust Giyim bilgisi.");
    }

    // İkinci üst giyim alanı kontrolü
    String upperWearUrl2 = json.containsKey('Ust Giyim2') && json['Ust Giyim2'] != null
        ? json['Ust Giyim2']['imageUrl'] ?? ''
        : '';

    // Dış giyim kontrolü
    String outerWearUrl = json.containsKey('Dis Giyim') && json['Dis Giyim'] != null
        ? json['Dis Giyim']['imageUrl'] ?? ''
        : '';

    // İkinci dış giyim kontrolü
    String outerWearUrl2 = json.containsKey('Dis Giyim2') && json['Dis Giyim2'] != null
        ? json['Dis Giyim2']['imageUrl'] ?? ''
        : '';

    String warning = json.containsKey('Warning') && json['Warning'] != null
        ? json['Warning'].toString()
        : '';

    return Combin(
      id: json.containsKey('id') ? json['id'].toString() : 'unknown',
      lowerWearUrl: json['Alt Giyim']['imageUrl'],
      upperWearUrl1: json['Ust Giyim']['imageUrl'],
      upperWearUrl2: upperWearUrl2,
      outerWearUrl: outerWearUrl,
      outerWearUrl2: outerWearUrl2,
      warning: warning,
    );
  }
}