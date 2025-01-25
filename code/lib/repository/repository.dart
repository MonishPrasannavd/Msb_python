abstract class IRepository<T> {
  Future<T?> getOne(String id);

  Future<List<T>> getAll();

  Future<T?> saveOne(T entry);

  Future<List<T>> saveAll(List<T> entries);

  Future<bool> updateOne(T entry);

  Future<bool> updateAll(List<T> entries);

  Future<bool> deleteOne(T entry);

  Future<bool> deleteAll(List<T> entries);
}
