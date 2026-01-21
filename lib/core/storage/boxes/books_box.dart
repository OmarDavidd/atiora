import 'package:atiora/data/models/book_model.dart';
import 'package:hive/hive.dart';
/*
part 'books_box.g.dart';

@HiveType(typeId: 0)
class BookModelAdapter extends TypeAdapter<BookModel> {
  @override
  final int typeId = 0;

  @override
  BookModel read(Reader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BookModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      title: fields[2] as String,
      author: fields[3] as String?,
      genre: (fields[4] as List).cast<String>(),
      totalPages: fields[5] as int,
      currentPage: fields[6] as int,
      status: fields[7] as String,
      rating: fields[8] as double,
      coverUrl: fields[9] as String?,
      createdAt: fields[10] as DateTime,
      updatedAt: fields[11] as DateTime,
    );
  }

  @override
  void write(Writer writer, BookModel obj) {
    writer
      ..writeByte(12)
      ..write(0, obj.id)
      ..write(1, obj.userId)
      ..write(2, obj.title)
      ..write(3, obj.author)
      ..write(4, obj.genre)
      ..write(5, obj.totalPages)
      ..write(6, obj.currentPage)
      ..write(7, obj.status)
      ..write(8, obj.rating)
      ..write(9, obj.coverUrl)
      ..write(10, obj.createdAt)
      ..write(11, obj.updatedAt);
  }
}
*/