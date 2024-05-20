import 'package:flutter/material.dart';
import 'package:kombinimcebimde_flutter/features/AddProduct/views/addproduct_view.dart';
import 'package:kombinimcebimde_flutter/features/Favorites/favorite_view.dart';
import 'package:kombinimcebimde_flutter/features/Home/views/home_view.dart';
import 'package:kombinimcebimde_flutter/features/Login/views/signin_view.dart';
import 'package:kombinimcebimde_flutter/features/Profile/profile_view.dart';
import 'package:kombinimcebimde_flutter/features/WeeklyRecommendation/weekly_recommendation_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/Home/home_viewmodel.dart';

// Drawer'ı bağımsız bir widget olarak tanımlayın
class AppDrawer extends StatelessWidget {
  final int activePageIndex; // Aktif sayfayı belirtmek için
  
  AppDrawer({required this.activePageIndex});

  @override
  Widget build(BuildContext context) {
    final homeViewModel = Provider.of<HomeViewModel>(context);
    homeViewModel.getuserinfo();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
           DrawerHeader(
              decoration: BoxDecoration(color: Colors.grey),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20,),
                   Row(
                    children: [
                      Icon(Icons.sunny,color: Colors.yellow, size: 50,),
                      SizedBox(width: 20,),
                      Text("Çoğunlukla Güneşli ", style: TextStyle(fontSize:16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Text(" 20°C", style: TextStyle(fontSize:16, fontWeight: FontWeight.bold)),

                  Spacer(),
                  Text("Hoşgeldin, Muhammet ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              )),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: activePageIndex == 1
                    ? const Color.fromARGB(255, 210, 206, 206)
                    : Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: ListTile(
                onTap: () {
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
                },
                leading: Image.asset(
                  "assets/kombinicon.png",
                  width: 35,
                  height: 35,
                ),
                title: const Text(
                  "Kombinler",
                  style: TextStyle(fontSize: 17, color: Colors.black),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: activePageIndex == 2
                    ? const Color.fromARGB(255, 210, 206, 206)
                    : Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          AddProduct(),
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
                },
                leading: Image.asset(
                  "assets/clothes.png",
                  width: 35,
                  height: 35,
                ),
                title: const Text(
                  "Dolabım",
                  style: TextStyle(fontSize: 17),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: activePageIndex == 3
                    ? const Color.fromARGB(255, 210, 206, 206)
                    : Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: ListTile(
                onTap: (){
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          FavoriteView(),
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
                },
                leading: Image.asset(
                  "assets/favorite.png",
                  width: 35,
                  height: 35,
                ),
                title: const Text(
                  "Favorilerim",
                  style: TextStyle(fontSize: 17),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: activePageIndex == 4
                    ? const Color.fromARGB(255, 210, 206, 206)
                    : Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: ListTile(
                onTap: (){
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          ProfileView(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        var begin = Offset(1.0, 0.0); // Sağdan sola kaydırma
                        var end = Offset.zero;
                        var curve = Curves.easeInOut;

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
                },
                leading: Image.asset(
                  "assets/hesabim2.png",
                  width: 30,
                  height: 30,
                ),
                title: const Text(
                  "Hesabım",
                  style: TextStyle(fontSize: 17),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: activePageIndex == 5
                    ? const Color.fromARGB(255, 210, 206, 206)
                    : Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: ListTile(
                onTap: (){
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          WeeklyRecommendation(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        var begin = Offset(1.0, 0.0); // Sağdan sola kaydırma
                        var end = Offset.zero;
                        var curve = Curves.easeInOut;

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
                },
                leading: Image.asset(
                  "assets/hesabim2.png",
                  width: 30,
                  height: 30,
                ),
                title: const Text(
                  "Haftalık Kombin Önerileri",
                  style: TextStyle(fontSize: 17),
                ),
              ),
            ),
          ),
          ListTile(
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove('id');
              await prefs.remove('email');
              await prefs.remove('password');
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      SigninView(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    var begin = Offset(1.0, 0.0); // Sağdan sola kaydırma
                    var end = Offset.zero;
                    var curve = Curves.easeInOut;

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
            },
            leading: Image.asset(
              "assets/cikis.png",
              width: 30,
              height: 30,
            ),
            title: const Text(
              "Çıkış Yap",
              style: TextStyle(fontSize: 17),
            ),
          ),
        ],
      ),
    );
  }
}
