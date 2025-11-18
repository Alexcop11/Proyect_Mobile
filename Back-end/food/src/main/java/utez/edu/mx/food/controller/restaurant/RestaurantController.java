package utez.edu.mx.food.controller.restaurant;

import utez.edu.mx.food.service.restaurant.RestaurantDTO;
import utez.edu.mx.food.service.restaurant.RestaurantService;
import utez.edu.mx.food.utils.Message;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/restaurants")
@CrossOrigin(origins = {"*"})
public class RestaurantController {

    private static final Logger logger = LoggerFactory.getLogger(RestaurantController.class);

    @Autowired
    private RestaurantService restaurantService;

    @GetMapping("/")
    public ResponseEntity<Message> getAllRestaurants() {
        logger.info("Solicitando listado de todos los restaurantes");
        return restaurantService.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Message> getRestaurantById(@PathVariable Integer id) {
        logger.info("Solicitando restaurante con ID: {}", id);
        return restaurantService.findById(id);
    }

    @PostMapping("/")
    public ResponseEntity<Message> createRestaurant(@RequestBody RestaurantDTO restaurantDTO) {
        logger.info("Creando nuevo restaurante: {}", restaurantDTO.getNombre());
        return restaurantService.save(restaurantDTO);
    }

    @PutMapping("/")
    public ResponseEntity<Message> updateRestaurant(@RequestBody RestaurantDTO restaurantDTO) {
        logger.info("Actualizando restaurante con ID: {}", restaurantDTO.getIdRestaurante());
        return restaurantService.update(restaurantDTO);
    }

    @PatchMapping("/{id}/status")
    public ResponseEntity<Message> changeRestaurantStatus(@PathVariable Integer id) {
        logger.info("Cambiando estado del restaurante con ID: {}", id);
        return restaurantService.changeStatus(id);
    }
}