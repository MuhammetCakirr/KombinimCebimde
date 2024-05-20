from .models import UserFavorites, user,Category,userclothes,Kombin
from PIL import Image
from rembg import remove
import numpy as np
from PIL import Image
from django.http import JsonResponse
import re
from django.core.exceptions import ValidationError
from django.views.decorators.csrf import csrf_exempt
import json
from itertools import product
from django.core.files.storage import default_storage
from django.core.files.base import ContentFile
from rest_framework.decorators import api_view, parser_classes
from rest_framework.parsers import MultiPartParser
from rest_framework.response import Response
from rest_framework import status
import os
from django.conf import settings
import requests
from rest_framework.parsers import JSONParser
from .models import UserClothesSerializer
from PIL import Image
import pillow_heif
import itertools
from datetime import datetime, timedelta
import random

@api_view(['POST'])
@parser_classes([JSONParser])
def daily_combinations(request):
    try:
        user_id = request.data.get("user_id")
        if not user_id:
            return Response({"error": "Kullanıcı kimliği eksik."}, status=status.HTTP_400_BAD_REQUEST)
        try:  
            latitude = 41.015137
            longitude = 28.979530
            url = f"https://api.open-meteo.com/v1/forecast?latitude={latitude}&longitude={longitude}&daily=temperature_2m_max&timezone=auto"
            response = requests.get(url)
            if response.status_code != 200:
                return Response({"error": "Hava durumu verisi alınamadı."}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
            weather_data = response.json()
             
            temperature = weather_data["daily"]["temperature_2m_max"][0]
        except Exception as e:
            return Response({"error": f"Hava durumu API'si hatası: {str(e)}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        try:
            # Kullanıcıya ait kıyafetleri alın
            user_clothes_list = userclothes.objects.filter(userId=user_id)
            serializer = UserClothesSerializer(user_clothes_list, many=True)  # Listeler için 'many=True' kullanılır
            serialized_data = serializer.data  # JSON'a dönüştürülmüş veri

            if not user_clothes_list.exists():
                return Response({"suggested_combinations": []}, status=status.HTTP_200_OK)

        except Exception as e:
            return Response({"error": f"Kullanıcı kıyafetleri alınırken hata: {str(e)}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
        clothes_by_category = {
            "Tişört": [],
            "Gömlek": [],
            "Sweatshirt": [],
            "Süveter": [],
            "Pantolon": [],
            "Etek": [],
            "Şort": [],
            "Eşofman": [],
            "Mont": [],
            "Hırka": [],
            "Ceket": [],
            "Elbise": [],
            "Bluz": [],
            "Kazak": [],
        }

        try:
            for clothing in serialized_data:
                try:
                    category_id = clothing["categoryId"]
                    onecategory = Category.objects.get(id=category_id)
                    cat_name = onecategory.name

                except Category.DoesNotExist:
                    cat_name = "Bilinmiyor"  # Hata durumunda varsayılan kategori

                if cat_name in clothes_by_category:
                    clothes_by_category[cat_name].append(clothing)

        except Exception as e:
            return Response({"error": f"Kıyafet kategorilerini gruplama hatası: {str(e)}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        try:
            # Farklı sıcaklık aralıkları için kategori kombinasyonlarını tanımlama
            temperature_ranges = {
                (0, 9): ['Pantolon', 'Sweatshirt', 'Mont','Kazak','Tişört','Hırka'],
                (10, 15): ['Pantolon', 'Sweatshirt', 'Mont', 'Ceket','Kazak','Tişört','Hırka'],
                (16, 25): ['Pantolon', 'Tişört', 'Ceket','Hırka','Eşofman','Gömlek'],
                (26, 35): ['Pantolon','Şort', 'Tişört','Eşofman','Gömlek']
            }
            disgiyim_categories = ['Ceket', 'Mont', 'Hırka']
            kislikgiyim_categories = ['Kazak', 'SweatShirt','Süveter']
            alt_giyim_categories = ['Pantolon', 'Şort','Eşofman']
            ust_giyim_categories = ['Tişört', 'Gömlek']
            # Belirtilen sıcaklık aralığı için kategorileri bulun
            for temp_range, categories in temperature_ranges.items():
                if temp_range[0] <= temperature <= temp_range[1]:
                    # Geçerli kategorileri alın ve boş olmayanları kontrol edin
                    valid_categories = [category for category in categories if category in clothes_by_category and clothes_by_category[category]]
                    
                    if not valid_categories:
                        continue  # Hiç geçerli kategori yoksa, devam edin
                    if 25<= temperature <= 35:
                        print("girdi 25 üstü ")
                        kombin_listesi=  get_saved_combinations(user_id,1)            
                        if isinstance(kombin_listesi, list) and len(kombin_listesi) > 0:
                            random.shuffle(kombin_listesi)
                            return Response({"kombin_listesi": kombin_listesi}, status=status.HTTP_200_OK)
                        else:
                            print("else girdi 25 üstü ")
                            create_yaz_kombini(user_id, clothes_by_category)
                            kombin_listesi = get_saved_combinations(user_id, 1)
                            if kombin_listesi:
                                random.shuffle(kombin_listesi)
                                return Response({"kombin_listesi": kombin_listesi}, status=status.HTTP_200_OK)
                            else:
                                return Response({"error": "Uygun kombinasyon bulunamadı."}, status=status.HTTP)
                        
                    elif 16<= temperature <=24:
                        kombin_listesi= get_saved_combinations(user_id,2)  
                        print("girdi 20 derece")
                        if isinstance(kombin_listesi, list) and len(kombin_listesi) > 0:
                            random.shuffle(kombin_listesi)
                            return Response({"kombin_listesi": kombin_listesi}, status=status.HTTP_200_OK)
                        else:
                            create_ilkbahar_kombini(user_id, clothes_by_category)
                            kombin_listesi = get_saved_combinations(user_id, 2)
                            if kombin_listesi:
                                random.shuffle(kombin_listesi)
                                return Response({"kombin_listesi": kombin_listesi}, status=status.HTTP_200_OK)
                            else:
                                return Response({"error": "Uygun kombinasyon bulunamadı."}, status=status.HTTP)
                        
                    elif 8 <= temperature <= 15:
                        kombin_listesi = get_saved_combinations(user_id,3) 
                        print("girdi")
                        if isinstance(kombin_listesi, list) and len(kombin_listesi) > 0:
                            random.shuffle(kombin_listesi)
                            return Response({"kombin_listesi": kombin_listesi}, status=status.HTTP_200_OK)
                        else:
                            
                            create_sonbahar_kombini(user_id, clothes_by_category)
                            kombin_listesi = get_saved_combinations(user_id, 3)
                            random.shuffle(kombin_listesi)
                            if kombin_listesi:
                                return Response({"kombin_listesi": kombin_listesi}, status=status.HTTP_200_OK)
                            else:
                                return Response({"error": "Uygun kombinasyon bulunamadı."}, status=status.HTTP)

                    elif temperature <= 7:
                        print("girdi 7 derece altı ")
                        kombin_listesi = get_saved_combinations(user_id, 4)
                        if isinstance(kombin_listesi, list) and len(kombin_listesi) > 0:
                            random.shuffle(kombin_listesi)
                            return Response({"kombin_listesi": kombin_listesi}, status=status.HTTP_200_OK)
                        else:
                            create_kis_kombini(user_id, clothes_by_category)
                            kombin_listesi = get_saved_combinations(user_id, 4)
                            random.shuffle(kombin_listesi)
                            if kombin_listesi:
                                return Response({"kombin_listesi": kombin_listesi}, status=status.HTTP_200_OK)
                            else:
                                return Response({"error": "Uygun kombinasyon bulunamadı."}, status=status.HTTP)        
        except Exception as e:
            return Response({"error": f"Kombinasyon oluşturma hatası: {str(e)}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        return Response({"suggested_combinations": []}, status=status.HTTP_200_OK)

    except Exception as e:
        return Response({"error": f"Genel hata: {str(e)}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['POST'])
@parser_classes([JSONParser])
def get_weekly_outfit_recommendations(request):
    try:
        user_id = request.data.get("user_id")  # Kullanıcı kimliğini al
        
        if not user_id:
            return JsonResponse({"status": "error", "message": "Kullanıcı kimliği eksik."}, status=400)
        
        # Bugünden itibaren haftanın her gününün tarihini ve hava durumunu al
        today = datetime.today()
        weekly_recommendations = []
        
        aylar = {
            'January': 'Ocak',
            'February': 'Şubat',
            'March': 'Mart',
            'April': 'Nisan',
            'May': 'Mayıs',
            'June': 'Haziran',
            'July': 'Temmuz',
            'August': 'Ağustos',
            'September': 'Eylül',
            'October': 'Ekim',
            'November': 'Kasım',
            'December': 'Aralık'
        }

        gunler = {
            'Monday': 'Pazartesi',
            'Tuesday': 'Salı',
            'Wednesday': 'Çarşamba',
            'Thursday': 'Perşembe',
            'Friday': 'Cuma',
            'Saturday': 'Cumartesi',
            'Sunday': 'Pazar'
        }

        for day_offset in range(7):
            # Belirli bir günün tarihini hesapla
            current_date = today + timedelta(days=day_offset)
            formatted_date = current_date.strftime("%Y-%m-%d")
            latitude = 41.015137
            longitude = 28.979530
            # Hava durumu API'sinden veri çek
            url = f"https://api.open-meteo.com/v1/forecast?latitude={latitude}&longitude={longitude}&daily=temperature_2m_max&timezone=auto"
            response = requests.get(url)
            data = response.json()

            # Günün en yüksek sıcaklığını al
            max_temperatures = data['daily']['temperature_2m_max']
            temperature_index = data['daily']['time'].index(formatted_date)
            temperature_for_date = max_temperatures[temperature_index]

            # Hava durumuna göre kombinasyon önerisi oluştur
            if 25< temperature_for_date <= 35:
                kombin_listesi = get_saved_combinations(user_id, 1)
                
                
            elif 16 <= temperature_for_date <= 25:
                kombin_listesi = get_saved_combinations(user_id, 2)

            elif 8 <= temperature_for_date <= 15:
                kombin_listesi = get_saved_combinations(user_id, 3)

            elif temperature_for_date <= 7:
                kombin_listesi = get_saved_combinations(user_id, 4)
            else:
                kombin_listesi = []

            # Öneriyi listeye ekle
            turkce_tarih = current_date.strftime('%d %B %A').replace(current_date.strftime('%B'), aylar[current_date.strftime('%B')]).replace(current_date.strftime('%A'), gunler[current_date.strftime('%A')])
            if kombin_listesi:
                # Kombin listesinden rastgele 10 eleman seç
                 kombin_listesi = random.sample(kombin_listesi, min(len(kombin_listesi), 10))
            outfit_recommendation = {
                "Tarih": turkce_tarih,
                "Derece": temperature_for_date,
                "Gunlukoneri": kombin_listesi if kombin_listesi else "Uygun kombinasyon bulunamadı."
            }
            weekly_recommendations.append(outfit_recommendation)
        return JsonResponse(weekly_recommendations, safe=False)

    except Exception as e:
        return JsonResponse({"status": "error", "message": str(e)}, status=500)

@api_view(['GET'])

def get_weather(request):
    try:
        
        latitude = 41.015137
        longitude = 28.979530
        url = f"https://api.open-meteo.com/v1/forecast?latitude={latitude}&longitude={longitude}&daily=temperature_2m_max,weathercode&timezone=auto"
        response = requests.get(url)
        
        if response.status_code != 200:
            return Response({"error": "Hava durumu verisi alınamadı."}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
        weather_data = response.json()
        
        # Sıcaklık ve hava durumu sembolünü alın
        temperature = weather_data["daily"]["temperature_2m_max"][0]  # İlk günün maksimum sıcaklığı
        weather_code = weather_data["daily"]["weathercode"][0]  # Hava durumu kodu
        
        # Hava durumu sembolünden durumu çıkarın (örneğin, güneşli, yağmurlu)
        weather_status = "Unknown"
        if weather_code == 1:
            weather_status = "Güneşli"
        elif weather_code in [2, 3]:
            weather_status = "Çoğunlukla Güneşli"
        elif weather_code in [45, 48]:
            weather_status = "Sisli"
        elif weather_code in [51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 71, 73, 75, 77, 80, 81, 82, 85, 86]:
            weather_status = "Yağmurlu"
        elif weather_code in [95, 96, 99]:
            weather_status = "Fırtınalı"
        
        
        response= Response({
            "status": "success",
            "temperature": temperature,
            "weather_code": weather_code,
        }, status=status.HTTP_200_OK)
        response["Content-Type"] = "application/json; charset=utf-8"
        
        return response
    
    except Exception as e:
        return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

def create_yaz_kombini(user_id, clothes_by_category):
    try:
        
        # Alt ve üst giyim kategorilerinden Tüm öğeleri seçmek için
        alt_giyim_options = [
            item for category in ['Pantolon', 'Şort'] 
            for item in clothes_by_category.get(category, [])
        ]
        
        ust_giyim_options = [
            item for category in ['Tişört'] 
            for item in clothes_by_category.get(category, [])
        ]
        

        all_combinations = list(product(alt_giyim_options, ust_giyim_options))
        

        suggested_combinations = []
        for alt_giyim, ust_giyim in all_combinations:

            suggested_combinations.append({
                "Alt Giyim": alt_giyim,
                "Ust Giyim": ust_giyim,
                "Ust Giyim2": "",
                "Dis Giyim": "",
                "Dis Giyim2": "",
                "Warning":""
            })

        save_combinations(user_id, suggested_combinations, 1)    

    except Exception as e:
        raise RuntimeError(f"Kombinasyon oluşturma hatası: {str(e)}")
    
def create_ilkbahar_kombini(user_id, clothes_by_category):
    try:
        # Alt giyim kategorisinden pantolon seçeneklerini al
        print("girdi create_ilkbahar_kombini fonksiyonu")
        alt_giyim_options = clothes_by_category.get('Pantolon', [])

        # Üst giyim kategorilerinden tişört ve gömlek seçeneklerini al
        ust_giyim_options = clothes_by_category.get('Tişört', []) + clothes_by_category.get('Gömlek', [])

        # Dış giyim kategorilerinden hırka ve ceket seçeneklerini al
        dis_giyim_options = clothes_by_category.get('Hırka', []) + clothes_by_category.get('Ceket', [])

        suggested_combinations = []

        # Eğer hiç dış giyim seçeneği yoksa uyarı ekle ve dış giyim olmadan kombinasyonları oluştur
        if not dis_giyim_options:
            warning_message = (
                "Üstünüze giymek için hiçbir dış giyim (Hırka, Mont, Ceket) ürününüz yok. "
                "Önerilen kombinin üzerine bir dış giyim ürünü giymenizi öneririm."
            )

            for alt_giyim in alt_giyim_options:
                for ust_giyim in ust_giyim_options:
                    suggested_combinations.append({
                        "Alt Giyim": alt_giyim,
                        "Ust Giyim": ust_giyim,
                        "Ust Giyim2": None,
                        "Dis Giyim": None, 
                        "Dis Giyim2": None, # Eğer tek parça üst giyim ise dış giyim yok
                        "Warning": warning_message,
                    })

        else:
            print("girdi create_ilkbahar_kombini else")
            for alt_giyim in alt_giyim_options:
                for ust_giyim_combo in ust_giyim_options + [None]:
                    # Eğer ust_giyim_combo None ise, yani sadece bir üst giyim varsa
                    if ust_giyim_combo is None:
                        for dis_giyim in dis_giyim_options:
                            suggested_combinations.append({
                                "Alt Giyim": alt_giyim,
                                "Ust Giyim": ust_giyim_options[0],  # İlk üst giyim
                                "Ust Giyim2": None,
                                "Dis Giyim": dis_giyim,
                                "Dis Giyim2": None,
                                "Warning": "",
                            })
                    else:
                        for ust_giyim in ust_giyim_options:
                            if ust_giyim != ust_giyim_combo and ust_giyim['categoryId'] != ust_giyim_combo['categoryId']:
                                suggested_combinations.append({
                                    "Alt Giyim": alt_giyim,
                                    "Ust Giyim": ust_giyim_combo,  # İkinci üst giyim
                                    "Ust Giyim2": ust_giyim,
                                    "Dis Giyim": None,
                                    "Dis Giyim2": None,
                                    "Warning": "",
                                })

        # Aynı categoryId'ye sahip üst giyim öğelerini filtrele
        filtered_combinations = []
        for combination in suggested_combinations:
            if combination["Ust Giyim2"] is None or combination["Ust Giyim2"]['categoryId'] != combination["Ust Giyim"]['categoryId']:
                filtered_combinations.append(combination)

        save_combinations(user_id, filtered_combinations, 2)

    except Exception as e:
        print(f"Hata: {str(e)}")
        raise RuntimeError(f"Kombinasyon oluşturma hatası: {str(e)}")

def create_sonbahar_kombini(user_id, clothes_by_category):
    
    try:
        alt_giyim_options = clothes_by_category.get('Pantolon', [])
        ust_giyim_options = sum((clothes_by_category.get(category, []) for category in ['Tişört', 'Gömlek', 'Sweatshirt', 'Kazak', 'Süveter']), [])
        dis_giyim_options = sum((clothes_by_category.get(category, []) for category in ['Hırka', 'Mont', 'Ceket']), [])
        
        if not alt_giyim_options or not ust_giyim_options or not dis_giyim_options:
            raise RuntimeError("Kombin oluşturmak için yeterli giyim seçeneği bulunamadı.")
        
        

        suggested_combinations = []

        # Tüm kombinasyonları oluştur
        for alt_giyim, ust_giyim, dis_giyim in product(alt_giyim_options, ust_giyim_options, dis_giyim_options):
            # Aynı kategoride üst giyimler varsa veya dış giyimler varsa kombinasyon atla
            if ust_giyim['categoryId'] == dis_giyim['categoryId']:
                continue
                
            # İkinci üst giyim ve dış giyim seçeneklerini kontrol et
            ust_giyim2 = None
            dis_giyim2 = None
            if len(ust_giyim_options) > 1:
                ust_giyim2 = ust_giyim_options[1]
            if len(dis_giyim_options) > 1:
                dis_giyim2 = dis_giyim_options[1]

            # Üst giyim kategorilerinin ve dış giyim kategorilerinin farklı olup olmadığını kontrol et
            if ust_giyim['categoryId'] != ust_giyim2['categoryId'] and ust_giyim['id'] != ust_giyim2['id'] and dis_giyim['id'] != dis_giyim2['id'] :
                suggested_combinations.append({
                    "Alt Giyim": alt_giyim,
                    "Ust Giyim": ust_giyim,
                    "Ust Giyim2": ust_giyim2,
                    "Dis Giyim": dis_giyim,
                    "Dis Giyim2": dis_giyim2,
                    "Warning":""
                })
                
        save_combinations(user_id, suggested_combinations, 3)

    except Exception as e:
        raise RuntimeError(f"Kombinasyon oluşturma hatası: {str(e)}") 
    
def create_kis_kombini(user_id, clothes_by_category):
    print("girdi create_kis_kombini ")
    try:
        alt_giyim_options = clothes_by_category.get('Pantolon', [])
        ust_giyim_options = sum((clothes_by_category.get(category, []) for category in ['Tişört', 'Gömlek', 'Sweatshirt', 'Kazak', 'Süveter']), [])
        hirka_options = clothes_by_category.get('Hırka', [])
        mont_options = clothes_by_category.get('Mont', [])
        
        if not alt_giyim_options or not ust_giyim_options or not hirka_options or not mont_options:
            raise RuntimeError("Kombin oluşturmak için yeterli giyim seçeneği bulunamadı.")
        
        print("girdi for üstüne ")

        suggested_combinations = []

        # Tüm kombinasyonları oluştur
        for alt_giyim, ust_giyim, hirka in product(alt_giyim_options, ust_giyim_options, hirka_options):
            # Aynı kategoride üst giyimler veya dış giyimler varsa kombinasyon atla
            if ust_giyim['categoryId'] == hirka['categoryId']:
                continue
                
            # İkinci üst giyim seçeneğini kontrol et
            ust_giyim2 = None
            if len(ust_giyim_options) > 1:
                ust_giyim2 = ust_giyim_options[1]

            # Montun kesin olmasını sağla
            for mont in mont_options:
                # İkinci üst giyim farklı kategoride ve farklı bir öğe mi kontrol et
                if ust_giyim2['categoryId'] != ust_giyim['categoryId'] and ust_giyim2['id'] != ust_giyim['id']:
                    suggested_combinations.append({
                        "Alt Giyim": alt_giyim,
                        "Ust Giyim": ust_giyim,
                        "Ust Giyim2": ust_giyim2,
                        "Dis Giyim": mont,
                        "Dis Giyim2": hirka,
                        "Warning":""
                    })
                
        save_combinations(user_id, suggested_combinations, 4)

    except Exception as e:
        raise RuntimeError(f"Kombinasyon oluşturma hatası: {str(e)}") 

def save_combinations(userId, combinations, tur):
    try:       
        Kombin.objects.filter(userId=userId, tur=tur).delete()  
        if not combinations:
            return JsonResponse({"status": "error", "message": "Kombinasyon listesi boş."}, status=400)
        
        for combination in combinations:
            try:
                # Alt giyim
                altgiyim_id = None
                if 'Alt Giyim' in combination and isinstance(combination['Alt Giyim'], dict):
                    altgiyim_id = combination['Alt Giyim'].get('id')

                # Üst giyim
                ustgiyim_id = None
                if 'Ust Giyim' in combination and isinstance(combination['Ust Giyim'], dict):
                    ustgiyim_id = combination['Ust Giyim'].get('id')

                # İkinci üst giyim
                ustgiyim2_id = None
                if 'Ust Giyim2' in combination and isinstance(combination['Ust Giyim2'], dict):
                    ustgiyim2_id = combination['Ust Giyim2'].get('id')

                # Dış giyim
                disgiyim_id = None
                if 'Dis Giyim' in combination and isinstance(combination['Dis Giyim'], dict):
                    disgiyim_id = combination['Dis Giyim'].get('id')

                # İkinci dış giyim
                disgiyim2_id = None
                if 'Dis Giyim2' in combination and isinstance(combination['Dis Giyim2'], dict):
                    disgiyim2_id = combination['Dis Giyim2'].get('id')

                Kombin.objects.create(   
                    userId=userId, 
                    altgiyimId=altgiyim_id,
                    ustgiyimId=ustgiyim_id,
                    ustgiyim2Id=ustgiyim2_id,
                    disgiyimId=disgiyim_id,
                    disgiyim2Id=disgiyim2_id,
                    warning=combination.get('Warning', ''),
                    tur=tur
                )
                
            except Exception as e:
                print({"status": "error", "message": str(e)})

    except Exception as e:
        return JsonResponse({"status": "error", "message": str(e)}, status=400) 
   
def get_saved_combinations(userId, tur):
    print('get_saved_combinations fonksiyonuna girdi.')
    try:
        # Kullanıcının kaydedilmiş kombinasyonlarını alın
        user_combinations = Kombin.objects.filter(userId=userId, tur=tur)
        
        if not user_combinations.exists():
            return JsonResponse({"status": "error", "message": "Kaydedilmiş kombinasyon bulunamadı."}, status=404)
        
        saved_combinations = []
        
        # Her kombinasyon için ilgili kıyafet URL'lerini alın
        for combin in user_combinations:
            combination_info = {
                "id": combin.id,
                "Alt Giyim": None,
                "Ust Giyim": None,
                "Ust Giyim2": None,
                "Dis Giyim": None,
                "Dis Giyim2": None,
                "Warning": combin.warning
            }

            # Alt giyim
            if combin.altgiyimId:
                alt_clothes = userclothes.objects.filter(id=combin.altgiyimId).first()
                combination_info["Alt Giyim"] = {
                    "id": combin.altgiyimId,
                    "imageUrl": alt_clothes.imageUrl if alt_clothes else "",
                }

            # Üst giyim
            if combin.ustgiyimId:
                ust_clothes = userclothes.objects.filter(id=combin.ustgiyimId).first()
                combination_info["Ust Giyim"] = {
                    "id": combin.ustgiyimId,
                    "imageUrl": ust_clothes.imageUrl if ust_clothes else "",
                }

            # İkinci üst giyim
            if combin.ustgiyim2Id:
                ust2_clothes = userclothes.objects.filter(id=combin.ustgiyim2Id).first()
                combination_info["Ust Giyim2"] = {
                    "id": combin.ustgiyim2Id,
                    "imageUrl": ust2_clothes.imageUrl if ust2_clothes else "",
                }

            # Dış giyim
            if combin.disgiyimId:
                dis_clothes = userclothes.objects.filter(id=combin.disgiyimId).first()
                combination_info["Dis Giyim"] = {
                    "id": combin.disgiyimId,
                    "imageUrl": dis_clothes.imageUrl if dis_clothes else "",
                }

            # İkinci dış giyim
            if combin.disgiyim2Id:
                dis2_clothes = userclothes.objects.filter(id=combin.disgiyim2Id).first()
                combination_info["Dis Giyim2"] = {
                    "id": combin.disgiyim2Id,
                    "imageUrl": dis2_clothes.imageUrl if dis2_clothes else "",
                }

            saved_combinations.append(combination_info)
        
        return saved_combinations

    except Exception as e:
        print(f"Hata: {str(e)}")
        return []
@csrf_exempt
@api_view(['POST']) 
def add_favorite(request):
    try:
        data = json.loads(request.body)
        user_id = data.get('user_id')
        kombin_id = data.get('kombin_id')

        if not user_id or not kombin_id:
            return JsonResponse({'error': 'Eksik veri.'}, status=400)

        # Kullanıcı için favori kaydı olup olmadığını kontrol edin
        user_fav, created = UserFavorites.objects.get_or_create(userId=user_id)

        # Mevcut favori kombinasyonlarının dizisini al
        if user_fav.favoriteIds:
            favorite_ids_list = user_fav.favoriteIds.split(",")  # Virgülle ayrılmış
        else:
            favorite_ids_list = []

        # Eğer kombin zaten favorilerdeyse, eklemeyi önle
        if kombin_id in favorite_ids_list:
            update_favorite(user_id,kombin_id)
            return JsonResponse({'status': 'success', 'message': 'Kombin favorilerden çıkarıldı.'}, status=200)

        # Yeni kombinId'yi listeye ekle
        favorite_ids_list.append(kombin_id)

        # Listeyi yeniden virgülle ayırarak dizeye dönüştür
        user_fav.favoriteIds = ",".join(favorite_ids_list)

        user_fav.save()  # Veritabanında kaydedin

        return JsonResponse({'status': 'success', 'message': 'Kombin favorilere eklendi.'}, status=200)

    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)

def update_favorite(user_id,kombin_id):
    try:
        if not user_id or not kombin_id:  # Eksik veri kontrolü
            return JsonResponse({'error': 'Eksik veri.'}, status=400)

        # Kullanıcı için favori kaydı olup olmadığını kontrol edin
        user_fav, created = UserFavorites.objects.get_or_create(userId=user_id)

        # Mevcut favori kombinasyonlarının listesini alın
        if user_fav.favoriteIds:
            favorite_ids_list = user_fav.favoriteIds.split(",")  # Virgülle ayrılmış liste
        else:
            favorite_ids_list = []  # Favori olmayan liste

        # Eğer kombinasyon favorilerdeyse, çıkartın
        if kombin_id in favorite_ids_list:
            favorite_ids_list.remove(kombin_id)  # Listeden kombinasyon kimliğini çıkartın
            user_fav.favoriteIds = ",".join(favorite_ids_list)  # Listeyi virgülle ayırarak dizeye dönüştür
            user_fav.save()  # Güncellenmiş favorileri kaydedin

            return JsonResponse({'status': 'success', 'message': 'Kombin favorilerden çıkarıldı.'}, status=200)

        return JsonResponse({'error': 'Kombin favorilerde değil.'}, status=400)

    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)  # Hata durumunda istisna yakalama   

@csrf_exempt
@api_view(['POST']) 
def get_favorites(request):
    try:
        data = json.loads(request.body)
        user_id = data.get('user_id')  # İstekten kullanıcı kimliğini alın

        if not user_id:
            return JsonResponse({'error': 'Kullanıcı kimliği eksik.'}, status=400)

        # Kullanıcının favori kombinasyonlarını alın
        try:
            user_fav = UserFavorites.objects.get(userId=user_id)  # Kullanıcıya ait favori kaydını alın
            favorite_ids = user_fav.favoriteIds.split(",") if user_fav.favoriteIds else []  # Virgülle ayrılmış liste

            if not favorite_ids:  # Eğer favori kimlikleri boşsa
                return JsonResponse({
                    'status': 'success',
                    'favorite_combinations': []
                }, status=200)  # Boş bir liste ile başarılı yanıt döndürün

            # Favori kombinasyonların ayrıntılarını alın
            combinations = Kombin.objects.filter(id__in=favorite_ids)  # Belirtilen kimliklerle kombinasyonları alın

            # Her kombinasyon için ilgili kıyafetlerin ayrıntılarını alın
            favorite_combinations = []
            for combin in combinations:
                combination_data = {
                    'id': combin.id,
                    'Alt Giyim': {
                        'id': combin.altgiyimId,
                        'imageUrl': userclothes.objects.get(id=combin.altgiyimId).imageUrl
                    },
                    'Ust Giyim': {
                        'id': combin.ustgiyimId,
                        'imageUrl': userclothes.objects.get(id=combin.ustgiyimId).imageUrl
                    },
                    'Ust Giyim2': {
                        'id': combin.ustgiyim2Id,
                        'imageUrl': userclothes.objects.get(id=combin.ustgiyim2Id).imageUrl if combin.ustgiyim2Id else None
                    },
                    'Dis Giyim': {
                        'id': combin.disgiyimId,
                        'imageUrl': userclothes.objects.get(id=combin.disgiyimId).imageUrl if combin.disgiyimId else None
                    },
                    'Dis Giyim2': {
                        'id': combin.disgiyim2Id,
                        'imageUrl': userclothes.objects.get(id=combin.disgiyim2Id).imageUrl if combin.disgiyim2Id else None
                    },
                    'Warning': combin.warning  # Uyarı mesajı, eğer varsa
                }
                favorite_combinations.append(combination_data)  # Favori kombinasyonları listeye ekleyin

            return JsonResponse({
                'status': 'success',
                'favorite_combinations': favorite_combinations
            }, status=200)

        except UserFavorites.DoesNotExist:
            return JsonResponse({'error': 'Favoriler bulunamadı.'}, status=404)

    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)  # Hata durumunda

@api_view(['POST']) 
def delete_photo(request):
    try:
        data = request.data  # İstekten gelen verileri alın
        photo_name = data.get('photo_name')  # Dosya adı
        record_id = data.get('id')  # Silinecek veritabanı kaydının ID'si

        if not photo_name or not record_id:  # Eksik veri varsa hata döndür
            return Response(
                {"error": "Fotoğraf adı ve ID gereklidir."},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Veritabanında kaydı ID'ye göre bul
        photo_record = userclothes.objects.filter(id=record_id).first()
        user_id = photo_record.userId

        if not photo_record or photo_record.imageUrl != photo_name:
            # Kayıt bulunamazsa veya dosya adı eşleşmezse hata döndür
            return Response(
                {"error": "Kayıt bulunamadı veya eşleşme yok."},
                status=status.HTTP_404_NOT_FOUND
            )

        # Dosya yolunu ayarlayın
        file_path = os.path.join('uploads', photo_name)

        if default_storage.exists(file_path):
            default_storage.delete(file_path)  # Dosyayı sistemden silin

        photo_record.delete()  # Veritabanındaki kaydı silin

        latitude = 41.015137
        longitude = 28.979530
        temperature = get_current_temperature(latitude, longitude)
        
        clothes_by_category=get_user_clothes_by_category(user_id)

        try:
            # Farklı sıcaklık aralıkları için kategori kombinasyonlarını tanımlama
            temperature_ranges = {
                (0, 9): ['Pantolon', 'Sweatshirt', 'Mont','Kazak','Tişört','Hırka'],
                (10, 15): ['Pantolon', 'Sweatshirt', 'Mont', 'Ceket','Kazak','Tişört','Hırka'],
                (16, 25): ['Pantolon', 'Tişört', 'Ceket','Hırka','Eşofman','Gömlek'],
                (26, 35): ['Pantolon','Şort', 'Tişört','Eşofman','Gömlek']
            }   
            # Belirtilen sıcaklık aralığı için kategorileri bulun
            for temp_range, categories in temperature_ranges.items():
                if temp_range[0] <= temperature <= temp_range[1]:
                    # Geçerli kategorileri alın ve boş olmayanları kontrol edin
                    valid_categories = [category for category in categories if category in clothes_by_category and clothes_by_category[category]]
                    if not valid_categories:
                        continue  # Hiç geçerli kategori yoksa, devam edin
                    if 26 <= temperature <= 35:
                        create_yaz_kombini(user_id,clothes_by_category)            
                    elif 16<= temperature <=25:
                        create_ilkbahar_kombini(user_id,clothes_by_category)
                    elif 8 <= temperature <= 15:
                        print('fotoğraf sildikten sonra tekrar oluşma ifine girdi')
                        create_sonbahar_kombini(user_id,clothes_by_category)
                    elif temperature <=7:
                        create_kis_kombini(user_id,clothes_by_category)
        except Exception as e:
            return Response({"error": f"Kombinasyon oluşturma hatası: {str(e)}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        return Response(
            {"success": "Fotoğraf ve veritabanı kaydı başarıyla silindi."},
            status=status.HTTP_200_OK
        )

    except Exception as e:
        return Response(
            {"error": f"Bir hata oluştu: {str(e)}"},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )

@api_view(['POST'])  
def getUserClothes(request):
    try:
        # İstekten kullanıcı kimliğini al
        data = json.loads(request.body)  # JSON'dan veri al
        user_id = data.get("user_id")  # Kullanıcı kimliğini al
        
        if not user_id:  # Kullanıcı kimliği eksikse
            return Response(
                {"error": "Kullanıcı kimliği gereklidir."},
                status=status.HTTP_400_BAD_REQUEST
            )
        print(user_id)
        # Kullanıcı kimliğine göre kıyafetleri alın
        user_clothes = userclothes.objects.filter(userId=user_id)

        # Eğer kullanıcıya ait kıyafet yoksa
        if not user_clothes.exists():
            return Response(
                {"message": "Bu kullanıcıya ait kıyafet bulunamadı."},
                status=status.HTTP_404_NOT_FOUND
            )

        # Kıyafetleri bir liste olarak döndür
        clothes_list = [{"id": item.id, "categoryId": item.categoryId, "imageUrl": item.imageUrl} for item in user_clothes]
        print(clothes_list)
        return Response(
            {"clothes": clothes_list},
            status=status.HTTP_200_OK
        )

    except Exception as e:  # Hata durumunda
        return Response(
            {"error": str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )

@api_view(['POST'])
@parser_classes([MultiPartParser])
def uploadimages(request):
    files = request.FILES.getlist('file')  
    if not files:
        return Response(
            {"error": "Dosyalar eksik."},
            status=status.HTTP_400_BAD_REQUEST,
        )
    upload_folder = os.path.join(settings.MEDIA_ROOT, 'uploads')

    if not os.path.exists(upload_folder):
        os.makedirs(upload_folder) 
    for file in files:
        match = re.search(r'_user_(\d+)_category_(\d+)\.', file.name)  
        if match:
            user_id = match.group(1)  
            category_id = match.group(2)  
            new_file_name = f"{os.path.splitext(file.name)[0]}.png"  
            file_path = os.path.join(upload_folder, new_file_name)
            
            cropped_image = crop_unused_regions(file)  
            cropped_image.save(file_path, "PNG")  
            userclothes.objects.create(
                userId=user_id,  
                imageUrl=file_path,
                categoryId=category_id, 
            )

    latitude = 41.015137
    longitude = 28.979530
    temperature = get_current_temperature(latitude, longitude)
    clothes_by_category=get_user_clothes_by_category(user_id)
    
    try:
        # Farklı sıcaklık aralıkları için kategori kombinasyonlarını tanımlama
        temperature_ranges = {
            (0, 9): ['Pantolon', 'Sweatshirt', 'Mont','Kazak','Tişört','Hırka'],
            (10, 15): ['Pantolon', 'Sweatshirt', 'Mont', 'Ceket','Kazak','Tişört','Hırka'],
            (16, 25): ['Pantolon', 'Tişört', 'Ceket','Hırka','Eşofman','Gömlek'],
            (26, 35): ['Pantolon','Şort', 'Tişört','Eşofman','Gömlek']
        }   
        # Belirtilen sıcaklık aralığı için kategorileri bulun
        for temp_range, categories in temperature_ranges.items():
            if temp_range[0] <= temperature <= temp_range[1]:
                # Geçerli kategorileri alın ve boş olmayanları kontrol edin
                valid_categories = [category for category in categories if category in clothes_by_category and clothes_by_category[category]]
                if not valid_categories:
                    continue  # Hiç geçerli kategori yoksa, devam edin
                if 26 <= temperature <= 35:
                    create_yaz_kombini(user_id,clothes_by_category)            
                elif 16<= temperature <=25:
                    create_ilkbahar_kombini(user_id,clothes_by_category)
                elif 8 <= temperature <= 15:
                    create_sonbahar_kombini(user_id,clothes_by_category)
                elif temperature <=7:
                    create_kis_kombini(user_id,clothes_by_category)
   
    except Exception as e:
        return Response({"error": f"Kombinasyon oluşturma hatası: {str(e)}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    return Response(
        {"success": "Fotoğraflar başarıyla yüklendi."},
        status=status.HTTP_200_OK,
    )

@csrf_exempt
def getCategories(request):
    if request.method == 'GET':  # Yalnızca GET isteği kabul edilir
        try:
            categories = Category.objects.all()  # Tüm kategorileri getir

            # Kategorileri JSON formatında liste olarak döndür
            category_data = [
                {
                    "id": category.id,
                    "name": category.name,
                }
                for category in categories
            ]

            return JsonResponse({"categories": category_data}, status=200)

        except Exception as e:
            return JsonResponse({"error": f"Bir hata oluştu: {str(e)}"}, status=500)  # Genel hata yakalama

    else:
        return JsonResponse({"error": "Yalnızca GET isteği kabul edilir."}, status=405)  # Sadece GET istekleri için
    
@csrf_exempt
def login(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)  # JSON'dan veri alma

            # Gerekli alanların kontrolü
            if not data.get('email') or not data.get('password'):
                return JsonResponse({"error": "E-posta ve şifre gereklidir."}, status=400)

            # Verilen e-posta ile kullanıcı olup olmadığını kontrol et
            try:    
                mevcut_kullanici = user.objects.get(email=data['email'])  # E-posta ile kullanıcı bul
            except user.DoesNotExist:
                return JsonResponse({"error": "Böyle bir kullanıcı yok."}, status=404)  # Kullanıcı yok

            # Şifre kontrolü

            if data['password'] == mevcut_kullanici.password:  # Şifre doğru mu?
                user_data = {
                    "id": mevcut_kullanici.id,
                    "fname": mevcut_kullanici.fname,
                    "email": mevcut_kullanici.email,
                    "phone": mevcut_kullanici.phone,
                    "is_active": mevcut_kullanici.is_active,
                    "date_joined": mevcut_kullanici.date_joined,
                }
                
                return JsonResponse({"success": "Giriş başarılı.", "user": user_data}, status=200)  # Başarılı giriş
            else:
                
                return JsonResponse({"error": "Yanlış şifre."}, status=401)  # Yanlış şifre

        except Exception as e:
            return JsonResponse({"error": f"Bir hata oluştu: {str(e)}"}, status=500)

    else:
        return JsonResponse({"error": "Yalnızca POST isteği kabul edilir."}, status=405)

@csrf_exempt
def signup(request):
    if request.method == 'POST':
        
        try:
            data = json.loads(request.body)

            # E-posta, isim ve şifre gibi gerekli alanları kontrol ediyoruz
            if not data.get('fname') or not data.get('email') or not data.get('password') or not data.get('phone'):
                return JsonResponse({"error": "Lütfen Tüm alanları Doldurunuz."}, status=400)


            # E-postanın zaten var olup olmadığını kontrol et
            if user.objects.filter(email=data['email']).exists():
                return JsonResponse({"error": "Bu e-posta zaten kullanılıyor."}, status=409)  # 409 Conflict

            # Yeni kullanıcı oluştur ve kaydet
            kullanici = user(
                fname=data['fname'],
                email=data['email'],
                password=data['password'],
                phone=data['phone'],
                is_active=data['is_active'],
                date_joined=data['date_joined']  
            )
            kullanici.save()

            user_data = {
                "id": kullanici.id,
                "fname": kullanici.fname,
                "email": kullanici.email,
                "phone": kullanici.phone,
                "is_active": kullanici.is_active,
                "date_joined": kullanici.date_joined,
            }

            return JsonResponse({"success": "Kullanıcı başarıyla oluşturuldu.", "user": user_data}, status=200)

        except ValidationError as e:
            return JsonResponse({"error": f"Geçersiz veri: {e.message}"}, status=400)

        except Exception as e:
            return JsonResponse({"error": f"Bir hata oluştu: {str(e)}"}, status=500)

    else:
        return JsonResponse({"error": "Yalnızca POST isteği kabul edilir."}, status=405)

@csrf_exempt
def get_user_info(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            user_id = data.get('user_id')  # POST isteğinden kullanıcı kimliğini alın
            
            if not user_id:
                return JsonResponse({'error': 'Kullanıcı kimliği eksik.'}, status=400)

            # Kullanıcı bilgilerini veritabanından alın
            try:
                userr = user.objects.get(id=user_id)  # Belirtilen kimliğe göre kullanıcıyı alın

                # Kullanıcıya ait yüklenen kıyafet sayısını hesaplayın
                clothes_count = userclothes.objects.filter(userId=user_id).count()
                
                # Kullanıcı için oluşturulan kombin sayısını hesaplayın
                kombin_count = Kombin.objects.filter(userId=user_id).count()
                
                # Kullanıcının favori kombin sayısını hesaplayın
                try:
                    user_fav = UserFavorites.objects.get(userId=user_id)
                    favorite_count = len(user_fav.favoriteIds.split(","))  # Favori listesinde kaç eleman olduğunu sayın
                except UserFavorites.DoesNotExist:
                    favorite_count = 0  # Favori kaydı yoksa 0

                user_info = {
                    'id': userr.id,
                    'email': userr.email,
                    'phone': userr.phone,
                    'sifre': userr.password,
                    'joineddate': userr.date_joined.strftime('%Y-%m-%d'),  # Tarih formatını belirleyin
                    'fname': userr.fname,  
                    'clothes_count': clothes_count,
                    'kombin_count': kombin_count,
                    'favorite_count': favorite_count,
                }
                
                print(user_info)
                return JsonResponse({'status': 'success', 'user_info': user_info}, status=200)

            except user.DoesNotExist:
                return JsonResponse({'error': 'Kullanıcı bulunamadı.'}, status=404)

        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)

    return JsonResponse({'error': 'Geçersiz istek türü.'}, status=405)

@csrf_exempt
def update_user_info(request):
    if request.method == 'POST':  # Yalnızca POST isteklerini işleyin
        try:
            data = json.loads(request.body)  # İstek gövdesini JSON olarak ayrıştırın
            user_id = data.get('user_id')  # Kullanıcı kimliğini alın
            fname = data.get('fname')  # İsim
            email = data.get('email')  # E-posta
            phone = data.get('phone')  # Telefon
            password = data.get('password')  # Şifre

            # Eksik alan kontrolü
            if not user_id:
                return JsonResponse({'error': 'Kullanıcı kimliği eksik.'}, status=400)

            # Kullanıcıyı bul ve güncelle
            try:
                userr = user.objects.get(id=user_id)  # Kullanıcıyı bul
                if fname: userr.fname = fname
                if email: userr.email = email
                if phone: userr.phone = phone
                if password: userr.password=password  # Şifreyi güvenli bir şekilde değiştirin
                userr.save()  # Güncellemeleri kaydedin

                return JsonResponse({'status': 'success', 'message': 'Kullanıcı bilgileri güncellendi.'}, status=200)

            except user.DoesNotExist:
                return JsonResponse({'error': 'Kullanıcı bulunamadı.'}, status=404)

        except json.JSONDecodeError:
            return JsonResponse({'error': 'Geçersiz JSON verisi.'}, status=400)

        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)

    return JsonResponse({'error': 'Geçersiz istek türü.'}, status=405)

pillow_heif.register_heif_opener()
def crop_unused_regions(image_path):
    input_image = Image.open(image_path)
    output_image = remove(input_image)
    return output_image

def get_current_temperature(latitude, longitude):
    try:
        url = f"https://api.open-meteo.com/v1/forecast?latitude={latitude}&longitude={longitude}&daily=temperature_2m_max&timezone=auto"
        response = requests.get(url)
        if response.status_code != 200:
            raise Exception("Hava durumu verisi alınamadı.")
        weather_data = response.json()
        temperature = weather_data["daily"]["temperature_2m_max"][0]
        return temperature
    except Exception as e:
        raise RuntimeError(f"Hava durumu API'si hatası: {str(e)}")

def get_user_clothes_by_category(user_id):
    try:
        # Kullanıcıya ait kıyafetleri alın
        print('get_user_clothes_by_category')
        user_clothes_list = userclothes.objects.filter(userId=user_id)
        serializer = UserClothesSerializer(user_clothes_list, many=True)  # Listeler için 'many=True' kullanılır
        serialized_data = serializer.data  # JSON'a dönüştürülmüş veri
        if not user_clothes_list.exists():
            return {"suggested_combinations": []}, None  # Boş kombinasyon listesi ve None döndür
        clothes_by_category = {
            "Tişört": [],
            "Gömlek": [],
            "Sweatshirt": [],
            "Süveter": [],
            "Pantolon": [],
            "Etek": [],
            "Şort": [],
            "Eşofman": [],
            "Mont": [],
            "Hırka": [],
            "Ceket": [],
            "Elbise": [],
            "Bluz": [],
            "Kazak": [],
        }
        for clothing in serialized_data:
            try:
                category_id = clothing["categoryId"]
                onecategory = Category.objects.get(id=category_id)
                cat_name = onecategory.name
            except Category.DoesNotExist:
                cat_name = "Bilinmiyor"  # Hata durumunda varsayılan kategori
            if cat_name in clothes_by_category:
                clothes_by_category[cat_name].append(clothing)
        return clothes_by_category
    except Exception as e:
        raise RuntimeError(f"Kıyafet kategorilerini gruplama hatası: {str(e)}")

class YazKombini:
    def __init__(self, alt_giyim=None, ust_giyim=None, ust_giyim2=None ,warning='', outer_giyim=None, outer_giyim2=None):
        self.alt_giyim = alt_giyim
        self.ust_giyim = ust_giyim
        self.ust_giyim2=ust_giyim2
        self.warning = warning  
        self.outer_giyim = outer_giyim  
        self.outer_giyim2=outer_giyim2

    def __repr__(self):
        return (
            f"Yaz Kombini("
            f"Alt Giyim: {self.alt_giyim}, "
            f"Üst Giyim: {self.ust_giyim}, "
            f"Üst Giyim 2: {self.ust_giyim2}, "
            f"Dış Giyim: {self.outer_giyim}, "
            f"Dış Giyim 2: {self.outer_giyim2}, "
            f"Uyarı: {self.warning}"
            f")"
        )


