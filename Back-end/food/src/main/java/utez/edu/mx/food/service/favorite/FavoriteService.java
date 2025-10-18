package utez.edu.mx.food.service.favorite;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import utez.edu.mx.food.model.favorite.FavoriteBean;
import utez.edu.mx.food.model.favorite.FavoriteRepository;
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
public class FavoriteService {

    private static final Logger logger = LoggerFactory.getLogger(FavoriteService.class);

    private final FavoriteRepository favoriteRepository;
    private final UserRepository userRepository;
    private final RestaurantRepository restaurantRepository;

    @Autowired
    public FavoriteService(FavoriteRepository favoriteRepository, UserRepository userRepository,
                           RestaurantRepository restaurantRepository) {
        this.favoriteRepository = favoriteRepository;
        this.userRepository = userRepository;
        this.restaurantRepository = restaurantRepository;
    }

    @Transactional(readOnly = true)
    public ResponseEntity<Message> findAll() {
        List<FavoriteBean> favorites = favoriteRepository.findAll();
        logger.info("Búsqueda de favoritos realizada correctamente");
        return new ResponseEntity<>(new Message(favorites, "Listado de favoritos", TypesResponse.SUCCESS), HttpStatus.OK);
    }

    @Transactional(readOnly = true)
    public ResponseEntity<Message> findById(Integer id) {
        Optional<FavoriteBean> favorite = favoriteRepository.findById(id);
        if (!favorite.isPresent()) {
            return new ResponseEntity<>(new Message("Favorito no encontrado", TypesResponse.ERROR), HttpStatus.NOT_FOUND);
        }
        logger.info("Favorito encontrado correctamente");
        return new ResponseEntity<>(new Message(favorite.get(), "Favorito encontrado", TypesResponse.SUCCESS), HttpStatus.OK);
    }

