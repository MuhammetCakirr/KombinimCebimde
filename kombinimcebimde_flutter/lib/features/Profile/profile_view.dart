import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kombinimcebimde_flutter/features/Profile/profile_viewmodel.dart';
import 'package:provider/provider.dart';

import '../../product/MyDrawer.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}


class _ProfileViewState extends State<ProfileView> {
  bool obscureText=true;


  void _toggleObscure() {
    setState(() {
      obscureText = !obscureText;
    });
  }
  TextEditingController fullnamecontroller = TextEditingController();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController sifrecontroller = TextEditingController();
  TextEditingController telefoncontroller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ChangeNotifierProvider(
        create: (context) => ProfileViewModel()..getuserinfo(),
        child: Scaffold(
          drawer: AppDrawer(activePageIndex: 4,),
          appBar: AppBar(
            title: Text("Hesabım"),
          ),
          body: Consumer<ProfileViewModel>(
            builder: (BuildContext context, ProfileViewModel value, Widget? child)
            {
              emailcontroller.text=value.email;
              sifrecontroller.text=value.sifre;
              fullnamecontroller.text=value.fname;
              telefoncontroller.text=value.phone;
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10,),
                   Padding(
                     padding: const EdgeInsets.only(left: 8.0),
                     child:  Center(child: Text("Dolap Bilgileri",style: TextStyle(fontSize: 22,fontFamily: AutofillHints.addressCity),)),
                   ),
                    SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        buildDolapInfoColumn(value.kiyafetsayisi.toString(),"Kıyafet Sayısı"),
                        buildDolapInfoColumn(value.kombinonerisi.toString(),"Kombin Önerisi"),
                        buildDolapInfoColumn(value.favorikombinsayisi.toString(),"Favori Kombin"),
                      ],
                    ),
                    SizedBox(height: 10,),
                    Divider(height: 1,),
                    const SizedBox(height: 10,),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Center(child: const Text("Hesap Bilgileri",style: TextStyle(fontSize: 22,fontFamily: AutofillHints.addressCity),)),
                    ),
                    Form(
                      key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [


                    const SizedBox(
                      height: 7,
                    ),
                    dynamicTextWidget("Ad-Soyad"),
                    const SizedBox(
                      height: 7,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal:  8.0),
                      child: MyTextFormField(fullnamecontroller,Icon(Icons.person),"Ad Soyad"),
                    ),
                    const SizedBox(
                      height: 7,
                    ),
                    dynamicTextWidget("E-posta"),
                    const SizedBox(
                      height: 7,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal:  8.0),
                      child: MyTextFormField(emailcontroller,Icon(Icons.email_rounded),"E-posta"),
                    ),
                    const SizedBox(
                      height: 7,
                    ),
                    dynamicTextWidget("Telefon "),
                    const SizedBox(
                      height: 7,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal:  8.0),
                      child: MyTextFormField(telefoncontroller,Icon(Icons.phone),"Telefon"),
                    ),
                    const SizedBox(
                      height: 7,
                    ),
                    dynamicTextWidget("Şifre"),
                    const SizedBox(
                      height: 7,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal:  8.0),
                      child: SifreTextFormField(sifrecontroller,Icon(Icons.password_sharp),"Şifre"),
                    ),
                    const SizedBox(
                      height: 7,
                    ),
                    Center(
                        child: ElevatedButton(
                            onPressed: () async{
                              if (_formKey.currentState!.validate()) {
                               await value.updateuserinfo(
                                 fullnamecontroller.text,
                                 emailcontroller.text,
                                 telefoncontroller.text,
                                 sifrecontroller.text,
                               );
                              }
                            },
                            child: Text("Kaydet"),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(MediaQuery.of(context).size.width*0.8, 50), // Genişlik ve yükseklik belirler
                            backgroundColor: Colors.black12, // Arka plan rengi
                            foregroundColor: Colors.white, // Yazı rengi
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20), // Köşeleri yuvarlatır
                            ),
                          ),
                        ),
                    )
                          ],
                        )
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Column buildDolapInfoColumn(String sayi, String text) {
    return Column(
                      children: [
                        Text(sayi,style: TextStyle(fontSize: 18,color: Colors.grey),),
                        SizedBox(height: 5,),
                        Text(text,style: TextStyle(fontSize: 19))
                      ],
                    );
  }
  Widget dynamicTextWidget(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal:  8.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black87,
          fontFamily: "font4",
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  TextFormField MyTextFormField(TextEditingController controller,Icon icon,String hinttext) {
    return TextFormField(
      controller: controller,
      validator: (value) => value != null
          ? value.isEmpty
          ? "Lütfen bu alanı doldurunuz."
          : null
          : "Lütfen bu alanı doldurunuz.",
      decoration: InputDecoration(

        prefixIcon:icon,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 17, vertical: 18),
        hintText: hinttext,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(width: 1),
        ),
      ),
    );
  }

  TextFormField SifreTextFormField(TextEditingController controller,Icon icon,String hinttext) {
    return TextFormField(
      obscureText: obscureText,
      controller: controller,
      validator: (value) => value != null
          ? value.isEmpty
          ? "Lütfen bu alanı doldurunuz."
          : null
          : "Lütfen bu alanı doldurunuz.",
      decoration: InputDecoration(
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: _toggleObscure,
        ),
        prefixIcon:icon,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 17, vertical: 18),
        hintText: hinttext,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(width: 1),
        ),
      ),
    );
  }
}
