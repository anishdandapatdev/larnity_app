import 'package:fpdart/fpdart.dart';
import 'package:larnity/src/core/error/failures.dart';

abstract interface class UseCase<SuccessType, Params> {
  Future<Either<Failure, SuccessType>> call({required Params params});
}

class NoParams {}
