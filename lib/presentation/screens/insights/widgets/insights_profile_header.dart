import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keklist/presentation/blocs/user_profile_bloc/user_profile_bloc.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/core/widgets/kek_bottom_sheet.dart';
import 'package:keklist/presentation/screens/emotions/emoji_picker_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

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
  final UserProfileState profile;
  final double size;

  const UserAvatarView({super.key, required this.profile, required this.size});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final File? image = profile.avatarImage;
    final String? emoji = profile.avatarEmoji;
    final String initial = (profile.nickname?.trim().characters.firstOrNull ?? '?').toUpperCase();
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(shape: BoxShape.circle, color: colors.onSurface.withValues(alpha: 0.1)),
      alignment: Alignment.center,
      child: image != null
          ? Image.file(image, width: size, height: size, fit: BoxFit.cover, gaplessPlayback: true)
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

/// Edits the name and picks the avatar: a photo, an emoji or the name's letter.
final class ProfileEditSheet extends StatefulWidget {
  const ProfileEditSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const ProfileEditSheet(),
  );

  @override
  State<ProfileEditSheet> createState() => _ProfileEditSheetState();
}

final class _ProfileEditSheetState extends State<ProfileEditSheet> {
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
    final UserProfileState profile = context.watch<UserProfileBloc>().state;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: KekBottomSheetStyle.decoration(context),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              KekBottomSheetStyle.handle(context),
              Text(context.l10n.profile, style: KekBottomSheetStyle.titleStyle(context)),
              const SizedBox(height: 16.0),
              UserAvatarView(profile: profile, size: _kAvatarSize),
              const SizedBox(height: 12.0),
              Wrap(
                spacing: 8.0,
                alignment: WrapAlignment.center,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.photo_outlined),
                    label: Text(context.l10n.profilePhoto),
                    onPressed: _pickPhoto,
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.emoji_emotions_outlined),
                    label: Text(context.l10n.profileEmoji),
                    onPressed: _pickEmoji,
                  ),
                  if (profile.avatarImage != null || profile.avatarEmoji != null)
                    ActionChip(
                      avatar: const Icon(Icons.text_fields_rounded),
                      label: Text(context.l10n.profileInitial),
                      onPressed: () => _updateAvatar(UserProfileUpdateAvatar()),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 16.0),
                child: TextField(
                  controller: _nameController,
                  textAlign: TextAlign.center,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(hintText: context.l10n.profileName, border: const OutlineInputBorder()),
                  onChanged: (name) => context.read<UserProfileBloc>().add(UserProfileUpdateNickName(nickName: name)),
                  onSubmitted: (_) => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateAvatar(UserProfileUpdateAvatar event) => context.read<UserProfileBloc>().add(event);

  Future<void> _pickPhoto() async {
    final XFile? picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: _kAvatarPixels,
      maxHeight: _kAvatarPixels,
      imageQuality: 90,
    );
    if (picked == null || !mounted) return;
    _updateAvatar(UserProfileUpdateAvatar(photo: File(picked.path)));
  }

  Future<void> _pickEmoji() => showCupertinoModalBottomSheet(
    context: context,
    builder: (_) => Material(
      child: EmojiPickerScreen(onSelect: (emoji) => _updateAvatar(UserProfileUpdateAvatar(emoji: emoji))),
    ),
  );
}
