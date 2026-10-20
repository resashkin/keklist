import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:keklist/domain/repositories/mind/mind_repository.dart';
import 'package:keklist/domain/services/entities/mind.dart';

part 'mind_searcher_state.dart';

final class MindSearcherCubit extends Cubit<MindSearcherState> {
  final MindRepository repository;

  MindSearcherCubit({required this.repository}) : super(MindSearcherInitial());

  Future<List<Mind>> searchMindList(String text) async {
    final lowerCasedTrimmedText = text.toLowerCase().trim();

    final minds = repository.values;
    final filteredMinds =
        minds.where((mind) => mind.plainNote.trim().toLowerCase().contains(lowerCasedTrimmedText)).toList();

    return filteredMinds;
  }
}
