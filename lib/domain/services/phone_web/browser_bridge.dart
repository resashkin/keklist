/// What only a browser can do; the phone build never calls it.
abstract interface class BrowserBridge {
  /// Names of server-sent events from [url]; "open" on every (re)connect.
  Stream<String> serverEvents(String url);

  /// The data of each [event] that comes through [serverEvents].
  Stream<String> eventData(String event);

  /// Sends the page to the PIN form.
  void openLogin();
}
