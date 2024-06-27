class Band {
  Band({required this.id, required this.name, required this.votes});

  String id;
  String name;
  int votes;

  //hacemos un factory contructor que lo que hace es regresar una instancia de mi clase con los valores que recibo en el obj
  factory Band.fromMap(Map<String, dynamic> obj) =>
      Band(id: obj['id'], name: obj['name'], votes: obj['votes']);
}
