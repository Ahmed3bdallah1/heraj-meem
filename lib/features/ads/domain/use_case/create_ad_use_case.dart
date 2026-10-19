import 'dart:io';

import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../entities/create_ad_request.dart';
import '../repo/create_ad_repo.dart';

class UploadAdMediaUseCase extends UseCaseParam<String, File> {
  final CreateAdRepo repo;

  UploadAdMediaUseCase(this.repo);

  @override
  Future<Either<Failure, String>> call(File param) {
    return repo.uploadMedia(param);
  }
}

class CreateAdUseCase extends UseCaseParam<String, CreateAdRequest> {
  final CreateAdRepo repo;

  CreateAdUseCase(this.repo);

  @override
  Future<Either<Failure, String>> call(CreateAdRequest param) {
    return repo.createAd(param);
  }
}

class PromoteAdMediaUseCase extends UseCaseParam<bool, PromoteAdMediaParam> {
  final CreateAdRepo repo;

  PromoteAdMediaUseCase(this.repo);

  @override
  Future<Either<Failure, bool>> call(PromoteAdMediaParam param) {
    return repo.promoteMedia(adId: param.adId, mediaIds: param.mediaIds);
  }
}

class DeleteAdMediaUseCase extends UseCaseParam<bool, String> {
  final CreateAdRepo repo;

  DeleteAdMediaUseCase(this.repo);

  @override
  Future<Either<Failure, bool>> call(String param) {
    return repo.deleteMedia(param);
  }
}

class PromoteAdMediaParam {
  final String adId;
  final List<String> mediaIds;

  const PromoteAdMediaParam({required this.adId, required this.mediaIds});
}
