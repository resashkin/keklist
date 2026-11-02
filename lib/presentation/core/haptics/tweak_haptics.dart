import 'package:haptic_feedback/haptic_feedback.dart';

/// A light tick for every value changed in a tweak sheet and every pinch step.
void tweakChangeHaptic() => Haptics.vibrate(HapticsType.selection);
