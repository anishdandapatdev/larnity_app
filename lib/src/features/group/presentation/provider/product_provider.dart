import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/features/group/data/datasource/product_datasource.dart';
import 'package:larnity/src/features/group/data/models/product_model.dart';

class ProductState {
  final AsyncState? fetchState;
  final AsyncState? createState;
  final String? error;
  final List<ProductModel>? products;

  const ProductState({
    this.fetchState,
    this.createState,
    this.error,
    this.products,
  });

  ProductState copyWith({
    AsyncState? fetchState,
    AsyncState? createState,
    String? error,
    List<ProductModel>? products,
  }) {
    return ProductState(
      fetchState: fetchState ?? this.fetchState,
      createState: createState ?? this.createState,
      error: error ?? this.error,
      products: products ?? this.products,
    );
  }
}

final productProvider = NotifierProvider.autoDispose.family<ProductNotifier, ProductState, String>(ProductNotifier.new);

class ProductNotifier extends AutoDisposeFamilyNotifier<ProductState, String> {
  @override
  ProductState build(String arg) {
    return const ProductState(
      fetchState: AsyncState.initial,
      createState: AsyncState.initial,
      products: [],
    );
  }

  Future<void> fetchProducts({String type = 'PRODUCT'}) async {
    state = state.copyWith(fetchState: AsyncState.loading);

    final dataSource = ref.read(productDataSourceProvider);
    final result = await dataSource.getItems(groupId: arg, type: type);

    result.fold(
      (failure) {
        state = state.copyWith(
          fetchState: AsyncState.failure,
          error: failure.message,
        );
      },
      (items) {
        state = state.copyWith(
          fetchState: AsyncState.success,
          products: items,
          error: null,
        );
      },
    );
  }

  Future<void> addProduct({
    required ProductModel product,
    Function? successCallBack,
    Function(String)? failureCallBack,
  }) async {
    state = state.copyWith(createState: AsyncState.loading);

    final dataSource = ref.read(productDataSourceProvider);
    final result = await dataSource.createItem(item: product);

    result.fold(
      (failure) {
        state = state.copyWith(
          createState: AsyncState.failure,
          error: failure.message,
        );
        if (failureCallBack != null) {
          failureCallBack(failure.message);
        }
      },
      (createdProduct) {
        final currentProducts = List<ProductModel>.from(state.products ?? []);
        currentProducts.add(createdProduct);
        state = state.copyWith(
          createState: AsyncState.success,
          products: currentProducts,
          error: null,
        );
        if (successCallBack != null) {
          successCallBack();
        }
      },
    );
  }

  Future<void> deleteProduct({
    required String productId,
    Function? successCallBack,
  }) async {
    final dataSource = ref.read(productDataSourceProvider);
    final result = await dataSource.deleteItem(itemId: productId);

    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (_) {
        final currentProducts = List<ProductModel>.from(state.products ?? []);
        currentProducts.removeWhere((product) => product.id == productId);
        state = state.copyWith(products: currentProducts, error: null);
        if (successCallBack != null) {
          successCallBack();
        }
      },
    );
  }
}
