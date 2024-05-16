/// Flatten a nested Map into a single level map
///
/// If no [delimiter] is specified, will separate depth levels by `.`.
///
/// If you don't want to flatten arrays (with 0, 1,... indexes),
/// use [safe] mode.
///
/// To avoid circular reference issues or huge calculations,
/// you can specify the [maxDepth] the function will traverse.
/// if you are not sure what is the components of this map
///
Map<String, dynamic> flatten(
  Map<String, dynamic> target, {
  String delimiter = ".",
  bool safe = false,
  int? maxDepth,
}) {
  final result = <String, dynamic>{};

  void step(
    Map<String, dynamic> obj, [
    String? previousKey,
    int currentDepth = 1,
  ]) {
    obj.forEach((key, value) {
      final newKey = previousKey != null ? "$previousKey$delimiter$key" : key;

      if (maxDepth != null && currentDepth >= maxDepth) {
        result[newKey] = value;
        return;
      }
      if (value is Map<String, dynamic>) {
        return step(value, newKey, currentDepth + 1);
      }
      if (value is List && !safe) {
        return step(
          _listToMap(value),
          newKey,
          currentDepth + 1,
        );
      }
      result[newKey] = value;
    });
  }

  step(target);

  return result;
}

Map<String, T> _listToMap<T>(List<T> list) =>
    list.asMap().map((key, value) => MapEntry(key.toString(), value));

/// this function is aimed to flat the multi dimensional map of maps into one big map
/// this function is for map<"",maps> only
/// these two function flatting the specific types without adding "." delimiter
/// and ignoring the bigger maps's key which
/// this is quicker and smoother
Map flattenMapOfMaps<T>(Map map) {
  Map result = {};

  void flatten(key, value) {
    if (value is Map) {
      value.forEach(flatten);
    } else {
      result.putIfAbsent(key, () => value);
    }
  }

  map.forEach(flatten);

  return result;
}


/// this function is aimed to flat the multi dimensional maps List into one big map
Map<String, dynamic> flattenListOfMaps(List<Map<String, dynamic>> mapsList) {
  Map<String, dynamic> result = {};
  for (var map in mapsList) {
    _flatten(map, result);
  }
  return result;
}

void _flatten(Map<String, dynamic> map, Map<String, dynamic> result) {
  for (var key in map.keys) {
    var value = map[key];
    if (value is Map<String, dynamic>) {
      _flatten(value, result);
    } else {
      result[key] = value;
    }
  }
}
