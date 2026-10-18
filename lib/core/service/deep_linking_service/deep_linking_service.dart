// import 'package:app_links/app_links.dart';
// import 'package:get/get.dart';
//
// class DeepLinkService {
//   static final AppLinks _appLinks = AppLinks();
//
//   static Stream<String?> get deepLinksStream =>
//       _appLinks.uriLinkStream.map((uri) => uri.toString());
//
//   static Future<String?> getInitialLink() async {
//     try {
//       final Uri? initialUri = await _appLinks.getInitialLink();
//       return initialUri?.toString();
//     } catch (e) {
//       print('Error getting initial link: $e');
//       return null;
//     }
//   }
//
//   static Map<String, dynamic> parseDeepLink(String url) {
//     final Uri uri = Uri.parse(url);
//     final Map<String, dynamic> params = {};
//
//     // Extract path segments
//     final pathSegments = uri.pathSegments;
//     if (pathSegments.isNotEmpty) {
//       if (uri.path.contains('/cars/') && pathSegments.length > 1) {
//         params['carId'] = pathSegments[1];
//       }
//     }
//
//     uri.queryParameters.forEach((key, value) {
//       params[key] = value;
//     });
//
//     return params;
//   }
//
//   static void handleDeepLink(String url) {
//     final params = parseDeepLink(url);
//
//     if (url.contains('/cars/')) {
//       final carId = params['carId'];
//       if (carId != null) {
//         Get.toNamed('/car', arguments: {'carId': carId});
//       }
//     } else if (url.contains('mycar://open/car')) {
//       final carId = params['id'];
//       if (carId != null) {
//         Get.toNamed('/car', arguments: {'carId': carId});
//       }
//     }
//     // Add more deep link patterns as needed
//   }
// }
