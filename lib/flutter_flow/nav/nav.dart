import 'dart:async';

import 'package:eqlite/Auth/Login/Login_widget.dart';
import 'package:eqlite/Auth/Verify/verify_widget.dart';
import 'package:eqlite/Dashboard/dashboard_widget.dart';
import 'package:eqlite/SplashScreen/SplashScreen_widget.dart';
// Added routes imports
import 'package:eqlite/About/About_widget.dart';
import 'package:eqlite/AddAddress/NewAddress_widget.dart';
import 'package:eqlite/AddressBook/AddressBook_widget.dart';
import 'package:eqlite/BusinessPage/businessWidget.dart';
import 'package:eqlite/CompleteLocation/CompleteLocation_widget.dart';
import 'package:eqlite/Component/AddAnotherPerson/AddOtherWidget.dart';
import 'package:eqlite/Component/AppointmentTime/AppointmentTimeWidget.dart';
import 'package:eqlite/Component/AppointmentType/appointment_type_widget.dart';
import 'package:eqlite/Component/BusinessDetail/business_info_widget.dart';
import 'package:eqlite/Component/Confirmation/exitConfirmation.dart';
import 'package:eqlite/Component/Confirmation/permissionConfirmation.dart';
import 'package:eqlite/Component/Congratulate/confirm_ui_widget.dart';
import 'package:eqlite/Component/Congratulate/congratulation_widget.dart';
import 'package:eqlite/FavoriteBusiness/FavoriteBusiness_widget.dart';
import 'package:eqlite/Feedback/Feedback_widget.dart';
import 'package:eqlite/FixAppointment/fix_Appointment_Widget.dart';
import 'package:eqlite/GlobalSearch/globalSearch_Widget.dart';
import 'package:eqlite/Profile/Profile_widget.dart';
import 'package:eqlite/ScannerQr/Scanner_widget.dart';
import 'package:eqlite/SelectCity/select_city_widget.dart';
import 'package:eqlite/ServicePage/AddServicePageWidget.dart';
import 'package:eqlite/Setting/Setting.dart';
import 'package:eqlite/SettingPage/setting_widget.dart';
import 'package:eqlite/UpcomingAppointment/detail_Appointment_Widget.dart';
import 'package:eqlite/YourAppointments/YourAppointments_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '/main.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/lat_lng.dart';
import '/flutter_flow/place.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'serialization_util.dart';

export 'package:go_router/go_router.dart';
export 'serialization_util.dart';

const kTransitionInfoKey = '__transition_info__';

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  bool showSplashImage = false;

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }
}

