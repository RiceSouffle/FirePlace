import 'models/interest.dart';

class AppConstants {
  static const List<Interest> allInterests = [
    // Animals
    Interest(
      id: 'cats',
      label: 'Cats',
      emoji: '\u{1F431}',
      subreddits: ['cats', 'Catswithjobs', 'catpics', 'IllegallySmolCats', 'StartledCats', 'CatLoaf', 'SupermodelCats', 'blep'],
    ),
    Interest(
      id: 'dogs',
      label: 'Dogs',
      emoji: '\u{1F436}',
      subreddits: ['dogs', 'rarepuppers', 'aww', 'WhatsWrongWithYourDog', 'dogpictures', 'Zoomies', 'puppies', 'DogsWithJobs'],
    ),
    Interest(
      id: 'animals',
      label: 'Animals',
      emoji: '\u{1F43E}',
      subreddits: ['AnimalsBeingDerps', 'AnimalsBeingBros', 'NatureIsFuckingLit', 'Eyebleach', 'hardcoreaww', 'bigcats', 'birdsofprey', 'foxes'],
    ),

    // Vehicles & Machines
    Interest(
      id: 'cars',
      label: 'Cars',
      emoji: '\u{1F697}',
      subreddits: ['carporn', 'cars', 'Autos', 'spotted', 'JDM', 'BMW', 'Porsche', 'classiccars'],
    ),
    Interest(
      id: 'motorcycles',
      label: 'Motorcycles',
      emoji: '\u{1F3CD}',
      subreddits: ['motorcycles', 'bikesgonewild', 'MotorcyclePorn', 'caferacers'],
    ),

    // Photography & Visual Arts
    Interest(
      id: 'photography',
      label: 'Photography',
      emoji: '\u{1F4F7}',
      subreddits: ['itookapicture', 'photocritique', 'photographs', 'pics', 'MostBeautiful', 'ExposurePorn', 'streetphotography'],
    ),
    Interest(
      id: 'art',
      label: 'Art',
      emoji: '\u{1F3A8}',
      subreddits: ['Art', 'ArtPorn', 'museum', 'ImaginaryLandscapes', 'ImaginaryCharacters', 'DigitalArt', 'painting', 'Illustration'],
    ),
    Interest(
      id: 'digitalart',
      label: 'Digital Art',
      emoji: '\u{1F5BC}',
      subreddits: ['DigitalArt', 'DigitalPainting', 'conceptart', 'ImaginaryWorlds', 'ImaginaryMonsters', 'SpecArt'],
    ),

    // Nature & Outdoors
    Interest(
      id: 'nature',
      label: 'Nature',
      emoji: '\u{1F33F}',
      subreddits: ['EarthPorn', 'NaturePorn', 'nature', 'LandscapePhotography', 'waterfalls', 'geologyporn'],
    ),
    Interest(
      id: 'ocean',
      label: 'Ocean',
      emoji: '\u{1F30A}',
      subreddits: ['oceanporn', 'BeachPorn', 'underwaterphotography', 'surfing', 'scuba', 'SeaPorn'],
    ),
    Interest(
      id: 'weather',
      label: 'Weather',
      emoji: '\u{26C8}',
      subreddits: ['WeatherPorn', 'stormchasing', 'LightningPorn', 'clouds', 'SkyPorn', 'sunsets'],
    ),
    Interest(
      id: 'plants',
      label: 'Plants',
      emoji: '\u{1F331}',
      subreddits: ['plants', 'houseplants', 'gardening', 'succulents', 'IndoorGarden', 'PlantedTank', 'BotanicalPorn'],
    ),

    // Lifestyle
    Interest(
      id: 'food',
      label: 'Food',
      emoji: '\u{1F355}',
      subreddits: ['FoodPorn', 'food', 'Cooking', 'Baking', 'MealPrepSunday', 'sushi', 'Pizza', 'steak'],
    ),
    Interest(
      id: 'coffee',
      label: 'Coffee',
      emoji: '\u{2615}',
      subreddits: ['Coffee', 'espresso', 'cafe', 'LatteArt', 'CoffeePorn'],
    ),
    Interest(
      id: 'travel',
      label: 'Travel',
      emoji: '\u{2708}',
      subreddits: ['travel', 'TravelPorn', 'backpacking', 'CityPorn', 'VillagePorn', 'AbandonedPorn', 'japanpics'],
    ),
    Interest(
      id: 'fitness',
      label: 'Fitness',
      emoji: '\u{1F4AA}',
      subreddits: ['fitness', 'gym', 'bodyweightfitness', 'running', 'CrossFit', 'yoga', 'GymMemes'],
    ),
    Interest(
      id: 'fashion',
      label: 'Fashion',
      emoji: '\u{1F457}',
      subreddits: ['streetwear', 'malefashionadvice', 'femalefashion', 'sneakers', 'Watches', 'fashionporn'],
    ),

    // Architecture & Design
    Interest(
      id: 'architecture',
      label: 'Architecture',
      emoji: '\u{1F3DB}',
      subreddits: ['ArchitecturePorn', 'architecture', 'CozyPlaces', 'RoomPorn', 'CabinPorn', 'InfrastructurePorn'],
    ),
    Interest(
      id: 'interiordesign',
      label: 'Interior Design',
      emoji: '\u{1F6CB}',
      subreddits: ['RoomPorn', 'CozyPlaces', 'AmateurRoomPorn', 'malelivingspace', 'InteriorDesign', 'HomeDecorating'],
    ),

    // Science & Tech
    Interest(
      id: 'space',
      label: 'Space',
      emoji: '\u{1F680}',
      subreddits: ['spaceporn', 'space', 'astrophotography', 'Astronomy', 'NASA', 'SpaceXMasterrace', 'Hubble'],
    ),
    Interest(
      id: 'tech',
      label: 'Technology',
      emoji: '\u{1F4BB}',
      subreddits: ['technology', 'gadgets', 'tech', 'battlestations', 'PCMasterRace', 'MechanicalKeyboards', 'setups'],
    ),
    Interest(
      id: 'science',
      label: 'Science',
      emoji: '\u{1F52C}',
      subreddits: ['science', 'EverythingScience', 'chemicalreactiongifs', 'MicroPorn', 'geology'],
    ),

    // Entertainment
    Interest(
      id: 'gaming',
      label: 'Gaming',
      emoji: '\u{1F3AE}',
      subreddits: ['gaming', 'gamingsetups', 'GamingScreens', 'retrogaming', 'NintendoSwitch', 'pcgaming', 'PS5'],
    ),
    Interest(
      id: 'anime',
      label: 'Anime',
      emoji: '\u{1F338}',
      subreddits: ['anime', 'Animewallpaper', 'AnimeArt', 'ImaginaryAnime', 'animegifs'],
    ),
    Interest(
      id: 'movies',
      label: 'Movies & TV',
      emoji: '\u{1F3AC}',
      subreddits: ['MoviePosterPorn', 'CineShots', 'movies', 'television', 'FilmGrain'],
    ),
    Interest(
      id: 'music',
      label: 'Music',
      emoji: '\u{1F3B5}',
      subreddits: ['MusicPorn', 'concertporn', 'vinyl', 'guitarporn', 'audiophile', 'BattleJackets'],
    ),
    Interest(
      id: 'memes',
      label: 'Memes',
      emoji: '\u{1F602}',
      subreddits: ['memes', 'dankmemes', 'me_irl', 'wholesomememes', 'MemeEconomy', 'trippinthroughtime'],
    ),

    // Sports
    Interest(
      id: 'sports',
      label: 'Sports',
      emoji: '\u{26BD}',
      subreddits: ['sports', 'sportsphotography', 'SportsArt', 'nba', 'soccer', 'formula1'],
    ),

    // Crafts & Hobbies
    Interest(
      id: 'woodworking',
      label: 'Woodworking',
      emoji: '\u{1FA93}',
      subreddits: ['woodworking', 'Woodcarving', 'turning', 'BeginnerWoodWorking'],
    ),
    Interest(
      id: 'diy',
      label: 'DIY',
      emoji: '\u{1F6E0}',
      subreddits: ['DIY', 'somethingimade', 'crafts', 'leathercraft', 'knitting', 'crochet'],
    ),

    // Misc Visual
    Interest(
      id: 'aesthetic',
      label: 'Aesthetics',
      emoji: '\u{2728}',
      subreddits: ['VaporwaveAesthetics', 'outrun', 'Cyberpunk', 'RetroFuturism', 'liminalspace', 'AccidentalRenaissance'],
    ),
    Interest(
      id: 'maps',
      label: 'Maps',
      emoji: '\u{1F5FA}',
      subreddits: ['MapPorn', 'papertowns', 'oldmaps', 'dataisbeautiful'],
    ),
    Interest(
      id: 'history',
      label: 'History',
      emoji: '\u{1F3F0}',
      subreddits: ['HistoryPorn', 'OldSchoolCool', 'TheWayWeWere', 'ColorizedHistory', 'ArtefactPorn'],
    ),
  ];
}
