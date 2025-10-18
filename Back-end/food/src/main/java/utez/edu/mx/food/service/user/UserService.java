package utez.edu.mx.food.service.user;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import utez.edu.mx.food.model.user.UserBean;
import utez.edu.mx.food.model.user.UserRepository;
import utez.edu.mx.food.utils.Message;
import utez.edu.mx.food.utils.TypesResponse;

import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.regex.Pattern;

@Transactional
@Service
public class UserService {

    private static final Logger logger = LoggerFactory.getLogger(UserService.class);
    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[A-Za-z0-9+_.-]+@(.+)$");
    private static final Pattern PHONE_PATTERN = Pattern.compile("^[+]?[0-9]{10,15}$");

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Autowired
    public UserService(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Transactional(readOnly = true)
    public ResponseEntity<Message> findAll() {
        List<UserBean> users = userRepository.findAll();
        logger.info("Búsqueda de usuarios realizada correctamente");
        return new ResponseEntity<>(new Message(users, "Listado de usuarios", TypesResponse.SUCCESS), HttpStatus.OK);
    }

    @Transactional(readOnly = true)
    public ResponseEntity<Message> findById(Integer id) {
        Optional<UserBean> user = userRepository.findById(id);
        if (!user.isPresent()) {
            return new ResponseEntity<>(new Message("Usuario no encontrado", TypesResponse.ERROR), HttpStatus.NOT_FOUND);
        }
        logger.info("Usuario encontrado correctamente");
        return new ResponseEntity<>(new Message(user.get(), "Usuario encontrado", TypesResponse.SUCCESS), HttpStatus.OK);
    }

    @Transactional(rollbackFor = {SQLException.class})
    public ResponseEntity<Message> save(UserDTO dto) {
        if (dto.getEmail() == null || dto.getEmail().trim().isEmpty()) {
            return new ResponseEntity<>(new Message("El email no puede estar vacío", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        if (!EMAIL_PATTERN.matcher(dto.getEmail()).matches()) {
            return new ResponseEntity<>(new Message("El formato del email no es válido", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        if (userRepository.existsByEmail(dto.getEmail())) {
            return new ResponseEntity<>(new Message("El email ya está registrado", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        if (dto.getPasswordHash() == null || dto.getPasswordHash().length() < 6) {
            return new ResponseEntity<>(new Message("La contraseña debe tener al menos 6 caracteres", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        if (dto.getNombre() == null || dto.getNombre().trim().isEmpty()) {
            return new ResponseEntity<>(new Message("El nombre no puede estar vacío", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        if (dto.getNombre().length() > 100) {
            return new ResponseEntity<>(new Message("El nombre no puede exceder 100 caracteres", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        if (dto.getApellido() != null && dto.getApellido().length() > 100) {
            return new ResponseEntity<>(new Message("El apellido no puede exceder 100 caracteres", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        if (dto.getTelefono() != null && !PHONE_PATTERN.matcher(dto.getTelefono()).matches()) {
            return new ResponseEntity<>(new Message("El formato del teléfono no es válido", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        if (dto.getTipoUsuario() == null) {
            return new ResponseEntity<>(new Message("El tipo de usuario es requerido", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        String hashedPassword = passwordEncoder.encode(dto.getPasswordHash());

        // Crear entidad
        UserBean user = new UserBean();
        user.setEmail(dto.getEmail().toLowerCase());
        user.setPasswordHash(hashedPassword);
        user.setTipoUsuario(dto.getTipoUsuario());
        user.setNombre(dto.getNombre());
        user.setApellido(dto.getApellido());
        user.setTelefono(dto.getTelefono());
        user.setFechaRegistro(LocalDateTime.now());
        user.setActivo(dto.getActivo() != null ? dto.getActivo() : true);

        user = userRepository.saveAndFlush(user);
        if (user == null) {
            return new ResponseEntity<>(new Message("El usuario no se pudo registrar", TypesResponse.ERROR), HttpStatus.BAD_REQUEST);
        }

        logger.info("Usuario registrado correctamente - ID: {}", user.getIdUsuario());
        return new ResponseEntity<>(new Message(user, "Usuario registrado correctamente", TypesResponse.SUCCESS), HttpStatus.CREATED);
    }

    @Transactional(rollbackFor = {SQLException.class})
    public ResponseEntity<Message> update(UserDTO dto) {
        Optional<UserBean> userOptional = userRepository.findById(dto.getIdUsuario());
        if (!userOptional.isPresent()) {
            return new ResponseEntity<>(new Message("Usuario no encontrado", TypesResponse.ERROR), HttpStatus.NOT_FOUND);
        }

        UserBean user = userOptional.get();

        // Validaciones
        if (dto.getNombre() == null || dto.getNombre().trim().isEmpty()) {
            return new ResponseEntity<>(new Message("El nombre no puede estar vacío", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        if (dto.getNombre().length() > 100) {
            return new ResponseEntity<>(new Message("El nombre no puede exceder 100 caracteres", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        if (dto.getApellido() != null && dto.getApellido().length() > 100) {
            return new ResponseEntity<>(new Message("El apellido no puede exceder 100 caracteres", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        if (dto.getTelefono() != null && !PHONE_PATTERN.matcher(dto.getTelefono()).matches()) {
            return new ResponseEntity<>(new Message("El formato del teléfono no es válido", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        user.setNombre(dto.getNombre());
        user.setApellido(dto.getApellido());
        user.setTelefono(dto.getTelefono());
        if (dto.getActivo() != null) {
            user.setActivo(dto.getActivo());
        }

        user = userRepository.saveAndFlush(user);
        if (user == null) {
            return new ResponseEntity<>(new Message("El usuario no se pudo actualizar", TypesResponse.ERROR), HttpStatus.BAD_REQUEST);
        }

        logger.info("Usuario actualizado correctamente - ID: {}", user.getIdUsuario());
        return new ResponseEntity<>(new Message(user, "Usuario actualizado correctamente", TypesResponse.SUCCESS), HttpStatus.OK);
    }

    @Transactional(rollbackFor = {SQLException.class})
    public ResponseEntity<Message> changeStatus(Integer id) {
        Optional<UserBean> userOptional = userRepository.findById(id);
        if (!userOptional.isPresent()) {
            return new ResponseEntity<>(new Message("Usuario no encontrado", TypesResponse.ERROR), HttpStatus.NOT_FOUND);
        }

        UserBean user = userOptional.get();
        user.setActivo(!user.getActivo());

        user = userRepository.saveAndFlush(user);
        if (user == null) {
            return new ResponseEntity<>(new Message("El estado del usuario no se pudo actualizar", TypesResponse.ERROR), HttpStatus.BAD_REQUEST);
        }

        String status = user.getActivo() ? "activado" : "desactivado";
        logger.info("Estado del usuario actualizado correctamente - ID: {}", user.getIdUsuario());
        return new ResponseEntity<>(new Message(user, "Usuario " + status + " correctamente", TypesResponse.SUCCESS), HttpStatus.OK);
    }

    @Transactional(readOnly = true)
    public ResponseEntity<Message> findByEmail(String email) {
        Optional<UserBean> user = userRepository.findByEmail(email);
        if (!user.isPresent()) {
            return new ResponseEntity<>(new Message("Usuario no encontrado", TypesResponse.ERROR), HttpStatus.NOT_FOUND);
        }
        return new ResponseEntity<>(new Message(user.get(), "Usuario encontrado", TypesResponse.SUCCESS), HttpStatus.OK);
    }

    @Transactional(readOnly = true)
    public boolean existsByEmail(String email) {
        return userRepository.existsByEmail(email);
    }

    @Transactional(readOnly = true)
    public List<UserBean> findByTipoUsuario(UserBean.TipoUsuario tipoUsuario) {
        return userRepository.findByTipoUsuario(tipoUsuario);
    }

    @Transactional(readOnly = true)
    public List<UserBean> findActiveUsers() {
        return userRepository.findByActivoTrue();
    }

    @Transactional(readOnly = true)
    public long countByTipoUsuario(UserBean.TipoUsuario tipoUsuario) {
        return userRepository.countByTipoUsuario(tipoUsuario);
    }

    @Transactional(readOnly = true)
    public Optional<UserBean> findByEmailSecurity(String email) {
        return userRepository.findByEmail(email);
    }
}