package utez.edu.mx.food.service.cloud;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@Service
public class CloudinaryService {

    @Autowired
    private Cloudinary cloudinary;

    public String uploadFile(MultipartFile file, String folderName) throws IOException {
        try {
            Map<String, Object> uploadParams = new HashMap<>();
            uploadParams.put("folder", folderName);
            uploadParams.put("use_filename", Optional.of(true));
            uploadParams.put("unique_filename", Optional.of(true));
            uploadParams.put("overwrite", Optional.of(false));
            uploadParams.put("resource_type", "auto");

            Map<?, ?> uploadResult = cloudinary.uploader().upload(file.getBytes(), uploadParams);
            return uploadResult.get("url").toString();

        } catch (IOException e) {
            throw new IOException("Error al subir archivo a Cloudinary: " + e.getMessage(), e);
        } catch (Exception e) {
            throw new RuntimeException("Error inesperado en Cloudinary: " + e.getMessage(), e);
        }
    }

    public void deleteFile(String imageUrl) throws IOException {
        try {
            String publicId = extractPublicIdFromUrl(imageUrl);
            if (publicId != null) {
                // SOLUCIÓN: Usar HashMap aquí también
                Map<String, Object> deleteParams = new HashMap<>();
                deleteParams.put("invalidate", Optional.of(true));
                cloudinary.uploader().destroy(publicId, deleteParams);
            }
        } catch (Exception e) {
            throw new IOException("Error al eliminar archivo de Cloudinary: " + e.getMessage(), e);
        }
    }

    private String extractPublicIdFromUrl(String imageUrl) {
        try {
            String[] parts = imageUrl.split("/");
            int uploadIndex = -1;
            for (int i = 0; i < parts.length; i++) {
                if ("upload".equals(parts[i])) {
                    uploadIndex = i;
                    break;
                }
            }

            if (uploadIndex != -1 && uploadIndex + 1 < parts.length) {
                StringBuilder publicId = new StringBuilder();
                for (int i = uploadIndex + 1; i < parts.length; i++) {
                    if (i > uploadIndex + 1) publicId.append("/");
                    publicId.append(parts[i]);
                }

                // Remover la extensión del archivo
                String result = publicId.toString();
                int dotIndex = result.lastIndexOf('.');
                if (dotIndex != -1) {
                    result = result.substring(0, dotIndex);
                }
                return result;
            }
            return null;
        } catch (Exception e) {
            System.err.println("Error extrayendo public_id de: " + imageUrl);
            return null;
        }
    }

    // Método adicional para debugging
    public Map<String, Object> testConnection() {
        Map<String, Object> result = new HashMap<>();
        try {
            // Usar HashMap para evitar errores de tipos
            Map<String, Object> testParams = new HashMap<>();
            testParams.put("public_id", "test_connection");

            Map<?, ?> testResult = cloudinary.uploader().upload(
                    "data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7",
                    testParams
            );
            result.put("status", "success");
            result.put("message", "Conexión a Cloudinary exitosa");
            return result;
        } catch (Exception e) {
            result.put("status", "error");
            result.put("message", "Error en conexión a Cloudinary: " + e.getMessage());
            return result;
        }
    }
}