GoRouter createRouter(AppStateNotifier appStateNotifier) => GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: appStateNotifier,
      errorBuilder: (context, state) => SplashScreen(),
      routes: [
        FFRoute(
          name: '_initialize',
          path: '/',
          builder: (context, _) => SplashScreen(),
        ),
        FFRoute(
          name: 'HomePage',
          path: '/homePage',
          builder: (context, params) =>  HomePageWidget(),
        ),
        FFRoute(
          name: 'splashscreen',
          path: '/splashscreen',
          builder: (context, params) => SplashScreen(),
        ),
        FFRoute(
          name: 'loginpage',
          path: '/loginpage',
          builder: (context, params) => LoginWidget(),
        ),
        // Additional pages
        FFRoute(
          name: 'verify',
          path: '/verify',
          builder: (context, params) => VerifyWidget(
            phone: params.getParam('phone', ParamType.String) ?? '',
            otp: params.getParam('otp', ParamType.String) ?? '',
          ),
        ),
        FFRoute(
          name: 'about',
          path: '/about',
          builder: (context, params) => AboutWidget(),
        ),
        FFRoute(
          name: 'addressBook',
          path: '/addressBook',
          builder: (context, params) => AddressBookWidget(),
        ),
        FFRoute(
          name: 'businessLocation',
          path: '/businessLocation',
          builder: (context, params) => BusinessLocationWidget(),
        ),
        FFRoute(
          name: 'completeLocation',
          path: '/completeLocation',
          builder: (context, params) => BusinessCompletelocationWidget(
            address: params.getParam('address', ParamType.JSON),
            id: params.getParam('id', ParamType.String),
          ),
        ),
        FFRoute(
          name: 'business',
          path: '/business',
          builder: (context, params) => BusinessPageWidget(
            categoryId: params.getParam('categoryId', ParamType.String) ?? '',
            categoryName: params.getParam('categoryName', ParamType.String) ?? '',
            latitude: params.getParam('latitude', ParamType.String),
            longitude: params.getParam('longitude', ParamType.String),
          ),
        ),
        FFRoute(
          name: 'appointmentType',
          path: '/appointmentType',
          builder: (context, params) => AppointmentTypeWidget(
            userId: params.getParam('userId', ParamType.String) ?? '',
            queueId: params.getParam('queueId', ParamType.String) ?? '',
            queueDate: params.getParam('queueDate', ParamType.String) ?? '',
            queueServices: params.getParam('queueServices', ParamType.JSON, true) ?? const [],
          ),
        ),
        FFRoute(
          name: 'congratulation',
          path: '/congratulation',
          builder: (context, params) => CongratulationWidget(
            response: params.getParam('response', ParamType.JSON),
          ),
        ),
        FFRoute(
          name: 'favoriteBusiness',
          path: '/favoriteBusiness',
          builder: (context, params) => FavoriteBusinessWidget(),
        ),
        FFRoute(
          name: 'feedback',
          path: '/feedback',
          builder: (context, params) => FeedbackWidget(),
        ),
        FFRoute(
          name: 'fixAppointment',
          path: '/fixAppointment',
          builder: (context, params) => FixAppointmentWidget(
            services: params.getParam('services', ParamType.JSON, true) ?? const [],
            date: params.getParam('date', ParamType.String) ?? '',
            businessName: params.getParam('businessName', ParamType.String) ?? '',
            formatDate: params.getParam('formatDate', ParamType.String) ?? '',
            uuid: params.getParam('uuid', ParamType.String) ?? '',
            rescheduleData: params.getParam('rescheduleData', ParamType.JSON),
          ),
        ),
        FFRoute(
          name: 'globalSearch',
          path: '/globalSearch',
          builder: (context, params) => GlobalSearchWidget(
            lat: params.getParam('lat', ParamType.String),
            long: params.getParam('long', ParamType.String),
          ),
        ),
        FFRoute(
          name: 'profile',
          path: '/profile',
          builder: (context, params) => ProfileWidget(
            backButton: params.getParam('backButton', ParamType.bool) ?? true,
          ),
        ),
        FFRoute(
          name: 'scanner',
          path: '/scanner',
          builder: (context, params) => ScannerQr(
            lat: params.getParam('lat', ParamType.String),
            long: params.getParam('long', ParamType.String),
          ),
        ),
        FFRoute(
          name: 'selectCity',
          path: '/selectCity',
          builder: (context, params) => SelectCityWidget(),
        ),
        FFRoute(
          name: 'addService',
          path: '/addService',
          builder: (context, params) => AddServicePageWidget(
            businessId: params.getParam('businessId', ParamType.String) ?? '',
            lat: params.getParam('lat', ParamType.String),
            long: params.getParam('long', ParamType.String),
          ),
        ),
        FFRoute(
          name: 'setting',
          path: '/setting',
          builder: (context, params) => SettingWidget(),
        ),
        FFRoute(
          name: 'settingPage',
          path: '/settingPage',
          builder: (context, params) => SettingPageWidget(),
        ),
        FFRoute(
          name: 'upcomingAppointmentDetail',
          path: '/upcomingAppointmentDetail',
          builder: (context, params) => DetailAppointmentsWidget(
            lat: params.getParam('lat', ParamType.String),
            long: params.getParam('long', ParamType.String),
          ),
        ),
        FFRoute(
          name: 'yourAppointments',
          path: '/yourAppointments',
          builder: (context, params) => YourAppointmentsWidget(),
        ),
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
    );

extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(
        entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
}

