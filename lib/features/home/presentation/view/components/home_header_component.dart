import 'package:flutter/material.dart';

import '../widgets/home_entrance.dart';
import '../widgets/home_header_widget.dart';

class HomeHeaderComponent extends StatelessWidget {
  const HomeHeaderComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeEntrance(
      child: HomeHeaderWidget(isHome: true),
    );
  }
}
