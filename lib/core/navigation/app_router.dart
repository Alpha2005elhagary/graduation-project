import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RouteNames {
  RouteNames._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String habits = '/habits';
  static const String habitDetail = '/habits/:id';
  static const String tasks = '/tasks';
  static const String addTask = '/tasks/add';
  static const String focus = '/focus';
  static const String coach = '/coach';
  static const String breathing = '/breathing';
  static const String analytics = '/analytics';
  static const String gamification = '/gamification';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
}

class AppRouter {
  AppRouter._();

  static GoRouter router({dynamic redirect}) {
    return GoRouter(
      redirect: redirect,
      routes: [
        GoRoute(path: RouteNames.splash, builder: (_, _) => const SizedBox()),
        GoRoute(
          path: RouteNames.onboarding,
          builder: (_, _) => const SizedBox(),
        ),
        GoRoute(
          path: RouteNames.login,
          builder: (_, _) => const SizedBox(),
        ),
        GoRoute(
          path: RouteNames.register,
          builder: (_, _) => const SizedBox(),
        ),
        GoRoute(
          path: RouteNames.home,
          builder: (_, _) => const SizedBox(),
        ),
      ],
    );
  }
}