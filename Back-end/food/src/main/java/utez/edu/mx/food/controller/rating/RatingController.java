package utez.edu.mx.food.controller.rating;

import utez.edu.mx.food.service.rating.RatingDTO;
import utez.edu.mx.food.service.rating.RatingService;
import utez.edu.mx.food.utils.Message;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/ratings")
@CrossOrigin(origins = {"*"})
public class RatingController {

    private static final Logger logger = LoggerFactory.getLogger(RatingController.class);

    @Autowired
    private RatingService ratingService;

    @GetMapping("/")
    public ResponseEntity<Message> getAllRatings() {
        logger.info("Solicitando listado de todas las calificaciones");
        return ratingService.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Message> getRatingById(@PathVariable Integer id) {
        logger.info("Solicitando calificación con ID: {}", id);
        return ratingService.findById(id);
    }

    @GetMapping("/restaurant/{idRestaurante}")
    public ResponseEntity<Message> getRatingsByRestaurant(@PathVariable Integer idRestaurante) {
        logger.info("Solicitando calificaciones para restaurante con ID: {}", idRestaurante);
        return ratingService.findByRestaurantId(idRestaurante);
    }


    @PostMapping("/")
    public ResponseEntity<Message> createRating(@RequestBody RatingDTO ratingDTO) {
        logger.info("Creando nueva calificación para restaurante ID: {}", ratingDTO.getIdRestaurante());
        return ratingService.save(ratingDTO);
    }

    @PutMapping("/")
    public ResponseEntity<Message> updateRating(@RequestBody RatingDTO ratingDTO) {
        logger.info("Actualizando calificación con ID: {}", ratingDTO.getIdCalificacion());
        return ratingService.update(ratingDTO);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Message> deleteRating(@PathVariable Integer id) {
        logger.info("Eliminando calificación con ID: {}", id);
        return ratingService.delete(id);
    }
}
