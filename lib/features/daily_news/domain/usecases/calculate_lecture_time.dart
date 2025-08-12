import 'package:symmetry_showcase/core/usecases/usecase.dart';

class CalculateLectureTime implements UseCase<int, CalculateLectureTimeParams> {
  @override
  Future<int> call(CalculateLectureTimeParams params) async {
    if (params.content.isEmpty) {
      return 1; // Tiempo mínimo de lectura
    }
    
    // Promedio de palabras por minuto de lectura: 200-250 palabras
    const int wordsPerMinute = 225;
    
    // Contar palabras en el contenido
    final words = _countWords(params.content);
    
    // Calcular tiempo de lectura en minutos
    final lectureTime = (words / wordsPerMinute).ceil();
    
    // Tiempo mínimo de 1 minuto
    return lectureTime < 1 ? 1 : lectureTime;
  }
  
  int _countWords(String text) {
    if (text.isEmpty) return 0;
    
    // Extraer caracteres adicionales del formato [+XXXX chars] si existe
    int additionalChars = _extractAdditionalChars(text);
    
    // Limpiar el texto removiendo el patrón [+XXXX chars] si existe
    String cleanedText = text.replaceAll(RegExp(r'\s*…\s*\[\+\d+\s+chars\]$'), '');
    
    // Limpiar el texto y dividir por espacios en blanco
    final processedText = cleanedText
        .replaceAll(RegExp(r'[^\w\s]'), ' ') // Reemplazar puntuación con espacios
        .replaceAll(RegExp(r'\s+'), ' ') // Normalizar espacios múltiples
        .trim();
    
    if (processedText.isEmpty && additionalChars == 0) return 0;
    
    // Contar palabras del texto visible
    int visibleWords = processedText.isEmpty ? 0 : processedText.split(' ').length;
    
    // Convertir caracteres adicionales a palabras aproximadas (promedio 5 caracteres por palabra)
    int additionalWords = (additionalChars / 5).round();
    
    return visibleWords + additionalWords;
  }
  
  int _extractAdditionalChars(String text) {
    // Buscar el patrón [+XXXX chars] al final del texto
    final match = RegExp(r'\[\+(\d+)\s+chars\]$').firstMatch(text);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '0') ?? 0;
    }
    return 0;
  }
}

class CalculateLectureTimeParams {
  final String content;
  
  const CalculateLectureTimeParams({required this.content});
}
