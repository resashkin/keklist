import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keklist/domain/services/phone_web/phone_web_mode.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/presentation/blocs/emotion_bloc/emotion_bloc.dart';
import 'package:keklist/presentation/blocs/mind_bloc/mind_bloc.dart';
import 'package:keklist/presentation/blocs/user_profile_bloc/user_profile_bloc.dart';
import 'package:keklist/presentation/core/helpers/emotion_colors.dart';
import 'package:keklist/presentation/core/widgets/glass_app_bar.dart';
import 'package:keklist/presentation/core/helpers/media_sources.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/core/widgets/kek_bottom_sheet.dart';
import 'package:keklist/presentation/screens/emotions/emoji_picker_screen.dart';
import 'package:material_ui/material_ui.dart';

const double _kAvatarSize = 88.0;
const double _kAvatarPixels = 512.0;

/// The top of insights: avatar, name and "Mindful for N days"; tapping it edits the profile.
final class InsightsProfileHeader extends StatelessWidget {
  final int mindfulDays;

  const InsightsProfileHeader({super.key, required this.mindfulDays});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final UserProfileState profile = context.watch<UserProfileBloc>().state;
    final String? name = profile.nickname?.trim();
    final bool hasName = name != null && name.isNotEmpty;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => ProfileEditSheet.show(context),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
        child: Column(
          spacing: 6.0,
          children: [
            UserAvatarView(profile: profile, size: _kAvatarSize),
            const SizedBox(height: 2.0),
            Text(
              hasName ? name : context.l10n.profileName,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: hasName ? null : theme.disabledColor,
              ),
            ),
            Text(
              context.l10n.profileMindfulDays(mindfulDays),
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

/// A round avatar: the photo, else the emoji, else the first letter of the name.
final class UserAvatarView extends StatelessWidget {
  final String? imagePath;
  final String? emoji;
  final String? nickname;
  final double size;

  const UserAvatarView._({required this.imagePath, required this.emoji, required this.nickname, required this.size});

  UserAvatarView({super.key, required UserProfileState profile, required this.size})
    : imagePath = profile.avatarImagePath,
      emoji = profile.avatarEmoji,
      nickname = profile.nickname;

  factory UserAvatarView.choice(UserAvatarChoice choice, {required double size}) =>
      UserAvatarView._(imagePath: choice.imagePath, emoji: choice.avatar.emoji, nickname: null, size: size);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final String? image = imagePath;
    final String initial = (nickname?.trim().characters.firstOrNull ?? '?').toUpperCase();
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(shape: BoxShape.circle, color: colors.onSurface.withValues(alpha: 0.1)),
      alignment: Alignment.center,
      child: image != null
          ? imageFor(image, width: size, height: size, fit: BoxFit.cover)
          : Text(
              emoji ?? initial,
              style: TextStyle(
                fontSize: size * (emoji != null ? 0.55 : 0.45),
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
    );
  }
}

/// Edits the name and the avatar: a selfie, a photo, an emoji or the name's letter, or one of the recent avatars.
final class ProfileEditSheet extends StatefulWidget {
  const ProfileEditSheet({super.key});

  static Future<void> show(BuildContext context) =>
      KekSheet.show(context: context, builder: (_) => const ProfileEditSheet());

  @override
  State<ProfileEditSheet> createState() => _ProfileEditSheetState();
}

final class _ProfileEditSheetState extends State<ProfileEditSheet> {
  static const double _avatarSize = 120.0;
  static const double _historyItemSize = 56.0;

  late final TextEditingController _nameController = TextEditingController(
    text: context.read<UserProfileBloc>().state.nickname,
  );

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final UserProfileState profile = context.watch<UserProfileBloc>().state;
    final Color glow = _topEmotionColor(context) ?? theme.colorScheme.primary;
    return KekSheetScaffold(
      title: context.l10n.profile,
      child: SingleChildScrollView(
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12.0),
              DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: glow.withValues(alpha: 0.7), width: 3.0),
                  boxShadow: [BoxShadow(color: glow.withValues(alpha: 0.45), blurRadius: 48.0, spreadRadius: 6.0)],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  // A solid backing keeps the glow outside the see-through avatar.
                  child: DecoratedBox(
                    decoration: BoxDecoration(shape: BoxShape.circle, color: theme.colorScheme.surface),
                    child: UserAvatarView(profile: profile, size: _avatarSize),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 4.0),
                child: TextField(
                  controller: _nameController,
                  textAlign: TextAlign.center,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: context.l10n.profileName,
                    hintStyle: theme.textTheme.headlineSmall?.copyWith(color: theme.disabledColor),
                    border: InputBorder.none,
                  ),
                  onChanged: (name) => context.read<UserProfileBloc>().add(UserProfileUpdateNickName(nickName: name)),
                  onSubmitted: (_) => Navigator.of(context).pop(),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 20.0,
                children: [
                  // The web version can't upload photos to the phone.
                  if (!kIsPhoneWeb) ...[
                    _AvatarActionButton(
                      icon: Icons.photo_camera_front_outlined,
                      label: context.l10n.profileSelfie,
                      onTap: () => _pickPhoto(ImageSource.camera),
                    ),
                    _AvatarActionButton(
                      icon: Icons.photo_outlined,
                      label: context.l10n.profilePhoto,
                      onTap: () => _pickPhoto(ImageSource.gallery),
                    ),
                  ],
                  _AvatarActionButton(
                    icon: Icons.emoji_emotions_outlined,
                    label: context.l10n.profileEmoji,
                    onTap: _pickEmoji,
                  ),
                  if (!profile.current.isEmpty)
                    _AvatarActionButton(
                      icon: Icons.text_fields_rounded,
                      label: context.l10n.profileInitial,
                      onTap: () => _updateAvatar(UserProfileUpdateAvatar()),
                    ),
                ],
              ),
              if (profile.history.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 8.0),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      context.l10n.profileRecentAvatars,
                      style: theme.textTheme.titleSmall?.copyWith(color: theme.hintColor),
                    ),
                  ),
                ),
                SizedBox(
                  height: _historyItemSize + 8.0,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    itemCount: profile.history.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10.0),
                    itemBuilder: (context, index) => _historyItem(profile.history[index], profile.current, glow),
                  ),
                ),
              ],
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _historyItem(UserAvatarChoice choice, UserAvatar current, Color glow) {
    final bool isCurrent = choice.avatar == current;
    return GestureDetector(
      onTap: isCurrent ? null : () => _updateAvatar(UserProfileSelectAvatar(choice.avatar)),
      onLongPressStart: (details) => _showHistoryMenu(choice.avatar, details.globalPosition),
      child: Container(
        padding: const EdgeInsets.all(2.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: isCurrent ? glow : Colors.transparent, width: 2.0),
        ),
        child: UserAvatarView.choice(choice, size: _historyItemSize),
      ),
    );
  }

  Future<void> _showHistoryMenu(UserAvatar avatar, Offset position) async {
    HapticFeedback.mediumImpact();
    final bool? shouldDelete = await showMenu<bool>(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx, position.dy),
      items: [
        PopupMenuItem<bool>(
          value: true,
          child: Row(
            spacing: 12.0,
            children: [
              const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              Text(context.l10n.delete, style: const TextStyle(color: Colors.redAccent)),
            ],
          ),
        ),
      ],
    );
    if (shouldDelete == true && mounted) _updateAvatar(UserProfileRemoveAvatar(avatar));
  }

  /// The color of the emotion the user marks most often: it tints the glow around the avatar.
  Color? _topEmotionColor(BuildContext context) {
    final EmotionState emotionState = context.watch<EmotionBloc>().state;
    final MindState mindState = context.watch<MindBloc>().state;
    if (emotionState is! EmotionsList || mindState is! MindList) return null;
    final Map<String, Color> colors = emotionColorsOf(emotionState.emotions);
    final Map<Color, int> counts = {};
    for (final String id in mindState.values.expand((mind) => mind.emotionIds)) {
      final Color? color = colors[id];
      if (color != null) counts[color] = (counts[color] ?? 0) + 1;
    }
    return counts.entries.fold<MapEntry<Color, int>?>(null, (best, entry) {
      return best == null || entry.value > best.value ? entry : best;
    })?.key;
  }

  void _updateAvatar(UserProfileEvent event) => context.read<UserProfileBloc>().add(event);

  Future<void> _pickPhoto(ImageSource source) async {
    final XFile? picked = await ImagePicker().pickImage(
      source: source,
      preferredCameraDevice: CameraDevice.front,
      maxWidth: _kAvatarPixels,
      maxHeight: _kAvatarPixels,
      imageQuality: 90,
    );
    if (picked == null || !mounted) return;
    _updateAvatar(UserProfileUpdateAvatar(photo: File(picked.path)));
  }

  Future<void> _pickEmoji() =>
      EmojiPickerScreen.show(context, onSelect: (emoji) => _updateAvatar(UserProfileUpdateAvatar(emoji: emoji)));
}

/// A round glass button with a caption under it, like the actions on a contact card.
final class _AvatarActionButton extends StatelessWidget {
  static const double _size = 52.0;

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AvatarActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 6.0,
        children: [
          GlassBubble(isCircle: true, height: _size, child: Icon(icon)),
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
