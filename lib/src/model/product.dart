import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class Product extends Equatable {
  final String id;
  final String name;
  final String description;
  final String owner;
  final double price;
  final double rating;

  Product(
      {@required this.id,
      @required this.name,
      @required this.description,
      @required this.owner,
      @required this.price,
      this.rating = .0})
      : super([id, name, description, owner, price, rating]);

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "owner": owner,
      "price": price,
      "rating": rating,
    };
  }

  static Product fromJson(Map<String, dynamic> json) {
    return Product(
      id: json["id"] as String,
      name: json["name"] as String,
      description: json["description"] as String,
      owner: json["owner"] as String,
      price: (json["price"] as num ?? .0).toDouble(),
      rating: (json["rating"] as num ?? .0).toDouble(),
    );
  }
}
