/// API endpoint path constants.
class ApiConstants {
  ApiConstants._();

  static const baseUrl = 'https://server-psi-seven-49.vercel.app/api';

  // Content
  static const hobbies = '/hobbies';
  static const categories = '/categories';
  static const search = '/hobbies/search';
  static const combos = '/hobbies/combos';
  static const seasonal = '/hobbies/seasonal';

  // Per-hobby
  static String hobby(String id) => '/hobbies/$id';
  static String faq(String hobbyId) => '/hobbies/$hobbyId/faq';
  static String cost(String hobbyId) => '/hobbies/$hobbyId/cost';
  static String budget(String hobbyId) => '/hobbies/$hobbyId/budget';
  static const mood = '/hobbies/mood';
}
