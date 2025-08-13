import 'package:symmetry_showcase/core/usecases/usecase.dart';

class CalculateLectureTime implements UseCase<int, CalculateLectureTimeParams> {
  @override
  Future<int> call(CalculateLectureTimeParams params) async {
    if (params.content.isEmpty) {
      return 1; // Tiempo mínimo de lectura
    }
    
    // Promedio de palabras por minuto de lectura: 200-250 palabras
    // Usamos 200 para ser más conservadores y dar tiempo suficiente
    const int wordsPerMinute = 200;
    
    // Contar palabras en el contenido
    final words = _countWords(params.content);
    
    // Calcular tiempo de lectura en minutos
    final lectureTime = (words / wordsPerMinute).ceil();
    
    // Tiempo mínimo de 1 minuto
    return lectureTime < 1 ? 1 : lectureTime;
  }
  
  int _countWords(String text) {
    if (text.isEmpty) return 0;
    
    // Limpiar el texto removiendo markdown y caracteres especiales
    String cleanedText = text
        .replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1') // negrita
        .replaceAll(RegExp(r'\*(.*?)\*'), r'$1') // cursiva
        .replaceAll(RegExp(r'`(.*?)`'), r'$1') // código
        .replaceAll(RegExp(r'\[(.*?)\]\(.*?\)'), r'$1') // enlaces
        .replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '') // headers
        .replaceAll(RegExp(r'\n{2,}'), ' ') // múltiples saltos de línea
        .replaceAll(RegExp(r'[^\w\s]'), ' ') // Reemplazar puntuación con espacios
        .replaceAll(RegExp(r'\s+'), ' ') // Normalizar espacios múltiples
        .trim();
    
    if (cleanedText.isEmpty) return 0;
    
    // Contar palabras dividiendo por espacios
    final words = cleanedText.split(' ').where((word) => word.isNotEmpty).length;
    
    return words;
  }
  

}

class CalculateLectureTimeParams {
  final String content;
  
  const CalculateLectureTimeParams({required this.content});
}
