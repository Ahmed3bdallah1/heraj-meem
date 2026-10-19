import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/create_ad_request.dart';
import '../../domain/repo/create_ad_repo.dart';
import '../data_source/create_ad_data_source.dart';

class CreateAdRepoImp extends CreateAdRepo {
  final CreateAdDataSource dataSource;

  CreateAdRepoImp({required this.dataSource});

  @override
  Future<Either<Failure, String>> uploadMedia(File file) async {
    try {
      return Right(await dataSource.uploadMedia(file));
    } catch (error) {
      return Left(_failure(error));
    }
  }

  @override
  Future<Either<Failure, String>> createAd(CreateAdRequest request) async {
    try {
      return Right(await dataSource.createAd(request));
    } catch (error) {
      return Left(_failure(error));
    }
  }

  @override
  Future<Either<Failure, bool>> promoteMedia({
    required String adId,
    required List<String> mediaIds,
  }) async {
    try {
      await dataSource.promoteMedia(adId: adId, mediaIds: mediaIds);
      return const Right(true);
    } catch (error) {
      return Left(_failure(error));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteMedia(String mediaId) async {
    try {
      await dataSource.deleteMedia(mediaId);
      return const Right(true);
    } catch (error) {
      return Left(_failure(error));
    }
  }

  Failure _failure(Object error) {
    if (error is DioException) return ServerFailure.fromDioError(error);
    return GeneralError(error);
  }
}
