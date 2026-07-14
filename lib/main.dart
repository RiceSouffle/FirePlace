import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'models/hive_adapters.dart';
import 'services/storage_service.dart';
import 'services/met_service.dart';
import 'services/picsum_service.dart';
import 'services/wikimedia_service.dart';
import 'services/cat_service.dart';
import 'services/gallery_service.dart';
import 'providers/interests_provider.dart';
import 'providers/feed_provider.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(FeedItemAdapter());
  Hive.registerAdapter(ScreenTimeEntryAdapter());

  final storageService = StorageService();
  await storageService.init();

  final gallery = GalleryService(
    met: MetService(),
    picsum: PicsumService(),
    wikimedia: WikimediaService(),
    cats: CatService(),
  );

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storageService),
        galleryServiceProvider.overrideWithValue(gallery),
      ],
      child: const FirePlaceApp(),
    ),
  );
}
