class EncryptionInstance {
  String encrypt(String data) {
    String result = "";

    for (int i = 0; i < data.length; i++) {
      String char = data[i];
      int numb = data.codeUnitAt(i);

      String mm = String.fromCharCode(numb + ((3 * (i + 12)) + data.length));
      // print(numb);
      result += mm;
    }

    return result;
  }

  String decrypt(String data) {
    String result = "";
    for (int i = 0; i < data.length; i++) {
      String char = data[i];
      int numb = data.codeUnitAt(i);

      String mm = String.fromCharCode(numb - ((3 * (i + 12)) + data.length));
      // print(numb);
      result += mm;
    }

    return result;
  }
}
