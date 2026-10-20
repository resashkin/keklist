part of '../../mind_collection_screen.dart';

class _SearchAppBar extends StatelessWidget {
  final TextEditingController searchTextController;
  final VoidCallback onSearchCancel;

  const _SearchAppBar({
    required this.searchTextController,
    required this.onSearchCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      automaticallyImplyLeading: true,
      title: _SearchAppBarTextField(
        textController: searchTextController,
        onCancel: onSearchCancel,
      ),
    );
  }
}

class _SearchAppBarTextField extends StatelessWidget {
  final VoidCallback onCancel;
  final TextEditingController textController;

  const _SearchAppBarTextField({
    required this.textController,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Flexible(
          flex: 1,
          child: Icon(Icons.search),
        ),
        const SizedBox(width: 8.0),
        Flexible(
          flex: 10,
          child: TextField(
            controller: textController,
            autofocus: true,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: context.l10n.searchForYourNotes,
            ),
          ),
        ),
        const SizedBox(width: 8.0),
        Flexible(
          flex: 1,
          child: IconButton(
            icon: const Icon(Icons.cancel),
            onPressed: onCancel,
          ),
        ),
        const SizedBox(width: 4.0),
      ],
    );
  }
}
