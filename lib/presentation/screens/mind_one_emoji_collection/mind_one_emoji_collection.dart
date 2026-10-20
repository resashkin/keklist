import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart' hide DateUtils;
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:keklist/presentation/core/helpers/extensions/state_extensions.dart';
import 'package:keklist/presentation/screens/actions/action_model.dart';
import 'package:keklist/presentation/screens/actions/actions_screen.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/messaged_list/mind_monolog_list_widget.dart';
import 'package:keklist/presentation/blocs/mind_bloc/mind_bloc.dart';
import 'package:keklist/presentation/core/helpers/bloc_utils.dart';
import 'package:keklist/presentation/core/dispose_bag.dart';
import 'package:keklist/presentation/core/helpers/mind_utils.dart';
import 'package:keklist/presentation/core/helpers/date_utils.dart';
import 'package:keklist/presentation/screens/mind_info/mind_info_screen.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

final class MindOneEmojiCollectionScreen extends StatefulWidget {
  final String emoji;
  final Iterable<Mind> allMinds;

  const MindOneEmojiCollectionScreen({super.key, required this.emoji, required this.allMinds});

  @override
  State<MindOneEmojiCollectionScreen> createState() => _MindOneEmojiCollectionScreenState();
}

final class _MindOneEmojiCollectionScreenState extends State<MindOneEmojiCollectionScreen> with DisposeBag {
  late final List<Mind> allMinds = widget.allMinds.sortedByProperty((e) => e.dayIndex).toList();

  List<Mind> get emojiMinds =>
      MindUtils.findMindsByEmoji(emoji: widget.emoji, allMinds: allMinds).sortedByProperty((e) => e.dayIndex);

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });

    subscribeToBloc<MindBloc>(
      onNewState: (state) async {
        if (state is MindList) {
          setState(() {
            allMinds
              ..clear()
              ..addAll(state.values.sortedByProperty((e) => e.dayIndex));
          });
        }
      },
    )?.disposed(by: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.emoji)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 150),
        controller: _scrollController,
        child: MindMonologListWidget(
          minds: emojiMinds,
          onTap: _showMindInfo,
          onOptions: _showActions,
          mindIdsToChildren: null,
        ),
      ),
    );
  }

  @override
  void dispose() {
    cancelSubscriptions();
    _scrollController.dispose();
    super.dispose();
  }

  void _showActions(Mind mind) {
    showBarModalBottomSheet(
      context: context,
      builder: (context) => ActionsScreen(
        actions: [
          (ActionModel.edit(context), () => _showMindInfo(mind)),
          (
            ActionModel.switchDay(context),
            () async {
              final int? switchedDay = await _showDateSwitcherToNewDay();
              if (switchedDay != null) {
                final List<Mind> switchedDayMinds = MindUtils.findMindsByDayIndex(
                  dayIndex: switchedDay,
                  allMinds: allMinds,
                );
                final int sortIndex = (switchedDayMinds.map((mind) => mind.sortIndex).maxOrNull ?? -1) + 1;
                final Mind newMind = mind.copyWith(dayIndex: switchedDay, sortIndex: sortIndex);
                sendEventToBloc<MindBloc>(MindEdit(mind: newMind));
              }
            },
          ),
          (ActionModel.delete(context), () => sendEventToBloc<MindBloc>(MindDelete(mind: mind))),
        ],
      ),
    );
  }

  Future<int?> _showDateSwitcherToNewDay() async {
    final List<DateTime?>? dates = await showCalendarDatePicker2Dialog(
      context: context,
      value: [DateUtils.getDateFromDayIndex(DateUtils.getTodayIndex())],
      config: CalendarDatePicker2WithActionButtonsConfig(firstDayOfWeek: 1),
      dialogSize: const Size(325, 400),
      borderRadius: BorderRadius.circular(15),
    );

    if (dates?.firstOrNull == null) {
      return null;
    }

    final int dayIndex = DateUtils.getDayIndex(from: dates!.first!);
    return dayIndex;
  }

  void _showMindInfo(Mind mind) {
    if (mountedContext == null) {
      return;
    }

    Navigator.of(mountedContext!).push(
      SwipeablePageRoute(
        builder: (_) => MindInfoScreen(rootMind: mind, allMinds: allMinds),
      ),
    );
  }
}
