class FAQModel {
  final int? id;
  final String question;
  final String answer;
  final int order;

  FAQModel({
    this.id,
    required this.question,
    required this.answer,
    this.order = 0,
  });

  factory FAQModel.fromJson(Map<String, dynamic> json) {
    return FAQModel(
      id: json['id'],
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'question': question,
      'answer': answer,
      'order': order,
    };
  }
}
