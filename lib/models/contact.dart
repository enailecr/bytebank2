class Contact {
  final int id;
  final String name;
  final int? account;

  Contact(
    this.id,
    this.name,
    this.account,
  );

  @override
  String toString() {
    return 'Contact{name: $name, accountNumber: $account}';
  }
}
