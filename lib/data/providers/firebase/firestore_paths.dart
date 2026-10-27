class FirestorePaths {
  FirestorePaths._();

  static const users = 'users';
  static const readings = 'readings';

  static String userDoc(String uid) => '$users/$uid';

  static String userReadings(String uid) => '$users/$uid/$readings';
}
