class MapUtil {
  static _getDoubleValue(value) {
    try {
      return double.tryParse(value.toString());
    } catch (e) {
      return 0;
    }
  }

  static double validateLat(value) {
    value = _getDoubleValue(value);
    if (value > 90 || value < -90) {
      return 0;
    }
    return value;
  }

  static validateLong(value) {
    value = _getDoubleValue(value);
    if (value > 180 || value < -180) {
      return 0;
    }
    return value;
  }
}