extension NavigationExtensions on BuildContext {
  void safePop() {
    // If there is only one route on the stack, navigate to the initial
    // page instead of popping.
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      extra != null ? extra as Map<String, dynamic> : {};
  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(pathParameters)
    ..addAll(queryParameters)
    ..addAll(extraMap);
  TransitionInfo get transitionInfo => extraMap.containsKey(kTransitionInfoKey)
      ? extraMap[kTransitionInfoKey] as TransitionInfo
      : TransitionInfo.appDefault();
}

class FFParameters {
  FFParameters(this.state, [this.asyncParams = const {}]);

  final GoRouterState state;
  final Map<String, Future<dynamic> Function(String)> asyncParams;

  Map<String, dynamic> futureParamValues = {};

  // Parameters are empty if the params map is empty or if the only parameter
  // present is the special extra parameter reserved for the transition info.
  bool get isEmpty =>
      state.allParams.isEmpty ||
      (state.extraMap.length == 1 &&
          state.extraMap.containsKey(kTransitionInfoKey));
  bool isAsyncParam(MapEntry<String, dynamic> param) =>
      asyncParams.containsKey(param.key) && param.value is String;
  bool get hasFutures => state.allParams.entries.any(isAsyncParam);
  Future<bool> completeFutures() => Future.wait(
        state.allParams.entries.where(isAsyncParam).map(
          (param) async {
            final doc = await asyncParams[param.key]!(param.value)
                .onError((_, __) => null);
            if (doc != null) {
              futureParamValues[param.key] = doc;
              return true;
            }
            return false;
          },
        ),
      ).onError((_, __) => [false]).then((v) => v.every((e) => e));

  dynamic getParam<T>(
    String paramName,
    ParamType type, [
    bool isList = false,
  ]) {
    if (futureParamValues.containsKey(paramName)) {
      return futureParamValues[paramName];
    }
    if (!state.allParams.containsKey(paramName)) {
      return null;
    }
    final param = state.allParams[paramName];
    // Got parameter from `extras`, so just directly return it.
    if (param is! String) {
      return param;
    }
    // Return serialized value.
    return deserializeParam<T>(
      param,
      type,
      isList,
    );
  }
}

class FFRoute {
  const FFRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.requireAuth = false,
    this.asyncParams = const {},
    this.routes = const [],
  });

  final String name;
  final String path;
  final bool requireAuth;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, FFParameters) builder;
  final List<GoRoute> routes;

  GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(
        name: name,
        path: path,
        pageBuilder: (context, state) {
          final ffParams = FFParameters(state, asyncParams);
          final page = ffParams.hasFutures
              ? FutureBuilder(
                  future: ffParams.completeFutures(),
                  builder: (context, _) => builder(context, ffParams),
                )
              : builder(context, ffParams);
          final child = page;

          final transitionInfo = state.transitionInfo;
          return transitionInfo.hasTransition
              ? CustomTransitionPage(
                  key: state.pageKey,
                  child: child,
                  transitionDuration: transitionInfo.duration,
                  transitionsBuilder: PageTransition(
                    type: transitionInfo.transitionType,
                    duration: transitionInfo.duration,
                    reverseDuration: transitionInfo.duration,
                    alignment: transitionInfo.alignment,
                    child: child,
                  ).transitionsBuilder,
                )
              : MaterialPage(key: state.pageKey, child: child);
        },
        routes: routes,
      );
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  static TransitionInfo appDefault() => TransitionInfo(hasTransition: false);
}

class RootPageContext {
  const RootPageContext(this.isRootPage, [this.errorRoute]);
  final bool isRootPage;
  final String? errorRoute;

  static bool isInactiveRootPage(BuildContext context) {
    final rootPageContext = context.read<RootPageContext?>();
    final isRootPage = rootPageContext?.isRootPage ?? false;
    final location = GoRouter.of(context).location;
    return isRootPage &&
        location != '/' &&
        location != rootPageContext?.errorRoute;
  }

  static Widget wrap(Widget child, {String? errorRoute}) => Provider.value(
        value: RootPageContext(true, errorRoute),
        child: child,
      );
}
