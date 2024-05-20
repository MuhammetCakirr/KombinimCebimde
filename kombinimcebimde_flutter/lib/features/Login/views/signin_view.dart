

import 'package:flutter/material.dart';
import 'package:kombinimcebimde_flutter/features/Home/views/home_view.dart';
import 'package:kombinimcebimde_flutter/features/Login/mixin/TextField_mixin.dart';
import 'package:kombinimcebimde_flutter/features/Login/viewmodel/login_viewmodel.dart';
import 'package:kombinimcebimde_flutter/features/Register/views/signup_view.dart';
import 'package:kombinimcebimde_flutter/product/MediaQuery/mediaquery.dart';
import 'package:provider/provider.dart';

class SigninView extends StatefulWidget {
  const SigninView({super.key});

  @override
  State<SigninView> createState() => _SigninViewState();
}

class _SigninViewState extends State<SigninView> with MyMixinProducts {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailcontroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();
  final String _hosgeldiniz = "Hoşgeldiniz";
  final String _bilgigir = "Lütfen bilgilerinizi girerek Giriş Yapınız";
  final String _zatenhesabinyoksa = "Eğer Bir hesabın yoksa";
  final String _girisyap = "Giriş Yap";
  final String _kayitol = "KAYIT OL";
  @override
  Widget build(BuildContext context) {
    MyMediaQuery myMediaQuery = MyMediaQuery(context);
    return ChangeNotifierProvider(
      create: (BuildContext context) {
        return LoginViewmodel();
      },
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
          ),
          body: Consumer<LoginViewmodel>(
            builder: (buildercontext, loginviewmodel, child) {
              return SingleChildScrollView(
                reverse: true,
                child: Column(
                  children: [
                    buildercontext.watch<LoginViewmodel>().isLoading
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : Image.asset("assets/logo8.png",
                            height: myMediaQuery.screenHeight * 0.23),
                    buildMyPageContent(_hosgeldiniz, 23, "font2"),
                    buildMyPageContent(_bilgigir, 18, "font4"),
                    Form(
                        key: formKey,
                        child: Column(
                          children: [
                            buildMyTextField(
                              "E-posta",
                              Icons.person,
                              false,
                              16,
                              18,
                              5,
                              "font2",
                              emailcontroller,
                              (value) {
                                if (value == null || value.isEmpty) {
                                  return "Lütfen E-posta giriniz";
                                } 
                                return null;
                              },
                              
                              onChanged: (value) =>
                                    loginviewmodel.email = value
                            ),
                            buildMyTextField("Şifre", Icons.lock, true, 16, 18,
                                5, "font2", passwordcontroller, 
                                (value) {
                              if (value == null || value.isEmpty) {
                                return "Lütfen Şifre giriniz";
                              } 
                              return null;
                            },
                                onChanged: (value) =>
                                    loginviewmodel.password = value),
                          ],
                        )),
                    if (buildercontext.watch<LoginViewmodel>().errorMessage.isNotEmpty)
                      Text(
                        loginviewmodel.errorMessage,
                        style: TextStyle(color: Colors.red, fontSize: 15),
                      ),
                    
                    girisyapbuttonMethod(loginviewmodel, buildercontext,emailcontroller.text,passwordcontroller.text),
                    ZatenHesabinyoksaMethod(context),
                    Padding(
                        padding: EdgeInsets.only(
                            bottom: myMediaQuery.bottomviewinsens))
                  ],
                ),
              );
            },
          )),
    );
  }

  ElevatedButton girisyapbuttonMethod(
      LoginViewmodel loginViewmodel, BuildContext context,String email,String password) {
    return ElevatedButton(
      onPressed: () {
        if (formKey.currentState?.validate() ?? false) {
          
        signinfun(loginViewmodel, context,email,password); // Form geçerli ise oturum açma işlemini başlat
      }
        
      },
      child: Text(
        _girisyap,
        style: const TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
    );
  }

  void signinfun(LoginViewmodel loginViewmodel, BuildContext context,String email,String password) async {
    
   await loginViewmodel.signup();
    if (loginViewmodel.errorMessage.isEmpty) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomeView()),
    );
  } else {
    print("Giriş hatası: ${loginViewmodel.errorMessage}");
  }
  }

  Row ZatenHesabinyoksaMethod(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _zatenhesabinyoksa,
          style: const TextStyle(
              fontFamily: "font4",
              color: Colors.grey,
              fontSize: 15,
              fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SignupView()),
            );
          },
          child: Text(_kayitol,
              style: const TextStyle(
                  fontFamily: "font2", color: Colors.black, fontSize: 16)),
        ),
      ],
    );
  }
}
