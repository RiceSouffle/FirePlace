import 'package:hive_ce/hive.dart';
import 'feed_item.dart';
import 'content_source.dart';
import 'screen_time_entry.dart';

class ContentSourceAdapter extends TypeAdapter<ContentSource> {
  @override
  final int typeId = 1;

  @override
  ContentSource read(BinaryReader reader) {
    return ContentSource.values[reader.readInt()];
  }

  @override
  void write(BinaryWriter writer, ContentSource obj) {
    writer.writeInt(obj.index);
  }
}

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
      title: fields[3] as String?,
      description: fields[4] as String?,
      source: fields[5] as ContentSource,
      authorName: fields[6] as String,
      authorUrl: fields[7] as String?,
      sourceUrl: fields[8] as String,
      interestId: fields[9] as String,
      width: fields[10] as int,
      height: fields[11] as int,
      avgColor: fields[12] as String?,
      fetchedAt: fields[13] as DateTime,
      isLiked: fields[14] as bool? ?? false,
      isSaved: fields[15] as bool? ?? false,
      subreddit: fields[16] as String? ?? '',
      createdUtc: fields[17] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, FeedItem obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.imageUrl)
      ..writeByte(2)
      ..write(obj.thumbnailUrl)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.source)
      ..writeByte(6)
      ..write(obj.authorName)
      ..writeByte(7)
      ..write(obj.authorUrl)
      ..writeByte(8)
      ..write(obj.sourceUrl)
      ..writeByte(9)
      ..write(obj.interestId)
      ..writeByte(10)
      ..write(obj.width)
      ..writeByte(11)
      ..write(obj.height)
      ..writeByte(12)
      ..write(obj.avgColor)
      ..writeByte(13)
      ..write(obj.fetchedAt)
      ..writeByte(14)
      ..write(obj.isLiked)
      ..writeByte(15)
      ..write(obj.isSaved)
      ..writeByte(16)
      ..write(obj.subreddit)
      ..writeByte(17)
      ..write(obj.createdUtc);
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
