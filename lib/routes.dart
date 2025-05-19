import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:visits_tracker/models/activity.dart';
import 'package:visits_tracker/models/customer.dart';
import 'package:visits_tracker/models/visits.dart';
import 'package:visits_tracker/views/stats.dart';
import 'package:visits_tracker/widgets/main_scaffold.dart';
import 'views/visit_list.dart';
import 'views/new_visit.dart';
import 'views/visit_details.dart';


final router = GoRouter(
  initialLocation: '/',
  routes: [
    // Bottom nav wrapper
    ShellRoute(
      builder: (context, state, child) {
        final location = state.uri.path;
        final currentIndex = location.startsWith('/stats') ? 1 : 0;

        return MainScaffold(
          child: child,
          currentIndex: currentIndex,
        );
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const VisitListPage(),
        ),
        GoRoute(
          path: '/stats',
          builder: (context, state) => const StatisticsPage(),
        ),
      ],
    ),

    // Center FAB action (Add Visit)
    GoRoute(
      path: '/add',
      builder: (context, state) => const AddVisitPage(),
    ),

    // Visit Details
    GoRoute(
      path: '/visit/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? -1;
        return VisitDetailPage(visitId: id);
      },
    ),
  ],
);

// class App extends StatelessWidget {
//   const App({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final router = GoRouter(
//       routes: [
//         GoRoute(
//           path: '/',
//           builder: (context, state) => const VisitListPage(),
//         ),
//         GoRoute(
//           path: '/add',
//           builder: (context, state) => const AddVisitPage(),
//         ),
//         GoRoute(
//   path: '/visit/:id',
//   builder: (context, state) {
//     final id = int.tryParse(state.pathParameters['id'] ?? '') ?? -1;
//     return VisitDetailPage(visitId: id);
//   },
// ),



//       ],
//     );

//     return MaterialApp.router(
//       title: 'Visits Tracker',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       routerConfig: router,
//     );
//   }
// }