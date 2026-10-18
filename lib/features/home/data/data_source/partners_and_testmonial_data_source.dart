import 'package:heraj_meem/features/home/domain/entities/partners.dart';
import 'package:heraj_meem/features/home/domain/entities/testimonials.dart';
import '../../../../core/service/webservice/dio_helper.dart';

abstract class PartnersAndTestimonialDataSource {
  Future<List<Partner>> getPartners();
  Future<List<Testimonials>> getTestimonials();
}

class PartnersAndTestimonialDataSourceImp extends PartnersAndTestimonialDataSource {
  final ApiService apiService;

  PartnersAndTestimonialDataSourceImp({required this.apiService});

  @override
  Future<List<Partner>> getPartners() async {
    final res = await apiService.get(url:  "", returnDataOnly: false);
    final list = res["partners"] as List<dynamic>;
    return list.map((e) => Partner.fromJson(e)).toList();
  }

  @override
  Future<List<Testimonials>> getTestimonials() async {
    final res = await apiService.get(url: "",returnDataOnly: false);
    final list =res["testimonials"] as List<dynamic>;
    return list.map((e) => Testimonials.fromJson(e)).toList();
  }
}
