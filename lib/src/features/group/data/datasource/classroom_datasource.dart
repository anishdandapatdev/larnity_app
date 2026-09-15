import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:larnity/src/core/error/failures.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_table.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/features/group/data/models/course_model.dart';
import 'package:larnity/src/features/group/data/models/module_model.dart';
import 'package:larnity/src/features/group/data/models/section_model.dart';
import 'package:larnity/src/features/group/data/models/content_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final classroomDataSourceProvider = Provider<ClassroomDataSource>((ref) {
  return ClassroomDataSource(supabaseClient: ref.watch(supabaseClientProvider));
});

class ClassroomDataSource {
  final SupabaseClient supabaseClient;

  ClassroomDataSource({required this.supabaseClient});

  // ── Course CRUD ──

  Future<Either<Failure, List<CourseModel>>> getCourses({
    required String groupId,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.course)
          .select('*, Module(count)')
          .eq('groupId', groupId)
          .order('created_at', ascending: false);

      final courses = (response as List)
          .map((e) => CourseModel.fromMap(e as Map<String, dynamic>))
          .toList();

      Log.info('Fetched ${courses.length} courses for group $groupId');
      return Right(courses);
    } on PostgrestException catch (e) {
      Log.error('getCourses error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('getCourses error: $e');
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, CourseModel>> getCourseDetail({
    required String courseId,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.course)
          .select('*, Module(*, Section(*, Content(*)))')
          .eq('id', courseId)
          .single();

      final course = CourseModel.fromMap(response);
      Log.info('Fetched course detail: ${course.id}');
      return Right(course);
    } on PostgrestException catch (e) {
      Log.error('getCourseDetail error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('getCourseDetail error: $e');
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, CourseModel>> createCourse({
    required CourseModel course,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.course)
          .insert(course.toMap())
          .select()
          .single();

      final created = CourseModel.fromMap(response);
      Log.info('Created course: ${created.id}');
      return Right(created);
    } on PostgrestException catch (e) {
      Log.error('createCourse error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('createCourse error: $e');
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, CourseModel>> updateCourse({
    required CourseModel course,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.course)
          .update(course.toMap())
          .eq('id', course.id!)
          .select()
          .single();

      final updated = CourseModel.fromMap(response);
      Log.info('Updated course: ${updated.id}');
      return Right(updated);
    } on PostgrestException catch (e) {
      Log.error('updateCourse error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('updateCourse error: $e');
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, void>> deleteCourse({required String courseId}) async {
    try {
      await supabaseClient
          .from(SupabaseTable.course)
          .delete()
          .eq('id', courseId);

      Log.info('Deleted course: $courseId');
      return const Right(null);
    } on PostgrestException catch (e) {
      Log.error('deleteCourse error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('deleteCourse error: $e');
      return Left(Failure(e.toString()));
    }
  }

  // ── Module CRUD ──

  Future<Either<Failure, ModuleModel>> createModule({
    required ModuleModel module,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.module)
          .insert(module.toMap())
          .select()
          .single();
      final created = ModuleModel.fromMap(response);
      Log.info('Created module: ${created.id}');
      return Right(created);
    } on PostgrestException catch (e) {
      Log.error('createModule error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('createModule error: $e');
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, void>> deleteModule({required String moduleId}) async {
    try {
      await supabaseClient
          .from(SupabaseTable.module)
          .delete()
          .eq('id', moduleId);
      Log.info('Deleted module: $moduleId');
      return const Right(null);
    } on PostgrestException catch (e) {
      Log.error('deleteModule error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('deleteModule error: $e');
      return Left(Failure(e.toString()));
    }
  }

  // ── Section CRUD ──

  Future<Either<Failure, SectionModel>> createSection({
    required SectionModel section,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.section)
          .insert(section.toMap())
          .select()
          .single();
      final created = SectionModel.fromMap(response);
      Log.info('Created section: ${created.id}');
      return Right(created);
    } on PostgrestException catch (e) {
      Log.error('createSection error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('createSection error: $e');
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, void>> deleteSection({
    required String sectionId,
  }) async {
    try {
      await supabaseClient
          .from(SupabaseTable.section)
          .delete()
          .eq('id', sectionId);
      Log.info('Deleted section: $sectionId');
      return const Right(null);
    } on PostgrestException catch (e) {
      Log.error('deleteSection error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('deleteSection error: $e');
      return Left(Failure(e.toString()));
    }
  }

  // ── Content CRUD ──

  Future<Either<Failure, ContentModel>> createContent({
    required ContentModel content,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.content)
          .insert(content.toMap())
          .select()
          .single();
      final created = ContentModel.fromMap(response);
      Log.info('Created content: ${created.id}');
      return Right(created);
    } on PostgrestException catch (e) {
      Log.error('createContent error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('createContent error: $e');
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, void>> deleteContent({
    required String contentId,
  }) async {
    try {
      await supabaseClient
          .from(SupabaseTable.content)
          .delete()
          .eq('id', contentId);
      Log.info('Deleted content: $contentId');
      return const Right(null);
    } on PostgrestException catch (e) {
      Log.error('deleteContent error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('deleteContent error: $e');
      return Left(Failure(e.toString()));
    }
  }
}
