//imports for app
import 'dart:convert';
import 'package:fetch/global_variables.dart';
import 'package:flutter/material.dart';

//Base class for using
class DogGallery extends StatefulWidget {
  const DogGallery({super.key});

  @override
  _DogGalleryState createState() => _DogGalleryState();
}

class _DogGalleryState extends State<DogGallery> {
  TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    loadAllBreeds();
    //allows displayBreedsForFilter to be a full list when just initialized
    displayBreedsForFilter = allBreeds.toList();
  }

  //filters the list based on whether the breeds contain the search query and if they are actively being used to display images
  void filterList(String query) {
    List<String> filteredList = [];
    for (var breed in allBreeds) {
      if (breed
              .toLowerCase()
              .contains(query.toLowerCase()) && //for the search query
          !activeFilters.contains(breed)) {
        //for the active filters
        filteredList.add(breed);
      }
    }
    setState(() {
      displayBreedsForFilter = filteredList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: 'Search for a breed',
            ),
            onChanged: (query) {
              filterList(query);
            },
          ),
        ),
        body: isLoading //if the app is still loading the assets
            ? const Center(
                child: CircularProgressIndicator(), // Show a loading spinner
              )
            : Column(children: [
                Expanded(
                  //list of active filters
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 0,
                        mainAxisSpacing: 0,
                        childAspectRatio: 7.0),
                    itemCount: activeFilters.toList().length,
                    itemBuilder: (context, index) {
                      return ListTile(
                          title: Text(activeFilters.toList()[index]),
                          trailing: IconButton(
                            onPressed: () {
                              setState(() {
                                //if clicked, removes the filter and the corresponding images
                                activeFilters
                                    .remove(activeFilters.toList()[index]);
                                filterList(searchController.text);
                                changeDisplayDogs();
                              });
                            },
                            icon: const Icon(Icons.close),
                          ));
                    },
                  ),
                ),
                Expanded(
                  flex: 3,
                  //list of all dog-breeds
                  child: ListView.builder(
                      itemCount: displayBreedsForFilter.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                            title: TextButton(
                          child: Text(displayBreedsForFilter[index]),
                          onPressed: () async {
                            //add the images for the selected dog breed and changes images accordingly
                            await addBreedImages(displayBreedsForFilter[index]);
                            setState(() {
                              activeFilters.add(displayBreedsForFilter[index]);
                              changeDisplayDogs();
                            });

                            filterList(searchController.text);
                          },
                        ));
                      }),
                ),
                //a grid of all the images
                Expanded(
                    flex: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: 4.0,
                          mainAxisSpacing: 4.0,
                        ),
                        itemCount: displayDogs.length,
                        itemBuilder: (context, index) {
                          return GridTile(
                            child: Image.network(
                              displayDogs[index],
                              fit: BoxFit
                                  .cover, // Adjust image to cover the tile
                            ),
                          );
                        },
                      ),
                    ))
              ]));
  }

  //updates the displayed dogs based on the active filters
  void changeDisplayDogs() {
    displayDogs = [];

    setState(() {
      for (String breed in activeFilters) {
        for (String image in breedToImages[breed]) {
          displayDogs.add(image);
        }
      }
    });
    //if no active filters, display random dogs
    if (displayDogs.isEmpty) {
      displayDogs = randomDisplayDogs.toList();
    }
  }

  //gets all the dog-breeds
  void loadAllBreeds() async {
    allBreeds = {};
    try {
      var response =
          await client.get(Uri.parse("https://dog.ceo/api/breeds/list/all"));

      if (response.statusCode == 200) {
        var breedsMap = jsonDecode(response.body)["message"];
        for (int i = 0; i < breedsMap.length; i++) {
          if (breedsMap.values.elementAt(i).length == 0) {
            //if the dog breed has no sub-breed
            allBreeds.add(breedsMap.keys.elementAt(i));
          }
          for (int j = 0; j < breedsMap.values.elementAt(i).length; j++) {
            //if the dog breed has sub-breed
            String subBreed = breedsMap.values.elementAt(i)[j];
            allBreeds.add("$subBreed ${breedsMap.keys.elementAt(i)}");
          }
        }
      }

      //getting random dogs for a placeholder before a user searches for a dog breed
      response = await client.get(Uri.parse(
          "https://dog.ceo/api/breeds/image/random/25")); //using 25 as a buffer for 20
      if (response.statusCode == 200) {
        randomDisplayDogs = jsonDecode(response.body)["message"].toSet();

        setState(() {
          //loading is complete and can switch to the grid viewer
          isLoading = false;
          displayDogs = randomDisplayDogs.toList();
          displayDogs = displayDogs.sublist(0, 20);
        });
      }
    } catch (e) {
      //prints the error and stops rendering the app
      debugPrint(e.toString());
      setState(() {
        isLoading = false;
      });
    }
  }

  //used whenever an active filter is chosen
  Future<void> addBreedImages(String breed) async {
    if (!breedToImages.containsKey(breed)) {
      try {
        String url = "";
        if (breed.contains(" ")) {
          //checking for a sub-breed and adjusts url accordingly
          String subBreed = breed.split(" ")[0];
          String mainBreed = breed.split(" ")[1];
          url = "https://dog.ceo/api/breed/$mainBreed/$subBreed/images";
        } else {
          //call for just a main breed
          url = "https://dog.ceo/api/breed/$breed/images";
        }
        var response = await client.get(Uri.parse(url));

        if (response.statusCode == 200) {
          //adding the images to the map with the breed as the keys
          breedToImages[breed] = jsonDecode(response.body)["message"];
          
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }
}
