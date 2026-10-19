import 'dart:io';

import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/create_ad_request.dart';

abstract class CreateAdRepo {
  Future<Either<Failure, String>> uploadMedia(File file);

  Future<Either<Failure, String>> createAd(CreateAdRequest request);

  Future<Either<Failure, bool>> promoteMedia({
    required String adId,
    required List<String> mediaIds,
  });

  Future<Either<Failure, bool>> deleteMedia(String mediaId);
}
