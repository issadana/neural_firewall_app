/// Endpoint paths for the blacklist feature.
class BlacklistEndpoints {
  BlacklistEndpoints._();

  /// GET — list all entries. POST — add an entry. DELETE — clear all.
  static const String blacklist = '/blacklist';

  /// DELETE — remove a single entry by its server id.
  static String entry(int id) => '/blacklist/$id';
}
