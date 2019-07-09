import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_time/src/model/product.dart';
import 'package:logging/logging.dart';

class ProductsRepository {
  static const String productPath = 'product';
  final Logger log = Logger('ProductsRepository');

  final Firestore _firestore;

  ProductsRepository(this._firestore);

  Future<void> addNewProduct(Product product) {
    return _firestore
        .collection(productPath)
        .document(product.id)
        .setData(product.toJson());
  }

  Future<void> deleteProduct(String id) async {
    _firestore.collection(productPath).document(id).delete();
  }

  Stream<Product> subscribe(String owner, String productId) {
    log.info('Subscribing for product: $productId');
    return _firestore
        .collection('$productPath')
        .where('id', isEqualTo: productId)
        .where('owner', isEqualTo: owner)
        .snapshots()
        .map((snapshot) {
      if (snapshot.documents.isEmpty) {
        log.warning(
            'Subscription for $productId owned by $owner found no record.');
        return null;
      }
      if (snapshot.documents.length > 1) {
        log.warning(
            'Subscription for $productId owned by $owner returned more than one.');
        return null;
      }
      return Product.fromJson(snapshot.documents.first.data);
    });
  }

  Future<List<Product>> loadProducts(String owner) async {
    var documents = await _firestore
        .collection(productPath)
        .where('owner', isEqualTo: owner)
//       added for testing the created compound index
//        .where('price', isLessThan: 1000)
        .getDocuments();
    return documents.documents.map((doc) {
      return Product.fromJson(doc.data);
    }).toList();
  }

  Future<void> updateProduct(Product product) {
    return _firestore
        .collection(productPath)
        .document(product.id)
        .updateData(product.toJson());
  }
}
