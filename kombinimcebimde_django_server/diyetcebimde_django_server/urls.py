
from django.contrib import admin
from django.urls import path
from . import views
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path('admin/', admin.site.urls),
    path('adduser', views.signup,name='signup'),
    path('login', views.login,name='login'),
    path('uploadimages', views.uploadimages,name='uploadimages'),
    path('getUserClothes', views.getUserClothes,name='getUserClothes'),
    path('uploadimages', views.uploadimages,name='uploadimages'),
    path('getCategories', views.getCategories,name='getCategories'),
    path('delete_photo', views.delete_photo,name='delete_photo'),
    path('daily_combinations', views.daily_combinations,name='daily_combinations'),
    path('add_favorite', views.add_favorite, name='add_favorite'),
    path('get_favorites', views.get_favorites, name='get_favorites'),
    path('get_user_info', views.get_user_info, name='get_user_info'),
    path('update_user_info', views.update_user_info, name='update_user_info'),
    path('get_weather', views.get_weather, name='get_weather'),
    path('weeklyrecommendation', views.get_weekly_outfit_recommendations, name='get_weekly_outfit_recommendations'),
    
        
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
