class DbCredentials {
  final String host;
  final int port;
  final String user;
  final String password;
  final String dbName;

  DbCredentials({
    required this.host,
    required this.port,
    required this.user,
    required this.password,
    required this.dbName,
  });
}

DbCredentials getCredentials() {
  return DbCredentials(
    host: 'localhost',
    port: 3306,
  );
}
