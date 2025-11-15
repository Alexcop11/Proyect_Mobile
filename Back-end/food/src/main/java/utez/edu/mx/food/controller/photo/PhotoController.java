package utez.edu.mx.food.controller.photo;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import utez.edu.mx.food.model.photo.PhotoBean;
import utez.edu.mx.food.service.cloud.CloudinaryService;
import utez.edu.mx.food.service.photo.PhotoService;
import utez.edu.mx.food.utils.Message;
import utez.edu.mx.food.utils.TypesResponse;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/photos")
@CrossOrigin(origins = {"*"})
public class PhotoController {

    @Autowired
    private PhotoService photoService;

    @Autowired
    private CloudinaryService cloudinaryService;

    @PostMapping("/upload")
    public ResponseEntity<Message> uploadPhoto(
            @RequestParam("file") MultipartFile file,
            @RequestParam("idRestaurante") Integer idRestaurante,
            @RequestParam(value = "descripcion", required = false) String descripcion,
            @RequestParam(value = "esPortada", defaultValue = "false") Boolean esPortada) {

        try {
            PhotoBean photo = photoService.uploadPhoto(file, idRestaurante, descripcion, esPortada);
            return ResponseEntity.ok(new Message(photo, "Foto subida exitosamente", TypesResponse.SUCCESS));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(new Message(e.getMessage(), TypesResponse.ERROR));
        }
    }

    @GetMapping("/restaurant/{idRestaurante}")
    public ResponseEntity<Message> getPhotosByRestaurant(@PathVariable Integer idRestaurante) {
        try {
            List<PhotoBean> photos = photoService.getPhotosByRestaurant(idRestaurante);
            return ResponseEntity.ok(new Message(photos, "Fotos del restaurante", TypesResponse.SUCCESS));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(new Message(e.getMessage(), TypesResponse.ERROR));
        }
    }

    @PutMapping("/{idFoto}/portada")
    public ResponseEntity<Message> setAsPortada(@PathVariable Integer idFoto) {
        try {
            PhotoBean photo = photoService.setAsPortada(idFoto);
            return ResponseEntity.ok(new Message(photo, "Foto establecida como portada", TypesResponse.SUCCESS));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(new Message(e.getMessage(), TypesResponse.ERROR));
        }
    }

    @DeleteMapping("/{idFoto}")
    public ResponseEntity<Message> deletePhoto(@PathVariable Integer idFoto) {
        try {
            photoService.deletePhoto(idFoto);
            return ResponseEntity.ok(new Message("Foto eliminada exitosamente", TypesResponse.SUCCESS));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(new Message(e.getMessage(), TypesResponse.ERROR));
        }
    }


}