class Contact {
  final String name;
  final int? account;

  Contact(this.name, this.account);

  @override
  String toString() {
    return 'Contact{name: $name, accountNumber: $account}';
  }
}
