package utez.edu.mx.food.controller.user;

import utez.edu.mx.food.service.user.UserDTO;
import utez.edu.mx.food.service.user.UserService;
import utez.edu.mx.food.utils.Message;
import utez.edu.mx.food.utils.TypesResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = {"*"})
public class UserController {

    private static final Logger logger = LoggerFactory.getLogger(UserController.class);

    @Autowired
    private UserService userService;

    @GetMapping("/")
    public ResponseEntity<Message> getAllUsers() {
        logger.info("Solicitando listado de todos los usuarios");
        return userService.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Message> getUserById(@PathVariable Integer id) {
        logger.info("Solicitando usuario con ID: {}", id);
        return userService.findById(id);
    }

    @GetMapping("/email/{email}")
    public ResponseEntity<Message> getUserByEmail(@PathVariable String email) {
        logger.info("Solicitando usuario con email: {}", email);
        return userService.findByEmail(email);
    }

    @PostMapping("/")
    public ResponseEntity<Message> createUser(@RequestBody UserDTO userDTO) {
        logger.info("Creando nuevo usuario: {}", userDTO.getEmail());
        return userService.save(userDTO);
    }

    @PutMapping("/")
    public ResponseEntity<Message> updateUser(@RequestBody UserDTO userDTO) {
        logger.info("Actualizando usuario con ID: {}", userDTO.getIdUsuario());
        return userService.update(userDTO);
    }

    @PatchMapping("/{id}/status")
    public ResponseEntity<Message> changeUserStatus(@PathVariable Integer id) {
        logger.info("Cambiando estado del usuario con ID: {}", id);
        return userService.changeStatus(id);
    }
}