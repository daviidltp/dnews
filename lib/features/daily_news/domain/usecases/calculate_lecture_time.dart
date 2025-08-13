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
    
    // Extraer caracteres adicionales del formato … [+XXXX chars] si existe
    int additionalChars = _extractAdditionalChars(text);
    
    // Limpiar el texto removiendo el patrón … [+XXXX chars] o ... [+XXXX chars] si existe
    String cleanedText = text.replaceAll(RegExp(r'(…|\.\.\.)\s*\[\+\d+\s+chars\]'), '');
    
    // Limpiar el texto removiendo markdown y caracteres especiales
    cleanedText = cleanedText
        .replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1') // negrita
        .replaceAll(RegExp(r'\*(.*?)\*'), r'$1') // cursiva
        .replaceAll(RegExp(r'`(.*?)`'), r'$1') // código
        .replaceAll(RegExp(r'\[(.*?)\]\(.*?\)'), r'$1') // enlaces
        .replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '') // headers
        .replaceAll(RegExp(r'\n{2,}'), ' ') // múltiples saltos de línea
        .replaceAll(RegExp(r'[^\w\s]'), ' ') // Reemplazar puntuación con espacios
        .replaceAll(RegExp(r'\s+'), ' ') // Normalizar espacios múltiples
        .trim();
    
    if (cleanedText.isEmpty && additionalChars == 0) return 0;
    
    // Contar palabras del texto visible
    int visibleWords = cleanedText.isEmpty ? 0 : cleanedText.split(' ').where((word) => word.isNotEmpty).length;
    
    // Convertir caracteres adicionales a palabras aproximadas (promedio 5 caracteres por palabra)
    int additionalWords = (additionalChars / 5).round();
    
    return visibleWords + additionalWords;
  }
  
  int _extractAdditionalChars(String text) {
    // Buscar el patrón … [+XXXX chars] o ... [+XXXX chars] en el texto
    final match = RegExp(r'(…|\.\.\.)\s*\[\+(\d+)\s+chars\]').firstMatch(text);
    if (match != null) {
      return int.tryParse(match.group(2) ?? '0') ?? 0;
    }
    
    return 0;
  }
  

}

class CalculateLectureTimeParams {
  final String content;
  
  const CalculateLectureTimeParams({required this.content});
}
