import 'package:equatable/equatable.dart';

class WeekendPromoConfiguration extends Equatable {
  final bool enabled;
  final int discount;

  WeekendPromoConfiguration(this.enabled, this.discount)
      : super([enabled, discount]);

  factory WeekendPromoConfiguration.fromJson(Map<String, dynamic> json) {
    var enabled = json['enabled'];
    var discount = json['discount'];
    return WeekendPromoConfiguration(enabled, discount);
  }

  Map<String, dynamic> toJson() {
    return {'enabled': true, 'discount': discount};
  }
}
