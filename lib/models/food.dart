// food object

class Food {
  // Attributes
  final int? id;
  final String item;
  final int calories;

  Food({
    this.id,
    required this.item,
    required this.calories,
  });

  // map to json to insert into database
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item': item,
      'calories': calories,
    };
  }
  // retrieve from database and map to object
  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['id'] as int?,
      item: json['item'] as String,
      calories: json['calories'] as int,
    );
  }
}
