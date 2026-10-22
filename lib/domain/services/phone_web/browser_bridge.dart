/// What only a browser can do; the phone build never calls it.
abstract interface class BrowserBridge {
  /// Names of server-sent events from [url]; "open" on every (re)connect.
  Stream<String> serverEvents(String url);

  /// Sends the page to the PIN form.
  void openLogin();
}
