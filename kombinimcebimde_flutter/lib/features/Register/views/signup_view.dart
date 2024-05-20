import 'package:flutter/material.dart';
import 'package:kombinimcebimde_flutter/features/Home/views/home_view.dart';
import 'package:kombinimcebimde_flutter/features/Login/mixin/TextField_mixin.dart';
import 'package:kombinimcebimde_flutter/features/Login/views/signin_view.dart';
import 'package:kombinimcebimde_flutter/features/Register/viewmodel/signup_viewmodel.dart';
import 'package:kombinimcebimde_flutter/product/MediaQuery/mediaquery.dart';
import 'package:provider/provider.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});
  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> with MyMixinProducts {
  final TextEditingController emailcontroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();
  final TextEditingController phonecontroller = TextEditingController();
  final TextEditingController namecontroller = TextEditingController();
  final String hosgeldiniz = "Hoşgeldiniz";
  final String hesapolustur = "Hesap Oluştur";
  final String zatenhesabinvarsa = "Zaten bir hesabın varsa";
  final String girisyap = "GİRİŞ YAP";
  final String kayitol = "Kayıt Ol";
  @override
  Widget build(BuildContext context) {
    MyMediaQuery myMediaQuery = MyMediaQuery(context);
    return ChangeNotifierProvider(
      create: (context) => SignupViewmodel(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Consumer<SignupViewmodel>(
          builder: (context, signupViewModel, child) {
            return SingleChildScrollView(

              child: Column(
                children: [
                  SizedBox(height: 30,),
                  Image.asset("assets/logo8.png",
                      height: myMediaQuery.screenHeight * 0.23),
                  buildMyPageContent(hosgeldiniz, 23, "font2"),
                  buildMyPageContent(hesapolustur, 18, "font4"),
                  buildMyTextField(
                    "İsim-Soyisim", Icons.person, false, 16, 18, 5, "font2",
                    namecontroller,
                    (value) {
                      if (value == null || value.isEmpty) {
                        return "Lütfen İsminizi giriniz";
                      } else {
                        return "null";
                      }
                    },
                    onChanged: (value) =>
                        signupViewModel.name = value, // View Model'i güncelleyin
                  ),
                  buildMyTextField(
                    "E-posta",
                    Icons.email,
                    false,
                    16,
                    18,
                    5,
                    "font2",
                    emailcontroller,
                    (value) {
                                if (value == null || value.isEmpty) {
                                  return "Lütfen E-posta giriniz";
                                } else {
                                  return "null";
                                }
                              },
                    onChanged: (value) => signupViewModel.email = value,
                  ),
                  buildMyTextField(
                    "Telefon Numarası",
                    Icons.phone,
                    false,
                    16,
                    18,
                    5,
                    "font2",
                    phonecontroller,
                    (value) {
                                if (value == null || value.isEmpty) {
                                  return "Lütfen telefon numaranızı giriniz";
                                } else {
                                  return "null";
                                }
                              },
                    onChanged: (value) => signupViewModel.phone = value,
                  ),
                  buildMyTextField(
                    "Şifre",
                    Icons.lock,
                    true,
                    16,
                    18,
                    5,
                    "font2",
                    passwordcontroller,
                    (value) {
                                if (value == null || value.isEmpty) {
                                  return "Lütfen Şifre giriniz";
                                } else {
                                  return "null";
                                }
                              },
                    onChanged: (value) => signupViewModel.password = value,
                  ),
                  if (signupViewModel.errorMessage.isNotEmpty)
                    Text(
                      signupViewModel.errorMessage,
                      style: TextStyle(color: Colors.red, fontSize: 15),
                    ),
                  kayitolbuttonMethod(signupViewModel),
                  ZatenhesabinvarsaMethod(context)
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  ElevatedButton kayitolbuttonMethod(SignupViewmodel signupViewModel) {
    return ElevatedButton(
      onPressed: () async {
        try {
          await signupViewModel.signup();
          if (signupViewModel.errorMessage == "") {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Kayıt başarılı!')),
            );
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    HomeView(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  var begin = Offset(1.0, 0.0); // Sağdan sola kaydırma
                  var end = Offset.zero;
                  var curve = Curves
                      .easeInOut; // Daha yumuşak bir animasyon için eğri
                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);
                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
              ),
            );
          } // Kayıt işlemini başlat
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Kayıt başarısız: $e')),
          );
        }
      },
      child: Text(
        kayitol,
        style: const TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
    );
  }

  Row ZatenhesabinvarsaMethod(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          zatenhesabinvarsa,
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
              MaterialPageRoute(builder: (context) => const SigninView()),
            );
          },
          child: Text(girisyap,
              style: const TextStyle(
                  fontFamily: "font2", color: Colors.black, fontSize: 16)),
        ),
      ],
    );
  }
}
