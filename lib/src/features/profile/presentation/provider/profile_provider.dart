import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/service/cache/user_cache_service.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/features/auth/data/datasources/auth_datasource.dart';
import 'package:larnity/src/features/auth/data/models/user_model.dart';
import 'package:larnity/src/features/auth/presentation/provider/auth_provider.dart';
import 'package:larnity/src/features/profile/data/datasource/profile_datasource.dart';

final profileProvider = NotifierProvider<ProfileNotifier, ProfileState>(
  ProfileNotifier.new,
);

class ProfileNotifier extends Notifier<ProfileState> {
  @override
  ProfileState build() {
    return const ProfileState(state: AsyncState.initial);
  }

  Future<void> createProfile({
    required UserModel user,
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final dataSource = ref.read(profileDataSourceProvider);

    state = state.copyWith(state: AsyncState.loading);

    final response = await dataSource.createProfile(user: user);

    response.fold(
      (failure) {
        state = state.copyWith(
          state: AsyncState.failure,
          error: failure.message,
        );
        failureCallBack?.call(failure.message);
      },
      (savedUser) {
        state = state.copyWith(
          state: AsyncState.success,
          user: savedUser,
        );
        // Synchronize with auth provider & local cache
        ref.read(authProvider.notifier).updateUser(savedUser);
        ref.read(userCacheServiceProvider).saveUser(
          firstName: savedUser.firstName,
          lastName: savedUser.lastName,
          image: savedUser.image,
          phoneNumber: savedUser.phoneNumber,
        );
        successCallBack?.call();
      },
    );
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final dataSource = ref.read(authDataSourceProvider);

    state = state.copyWith(passwordState: AsyncState.loading);

    final response = await dataSource.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    response.fold(
      (failure) {
        state = state.copyWith(
          passwordState: AsyncState.failure,
          passwordError: failure.message,
        );
        failureCallBack?.call(failure.message);
      },
      (_) {
        state = state.copyWith(passwordState: AsyncState.success);
        successCallBack?.call();
      },
    );
  }

  Future<void> uploadProfileImage({
    required File imageFile,
    required String userId,
    void Function(String imageUrl)? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final dataSource = ref.read(profileDataSourceProvider);

    state = state.copyWith(imageState: AsyncState.loading);

    final response = await dataSource.uploadProfileImage(
      imageFile: imageFile,
      userId: userId,
    );

    response.fold(
      (failure) {
        state = state.copyWith(
          imageState: AsyncState.failure,
          imageError: failure.message,
        );
        failureCallBack?.call(failure.message);
      },
      (imageUrl) async {
        state = state.copyWith(
          imageState: AsyncState.success,
          user: state.user?.copyWith(image: imageUrl),
        );

        final currentUser = ref.read(authProvider).user;
        if (currentUser != null) {
          final updated = currentUser.copyWith(image: imageUrl);
          await dataSource.createProfile(user: updated);
          ref.read(authProvider.notifier).updateUser(updated);
          ref.read(userCacheServiceProvider).saveUser(
            firstName: updated.firstName,
            lastName: updated.lastName,
            image: updated.image,
            phoneNumber: updated.phoneNumber,
          );
        }

        successCallBack?.call(imageUrl);
      },
    );
  }

  Future<void> removeProfileImage({
    required String userId,
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final dataSource = ref.read(profileDataSourceProvider);

    state = state.copyWith(imageState: AsyncState.loading);

    final currentUser = ref.read(authProvider).user;
    if (currentUser != null) {
      final updated = currentUser.copyWith(image: '');
      final response = await dataSource.createProfile(user: updated);

      response.fold(
        (failure) {
          state = state.copyWith(
            imageState: AsyncState.failure,
            imageError: failure.message,
          );
          failureCallBack?.call(failure.message);
        },
        (savedUser) {
          state = state.copyWith(
            imageState: AsyncState.success,
            user: savedUser,
          );
          ref.read(authProvider.notifier).updateUser(savedUser);
          ref.read(userCacheServiceProvider).saveUser(
            firstName: savedUser.firstName,
            lastName: savedUser.lastName,
            image: '',
            phoneNumber: savedUser.phoneNumber,
          );
          successCallBack?.call();
        },
      );
    }
  }
}

class ProfileState {
  final AsyncState state;
  final AsyncState? passwordState;
  final AsyncState? imageState;
  final String? error;
  final String? passwordError;
  final String? imageError;
  final UserModel? user;

  const ProfileState({
    required this.state,
    this.passwordState,
    this.imageState,
    this.error,
    this.passwordError,
    this.imageError,
    this.user,
  });

  ProfileState copyWith({
    AsyncState? state,
    AsyncState? passwordState,
    AsyncState? imageState,
    String? error,
    String? passwordError,
    String? imageError,
    UserModel? user,
  }) {
    return ProfileState(
      state: state ?? this.state,
      passwordState: passwordState ?? this.passwordState,
      imageState: imageState ?? this.imageState,
      error: error ?? this.error,
      passwordError: passwordError ?? this.passwordError,
      imageError: imageError ?? this.imageError,
      user: user ?? this.user,
    );
  }
}
