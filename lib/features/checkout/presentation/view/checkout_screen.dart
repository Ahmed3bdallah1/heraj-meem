import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/features/address/data/model/address_model.dart';
import 'package:heraj_meem/features/address/presentation/manager/address_provider.dart';
import 'package:heraj_meem/features/address/presentation/view/add_address_screen.dart';
import 'package:heraj_meem/ui/shared_widgets/custom_filled_button.dart';
import 'package:heraj_meem/ui/shared_widgets/loading_widget.dart';
import 'package:heraj_meem/ui/shared_widgets/price_widget.dart';
import 'package:heraj_meem/features/categories/presentation/view/widgets/all_categories/animated_background.dart';
import '../managers/selection_providers.dart';
import '../managers/coupon_provider.dart';
import '../managers/payment_type.dart';
import '../managers/shipping_provider.dart';
import '../../../cart/data/models/cart_item_model.dart';
import '../../../cart/presentation/manager/fetch_cart_provider.dart';
import 'widgets/confirm_order_bottom_sheet.dart';
import 'package:heraj_meem/ui/ui.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundAnimationController;

  @override
  void initState() {
    super.initState();
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(fetchCartProvider);
    final couponState = ref.watch(couponStateProvider);
    final addressesAsync = ref.watch(fetchAddressesProvider);
    final selectedShipping = ref.watch(selectedShippingCompanyProvider);

    final items = cartAsync.valueOrNull?.items ?? <CartItemModel>[];
    final int itemsCount = couponState != null
        ? couponState.items.fold(0, (p, e) => p + e.quantity)
        : items.fold(0, (p, e) => p + (e.quantity ?? 0));
    final double subtotal = couponState != null
        ? couponState.subtotal
        : items.fold(0.0, (p, e) => p + (e.subtotal ?? 0.0));
    final double discount = couponState?.discount ?? 0.0;
    
    // Calculate shipping and tax
    final double shippingPrice = selectedShipping?.price ?? 0.0;
    final double tax = (subtotal - discount) * 0.20; // 20% VAT
    final double total = subtotal - discount + shippingPrice + tax;

    addressesAsync.whenData((addresses) {
      if (addresses.isNotEmpty) {
        final defaultAddress = addresses.firstWhere(
          (a) => a.isDefault,
          orElse: () => addresses.first,
        );
        final currentSelected = ref.read(selectedAddressIdProvider);
        if (currentSelected == null || currentSelected.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(selectedAddressIdProvider.notifier).state =
                defaultAddress.id;
          });
        }
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          AnimatedBackground(
            animation: _backgroundAnimationController,
          ),
          CustomScrollView(
            slivers: [
              // AppBar
              SliverAppBar(
                expandedHeight: 100,
                floating: true,
                pinned: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColor.white.withAlpha(230),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: AppColor.black,
                    ),
                    onPressed: () => Get.back(),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
                  title: Text(
                    "Check out".tr,
                    style: AppFont.font20W700Black,
                  ),
                  centerTitle: false,
                ),
              ),
              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Location Section Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColor.primary.withAlpha(38),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.location_on_rounded,
                              color: AppColor.primary,
                              size: 20,
                            ),
                          ),
                          const Gap(12),
                          Text(
                            "Location".tr,
                            style: AppFont.font20W700Black,
                          ),
                        ],
                      ),
                      const Gap(16),
                      addressesAsync.when(
                        data: (addresses) {
                          if (addresses.isEmpty) {
                            return InkWell(
                              onTap: () => Get.to(() => const AddAddressScreen()),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColor.grey1,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'No addresses found. Please add an address.'
                                      .tr,
                                  style: AppFont.font14W500Black,
                                ),
                              ),
                            );
                          }
                          final defaultAddress = addresses.firstWhere(
                            (a) => a.isDefault,
                            orElse: () => addresses.first,
                          );
                          final selectedId =
                              ref.watch(selectedAddressIdProvider) ??
                                  defaultAddress.id;
                          final selectedAddress = addresses.firstWhere(
                            (a) => a.id == selectedId,
                            orElse: () => defaultAddress,
                          );
                          return _LocationSection(
                            addresses: addresses,
                            selectedAddress: selectedAddress,
                            defaultAddress: defaultAddress,
                          );
                        },
                        loading: () => Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: AppColor.grey1,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(child: LoadingWidget()),
                        ),
                        error: (_, __) => Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColor.grey1,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('Error loading address'.tr),
                        ),
                      ),
                      const Gap(24),
                      // Payment Section Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColor.primary.withAlpha(38),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.payment_rounded,
                              color: AppColor.primary,
                              size: 20,
                            ),
                          ),
                          const Gap(12),
                          Text(
                            "Payment".tr,
                            style: AppFont.font20W700Black,
                          ),
                        ],
                      ),
                      const Gap(16),
                      _PaymentSection(),
                      const Gap(24),
                      // Shipping Section Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColor.primary.withAlpha(38),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.local_shipping_rounded,
                              color: AppColor.primary,
                              size: 20,
                            ),
                          ),
                          const Gap(12),
                          Text(
                            "Shipping".tr,
                            style: AppFont.font20W700Black,
                          ),
                        ],
                      ),
                      const Gap(16),
                      const _ShippingSection(),
                      const Gap(24),
                      // Order Summary Section Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColor.primary.withAlpha(38),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.receipt_long_rounded,
                              color: AppColor.primary,
                              size: 20,
                            ),
                          ),
                          const Gap(12),
                          Text(
                            "Order Summary".tr,
                            style: AppFont.font20W700Black,
                          ),
                        ],
                      ),
                      const Gap(16),
                      _OrderSummarySection(
                        itemsCount: itemsCount,
                        subtotal: subtotal,
                        discount: discount,
                        shipping: shippingPrice,
                        tax: tax,
                        total: total,
                      ),
                      Gap(MediaQuery.of(context).padding.bottom),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 16,
          left: 16,
          right: 16,
          top: 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: CustomFilledButton(
          text: "Check Out".tr,
          onPressed: () {
            // final selectedShipping = ref.read(selectedShippingCompanyProvider);
            // if (selectedShipping == null) {
            //   UIHelper.showGlobalSnackBar(
            //     text: "Please select a shipping company".tr,
            //     color: AppColor.danger2,
            //   );
            //   return;
            // }
            
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (context) {
                return ConfirmOrderBottomSheet(
                  itemsCount: itemsCount,
                  subtotal: subtotal,
                  discount: discount,
                  shipping: shippingPrice,
                  tax: tax,
                  total: total,
                  addressId: ref.read(selectedAddressIdProvider),
                  coupon: couponState?.coupon,
                  paymentTypeName: ref.read(selectedPaymentProvider).name,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _LocationSection extends ConsumerStatefulWidget {
  final List<AddressModel> addresses;
  final AddressModel selectedAddress;
  final AddressModel defaultAddress;

  const _LocationSection({
    required this.addresses,
    required this.selectedAddress,
    required this.defaultAddress,
  });

  @override
  ConsumerState<_LocationSection> createState() => _LocationSectionState();
}

class _LocationSectionState extends ConsumerState<_LocationSection> {
  GoogleMapController? _mapController;
  static const LatLng _defaultLatLng =
      LatLng(30.0444, 31.2357); // Cairo default

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateMapLocation(widget.selectedAddress);
    });
  }

  @override
  void didUpdateWidget(_LocationSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedAddress.id != widget.selectedAddress.id) {
      _updateMapLocation(widget.selectedAddress);
    }
  }

  void _updateMapLocation(AddressModel address) {
    final coordinates = address.location?.coordinates;
    if (coordinates != null && coordinates.length >= 2) {
      // Coordinates are in [longitude, latitude] format
      final latLng = LatLng(coordinates[1], coordinates[0]);
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(latLng, 15.0),
      );
    }
  }

  LatLng _getLatLng(AddressModel address) {
    final coordinates = address.location?.coordinates;
    if (coordinates != null && coordinates.length >= 2) {
      return LatLng(coordinates[1], coordinates[0]);
    }
    return _defaultLatLng;
  }

  Set<Marker> _getMarkers(AddressModel address) {
    final latLng = _getLatLng(address);
    return {
      Marker(
        markerId: MarkerId(address.id),
        position: latLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColor.grey1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: widget.selectedAddress.id,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: AppColor.primary),
              items: widget.addresses.map((address) {
                return DropdownMenuItem<String>(
                  value: address.id,
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: AppColor.primary,
                        size: 20,
                      ),
                      const Gap(8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              address.label,
                              style: AppFont.font14W600Black,
                            ),
                            if (address.isDefault) ...[
                              const Gap(2),
                              Text(
                                "Default".tr,
                                style: AppFont.font12W600Black.copyWith(
                                  color: AppColor.primary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  ref.read(selectedAddressIdProvider.notifier).state = newValue;
                }
              },
            ),
          ),
        ),
        const Gap(12),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColor.grey1,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColor.grey1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                _updateMapLocation(widget.selectedAddress);
              },
              initialCameraPosition: CameraPosition(
                target: _getLatLng(widget.selectedAddress),
                zoom: 15.0,
              ),
              markers: _getMarkers(widget.selectedAddress),
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapType: MapType.normal,
              zoomGesturesEnabled: false,
              scrollGesturesEnabled: false,
              tiltGesturesEnabled: false,
              rotateGesturesEnabled: false,
            ),
          ),
        ),
        const Gap(12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColor.grey1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on,
                color: AppColor.primary,
                size: 20,
              ),
              const Gap(8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.selectedAddress.city ?? ''}, ${widget.selectedAddress.country ?? ''}',
                      style: AppFont.font16W600Black,
                    ),
                    const Gap(4),
                    Text(
                      widget.selectedAddress.addressLine1,
                      style: AppFont.font14W500Black.copyWith(
                        color: AppColor.grey2,
                      ),
                    ),
                    if (widget.selectedAddress.addressLine2 != null) ...[
                      const Gap(2),
                      Text(
                        widget.selectedAddress.addressLine2!,
                        style: AppFont.font14W500Black.copyWith(
                          color: AppColor.grey2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                widget.selectedAddress.phone,
                textDirection: TextDirection.ltr,
                style: AppFont.font14W600Black.copyWith(
                  color: AppColor.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaymentSection extends ConsumerWidget {
  const _PaymentSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPayment = ref.watch(selectedPaymentProvider);
    final isVisaSelected = selectedPayment == PaymentType.Visa;

    return Column(
      children: [
        _PaymentOption(
          title: "Credit / Debit Card".tr,
          icon: Icons.credit_card,
          isSelected: isVisaSelected,
          isDisabled: true,
          onTap: () {
            ref.read(selectedPaymentProvider.notifier).state = PaymentType.Visa;
          },
        ),
        if (isVisaSelected) ...[
          const Gap(12),
          _VisaUnavailableBanner(),
        ],
        const Gap(12),
        _PaymentOption(
          title: "Cash On Delivery".tr,
          icon: Icons.money,
          isSelected: selectedPayment == PaymentType.Cash,
          onTap: () {
            ref.read(selectedPaymentProvider.notifier).state = PaymentType.Cash;
          },
        ),
      ],
    );
  }
}

class _VisaUnavailableBanner extends StatefulWidget {
  const _VisaUnavailableBanner();

  @override
  State<_VisaUnavailableBanner> createState() => _VisaUnavailableBannerState();
}

class _VisaUnavailableBannerState extends State<_VisaUnavailableBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColor.danger.withAlpha(26),
                AppColor.danger.withAlpha(13),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColor.danger.withAlpha(77),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColor.danger.withAlpha(38),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: AppColor.danger,
                  size: 20,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Not Available at the Moment".tr,
                      style: AppFont.font14W700Black.copyWith(
                        color: AppColor.danger,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      "Credit/Debit card payment is currently unavailable. Please use Cash on Delivery."
                          .tr,
                      style: AppFont.font12w400Black.copyWith(
                        color: AppColor.grey2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentOption extends StatefulWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.title,
    required this.icon,
    required this.isSelected,
    this.isDisabled = false,
    required this.onTap,
  });

  @override
  State<_PaymentOption> createState() => _PaymentOptionState();
}

class _PaymentOptionState extends State<_PaymentOption>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    if (widget.isSelected) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_PaymentOption oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isDisabled ? null : widget.onTap,
      onTapDown: (_) => setState(() => _isHovered = true),
      onTapUp: (_) => setState(() => _isHovered = false),
      onTapCancel: () => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..scale(_isHovered ? 0.98 : 1.0),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: widget.isSelected
                ? LinearGradient(
                    colors: [
                      AppColor.primary.withAlpha(26),
                      AppColor.primary.withAlpha(13),
                    ],
                  )
                : null,
            color: widget.isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isSelected
                  ? AppColor.primary
                  : (widget.isDisabled
                      ? AppColor.grey1.withAlpha(128)
                      : AppColor.grey1),
              width: widget.isSelected ? 2 : 1.5,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppColor.primary.withAlpha(51),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.isSelected
                            ? AppColor.primary
                            : AppColor.grey1,
                        width: 2,
                      ),
                      color: widget.isSelected
                          ? AppColor.primary
                          : Colors.transparent,
                    ),
                    child: widget.isSelected
                        ? Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
                  );
                },
              ),
              const Gap(16),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? AppColor.primary.withAlpha(38)
                      : AppColor.grey1.withAlpha(77),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.isSelected
                      ? AppColor.primary
                      : (widget.isDisabled
                          ? AppColor.grey2.withAlpha(128)
                          : AppColor.grey2),
                  size: 24,
                ),
              ),
              const Gap(16),
              Expanded(
                child: Text(
                  widget.title,
                  style: AppFont.font16W600Black.copyWith(
                    color: widget.isSelected
                        ? AppColor.primary
                        : (widget.isDisabled
                            ? AppColor.grey2.withAlpha(128)
                            : AppColor.grey2),
                  ),
                ),
              ),
              if (widget.isDisabled)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.danger.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Unavailable".tr,
                    style: AppFont.font10w400Black.copyWith(
                      color: AppColor.danger,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShippingSection extends ConsumerWidget {
  const _ShippingSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedAddressId = ref.watch(selectedAddressIdProvider);
    final calculatedShippingAsync = ref.watch(calculatedShippingProvider);
    final selectedShipping = ref.watch(selectedShippingCompanyProvider);

    if (selectedAddressId == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColor.grey1,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          "Please select an address first".tr,
          style: AppFont.font14W500Black,
        ),
      );
    }

    return calculatedShippingAsync.when(
      data: (companies) {
        if (companies.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColor.grey1,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "No shipping companies available".tr,
              style: AppFont.font14W500Black,
            ),
          );
        }

        return Column(
          children: companies.map((company) {
            final isSelected = selectedShipping?.companyId == company.companyId;
            return GestureDetector(
              onTap: () {
                ref.read(selectedShippingCompanyProvider.notifier).state = company;
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            AppColor.primary.withAlpha(26),
                            AppColor.primary.withAlpha(13),
                          ],
                        )
                      : null,
                  color: isSelected ? null : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppColor.primary
                        : AppColor.grey1,
                    width: isSelected ? 2 : 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColor.primary.withAlpha(51),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColor.primary
                              : AppColor.grey1,
                          width: 2,
                        ),
                        color: isSelected
                            ? AppColor.primary
                            : Colors.transparent,
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                    const Gap(16),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColor.primary.withAlpha(38)
                            : AppColor.grey1.withAlpha(77),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.local_shipping_rounded,
                        color: isSelected
                            ? AppColor.primary
                            : AppColor.grey2,
                        size: 24,
                      ),
                    ),
                    const Gap(16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            company.companyName,
                            style: AppFont.font16W600Black.copyWith(
                              color: isSelected
                                  ? AppColor.primary
                                  : AppColor.grey2,
                            ),
                          ),
                          if (company.estimatedDays != null) ...[
                            const Gap(4),
                            Text(
                              "${company.estimatedDays!.min}-${company.estimatedDays!.max} ${"days".tr}",
                              style: AppFont.font12w400Black.copyWith(
                                color: AppColor.grey2,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    PriceWidget(
                      price: company.price.toStringAsFixed(2),
                      style: AppFont.font16W600Black.copyWith(
                        color: isSelected
                            ? AppColor.primary
                            : AppColor.grey2,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
      loading: () => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColor.grey1,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: LoadingWidget()),
      ),
      error: (_, __) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColor.grey1,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text('Error loading shipping companies'.tr),
      ),
    );
  }
}

