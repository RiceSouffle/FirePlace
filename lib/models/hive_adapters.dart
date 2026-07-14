import 'package:hive_ce/hive.dart';
import 'feed_item.dart';
import 'screen_time_entry.dart';

class FeedItemAdapter extends TypeAdapter<FeedItem> {
  @override
  final int typeId = 0;

  @override
  FeedItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return FeedItem(
      id: fields[0] as String,
      imageUrl: fields[1] as String,
      thumbnailUrl: fields[2] as String,
      title: fields[3] as String,
      artist: fields[4] as String? ?? '',
      dateText: fields[5] as String?,
      medium: fields[6] as String?,
      category: fields[7] as String? ?? '',
      sourceName: fields[8] as String? ?? '',
      sourceUrl: fields[9] as String? ?? '',
      interestId: fields[10] as String? ?? '',
      width: fields[11] as int,
      height: fields[12] as int,
      fetchedAt: fields[13] as DateTime,
      isLiked: fields[14] as bool? ?? false,
      isSaved: fields[15] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, FeedItem obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.imageUrl)
      ..writeByte(2)
      ..write(obj.thumbnailUrl)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.artist)
      ..writeByte(5)
      ..write(obj.dateText)
      ..writeByte(6)
      ..write(obj.medium)
      ..writeByte(7)
      ..write(obj.category)
      ..writeByte(8)
      ..write(obj.sourceName)
      ..writeByte(9)
      ..write(obj.sourceUrl)
      ..writeByte(10)
      ..write(obj.interestId)
      ..writeByte(11)
      ..write(obj.width)
      ..writeByte(12)
      ..write(obj.height)
      ..writeByte(13)
      ..write(obj.fetchedAt)
      ..writeByte(14)
      ..write(obj.isLiked)
      ..writeByte(15)
      ..write(obj.isSaved);
  }
}

class ScreenTimeEntryAdapter extends TypeAdapter<ScreenTimeEntry> {
  @override
  final int typeId = 2;

  @override
  ScreenTimeEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return ScreenTimeEntry(
      date: fields[0] as String,
      totalSeconds: fields[1] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, ScreenTimeEntry obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.totalSeconds);
  }
}
