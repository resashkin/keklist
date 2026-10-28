import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/services.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:keklist/domain/services/web_server/keklist_web_server.dart';
import 'package:keklist/domain/services/web_server/web_access.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/screens/settings/settings_layout.dart';
import 'package:material_ui/material_ui.dart';

/// Rows of the "Web version" section: its switch, then while on where to open it, the PIN that guards it and its port.
List<SettingsRowModel> webVersionRows(BuildContext context, KeklistWebServer server) {
  final WebAccess access = server.access;
  final ThemeData theme = Theme.of(context);
  final Widget status = switch (server.state) {
    WebServerRunning(:final addresses) when addresses.isNotEmpty => Column(
      children: [
        for (final String address in addresses)
          ListTile(
            leading: const Icon(Icons.computer),
            title: Text(address, style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()])),
            subtitle: address == addresses.first ? Text(context.l10n.webVersionAddressHint) : null,
            trailing: const Icon(Icons.copy, size: 18.0),
            onTap: () => _copy(context, address),
          ),
      ],
    ),
    WebServerRunning() => _note(context.l10n.webVersionNoWifi),
    WebServerOff() => const SizedBox.shrink(),
    WebServerStarting() => _note(context.l10n.webVersionStarting),
    WebServerNoBundle() => _note(context.l10n.webVersionNoBundle),
    WebServerFailed(:final message) => _note(message, color: theme.colorScheme.error),
  };
  final SettingsRowModel toggle = SettingsRowModel(
    id: SettingsItemIds.webVersionEnabled,
    title: context.l10n.webVersionEnabled,
    tile: SwitchListTile.adaptive(
      secondary: const Icon(Icons.wifi_tethering),
      title: Text(context.l10n.webVersionEnabled),
      value: access.isEnabled,
      onChanged: (value) => _setEnabled(context, access, value),
    ),
  );
  if (!access.isEnabled) return [toggle];
  return [
    toggle,
    SettingsRowModel(id: SettingsItemIds.webVersionAddress, title: context.l10n.webVersion, tile: status),
    SettingsRowModel(
      id: SettingsItemIds.webVersionPin,
      title: context.l10n.webVersionPin,
      tile: ListTile(
        leading: const Icon(Icons.pin_outlined),
        title: Text(context.l10n.webVersionPin),
        subtitle: Text(access.hasPin ? context.l10n.webVersionPinSet : context.l10n.webVersionPinNotSet),
        trailing: access.hasPin
            ? IconButton(
                tooltip: context.l10n.webVersionRemovePin,
                icon: const Icon(Icons.delete_outline),
                onPressed: () => access.setPin(null),
              )
            : null,
        onTap: () => _setPin(context, access),
      ),
    ),
    SettingsRowModel(
      id: SettingsItemIds.webVersionPort,
      title: context.l10n.webVersionPort,
      tile: ListTile(
        leading: const Icon(Icons.lan_outlined),
        title: Text(context.l10n.webVersionPort),
        subtitle: Text('${access.port}'),
        onTap: () => _setPort(context, access),
      ),
    ),
  ];
}

Widget _note(String text, {Color? color}) => Builder(
  builder: (context) => ListTile(
    leading: const Icon(Icons.computer),
    title: Text(text, style: TextStyle(color: color ?? Theme.of(context).hintColor)),
  ),
);

void _copy(BuildContext context, String address) {
  Clipboard.setData(ClipboardData(text: address));
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.webVersionCopied)));
}

// Switching on without a PIN asks for one first: the web version is never served unguarded.
Future<void> _setEnabled(BuildContext context, WebAccess access, bool isEnabled) async {
  if (isEnabled && !access.hasPin) await _setPin(context, access);
  if (isEnabled && !access.hasPin) return;
  Haptics.vibrate(isEnabled ? HapticsType.success : HapticsType.light);
  await access.setEnabled(isEnabled);
}

Future<void> _setPin(BuildContext context, WebAccess access) async {
  final List<String>? values = await showTextInputDialog(
    context: context,
    title: context.l10n.webVersionPin,
    textFields: [
      DialogTextField(
        hintText: context.l10n.webVersionPinHint,
        keyboardType: TextInputType.number,
        obscureText: true,
        maxLength: 8,
        validator: (value) => WebAccess.pinFormat.hasMatch(value ?? '') ? null : context.l10n.webVersionPinHint,
      ),
    ],
  );
  final String? pin = values?.firstOrNull;
  if (pin != null && WebAccess.pinFormat.hasMatch(pin)) await access.setPin(pin);
}

Future<void> _setPort(BuildContext context, WebAccess access) async {
  final List<String>? values = await showTextInputDialog(
    context: context,
    title: context.l10n.webVersionPort,
    textFields: [
      DialogTextField(
        initialText: '${access.port}',
        keyboardType: TextInputType.number,
        validator: (value) {
          final int? port = int.tryParse(value ?? '');
          return port != null && port >= WebAccess.minPort && port <= WebAccess.maxPort
              ? null
              : '${WebAccess.minPort}–${WebAccess.maxPort}';
        },
      ),
    ],
  );
  final int? port = int.tryParse(values?.firstOrNull ?? '');
  if (port != null && port >= WebAccess.minPort && port <= WebAccess.maxPort) await access.setPort(port);
}
