import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/features/group/data/datasource/classroom_datasource.dart';
import 'package:larnity/src/features/group/data/models/course_model.dart';
import 'package:larnity/src/features/group/data/models/module_model.dart';
import 'package:larnity/src/features/group/data/models/section_model.dart';
import 'package:larnity/src/features/group/data/models/content_model.dart';

class ClassroomState {
  final AsyncState? fetchState;
  final AsyncState? createState;
  final AsyncState? detailState;
  final String? error;
  final List<CourseModel>? courses;
  final CourseModel? selectedCourse;

  ClassroomState({
    this.fetchState,
    this.createState,
    this.detailState,
    this.error,
    this.courses,
    this.selectedCourse,
  });

  ClassroomState copyWith({
    AsyncState? fetchState,
    AsyncState? createState,
    AsyncState? detailState,
    String? error,
    List<CourseModel>? courses,
    CourseModel? selectedCourse,
  }) {
    return ClassroomState(
      fetchState: fetchState ?? this.fetchState,
      createState: createState ?? this.createState,
      detailState: detailState ?? this.detailState,
      error: error ?? this.error,
      courses: courses ?? this.courses,
      selectedCourse: selectedCourse ?? this.selectedCourse,
    );
  }
}

final classroomProvider = NotifierProvider.autoDispose
    .family<ClassroomNotifier, ClassroomState, String>(ClassroomNotifier.new);

class ClassroomNotifier
    extends AutoDisposeFamilyNotifier<ClassroomState, String> {
  @override
  ClassroomState build(String arg) {
    Future.microtask(() => fetchCourses());
    return ClassroomState(fetchState: AsyncState.initial);
  }

  String get _groupId => arg;

  Future<void> fetchCourses() async {
    final ds = ref.read(classroomDataSourceProvider);
    state = state.copyWith(fetchState: AsyncState.loading);
    final result = await ds.getCourses(groupId: _groupId);
    result.fold(
      (failure) => state = state.copyWith(
        fetchState: AsyncState.failure,
        error: failure.message,
      ),
      (courses) => state = state.copyWith(
        fetchState: AsyncState.success,
        courses: courses,
      ),
    );
  }

  Future<void> fetchCourseDetail({required String courseId}) async {
    final ds = ref.read(classroomDataSourceProvider);
    state = state.copyWith(detailState: AsyncState.loading);
    final result = await ds.getCourseDetail(courseId: courseId);
    result.fold(
      (failure) => state = state.copyWith(
        detailState: AsyncState.failure,
        error: failure.message,
      ),
      (course) => state = state.copyWith(
        detailState: AsyncState.success,
        selectedCourse: course,
      ),
    );
  }

  Future<void> createCourse({
    required CourseModel course,
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final ds = ref.read(classroomDataSourceProvider);
    state = state.copyWith(createState: AsyncState.loading);
    final result = await ds.createCourse(course: course);
    result.fold(
      (failure) {
        state = state.copyWith(
          createState: AsyncState.failure,
          error: failure.message,
        );
        failureCallBack?.call(failure.message);
      },
      (created) {
        state = state.copyWith(
          createState: AsyncState.success,
          courses: [created, ...(state.courses ?? [])],
        );
        successCallBack?.call();
      },
    );
  }

  Future<void> deleteCourse({
    required String courseId,
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final ds = ref.read(classroomDataSourceProvider);
    final result = await ds.deleteCourse(courseId: courseId);
    result.fold((failure) => failureCallBack?.call(failure.message), (_) {
      state = state.copyWith(
        courses: state.courses?.where((c) => c.id != courseId).toList(),
      );
      successCallBack?.call();
    });
  }

  // ── Module ──

  Future<void> createModule({
    required ModuleModel module,
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final ds = ref.read(classroomDataSourceProvider);
    final result = await ds.createModule(module: module);
    result.fold((f) => failureCallBack?.call(f.message), (created) {
      if (state.selectedCourse?.id != null) {
        fetchCourseDetail(courseId: state.selectedCourse!.id!);
      }
      successCallBack?.call();
    });
  }

  Future<void> deleteModule({
    required String moduleId,
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final ds = ref.read(classroomDataSourceProvider);
    final result = await ds.deleteModule(moduleId: moduleId);
    result.fold((f) => failureCallBack?.call(f.message), (_) {
      if (state.selectedCourse?.id != null) {
        fetchCourseDetail(courseId: state.selectedCourse!.id!);
      }
      successCallBack?.call();
    });
  }

  // ── Section ──

  Future<void> createSection({
    required SectionModel section,
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final ds = ref.read(classroomDataSourceProvider);
    final result = await ds.createSection(section: section);
    result.fold((f) => failureCallBack?.call(f.message), (created) {
      if (state.selectedCourse?.id != null) {
        fetchCourseDetail(courseId: state.selectedCourse!.id!);
      }
      successCallBack?.call();
    });
  }

  Future<void> deleteSection({
    required String sectionId,
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final ds = ref.read(classroomDataSourceProvider);
    final result = await ds.deleteSection(sectionId: sectionId);
    result.fold((f) => failureCallBack?.call(f.message), (_) {
      if (state.selectedCourse?.id != null) {
        fetchCourseDetail(courseId: state.selectedCourse!.id!);
      }
      successCallBack?.call();
    });
  }

  // ── Content ──

  Future<void> createContent({
    required ContentModel content,
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final ds = ref.read(classroomDataSourceProvider);
    final result = await ds.createContent(content: content);
    result.fold((f) => failureCallBack?.call(f.message), (created) {
      if (state.selectedCourse?.id != null) {
        fetchCourseDetail(courseId: state.selectedCourse!.id!);
      }
      successCallBack?.call();
    });
  }

  Future<void> deleteContent({
    required String contentId,
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final ds = ref.read(classroomDataSourceProvider);
    final result = await ds.deleteContent(contentId: contentId);
    result.fold((f) => failureCallBack?.call(f.message), (_) {
      if (state.selectedCourse?.id != null) {
        fetchCourseDetail(courseId: state.selectedCourse!.id!);
      }
      successCallBack?.call();
    });
  }
}