class _OrderSummarySection extends StatelessWidget {
  final int itemsCount;
  final double subtotal;
  final double discount;
  final double shipping;
  final double tax;
  final double total;

  const _OrderSummarySection({
    required this.itemsCount,
    required this.subtotal,
    required this.discount,
    required this.shipping,
    required this.tax,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppColor.primary2.withAlpha(77),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColor.primary.withAlpha(51),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withAlpha(26),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _SummaryRow(
            icon: Icons.shopping_bag_rounded,
            label: "Products".tr,
            value: Text(
              "$itemsCount ${itemsCount == 1 ? 'product'.tr : 'products'.tr}",
              style: AppFont.font14W600Black.copyWith(
                color: AppColor.grey2,
              ),
            ),
          ),
          const Gap(12),
          if (discount > 0) ...[
            _SummaryRow(
              icon: Icons.local_offer_rounded,
              label: "Discount".tr,
              value: PriceWidget(
                price: "-${discount.toStringAsFixed(2)}",
                style: AppFont.font14W600Black,
                textColor: AppColor.danger,
              ),
            ),
            const Gap(12),
          ],
          _SummaryRow(
            icon: Icons.local_shipping_rounded,
            label: "Shipping".tr,
            value: PriceWidget(
              price: shipping.toStringAsFixed(2),
              style: AppFont.font14W600Black,
            ),
          ),
          const Gap(12),
          _SummaryRow(
            icon: Icons.receipt_rounded,
            label: "Tax (20% VAT)".tr,
            value: PriceWidget(
              price: tax.toStringAsFixed(2),
              style: AppFont.font14W600Black,
            ),
          ),
          const Gap(16),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColor.primary.withAlpha(77),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const Gap(16),
          _SummaryRow(
            icon: Icons.receipt_long_rounded,
            label: "Total".tr,
            value: PriceWidget(
              price: total.toStringAsFixed(2),
              style: AppFont.font20W700Black,
              textColor: AppColor.primary,
            ),
            isBold: true,
            isTotal: true,
          ),
          const Gap(12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColor.primary.withAlpha(13),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColor.primary.withAlpha(38),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: AppColor.primary,
                ),
                const Gap(8),
                Expanded(
                  child: Text(
                    "Tax and delivery fees are calculated based on your selected address and shipping company".tr,
                    style: AppFont.font12w400Black.copyWith(
                      color: AppColor.grey2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData? icon;
  final String label;
  final Widget value;
  final bool isBold;
  final bool isTotal;

  const _SummaryRow({
    this.icon,
    required this.label,
    required this.value,
    this.isBold = false,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: isTotal ? const EdgeInsets.all(12) : null,
      decoration: isTotal
          ? BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.primary.withAlpha(26),
                  AppColor.primary.withAlpha(13),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            )
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isTotal
                        ? AppColor.primary.withAlpha(38)
                        : AppColor.grey1.withAlpha(128),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: isTotal ? AppColor.primary : AppColor.grey2,
                  ),
                ),
                const Gap(8),
              ],
              Text(
                label,
                style: isBold
                    ? AppFont.font18W700Black
                    : AppFont.font14W600Black.copyWith(
                        color: AppColor.grey2,
                      ),
              ),
            ],
          ),
          value,
        ],
      ),
    );
  }
}
