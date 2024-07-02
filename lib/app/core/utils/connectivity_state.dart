import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

final connectivityStateProvider = StateProvider<InternetConnectionStatus>(
    (ref) => InternetConnectionStatus.disconnected);
