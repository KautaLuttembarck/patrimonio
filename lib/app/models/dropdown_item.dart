class DropdownItem {
  final String id;
  final String name;
  final String? description;

  const DropdownItem({required this.id, required this.name, this.description});

  @override
  String toString() => name;

  // Helper para filtrar itens baseado no texto de busca
  bool matchesSearch(String searchText) {
    final searchLower = searchText.toLowerCase();
    return name.toLowerCase().contains(searchLower) ||
        (description?.toLowerCase().contains(searchLower) ?? false);
  }

  factory DropdownItem.fromUaJson(Map<String, dynamic> json) {
    return DropdownItem(
      id: json['id_ua'].toString(),
      name: json['sigla'] ?? 'null',
      description: json['ua'],
    );
  }

  factory DropdownItem.fromUlJson(Map<String, dynamic> json) {
    return DropdownItem(
      id: json['id_ul'].toString(),
      name: json['Endereco'],
      description: json['Nome_resp'],
    );
  }
}
