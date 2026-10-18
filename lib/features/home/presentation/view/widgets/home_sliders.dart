import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:heraj_meem/helper/riverpod.dart';
import '../../../../../ui/shared_widgets/custom_slider.dart';
import '../../managers/fetch_home_data_provider.dart';
import 'silder_item_widget.dart';

class HomeSliders extends StatelessWidget {
  const HomeSliders({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final provider = ref.watch(fetchHomeDataProvider);
        return provider.customWhen(
            ref: ref,
            refreshable: fetchHomeDataProvider.future,
            data: (homeData) {
              if (homeData.sliders.isEmpty) {
                return const SizedBox.shrink();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: CustomSlider(
                      homeData.sliders.map((e) => SliderItem(e)).toList(),
                      height: 160,
                      autoPlay: true,
                      onPageChanged: (index, _) {
                        ref.read(sliderIndexProvider.notifier).state = index;
                      },
                    ),
                  ),
                  const Gap(10),
                ],
              );
            },
            loading: () {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSlider(
                    const [
                      SliderShimmerItem(),
                      SliderShimmerItem(),
                      SliderShimmerItem(),
                    ],
                    height: 160,
                    autoPlay: true,
                    onPageChanged: (index, _) {
                      ref.read(sliderIndexProvider.notifier).state = index;
                    },
                  ),
                ],
              );
            });
      },
    );
  }
}
