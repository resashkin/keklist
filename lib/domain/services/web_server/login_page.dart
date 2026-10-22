import 'dart:convert';

/// The page where a browser enters the PIN before the web version opens.
/// Plain HTML, so that it costs nothing to load before the PIN is known.
String loginPage({String? error}) {
  final message = error == null
      ? ''
      : '<p class="error" role="alert">${htmlEscape.convert(error)}</p>';
  return '''
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="color-scheme" content="light dark">
<title>keklist</title>
<style>
  :root {
    --background: #f6f7fb; --card: #ffffff; --text: #1a1b21;
    --muted: #5c5f6b; --line: #c5c7d1; --accent: #2b3a67;
    --on-accent: #ffffff; --error: #b3261e;
  }
  @media (prefers-color-scheme: dark) {
    :root {
      --background: #121318; --card: #1c1d24; --text: #e3e3ea;
      --muted: #a4a7b4; --line: #45474f; --accent: #b7c4ff;
      --on-accent: #1a2550; --error: #f2b8b5;
    }
  }
  * { box-sizing: border-box; }
  body {
    margin: 0; min-height: 100vh; display: grid; place-items: center;
    padding: 16px; background: var(--background); color: var(--text);
    font: 16px/1.5 system-ui, -apple-system, "Segoe UI", Roboto, sans-serif;
  }
  form {
    width: 100%; max-width: 360px; padding: 32px 24px 24px;
    background: var(--card); border: 1px solid var(--line);
    border-radius: 24px;
  }
  h1 { margin: 0 0 4px; font-size: 24px; font-weight: 600; }
  p { margin: 0 0 24px; color: var(--muted); }
  input {
    width: 100%; padding: 12px; font: inherit; font-size: 24px;
    letter-spacing: 0.3em; text-align: center; color: inherit;
    background: transparent; border: 1px solid var(--line);
    border-radius: 12px;
  }
  input:focus { outline: 2px solid var(--accent); border-color: transparent; }
  button {
    width: 100%; margin-top: 16px; padding: 12px; font: inherit;
    font-weight: 600; color: var(--on-accent); background: var(--accent);
    border: 0; border-radius: 999px; cursor: pointer;
  }
  .error { margin: 16px 0 0; color: var(--error); }
</style>
</head>
<body>
<form method="post" action="login">
  <h1>keklist</h1>
  <p>Enter the PIN set in Settings on the phone.</p>
  <input name="pin" type="password" inputmode="numeric" pattern="[0-9]*"
    maxlength="8" autocomplete="current-password" aria-label="PIN"
    required autofocus>
  <button>Open</button>
  $message
</form>
</body>
</html>
''';
}
