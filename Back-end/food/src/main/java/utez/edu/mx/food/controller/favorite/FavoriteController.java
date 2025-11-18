package utez.edu.mx.food.controller.favorite;

import utez.edu.mx.food.service.favorite.FavoriteDTO;
import utez.edu.mx.food.service.favorite.FavoriteService;
import utez.edu.mx.food.utils.Message;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/favorites")
@CrossOrigin(origins = {"*"})
public class FavoriteController {

    private static final Logger logger = LoggerFactory.getLogger(FavoriteController.class);

    @Autowired
    private FavoriteService favoriteService;

    @GetMapping("/")
    public ResponseEntity<Message> getAllFavorites() {
        logger.info("Solicitando listado de todos los favoritos");
        return favoriteService.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Message> getFavoriteById(@PathVariable Integer id) {
        logger.info("Solicitando favorito con ID: {}", id);
        return favoriteService.findById(id);
    }

    @PostMapping("/")
    public ResponseEntity<Message> createFavorite(@RequestBody FavoriteDTO favoriteDTO) {
        logger.info("Agregando restaurante {} a favoritos del usuario {}",
                favoriteDTO.getIdRestaurante(), favoriteDTO.getIdUsuario());
        return favoriteService.save(favoriteDTO);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Message> deleteFavorite(@PathVariable Integer id) {
        logger.info("Eliminando favorito con ID: {}", id);
        return favoriteService.delete(id);
    }

    @DeleteMapping("/user/{userId}/restaurant/{restaurantId}")
    public ResponseEntity<Message> removeFavoriteByUserAndRestaurant(
            @PathVariable Integer userId,
            @PathVariable Integer restaurantId) {
        logger.info("Eliminando favorito - Usuario: {}, Restaurante: {}", userId, restaurantId);
        return favoriteService.removeByUserAndRestaurant(userId, restaurantId);
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<Message> getFavoritesByUser(@PathVariable Integer userId) {
        logger.info("Solicitando favoritos del usuario con ID: {}", userId);
        return favoriteService.findByUsuario(userId);
    }

    @GetMapping("/restaurant/{restaurantId}")
    public ResponseEntity<Message> getFavoritesByRestaurant(@PathVariable Integer restaurantId) {
        logger.info("Solicitando favoritos del restaurante con ID: {}", restaurantId);
        return favoriteService.findByRestaurante(restaurantId);
    }

    @GetMapping("/user/{userId}/restaurant/{restaurantId}/exists")
    public ResponseEntity<Message> checkFavoriteExists(
            @PathVariable Integer userId,
            @PathVariable Integer restaurantId) {
        logger.info("Verificando si el restaurante {} está en favoritos del usuario {}", restaurantId, userId);
        return favoriteService.existsByUserAndRestaurant(userId, restaurantId);
    }

    @GetMapping("/user/{userId}/count")
    public ResponseEntity<Message> countFavoritesByUser(@PathVariable Integer userId) {
        logger.info("Contando favoritos del usuario con ID: {}", userId);
        return favoriteService.countByUsuario(userId);
    }

    @GetMapping("/restaurant/{restaurantId}/count")
    public ResponseEntity<Message> countFavoritesByRestaurant(@PathVariable Integer restaurantId) {
        logger.info("Contando favoritos del restaurante con ID: {}", restaurantId);
        return favoriteService.countByRestaurante(restaurantId);
    }
}