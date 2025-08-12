import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

abstract class FirebaseStorageService {
  Future<String> uploadImage(File imageFile, String fileName);
  Future<void> deleteImage(String imageUrl);
}

class FirebaseStorageServiceImpl implements FirebaseStorageService {
  final FirebaseStorage _storage;
  static const String _imagesPath = 'articles';

  FirebaseStorageServiceImpl(this._storage);

  @override
  Future<String> uploadImage(File imageFile, String fileName) async {
    try {
      // Crear una referencia única para el archivo
      final ref = _storage.ref().child(_imagesPath).child(fileName);
      
      // Subir el archivo con timeout
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask.timeout(
        const Duration(minutes: 2),
        onTimeout: () {
          uploadTask.cancel();
          throw Exception('Timeout: La subida de imagen tardó más de 2 minutos');
        },
      );
      
      // Obtener la URL de descarga
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Error al subir imagen: $e');
    }
  }

  @override
  Future<void> deleteImage(String imageUrl) async {
    try {
      // Extraer la referencia de la URL y eliminar
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Error al eliminar imagen: $e');
    }
  }
}
