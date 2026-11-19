import 'package:flutter/widgets.dart';

/// Below this shortest side (in logical pixels) the app lays out for a phone: the
/// `*Mobile` boards of the Design artifact (390 x 844). The Windows window is fixed at
/// 1024 x 768, so it never gets there.
const phoneShortestSide = 600.0;

bool isPhoneLayout(BuildContext context) => MediaQuery.sizeOf(context).shortestSide < phoneShortestSide;
