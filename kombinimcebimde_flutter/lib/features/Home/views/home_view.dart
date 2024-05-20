import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:kombinimcebimde_flutter/features/AddProduct/views/addproduct_view.dart';
import 'package:kombinimcebimde_flutter/features/Home/home_viewmodel.dart';
import 'package:kombinimcebimde_flutter/product/MyDrawer.dart';
import 'package:provider/provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
   return SafeArea(
      child: ChangeNotifierProvider(
        create: (context) => HomeViewModel()..getDailyCombination(),  // ViewModel'i oluştur ve veri yükle
        child: Scaffold(
          drawer: AppDrawer(activePageIndex: 1,),
          appBar: AppBar(
            title: Text("Anasayfa"),
          ),
          body: Consumer<HomeViewModel>(
            builder: (context, viewModel, _) {
              if (viewModel.isLoading) {
                return Center(child: CircularProgressIndicator());  // Yükleniyor göstergesi
              } else if (viewModel.errorMessage.isNotEmpty) {
                return Center(child: Text("Hata: ${viewModel.errorMessage}"));  // Hata mesajı
              }

              else if(viewModel.dailyCombinations.isEmpty){
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Hoşgeldin, ${viewModel.fname.toString()}", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                     Row(
                      children: [
                        Icon(Icons.sunny,color: Colors.yellow, size: 50,),
                        SizedBox(width: 5,),
                        Text(" ${viewModel.havadurumu.toString()} , ${viewModel.derece.toString()}°C ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),

                    const Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "😞", // Üzgün yüz emojisi
                            style: TextStyle(
                                fontSize:
                                40), // Emojiyi büyük yapın
                          ),
                          SizedBox(
                              height:
                              5), //
                          Text(
                            "Sana Kombin Önerisi yapamıyorum.",
                            style:  TextStyle(
                                fontSize: 16),
                          ),
                          SizedBox(
                              height:
                              5),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Dolabına kıyafet ekleyip tekrar dene.",
                              style:  TextStyle(
                                  fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    )


                  ],
                );
              }
              else {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,  // Öğeleri sola hizalayın
                      children: [
                        Text("Hoşgeldin,${viewModel.fname.toString()}", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            Icon(Icons.sunny,color: Colors.yellow, size: 50,),
                            SizedBox(width: 5,),
                            Text("${viewModel.havadurumu.toString()} , ${viewModel.derece.toString()} °C ", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 16),
                        Wrap(
                          spacing: 5.0,
                          runSpacing: 5.0,
                          children: viewModel.dailyCombinations.map((combination) {
                            String baseUrl = "http://172.20.10.4:8000/";
                            String ustgiyim1=combination.upperWearUrl1;
                            String ustgiyim2=combination.upperWearUrl2;
                            String disgiyim=combination.outerWearUrl;
                            String disgiyim2=combination.outerWearUrl2;
                            String altgiyim=combination.lowerWearUrl;
                            String ustgiyim1url = ustgiyim1.isNotEmpty? baseUrl + combination.upperWearUrl1.replaceAll('\\', '/'):"";
                            String altgiyimurl = altgiyim.isNotEmpty? baseUrl + combination.lowerWearUrl.replaceAll('\\', '/'):"";
                            String ustgiyim2url =ustgiyim2.isNotEmpty? baseUrl + combination.upperWearUrl2.replaceAll('\\', '/'):""; //opsiyonel
                            String disgiyimurl =disgiyim.isNotEmpty? baseUrl + combination.outerWearUrl.replaceAll('\\', '/'):"";  //opsiyonel
                            String disgiyimurl2 =disgiyim2.isNotEmpty? baseUrl + combination.outerWearUrl2.replaceAll('\\', '/'):"";  //opsiyonel

                            String warning =combination.warning; //opsiyonel
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: (MediaQuery.of(context).size.width - 60) / 2, // İki öğe için genişlik
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(width: 2, color: Color.fromARGB(255, 105, 105, 107)),
                                  color: Colors.white,
                                ),
                                child: Column(
                                  children: [
                                    Stack(
                                      children: [
                                        Container(
                                          height: MediaQuery.of(context).size.height * 0.25,
                                          child: checkimage(ustgiyim1url, ustgiyim2url, disgiyimurl,disgiyimurl2)

                                        ),
                                        warning.isNotEmpty?
                                        Positioned(
                                          top: 5,
                                          left: 5,
                                          child: GestureDetector(
                                            onTap: () {
                                              _showSnackbar(context,warning);
                                            },
                                            child: Container(
                                              height: 40,
                                              width: 40,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(width: 1, color: Color.fromARGB(
                                                    255, 122, 117, 117)),
                                                color: Color.fromARGB(
                                                    255, 122, 117, 117),
                                              ),
                                              child: const Icon(
                                                Icons.info_outline,
                                                color: Colors.white,
                                                size: 25,
                                              ),
                                            ),
                                          ),
                                        ):SizedBox(),
                                        Positioned(
                                          top: 5,
                                          right: 5,
                                          child: GestureDetector(
                                            onTap: ()async {
                                              await viewModel.addfavorite(combination.id);
                                            },
                                            child: Container(
                                              height: 40,
                                              width: 40,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(width: 1, color:Color.fromARGB(255, 86, 85, 85)),
                                                color: viewModel.favoriteIdlist.contains(combination.id)? Colors.white70:Color.fromARGB(255, 86, 85, 85),
                                              ),
                                              child: Icon(
                                                Icons.favorite,
                                                color: viewModel.favoriteIdlist.contains(combination.id)? Colors.red:Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10), // İki öğe arasında boşluk
                                    Container(
                                      height: MediaQuery.of(context).size.height * 0.30,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Image.network(
                                          altgiyimurl,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(), // Wrap için tüm kombinasyonlar
                        )
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

Widget checkimage(String url1,String url2,String url3,String url4){
    if(url2.isNotEmpty && url3.isNotEmpty&& url4.isNotEmpty){
      return CarouselSlider(
      items: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(
            url1,
            fit: BoxFit.cover,
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(
            url2,
            fit: BoxFit.cover,
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(
            url3,
            fit: BoxFit.cover,
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(
            url4,
            fit: BoxFit.cover,
          ),
        ),
      ],
      options: CarouselOptions(
  ),
  );
    }
    else if(url2.isNotEmpty && url3.isNotEmpty){
      return CarouselSlider(
          items: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                url1,
                fit: BoxFit.cover,
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                url2,
                fit: BoxFit.cover,
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                url3,
                fit: BoxFit.cover,
              ),
            ),
          ],
        options: CarouselOptions(

        ),
      );
    }
    else if(url2.isEmpty && url3.isNotEmpty){
      return CarouselSlider(
        items: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              url1,
              fit: BoxFit.cover,
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              url3,
              fit: BoxFit.cover,
            ),
          ),


        ],
        options: CarouselOptions(

        ),
      );
    }
    else if(url2.isNotEmpty && url3.isEmpty){
      return CarouselSlider(
        items: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              url1,
              fit: BoxFit.cover,
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              url2,
              fit: BoxFit.cover,
            ),
          ),

        ],
        options: CarouselOptions(


        ),
      );
    }
    else{
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          url1,
          fit: BoxFit.cover,
        ),
      );
    }

}

  // Mesajı ekrana yazdırmak için fonksiyon
  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text( "Üstünüze giymek için hiçbir dış giyim (Hırka, Mont, Ceket) ürününüz yok. "
            "Önerilen kombinin üzerine bir dış giyim ürünü giymenizi öneririm."),
        duration: Duration(seconds: 5), // Snack bar süresi
      ),
    );
  }
}

