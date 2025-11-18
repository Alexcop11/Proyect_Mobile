package utez.edu.mx.food.service.restaurant;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import utez.edu.mx.food.model.restaurant.RestaurantBean;
import utez.edu.mx.food.model.restaurant.RestaurantRepository;
import utez.edu.mx.food.model.user.UserBean;
import utez.edu.mx.food.model.user.UserRepository;
import utez.edu.mx.food.utils.Message;
import utez.edu.mx.food.utils.TypesResponse;

import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Transactional
@Service
public class RestaurantService {

    private static final Logger logger = LoggerFactory.getLogger(RestaurantService.class);

    private final RestaurantRepository restaurantRepository;
    private final UserRepository userRepository;

    @Autowired
    public RestaurantService(RestaurantRepository restaurantRepository, UserRepository userRepository) {
        this.restaurantRepository = restaurantRepository;
        this.userRepository = userRepository;
    }

    @Transactional(readOnly = true)
    public ResponseEntity<Message> findAll() {
        List<RestaurantBean> restaurants = restaurantRepository.findAll();
        logger.info("Búsqueda de restaurantes realizada correctamente");
        return new ResponseEntity<>(new Message(restaurants, "Listado de restaurantes", TypesResponse.SUCCESS), HttpStatus.OK);
    }

    @Transactional(readOnly = true)
    public ResponseEntity<Message> findById(Integer id) {
        Optional<RestaurantBean> restaurant = restaurantRepository.findById(id);
        if (!restaurant.isPresent()) {
            return new ResponseEntity<>(new Message("Restaurante no encontrado", TypesResponse.ERROR), HttpStatus.NOT_FOUND);
        }
        logger.info("Restaurante encontrado correctamente");
        return new ResponseEntity<>(new Message(restaurant.get(), "Restaurante encontrado", TypesResponse.SUCCESS), HttpStatus.OK);
    }