    @Transactional(rollbackFor = {SQLException.class})
    public ResponseEntity<Message> save(FavoriteDTO dto) {
        // Validaciones
        if (dto.getIdUsuario() == null) {
            return new ResponseEntity<>(new Message("El usuario es requerido", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        if (dto.getIdRestaurante() == null) {
            return new ResponseEntity<>(new Message("El restaurante es requerido", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        Optional<UserBean> usuario = userRepository.findById(dto.getIdUsuario());
        if (!usuario.isPresent()) {
            return new ResponseEntity<>(new Message("Usuario no encontrado", TypesResponse.ERROR), HttpStatus.NOT_FOUND);
        }

        Optional<RestaurantBean> restaurante = restaurantRepository.findById(dto.getIdRestaurante());
        if (!restaurante.isPresent()) {
            return new ResponseEntity<>(new Message("Restaurante no encontrado", TypesResponse.ERROR), HttpStatus.NOT_FOUND);
        }

        // Validar que el restaurante esté activo
        if (!restaurante.get().getActivo()) {
            return new ResponseEntity<>(new Message("No se puede agregar un restaurante inactivo a favoritos", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        // Validar que no exista ya el favorito
        if (favoriteRepository.existsByUsuarioAndRestaurante(usuario.get(), restaurante.get())) {
            return new ResponseEntity<>(new Message("Este restaurante ya está en tus favoritos", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        // Crear entidad
        FavoriteBean favorite = new FavoriteBean();
        favorite.setUsuario(usuario.get());
        favorite.setRestaurante(restaurante.get());
        favorite.setFechaAgregado(LocalDateTime.now());

        favorite = favoriteRepository.saveAndFlush(favorite);
        if (favorite == null) {
            return new ResponseEntity<>(new Message("El favorito no se pudo registrar", TypesResponse.ERROR), HttpStatus.BAD_REQUEST);
        }

        logger.info("Favorito registrado correctamente - ID: {}", favorite.getIdFavorito());
        return new ResponseEntity<>(new Message(favorite, "Restaurante agregado a favoritos correctamente", TypesResponse.SUCCESS), HttpStatus.CREATED);
    }

    @Transactional(rollbackFor = {SQLException.class})
    public ResponseEntity<Message> delete(Integer id) {
        Optional<FavoriteBean> favoriteOptional = favoriteRepository.findById(id);
        if (!favoriteOptional.isPresent()) {
            return new ResponseEntity<>(new Message("Favorito no encontrado", TypesResponse.ERROR), HttpStatus.NOT_FOUND);
        }

        favoriteRepository.deleteById(id);
        logger.info("Favorito eliminado correctamente - ID: {}", id);
        return new ResponseEntity<>(new Message("Restaurante eliminado de favoritos correctamente", TypesResponse.SUCCESS), HttpStatus.OK);
    }

    @Transactional(rollbackFor = {SQLException.class})
    public ResponseEntity<Message> removeByUserAndRestaurant(Integer userId, Integer restaurantId) {
        Optional<UserBean> usuario = userRepository.findById(userId);
        if (!usuario.isPresent()) {
            return new ResponseEntity<>(new Message("Usuario no encontrado", TypesResponse.ERROR), HttpStatus.NOT_FOUND);
        }

        Optional<RestaurantBean> restaurante = restaurantRepository.findById(restaurantId);
        if (!restaurante.isPresent()) {
            return new ResponseEntity<>(new Message("Restaurante no encontrado", TypesResponse.ERROR), HttpStatus.NOT_FOUND);
        }

        Optional<FavoriteBean> favoriteOptional = favoriteRepository.findByUsuarioAndRestaurante(usuario.get(), restaurante.get());
        if (!favoriteOptional.isPresent()) {
            return new ResponseEntity<>(new Message("Este restaurante no está en tus favoritos", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        favoriteRepository.delete(favoriteOptional.get());
        logger.info("Favorito eliminado correctamente - Usuario: {}, Restaurante: {}", userId, restaurantId);
        return new ResponseEntity<>(new Message("Restaurante eliminado de favoritos correctamente", TypesResponse.SUCCESS), HttpStatus.OK);
    }

    @Transactional(readOnly = true)
    public ResponseEntity<Message> findByUsuario(Integer userId) {
        Optional<UserBean> usuario = userRepository.findById(userId);
        if (!usuario.isPresent()) {
            return new ResponseEntity<>(new Message("Usuario no encontrado", TypesResponse.ERROR), HttpStatus.NOT_FOUND);
        }

        List<FavoriteBean> favorites = favoriteRepository.findByUsuario(usuario.get());
        logger.info("Favoritos del usuario encontrados correctamente - Usuario ID: {}", userId);
        return new ResponseEntity<>(new Message(favorites, "Favoritos del usuario", TypesResponse.SUCCESS), HttpStatus.OK);
    }

    @Transactional(readOnly = true)
    public ResponseEntity<Message> findByRestaurante(Integer restaurantId) {
        Optional<RestaurantBean> restaurante = restaurantRepository.findById(restaurantId);
        if (!restaurante.isPresent()) {
            return new ResponseEntity<>(new Message("Restaurante no encontrado", TypesResponse.ERROR), HttpStatus.NOT_FOUND);
        }

        List<FavoriteBean> favorites = favoriteRepository.findByRestaurante(restaurante.get());
        logger.info("Favoritos del restaurante encontrados correctamente - Restaurante ID: {}", restaurantId);
        return new ResponseEntity<>(new Message(favorites, "Favoritos del restaurante", TypesResponse.SUCCESS), HttpStatus.OK);
    }

    @Transactional(readOnly = true)
    public ResponseEntity<Message> existsByUserAndRestaurant(Integer userId, Integer restaurantId) {
        Optional<UserBean> usuario = userRepository.findById(userId);
        if (!usuario.isPresent()) {
            return new ResponseEntity<>(new Message("Usuario no encontrado", TypesResponse.ERROR), HttpStatus.NOT_FOUND);
        }

        Optional<RestaurantBean> restaurante = restaurantRepository.findById(restaurantId);
        if (!restaurante.isPresent()) {
            return new ResponseEntity<>(new Message("Restaurante no encontrado", TypesResponse.ERROR), HttpStatus.NOT_FOUND);
        }

        boolean exists = favoriteRepository.existsByUsuarioAndRestaurante(usuario.get(), restaurante.get());
        return new ResponseEntity<>(new Message(exists, "Estado de favorito", TypesResponse.SUCCESS), HttpStatus.OK);
    }

    @Transactional(readOnly = true)
    public ResponseEntity<Message> countByUsuario(Integer userId) {
        Optional<UserBean> usuario = userRepository.findById(userId);
        if (!usuario.isPresent()) {
            return new ResponseEntity<>(new Message("Usuario no encontrado", TypesResponse.ERROR), HttpStatus.NOT_FOUND);
        }

        long count = favoriteRepository.countByUsuario(usuario.get());
        return new ResponseEntity<>(new Message(count, "Cantidad de favoritos del usuario", TypesResponse.SUCCESS), HttpStatus.OK);
    }

    @Transactional(readOnly = true)
    public ResponseEntity<Message> countByRestaurante(Integer restaurantId) {
        Optional<RestaurantBean> restaurante = restaurantRepository.findById(restaurantId);
        if (!restaurante.isPresent()) {
            return new ResponseEntity<>(new Message("Restaurante no encontrado", TypesResponse.ERROR), HttpStatus.NOT_FOUND);
        }

        long count = favoriteRepository.countByRestaurante(restaurante.get());
        return new ResponseEntity<>(new Message(count, "Cantidad de favoritos del restaurante", TypesResponse.SUCCESS), HttpStatus.OK);
    }
}