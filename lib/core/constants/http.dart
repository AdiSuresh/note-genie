class HttpConstants {
  static const baseHeaders = {
    'Content-Type': 'application/json',
  };

  static Map<String, String> authHeaders(
    String token,
  ) {
    return {
      ...baseHeaders,
      'Authorization': 'Bearer $token',
    };
  }
}
