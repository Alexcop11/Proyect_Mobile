package utez.edu.mx.food.service.rating;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import utez.edu.mx.food.model.rating.RatingBean;
import utez.edu.mx.food.model.rating.RatingRepository;
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
public class RatingService {

    private static final Logger logger = LoggerFactory.getLogger(RatingService.class);

    private final RatingRepository ratingRepository;
    private final UserRepository userRepository;
    private final RestaurantRepository restaurantRepository;

    @Autowired
    public RatingService(RatingRepository ratingRepository, UserRepository userRepository,
                         RestaurantRepository restaurantRepository) {
        this.ratingRepository = ratingRepository;
        this.userRepository = userRepository;
        this.restaurantRepository = restaurantRepository;
    }

    @Transactional(readOnly = true)
    public ResponseEntity<Message> findAll() {
        List<RatingBean> ratings = ratingRepository.findAll();
        logger.info("Búsqueda de calificaciones realizada correctamente");
        return new ResponseEntity<>(new Message(ratings, "Listado de calificaciones", TypesResponse.SUCCESS), HttpStatus.OK);
    }

    @Transactional(readOnly = true)
    public ResponseEntity<Message> findById(Integer id) {
        Optional<RatingBean> rating = ratingRepository.findById(id);
        if (!rating.isPresent()) {
            return new ResponseEntity<>(new Message("Calificación no encontrada", TypesResponse.ERROR), HttpStatus.NOT_FOUND);
        }
        logger.info("Calificación encontrada correctamente");
        return new ResponseEntity<>(new Message(rating.get(), "Calificación encontrada", TypesResponse.SUCCESS), HttpStatus.OK);
    }

    @Transactional(readOnly = true)
    public ResponseEntity<Message> findByRestaurantId(Integer idRestaurante) {
        List<RatingBean> ratings = ratingRepository.findByRestaurante_IdRestaurante(idRestaurante);

        if (ratings.isEmpty()) {
            return new ResponseEntity<>(new Message("No hay calificaciones para este restaurante", TypesResponse.ERROR),
                    HttpStatus.NOT_FOUND);
        }

        logger.info("Se encontraron {} calificaciones para restaurante con ID {}", ratings.size(), idRestaurante);
        return new ResponseEntity<>(new Message(ratings, "Calificaciones encontradas", TypesResponse.SUCCESS),
                HttpStatus.OK);
    }


    @Transactional(rollbackFor = {SQLException.class})
    public ResponseEntity<Message> save(RatingDTO dto) {
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

        if (restaurante.get().getUsuarioPropietario().getIdUsuario().equals(dto.getIdUsuario())) {
            return new ResponseEntity<>(new Message("No puedes calificar tu propio restaurante", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        if (dto.getPuntuacionComida() == null || dto.getPuntuacionComida() < 1 || dto.getPuntuacionComida() > 5) {
            return new ResponseEntity<>(new Message("La puntuación de comida debe estar entre 1 y 5", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        if (dto.getPuntuacionServicio() == null || dto.getPuntuacionServicio() < 1 || dto.getPuntuacionServicio() > 5) {
            return new ResponseEntity<>(new Message("La puntuación de servicio debe estar entre 1 y 5", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        if (dto.getPuntuacionAmbiente() == null || dto.getPuntuacionAmbiente() < 1 || dto.getPuntuacionAmbiente() > 5) {
            return new ResponseEntity<>(new Message("La puntuación de ambiente debe estar entre 1 y 5", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        if (ratingRepository.existsByUsuarioAndRestaurante(usuario.get(), restaurante.get())) {
            return new ResponseEntity<>(new Message("Ya has calificado este restaurante", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        if (dto.getComentario() != null && dto.getComentario().length() > 1000) {
            return new ResponseEntity<>(new Message("El comentario no puede exceder 1000 caracteres", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        RatingBean rating = new RatingBean();
        rating.setUsuario(usuario.get());
        rating.setRestaurante(restaurante.get());
        rating.setPuntuacionComida(dto.getPuntuacionComida());
        rating.setPuntuacionServicio(dto.getPuntuacionServicio());
        rating.setPuntuacionAmbiente(dto.getPuntuacionAmbiente());
        rating.setComentario(dto.getComentario());
        rating.setFechaCalificacion(LocalDateTime.now());

        rating = ratingRepository.saveAndFlush(rating);
        if (rating == null) {
            return new ResponseEntity<>(new Message("La calificación no se pudo registrar", TypesResponse.ERROR), HttpStatus.BAD_REQUEST);
        }

        logger.info("Calificación registrada correctamente - ID: {}", rating.getIdCalificacion());
        return new ResponseEntity<>(new Message(rating, "Calificación registrada correctamente", TypesResponse.SUCCESS), HttpStatus.CREATED);
    }

    @Transactional(rollbackFor = {SQLException.class})
    public ResponseEntity<Message> update(RatingDTO dto) {
        Optional<RatingBean> ratingOptional = ratingRepository.findById(dto.getIdCalificacion());
        if (!ratingOptional.isPresent()) {
            return new ResponseEntity<>(new Message("Calificación no encontrada", TypesResponse.ERROR), HttpStatus.NOT_FOUND);
        }

        RatingBean rating = ratingOptional.get();

        if (dto.getPuntuacionComida() == null || dto.getPuntuacionComida() < 1 || dto.getPuntuacionComida() > 5) {
            return new ResponseEntity<>(new Message("La puntuación de comida debe estar entre 1 y 5", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        if (dto.getPuntuacionServicio() == null || dto.getPuntuacionServicio() < 1 || dto.getPuntuacionServicio() > 5) {
            return new ResponseEntity<>(new Message("La puntuación de servicio debe estar entre 1 y 5", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        if (dto.getPuntuacionAmbiente() == null || dto.getPuntuacionAmbiente() < 1 || dto.getPuntuacionAmbiente() > 5) {
            return new ResponseEntity<>(new Message("La puntuación de ambiente debe estar entre 1 y 5", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        if (dto.getComentario() != null && dto.getComentario().length() > 1000) {
            return new ResponseEntity<>(new Message("El comentario no puede exceder 1000 caracteres", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        rating.setPuntuacionComida(dto.getPuntuacionComida());
        rating.setPuntuacionServicio(dto.getPuntuacionServicio());
        rating.setPuntuacionAmbiente(dto.getPuntuacionAmbiente());
        rating.setComentario(dto.getComentario());

        rating = ratingRepository.saveAndFlush(rating);
        if (rating == null) {
            return new ResponseEntity<>(new Message("La calificación no se pudo actualizar", TypesResponse.ERROR), HttpStatus.BAD_REQUEST);
        }

        logger.info("Calificación actualizada correctamente - ID: {}", rating.getIdCalificacion());
        return new ResponseEntity<>(new Message(rating, "Calificación actualizada correctamente", TypesResponse.SUCCESS), HttpStatus.OK);
    }

    @Transactional(rollbackFor = {SQLException.class})
    public ResponseEntity<Message> delete(Integer id) {
        Optional<RatingBean> ratingOptional = ratingRepository.findById(id);
        if (!ratingOptional.isPresent()) {
            return new ResponseEntity<>(new Message("Calificación no encontrada", TypesResponse.ERROR), HttpStatus.NOT_FOUND);
        }

        ratingRepository.deleteById(id);
        logger.info("Calificación eliminada correctamente - ID: {}", id);
        return new ResponseEntity<>(new Message("Calificación eliminada correctamente", TypesResponse.SUCCESS), HttpStatus.OK);
    }
}
