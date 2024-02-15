enum Missions {
  watchTV,
  lookGallery,
  drinkWater,
  talkToEverybody;

  String get text => switch (this) {
        watchTV => 'Посмотри телевизор',
        lookGallery => 'Посмотри галерею',
        drinkWater => 'Выпей воды из кулера',
        talkToEverybody => 'Познакомься со всеми',
      };
}
