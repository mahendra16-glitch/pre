String removeEndPoint00(String value) {
  if (value.endsWith(".00")) {
    return value.replaceAll(RegExp(r"\.0+$"), "");
  } else {
    return value;
  }
}
