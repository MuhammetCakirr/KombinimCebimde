import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kombinimcebimde_flutter/features/AddProduct/addproduct_viewmodel.dart';
import 'package:kombinimcebimde_flutter/product/MyDrawer.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final ImagePicker _picker = ImagePicker();
ImageSource source=ImageSource.camera;
    Future<void> _showImageSourceDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Fotoğraf Seç"),
          content: Text("Fotoğrafı nereden seçmek istersiniz?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, ImageSource.camera); // Kameradan seç
                 source=ImageSource.camera;
              },
              child: Text("Kamera"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, ImageSource.gallery);
                source=ImageSource.gallery; // Galeriden seç
              },
              child: Text("Galeri"),
            ),
          ],
        );
      },
    );
  }
Future<void> _pickImage(BuildContext context, String category, AddproductViewmodel viewModel) async {
     await _showImageSourceDialog(context); // Diyalog göster ve yanıt al

    if (source != null) {
      final pickedFile = await _picker.pickImage(source: source); // Kullanıcının seçimine göre fotoğraf seç

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        viewModel.addImageToCategory(category, imageFile); // Fotoğrafı kategoriye ekle
        await viewModel.getCategories(); // Kategorileri güncelle
      }
    }
  }

  String findCategoryIdForImage(
      Map<String, List<File>> categoryImages, File imageFile) {
    for (var entry in categoryImages.entries) {
      String categoryId = entry.key;
      List<File> files = entry.value;

      if (files.contains(imageFile)) {
        return categoryId;
      }
    }

    return '';
  }

  Future<void> _showAllPhotosBottomSheet(AddproductViewmodel viewmodel) async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.25,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.11,
                  child: viewmodel.categoryImages.isEmpty
                      ? const Center(child: Text("Hiç Fotoğraf Yok"))
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: viewmodel.getAllPhotos().length,
                          itemBuilder: (context, index) {
                            final imageFile = viewmodel.getAllPhotos()[index];
                            final categoryId = findCategoryIdForImage(
                                viewmodel.categoryImages, imageFile);
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Stack(
                                children: [
                                  Container(
                                    height:MediaQuery.of(context).size.height *
                                        0.15 ,
                                    width: MediaQuery.of(context).size.height *
                                        0.13,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        width: 2,
                                        color: const Color.fromARGB(
                                            255, 105, 105, 107),
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.file(
                                        imageFile,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 5,
                                    right: 5,
                                    child: GestureDetector(
                                      onTap: () {
                                        viewmodel.deleteImageFromCategory(
                                            categoryId, imageFile);
                                      },
                                      child: Container(
                                        height: 30,
                                        width: 30,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            width: 1,
                                            color: Colors.white,
                                          ),
                                          color: const Color.fromARGB(
                                              255, 86, 85, 85),
                                        ),
                                        child: const Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ),
              // Tam genişlikte bir buton
              viewmodel.categoryImages.isNotEmpty
                  ? ElevatedButton(
                      onPressed: () async {
                        await viewmodel.uploadimages();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity,
                            50), // Butonun genişliği ve yüksekliği
                      ),
                      child: const Text("Fotoğrafları Dolabıma Yükle"),
                    )
                  : const SizedBox(),
            ],
          ),
        );
      },
    );
  }

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ChangeNotifierProvider(
        create: (BuildContext context) =>
            AddproductViewmodel()..getCategories(),
        child: Scaffold(
          key: scaffoldKey,
          drawer: AppDrawer(activePageIndex: 2),
          appBar: AppBar(
            title: const Text('Dolabım'),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                Expanded(
                  child: Consumer<AddproductViewmodel>(
                    builder: (context, viewmodel, _) {
                      if (viewmodel.isLoading) {
                        return Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            height: 100,
                            color: Colors.grey[300],
                          ),
                        );
                      } else {
                        return SingleChildScrollView(
                          child: Column(
                            children: viewmodel.categories.map((category) {
                              var categoryId = category['id'].toString();
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        category['name'],
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      viewmodel.categoryImages
                                              .containsKey(categoryId)
                                          ? InkWell(
                                              onTap: () {
                                                _showAllPhotosBottomSheet(
                                                    viewmodel);
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                    8.0), // Yuvarlak çerçevenin iç boşluğu
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.blue,
                                                    width: 2,
                                                  ),
                                                ),
                                                child: Text(
                                                  viewmodel
                                                      .categoryImages[
                                                          categoryId]!
                                                      .length
                                                      .toString(),
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : const SizedBox(),
                                      const Spacer(),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: IconButton(
                                          icon: const Icon(Icons.add),
                                          onPressed: () async {
                                            await _pickImage(context,
                                                categoryId, viewmodel);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.15,
                                    child: context
                                            .watch<AddproductViewmodel>()
                                            .userclothes
                                            .where((item) =>
                                                item["categoryId"].toString() ==
                                                categoryId)
                                            .toList()
                                            .isNotEmpty
                                        ? ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: context
                                                .watch<AddproductViewmodel>()
                                                .userclothes
                                                .where((item) =>
                                                    item["categoryId"]
                                                        .toString() ==
                                                    categoryId)
                                                .toList()
                                                .length,
                                            itemBuilder: (context, index) {
                                              var product = viewmodel
                                                  .userclothes
                                                  .where((item) =>
                                                      item["categoryId"]
                                                          .toString() ==
                                                      categoryId)
                                                  .toList()[index];
                                              String baseUrl =
                                                  "http://172.20.10.4:8000/";
                                              String imagePath =
                                                  product['imageUrl']
                                                      .toString();
                                              String fullUrl = baseUrl +
                                                  imagePath.replaceAll(
                                                      '\\', '/');
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 8.0),
                                                child: Stack(
                                                  children: [
                                                    Container(
                                                      height:MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.15, 
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.15,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                        border: Border.all(
                                                            width: 2,
                                                            color: const Color
                                                                .fromARGB(255,
                                                                105, 105, 107)),
                                                        color: Colors.white,
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                        child: Image.network(
                                                          fullUrl,
                                                          fit: BoxFit.contain,
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      top: 5,
                                                      right: 5,
                                                      child: GestureDetector(
                                                        onTap: () async {
                                                          await viewmodel.deleteimages(
                                                              product['imageUrl']
                                                                  .toString(),
                                                              product['id']
                                                                  .toString());
                                                        },
                                                        child: Container(
                                                          height: 30,
                                                          width: 30,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            border: Border.all(
                                                                width: 1,
                                                                color: Colors
                                                                    .white),
                                                            color: const Color
                                                                .fromARGB(255,
                                                                86, 85, 85),
                                                          ),
                                                          child: const Icon(
                                                            Icons.delete,
                                                            color: Colors.white,
                                                            size: 20,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          )
                                        : Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Text(
                                                  "😞", // Üzgün yüz emojisi
                                                  style: TextStyle(
                                                      fontSize:
                                                          20), // Emojiyi büyük yapın
                                                ),
                                                const SizedBox(
                                                    height:
                                                        5), // Biraz boşluk ekleyin
                                                Text(
                                                  "Dolabında Hiç ${category['name']} Yok.",
                                                  style: const TextStyle(
                                                      fontSize: 18),
                                                ),
                                              ],
                                            ),
                                          ),
                                  )
                                ],
                              );
                            }).toList(),
                          ),
                        );
                      }
                    },
                  ),
                ),
                // Altta sabit bir buton
                // InkWell(
                //   onTap: () {

                //          // ViewModel'i alın
                //     _showAllPhotosBottomSheet(viewModel); // Fonksiyona gönderin

                //   },
                //   child: Container(
                //     height: 50,
                //     color: Colors.grey[200],
                //     child: Center(
                //       child: Text("Daha Fazlası"),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
