import 'package:http/http.dart' as http;

var client = http.Client();
//breed variables
Set allBreeds = {}; //all dog breeds
List displayBreedsForFilter = []; //list of filtered dog breeds (excluding active filters and including the query)
Set activeFilters = {}; //list of active filters


// dog images
List displayDogs = []; //images displayed by grid view
Map breedToImages = {}; //key is the dog breed, value is the list of images
Set randomDisplayDogs = {}; //random images displayed by grid view


bool isLoading = true; //true if the grid view is loading