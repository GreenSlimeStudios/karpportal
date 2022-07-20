class EncryptionInstance {
  String encrypt(String data) {
    String result = "";

    for (int i = 0; i < data.length; i++) {
      String char = data[i];
      int num = data.codeUnitAt(i);

      String mm = String.fromCharCode(num + 2);
      print(num);
      result += mm;
    }

    return result;
  }

  String decrypt(String data) {
    String result = "";
    for (int i = 0; i < data.length; i++) {
      String char = data[i];
      int num = data.codeUnitAt(i);

      String mm = String.fromCharCode(num - 2);
      print(num);
      result += mm;
    }

    return result;
  }
}
