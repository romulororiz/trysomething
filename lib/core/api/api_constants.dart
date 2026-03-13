/// API endpoint path constants.
class ApiConstants {
  ApiConstants._();

  static const baseUrl = 'https://server-psi-seven-49.vercel.app/api';

  // Auth
  static const authRegister = '/auth/register';
  static const authLogin = '/auth/login';
  static const authRefresh = '/auth/refresh';
  static const authGoogle = '/auth/google';
  static const authApple = '/auth/apple';

  // Users
  static const usersMe = '/users/me';
  static const usersPreferences = '/users/preferences';

  // Content
  static const hobbies = '/hobbies';
  static const hobbyPacks = '/hobbies?packs=true';
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

  // User progress
  static const usersHobbies = '/users/hobbies';
  static const usersHobbiesSync = '/users/hobbies-sync';
  static String userHobby(String hobbyId) => '/users/hobbies/$hobbyId';
  static String userHobbyStep(String hobbyId, String stepId) =>
      '/users/hobbies/$hobbyId/steps/$stepId';
  static const usersActivity = '/users/activity';

  // Personal tools
  static const usersJournal = '/users/journal';
  static String usersJournalEntry(String entryId) => '/users/journal/$entryId';
  static String usersNotes(String hobbyId) => '/users/notes/$hobbyId';
  static String usersNoteStep(String hobbyId, String stepId) =>
      '/users/notes/$hobbyId/$stepId';
  static const usersSchedule = '/users/schedule';
  static String usersScheduleEvent(String eventId) =>
      '/users/schedule/$eventId';
  static String usersShopping(String hobbyId) => '/users/shopping/$hobbyId';

  // Social
  static const usersStories = '/users/stories';
  static String usersStory(String storyId) => '/users/stories/$storyId';
  static String usersStoryReact(String storyId, String type) =>
      '/users/stories/$storyId/react/$type';
  static const usersBuddies = '/users/buddies';
  static const usersBuddyRequests = '/users/buddy-requests';
  static String usersBuddyRequest(String requestId) =>
      '/users/buddy-requests/$requestId';
  static const usersSimilarUsers = '/users/similar-users';

  // Gamification
  static const usersChallenges = '/users/challenges';
  static const usersAchievements = '/users/achievements';

  // AI Generation
  static const generateHobby = '/generate/hobby';
  static const generateFaq = '/generate/faq';
  static const generateCost = '/generate/cost';
  static const generateBudget = '/generate/budget';

  // AI Coach
  static const coachChat = '/coach/chat';
}
