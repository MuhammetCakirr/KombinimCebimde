import 'package:flutter/material.dart';
import 'package:kombinimcebimde_flutter/features/AddProduct/addproduct_viewmodel.dart';

import 'package:kombinimcebimde_flutter/features/Home/home_viewmodel.dart';
import 'package:kombinimcebimde_flutter/features/Home/views/home_view.dart';
import 'package:kombinimcebimde_flutter/features/Login/viewmodel/login_viewmodel.dart';
import 'package:provider/provider.dart'; // Provider'ı içe aktarın
import 'package:kombinimcebimde_flutter/features/Login/views/signin_view.dart';
import 'package:shared_preferences/shared_preferences.dart'; // SigninView'i içe aktarın
// ViewModel'i içe aktarın

void main() {
  runApp(MyApp()); // MyApp çağırılır
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
bool? isLogin;
  @override
  void initState() {
    _checkLogin();
    super.initState();
  }
    Future<void> _checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('id') != null) {
      setState(() {
        isLogin = true;
      });
    } else {
      setState(() {
        isLogin = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider( // MultiProvider ile birden fazla provider ekleyebilirsiniz
      providers: [
        ChangeNotifierProvider(create: (context) => LoginViewmodel()),
        ChangeNotifierProvider(create: (context) => AddproductViewmodel()) ,
        ChangeNotifierProvider(create: (context) => HomeViewModel()) ,
      ],
      child: MaterialApp(
        title: 'Kombinim Cebimde',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home:  isLogin == null
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : isLogin!
          ? const HomeView()
          : const SigninView(),// Ana sayfa olarak SigninView
      ),
    );
  }
}
