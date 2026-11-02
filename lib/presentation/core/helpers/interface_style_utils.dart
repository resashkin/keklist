import 'package:keklist/domain/constants.dart';
import 'package:keklist/domain/repositories/settings/keklist_interface_style.dart';
import 'package:keklist/presentation/core/helpers/platform_utils.dart';
import 'package:native_liquid_glass/native_liquid_glass.dart';

// Native glass widgets render an empty box below iOS 26, which hid the tab bar there.
bool isLiquidGlassAvailableOnThisPlatform() =>
    DeviceUtils.safeGetPlatform() == SupportedPlatform.iOS && NativeLiquidGlassUtils.supportsLiquidGlass;

bool resolveUseLiquidGlass(KeklistInterfaceStyle style) =>
    style == KeklistInterfaceStyle.liquidGlass && isLiquidGlassAvailableOnThisPlatform();
