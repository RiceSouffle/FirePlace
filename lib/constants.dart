import 'models/interest.dart';

class AppConstants {
  /// A broad mix — popular everyday genres (cats, cars, watches, tech) via
  /// Wikimedia Commons and The Cat API, alongside fine art from The Met and
  /// modern photography. The first six double as the default feed.
  static const List<Interest> allInterests = [
    // Popular / everyday
    Interest(id: 'cats', label: 'Cats', source: Source.cats),
    Interest(id: 'cars', label: 'Cars', source: Source.wikimedia, query: 'sports car'),
    Interest(id: 'watches', label: 'Watches', source: Source.wikimedia, query: 'wristwatch'),
    Interest(id: 'tech', label: 'Tech', source: Source.wikimedia, query: 'smartphone'),
    Interest(id: 'photography', label: 'Photography', source: Source.photo),
    Interest(id: 'nature', label: 'Nature', source: Source.wikimedia, query: 'landscape'),
    Interest(id: 'dogs', label: 'Dogs', source: Source.wikimedia, query: 'dog'),
    Interest(id: 'motorcycles', label: 'Motorcycles', source: Source.wikimedia, query: 'motorcycle'),
    Interest(id: 'keyboards', label: 'Keyboards', source: Source.wikimedia, query: 'mechanical keyboard'),
    Interest(id: 'sneakers', label: 'Sneakers', source: Source.wikimedia, query: 'sneaker'),
    Interest(id: 'aircraft', label: 'Aircraft', source: Source.wikimedia, query: 'airliner'),
    Interest(id: 'space', label: 'Space', source: Source.wikimedia, query: 'nebula'),
    Interest(id: 'architecture', label: 'Architecture', source: Source.wikimedia, query: 'modern architecture'),
    Interest(id: 'food', label: 'Food', source: Source.wikimedia, query: 'food'),
    Interest(id: 'interiors', label: 'Interiors', source: Source.wikimedia, query: 'interior design'),

    // Fine art (The Met)
    Interest(id: 'painting', label: 'Painting', source: Source.met, query: 'painting'),
    Interest(id: 'impressionism', label: 'Impressionism', source: Source.met, query: 'impressionist'),
    Interest(id: 'japanese', label: 'Japanese Art', source: Source.met, query: 'ukiyo-e'),
    Interest(id: 'sculpture', label: 'Sculpture', source: Source.met, query: 'sculpture'),
    Interest(id: 'ancient', label: 'Ancient World', source: Source.met, query: 'ancient greek'),
    Interest(id: 'modern', label: 'Modern Art', source: Source.met, query: 'modern art'),
  ];
}
