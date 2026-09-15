import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/features/auth/data/datasources/auth_datasource.dart';
import 'package:larnity/src/features/auth/data/models/user_model.dart';
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
    void Function()? failureCallBack,
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
        failureCallBack?.call();
      },
          (user) {
        state = state.copyWith(
          state: AsyncState.success,
          user: user,
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
      (imageUrl) {
        state = state.copyWith(
          imageState: AsyncState.success,
          user: state.user?.copyWith(image: imageUrl),
        );
        successCallBack?.call(imageUrl);
      },
    );
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
