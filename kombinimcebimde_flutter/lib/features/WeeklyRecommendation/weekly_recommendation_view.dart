import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kombinimcebimde_flutter/features/WeeklyRecommendation/weekly_recommendation_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../product/MyDrawer.dart';

class WeeklyRecommendation extends StatefulWidget {
  const WeeklyRecommendation({super.key});

  @override
  State<WeeklyRecommendation> createState() => _WeeklyRecommendationState();
}

class _WeeklyRecommendationState extends State<WeeklyRecommendation> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: ChangeNotifierProvider(
          create: (BuildContext context) {
           return WeeklyRecommendationViewModel()..getWeeklyRecommendation();
          },
          child: Scaffold(
            drawer: AppDrawer(activePageIndex: 5),
            appBar: AppBar(
              title: const Text('Haftalık Öneriler'),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  Expanded(
                      child: Consumer<WeeklyRecommendationViewModel>
                        (builder: (BuildContext context, WeeklyRecommendationViewModel viewModel, Widget? child) {
                          if (viewModel.isLoading) {
                            return Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                height: 100,
                                color: Colors.grey[300],
                              ),
                            );
                          }
                          else
                          {
                            return SingleChildScrollView(
                              child: Column(
                                children: viewModel.weeklyRecommendations.map((recommendation) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                        child: Text(
                                          recommendation['Tarih'] +", "+ recommendation['Derece'].toString() +"°C" ,

                                            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)
                                        ),
                                      ),
                                      SizedBox(
                                        height: MediaQuery.of(context).size.height * 0.6,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: recommendation['Gunlukoneri'].length,
                                          itemBuilder: (context, index) {
                                            String baseUrl = "http://172.20.10.4:8000/";
                                            var gunlukOneri = recommendation['Gunlukoneri'][index];
                                            var ustgiyim = gunlukOneri['Ust Giyim'] != null ? gunlukOneri['Ust Giyim']['imageUrl'] : '';
                                            var ustgiyim2 = gunlukOneri['Ust Giyim2'] != null ? gunlukOneri['Ust Giyim2']['imageUrl'] : '';
                                            var disgiyim = gunlukOneri['Dis Giyim'] != null ? gunlukOneri['Dis Giyim']['imageUrl'] : '';
                                            var disgiyim2 = gunlukOneri['Dis Giyim2'] != null ? gunlukOneri['Dis Giyim2']['imageUrl'] : '';
                                            var altgiyim = gunlukOneri['Alt Giyim'] != null ? gunlukOneri['Alt Giyim']['imageUrl'] : '';

                                            String ustgiyim1url = ustgiyim.isNotEmpty ? baseUrl + ustgiyim.replaceAll('\\', '/') : "";
                                            String altgiyimurl = altgiyim.isNotEmpty ? baseUrl + altgiyim.replaceAll('\\', '/') : "";
                                            String ustgiyim2url = ustgiyim2.isNotEmpty ? baseUrl + ustgiyim2.replaceAll('\\', '/') : ""; // opsiyonel
                                            String disgiyimurl = disgiyim.isNotEmpty ? baseUrl + disgiyim.replaceAll('\\', '/') : "";  // opsiyonel
                                            String disgiyimurl2 = disgiyim2.isNotEmpty ? baseUrl + disgiyim2.replaceAll('\\', '/') : "";  // opsiyonel
                                            var warning = gunlukOneri['Warning'];

                                            return Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Container(
                                                width: (MediaQuery.of(context).size.width - 60) / 2,
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
                                                          child: checkimage(ustgiyim1url, ustgiyim2url, disgiyimurl, disgiyimurl2),
                                                        ),
                                                        warning.isNotEmpty
                                                            ? Positioned(
                                                          top: 5,
                                                          left: 5,
                                                          child: GestureDetector(
                                                            onTap: () {

                                                            },
                                                            child: Container(
                                                              height: 40,
                                                              width: 40,
                                                              decoration: BoxDecoration(
                                                                shape: BoxShape.circle,
                                                                border: Border.all(width: 1, color: Color.fromARGB(255, 122, 117, 117)),
                                                                color: Color.fromARGB(255, 122, 117, 117),
                                                              ),
                                                              child: const Icon(
                                                                Icons.info_outline,
                                                                color: Colors.white,
                                                                size: 25,
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                            : SizedBox(),

                                                      ],
                                                    ),
                                                    SizedBox(height: 10),
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
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            );

                          }
                      },
                      )
                  )
                ],
              ),
            ),
          ),
        )

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


}
