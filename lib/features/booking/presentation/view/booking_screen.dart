import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/ui/shared_widgets/custom_image_circle.dart';
import 'package:heraj/ui/shared_widgets/scaffold_back_ground.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  final tabs = ["الكل", "القادمة", "قيد التنفيذ", "انتهى"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldSliversBackGround(hideSearchBar: true, slivers: [
      SliverGap(16),
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final isDone = index.isEven;
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColor.grey1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 70,
                      decoration: BoxDecoration(
                          color: AppColor.primaryWhite,
                          borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          const Gap(10),
                          const CustomImageCircle(
                            image: "assets/base/woman.jpg",
                            radius: 16,
                          ),
                          const Gap(8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("اسم الخدمة",
                                  style: AppFont.font16W400Black),
                              Text("اسم مقدم الخدمة",
                                  style: AppFont.font12W600Black),
                            ],
                          )
                        ],
                      ),
                    ),
                    const Gap(10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("02:30 ص - 12 نوفمبر 2025",
                            style: AppFont.font12w400Black),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDone
                                ? Colors.blue.shade50
                                : Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isDone
                                    ? Icons.check_circle
                                    : Icons.timelapse,
                                color: isDone ? Colors.blue : Colors.orange,
                                size: 14,
                              ),
                              const Gap(4),
                              Text(isDone ? "اكتملت" : "قيد التنفيذ",
                                  style: AppFont.font12w400Black.copyWith(
                                      color: isDone
                                          ? Colors.blue
                                          : Colors.orange)),
                            ],
                          ),
                        )
                      ],
                    ),
                    const Gap(8),
                    const DottedDivider(),
                    const Gap(4),
                    Text("تفاصيل الحجز", style: AppFont.font14W600Black),
                    const Gap(4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "يوم الحجز",
                          style: AppFont.font12w400Black,
                        ),
                        Text(
                          "25 يونيو 2025",
                          style: AppFont.font12w400Black,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "وقت الحجز",
                          style: AppFont.font12w400Black,
                        ),
                        Text(
                          "02:30 صباحا",
                          style: AppFont.font12w400Black,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
          childCount: 5,
        ),
      ),
    ]);
  }
}

class DottedDivider extends StatelessWidget {
  final double height;
  final Color color;
  final double spacing;
  final double padding;
  final double dotSize;

  const DottedDivider({
    super.key,
    this.height = 1,
    this.color = const Color(0xffd0d9e5),
    this.spacing = 4,
    this.padding = 0,
    this.dotSize = 4,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashCount = (boxWidth / (dotSize + spacing)).floor();

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(dashCount, (_) {
              return Container(
                width: dotSize,
                height: height,
                decoration: BoxDecoration(
                  color: color,
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
