package utez.edu.mx.food.service.photo;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import utez.edu.mx.food.model.photo.PhotoBean;
import utez.edu.mx.food.model.photo.PhotoRepository;
import utez.edu.mx.food.model.restaurant.RestaurantBean;
import utez.edu.mx.food.model.restaurant.RestaurantRepository;
import utez.edu.mx.food.service.cloud.CloudinaryService;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class PhotoService {

    @Autowired
    private PhotoRepository photoRepository;

    @Autowired
    private RestaurantRepository restaurantRepository;

    @Autowired
    private CloudinaryService cloudinaryService;

    public PhotoBean uploadPhoto(MultipartFile file, Integer idRestaurante, String descripcion, Boolean esPortada) {
        try {
            // Validar que el archivo no esté vacío
            if (file.isEmpty()) {
                throw new RuntimeException("El archivo está vacío");
            }

            // Validar tipo de archivo
            String contentType = file.getContentType();
            if (contentType == null || !contentType.startsWith("image/")) {
                throw new RuntimeException("Solo se permiten archivos de imagen");
            }

            RestaurantBean restaurante = restaurantRepository.findById(idRestaurante)
                    .orElseThrow(() -> new RuntimeException("Restaurante no encontrado"));

            // Subir imagen a Cloudinary
            String url = cloudinaryService.uploadFile(file, "restaurantes/" + idRestaurante);

            // Si se marca como portada, quitar portada anterior
            if (esPortada != null && esPortada) {
                photoRepository.findByRestauranteIdRestauranteAndEsPortadaTrue(idRestaurante)
                        .ifPresent(photo -> {
                            photo.setEsPortada(Boolean.valueOf(false));
                            photoRepository.save(photo);
                        });
            }

            // Crear entidad de foto
            PhotoBean photo = new PhotoBean();
            photo.setRestaurante(restaurante);
            photo.setUrl(url);
            photo.setDescripcion(descripcion);
            photo.setEsPortada(Boolean.valueOf(esPortada != null && esPortada));
            photo.setFechaSubida(LocalDateTime.now());

            return photoRepository.save(photo);

        } catch (Exception e) {
            throw new RuntimeException("Error al subir la imagen: " + e.getMessage());
        }
    }

    public List<PhotoBean> getPhotosByRestaurant(Integer idRestaurante) {
        return photoRepository.findByRestauranteIdRestaurante(idRestaurante);
    }

    public PhotoBean setAsPortada(Integer idFoto) {
        PhotoBean photo = photoRepository.findById(idFoto)
                .orElseThrow(() -> new RuntimeException("Foto no encontrada"));

        // Quitar portada anterior
        photoRepository.findByRestauranteIdRestauranteAndEsPortadaTrue(photo.getRestaurante().getIdRestaurante())
                .ifPresent(previousPortada -> {
                    previousPortada.setEsPortada(Boolean.FALSE);
                    photoRepository.save(previousPortada);
                });

        // Establecer nueva portada
        photo.setEsPortada(Boolean.TRUE);
        return photoRepository.save(photo);
    }

    public void deletePhoto(Integer idFoto) {
        PhotoBean photo = photoRepository.findById(idFoto)
                .orElseThrow(() -> new RuntimeException("Foto no encontrada"));

        try {
            // Eliminar de Cloudinary
            cloudinaryService.deleteFile(photo.getUrl());
        } catch (Exception e) {
            System.err.println("Error eliminando archivo de Cloudinary: " + e.getMessage());
            throw new RuntimeException("Error al eliminar la imagen del almacenamiento: " + e.getMessage());
        }

        
        photoRepository.delete(photo);
    }
}