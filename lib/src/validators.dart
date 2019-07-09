class Validators {
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  );
  static final RegExp _passwordRegExp = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$',
  );

  static final RegExp _priceRegExp = RegExp(
    r'^\d+(,\d{3})*(\.\d+)?$',
  );

  static isValidEmail(String email) {
    return _emailRegExp.hasMatch(email.trim());
  }

  static isValidPassword(String password) {
    return _passwordRegExp.hasMatch(password);
  }

  static isValidPrice(String price) {
    return _priceRegExp.hasMatch(price);
  }
}