    @Transactional(rollbackFor = {SQLException.class})
    public ResponseEntity<Message> save(RestaurantDTO dto) {
        // Validaciones
        if (dto.getNombre() == null || dto.getNombre().trim().isEmpty()) {
            return new ResponseEntity<>(new Message("El nombre del restaurante no puede estar vacío", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        if (dto.getNombre().length() > 200) {
            return new ResponseEntity<>(new Message("El nombre no puede exceder 200 caracteres", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        if (dto.getDescripcion() != null && dto.getDescripcion().length() > 1000) {
            return new ResponseEntity<>(new Message("La descripción no puede exceder 1000 caracteres", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        if (dto.getDireccion() == null || dto.getDireccion().trim().isEmpty()) {
            return new ResponseEntity<>(new Message("La dirección no puede estar vacía", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        if (dto.getDireccion().length() > 500) {
            return new ResponseEntity<>(new Message("La dirección no puede exceder 500 caracteres", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        if (dto.getIdUsuarioPropietario() == null) {
            return new ResponseEntity<>(new Message("El propietario es requerido", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        Optional<UserBean> propietario = userRepository.findById(dto.getIdUsuarioPropietario());
        if (!propietario.isPresent()) {
            return new ResponseEntity<>(new Message("El propietario no existe", TypesResponse.ERROR), HttpStatus.NOT_FOUND);
        }

        if (propietario.get().getTipoUsuario() != UserBean.TipoUsuario.RESTAURANTE) {
            return new ResponseEntity<>(new Message("El usuario debe ser de tipo RESTAURANTE", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        // Validar coordenadas si se proporcionan
        if (dto.getLatitud() != null && (dto.getLatitud().doubleValue() < -90 || dto.getLatitud().doubleValue() > 90)) {
            return new ResponseEntity<>(new Message("La latitud debe estar entre -90 y 90", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        if (dto.getLongitud() != null && (dto.getLongitud().doubleValue() < -180 || dto.getLongitud().doubleValue() > 180)) {
            return new ResponseEntity<>(new Message("La longitud debe estar entre -180 y 180", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        // Validar precio promedio
        if (dto.getPrecioPromedio() != null && dto.getPrecioPromedio().doubleValue() < 0) {
            return new ResponseEntity<>(new Message("El precio promedio debe ser positivo", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        // Crear entidad
        RestaurantBean restaurant = new RestaurantBean();
        restaurant.setUsuarioPropietario(propietario.get());
        restaurant.setNombre(dto.getNombre());
        restaurant.setDescripcion(dto.getDescripcion());
        restaurant.setDireccion(dto.getDireccion());
        restaurant.setLatitud(dto.getLatitud());
        restaurant.setLongitud(dto.getLongitud());
        restaurant.setTelefono(dto.getTelefono());
        restaurant.setHorarioApertura(dto.getHorarioApertura());
        restaurant.setHorarioCierre(dto.getHorarioCierre());
        restaurant.setPrecioPromedio(dto.getPrecioPromedio());
        restaurant.setCategoria(dto.getCategoria());
        restaurant.setMenuUrl(dto.getMenuUrl());
        restaurant.setFechaRegistro(LocalDateTime.now());
        restaurant.setActivo(dto.getActivo() != null ? dto.getActivo() : true);

        restaurant = restaurantRepository.saveAndFlush(restaurant);
        if (restaurant == null) {
            return new ResponseEntity<>(new Message("El restaurante no se pudo registrar", TypesResponse.ERROR), HttpStatus.BAD_REQUEST);
        }

        logger.info("Restaurante registrado correctamente - ID: {}", restaurant.getIdRestaurante());
        return new ResponseEntity<>(new Message(restaurant, "Restaurante registrado correctamente", TypesResponse.SUCCESS), HttpStatus.CREATED);
    }

    @Transactional(rollbackFor = {SQLException.class})
    public ResponseEntity<Message> update(RestaurantDTO dto) {
        Optional<RestaurantBean> restaurantOptional = restaurantRepository.findById(dto.getIdRestaurante());
        if (!restaurantOptional.isPresent()) {
            return new ResponseEntity<>(new Message("Restaurante no encontrado", TypesResponse.ERROR), HttpStatus.NOT_FOUND);
        }

        RestaurantBean restaurant = restaurantOptional.get();

        // Validaciones
        if (dto.getNombre() == null || dto.getNombre().trim().isEmpty()) {
            return new ResponseEntity<>(new Message("El nombre del restaurante no puede estar vacío", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        if (dto.getNombre().length() > 200) {
            return new ResponseEntity<>(new Message("El nombre no puede exceder 200 caracteres", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        if (dto.getDescripcion() != null && dto.getDescripcion().length() > 1000) {
            return new ResponseEntity<>(new Message("La descripción no puede exceder 1000 caracteres", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        if (dto.getDireccion() == null || dto.getDireccion().trim().isEmpty()) {
            return new ResponseEntity<>(new Message("La dirección no puede estar vacía", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        // Actualizar campos
        restaurant.setNombre(dto.getNombre());
        restaurant.setDescripcion(dto.getDescripcion());
        restaurant.setDireccion(dto.getDireccion());
        restaurant.setLatitud(dto.getLatitud());
        restaurant.setLongitud(dto.getLongitud());
        restaurant.setTelefono(dto.getTelefono());
        restaurant.setHorarioApertura(dto.getHorarioApertura());
        restaurant.setHorarioCierre(dto.getHorarioCierre());
        restaurant.setPrecioPromedio(dto.getPrecioPromedio());
        restaurant.setCategoria(dto.getCategoria());
        restaurant.setMenuUrl(dto.getMenuUrl());
        if (dto.getActivo() != null) {
            restaurant.setActivo(dto.getActivo());
        }

        restaurant = restaurantRepository.saveAndFlush(restaurant);
        if (restaurant == null) {
            return new ResponseEntity<>(new Message("El restaurante no se pudo actualizar", TypesResponse.ERROR), HttpStatus.BAD_REQUEST);
        }

        logger.info("Restaurante actualizado correctamente - ID: {}", restaurant.getIdRestaurante());
        return new ResponseEntity<>(new Message(restaurant, "Restaurante actualizado correctamente", TypesResponse.SUCCESS), HttpStatus.OK);
    }

    @Transactional(rollbackFor = {SQLException.class})
    public ResponseEntity<Message> changeStatus(Integer id) {
        Optional<RestaurantBean> restaurantOptional = restaurantRepository.findById(id);
        if (!restaurantOptional.isPresent()) {
            return new ResponseEntity<>(new Message("Restaurante no encontrado", TypesResponse.ERROR), HttpStatus.NOT_FOUND);
        }

        RestaurantBean restaurant = restaurantOptional.get();
        restaurant.setActivo(!restaurant.getActivo());

        restaurant = restaurantRepository.saveAndFlush(restaurant);
        if (restaurant == null) {
            return new ResponseEntity<>(new Message("El estado del restaurante no se pudo actualizar", TypesResponse.ERROR), HttpStatus.BAD_REQUEST);
        }

        String status = restaurant.getActivo() ? "activado" : "desactivado";
        logger.info("Estado del restaurante actualizado correctamente - ID: {}", restaurant.getIdRestaurante());
        return new ResponseEntity<>(new Message(restaurant, "Restaurante " + status + " correctamente", TypesResponse.SUCCESS), HttpStatus.OK);
    }
}