from django.db import models
from rest_framework import serializers


class user(models.Model):
    id = models.AutoField(primary_key=True)
    fname = models.CharField(max_length=100)
    email = models.EmailField(max_length=100)
    phone=models.CharField(max_length=100)
    password = models.EmailField(max_length=100)
    is_active = models.EmailField(max_length=100)
    date_joined=models.EmailField(max_length=100)
    class Meta:
        app_label = 'diyetcebimde_django_server'
        db_table = 'user'

class questions(models.Model):
    question = models.CharField(max_length=100)
    text1 = models.CharField(max_length=100)
    text2 = models.EmailField(max_length=100)
    text3 = models.EmailField(max_length=100)
    text4 = models.EmailField(max_length=100)
    
    class Meta:
        app_label = 'diyetcebimde_django_server'
        db_table = 'questions'        

class answers(models.Model):
    questionId = models.CharField(max_length=100)
    userId = models.CharField(max_length=100)
    choice = models.EmailField(max_length=100)
    class Meta:
        app_label = 'diyetcebimde_django_server'
        db_table = 'answers'              

class Category(models.Model):
    id = models.AutoField(primary_key=True)
    name = models.CharField(max_length=100)
    class Meta:
        app_label = 'diyetcebimde_django_server'
        db_table = 'category'  



class Kombin(models.Model):
    id = models.AutoField(primary_key=True)
    userId=models.CharField(max_length=100)
    altgiyimId = models.CharField(max_length=100)
    ustgiyimId = models.CharField(max_length=100)
    ustgiyim2Id = models.IntegerField(null=True, blank=True)  
    disgiyimId = models.IntegerField(null=True, blank=True)  
    disgiyim2Id = models.IntegerField(null=True, blank=True)
    warning=  models.CharField(max_length=300)
    tur=models.CharField(max_length=100)

    class Meta:
        app_label = 'diyetcebimde_django_server'
        db_table = 'kombinler'          

class UserFavorites(models.Model):
    userId = models.CharField(max_length=100)  # Kullanıcı kimliği
    favoriteIds = models.CharField(max_length=300)
    class Meta:
        app_label = 'diyetcebimde_django_server'
        db_table = 'user_favorites'    



class userclothes(models.Model):
    id = models.AutoField(primary_key=True)
    userId = models.CharField(max_length=100)
    imageUrl = models.CharField(max_length=300)
    categoryId = models.CharField(max_length=100)
    class Meta:
        app_label = 'diyetcebimde_django_server'
        db_table = 'user_clothes'         
class UserClothesSerializer(serializers.ModelSerializer):
    class Meta:
        model = userclothes
        fields = ['id','imageUrl', 'categoryId']      

