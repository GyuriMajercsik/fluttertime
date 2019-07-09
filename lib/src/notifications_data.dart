import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_time/src/model/product.dart';
import 'package:meta/meta.dart';

@immutable
class PriceChangedNotification extends Equatable {
  final Product product;
  final double oldPrice;
  final Payload payload;

  PriceChangedNotification(
      {@required this.product, @required this.oldPrice, @required this.payload})
      : super([product, oldPrice, payload]);

  String get title => 'Price changed';
  String get description =>
      '${product.name} price changed \n ${oldPrice.toStringAsFixed(2)} '
      '----> ${product.price.toStringAsFixed(2)}';
}

@immutable
class CloudMessageNotification extends Equatable {
  final String title;
  final String description;
  final String data;

  CloudMessageNotification(this.title, this.description, this.data)
      : super([title, description]);
}

typedef SelectNotificationCallback = Future<dynamic> Function(String payload);

class Payload {
  final PayloadType type;
  final dynamic data;

  Payload._(this.type, this.data);

  factory Payload.fromJson(Map<String, dynamic> encodedPayload) {
    PayloadType type = PayloadType.fromName(encodedPayload['type']);

    assert(type != null);

    return Payload._(
        type, type.parsePayloadData(json.decode(encodedPayload['data'])));
  }

  Map<String, dynamic> toJson() {
    return {'type': type.toString(), 'data': data.toJson()};
  }

  factory Payload.viewProduct(Product product) {
    return Payload._(PayloadType.viewProduct, product);
  }
}

class PayloadType {
  static const viewProduct = const PayloadType._('viewProduct');

  static List<PayloadType> get values => const [
        viewProduct,
      ];

  final String _name;

  String get name => _name;

  const PayloadType._(this._name);

  @override
  String toString() {
    return _name;
  }

  @override
  bool operator ==(other) {
    if (other is! PayloadType) {
      return false;
    }

    return _name == other._name;
  }

  @override
  int get hashCode => _name.hashCode;

  static PayloadType fromName(String name) {
    return values.firstWhere((category) => category.name == name,
        orElse: () => null);
  }

  dynamic parsePayloadData(Map<String, dynamic> data) {
    if (this == PayloadType.viewProduct) {
      return Product.fromJson(data);
    }
  }
}
