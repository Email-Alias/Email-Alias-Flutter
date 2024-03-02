import 'package:email_alias/app/email/detail_email_content.dart';
import 'package:email_alias/app/home_content.dart';
import 'package:email_alias/app/settings/licenses_content.dart';
import 'package:email_alias/app/settings/settings_content.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'routes.g.dart';

@TypedGoRoute<HomeRoute>(
  path: '/',
  routes: [
    TypedGoRoute<DetailEmailRoute>(
      path: 'detail',
    ),
    TypedGoRoute<SettingsRoute>(
      path: 'settings',
      routes: [
        TypedGoRoute<LicenseRoute>(
          path: 'licenses',
        ),
      ],
    ),
  ],
)
@immutable
final class HomeRoute extends GoRouteData {
  const HomeRoute();

  @override
  Widget build(final BuildContext context, final GoRouterState state) => const HomeContent();
}

@immutable
final class DetailEmailRoute extends GoRouteData {
  const DetailEmailRoute({required this.comment, required this.address});

  final String comment;
  final String address;

  @override
  Widget build(final BuildContext context, final GoRouterState state) => DetailEmailContent(
    comment: comment,
    address: address,
  );
}

@immutable
final class SettingsRoute extends GoRouteData {
  const SettingsRoute();

  @override
  Widget build(final BuildContext context, final GoRouterState state) => const SettingsContent();
}

@immutable
final class LicenseRoute extends GoRouteData {
  const LicenseRoute();

  @override
  Widget build(final BuildContext context, final GoRouterState state) => const LicensesContent();
}
