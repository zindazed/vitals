// String host = "http://192.168.240.106/";
String host = "http://192.168.246.37/";
// String host = "http://192.168.43.120/";
// String host = "http://patientvitals.rf.gd/";

String xorCipher(String message, String key) {
  List<int> messageBytes = message.runes.toList();
  List<int> keyBytes = key.runes.toList();

  List<int> encryptedBytes = [];
  for (int i = 0; i < messageBytes.length; i++) {
    int encryptedByte = messageBytes[i] ^ keyBytes[i % keyBytes.length];
    encryptedBytes.add(encryptedByte);
  }

  String encryptedMessage = String.fromCharCodes(encryptedBytes);
  return encryptedMessage;
}

String xorDecipher(String encryptedMessage, String key) {
  List<int> encryptedBytes = encryptedMessage.runes.toList();
  List<int> keyBytes = key.runes.toList();

  List<int> decryptedBytes = [];
  for (int i = 0; i < encryptedBytes.length; i++) {
    int decryptedByte = encryptedBytes[i] ^ keyBytes[i % keyBytes.length];
    decryptedBytes.add(decryptedByte);
  }

  String decryptedMessage = String.fromCharCodes(decryptedBytes);
  return decryptedMessage;
}
