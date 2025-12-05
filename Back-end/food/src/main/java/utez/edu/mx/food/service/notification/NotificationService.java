package utez.edu.mx.food.service.notification;

import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.Notification;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import utez.edu.mx.food.model.notification.NotificationBean;
import utez.edu.mx.food.model.notification.NotificationRepository;
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
public class NotificationService {

    private static final Logger logger = LoggerFactory.getLogger(NotificationService.class);

    private final NotificationRepository notificationRepository;
    private final UserRepository userRepository;
    private final RestaurantRepository restaurantRepository;

    @Autowired
    public NotificationService(NotificationRepository notificationRepository, UserRepository userRepository,
                               RestaurantRepository restaurantRepository) {
        this.notificationRepository = notificationRepository;
        this.userRepository = userRepository;
        this.restaurantRepository = restaurantRepository;
    }

    @Transactional(readOnly = true)
    public ResponseEntity<Message> findAll() {
        List<NotificationBean> notifications = notificationRepository.findAll();
        logger.info("Búsqueda de notificaciones realizada correctamente");
        return new ResponseEntity<>(new Message(notifications, "Listado de notificaciones", TypesResponse.SUCCESS), HttpStatus.OK);
    }

    @Transactional(readOnly = true)
    public ResponseEntity<Message> findById(Integer id) {
        Optional<NotificationBean> notification = notificationRepository.findById(id);
        if (!notification.isPresent()) {
            return new ResponseEntity<>(new Message("Notificación no encontrada", TypesResponse.ERROR), HttpStatus.NOT_FOUND);
        }
        logger.info("Notificación encontrada correctamente");
        return new ResponseEntity<>(new Message(notification.get(), "Notificación encontrada", TypesResponse.SUCCESS), HttpStatus.OK);
    }

    @Transactional
    public ResponseEntity<Message> save(NotificationBean notification) {
        try {
            notification.setFechaCreacion(LocalDateTime.now());
            notification.setLeida(false);

            UserBean usuario = userRepository.findById(notification.getUsuario().getIdUsuario())
                    .orElse(null);

            if (usuario == null)
                return new ResponseEntity<>(new Message("Usuario no encontrado", TypesResponse.SUCCESS), HttpStatus.BAD_REQUEST);

            NotificationBean saved = notificationRepository.save(notification);

            boolean enviado = sendPush(usuario, saved);

            if (enviado) {
                saved.setFechaEnvio(LocalDateTime.now());
                notificationRepository.save(saved);
                return new ResponseEntity<>(new Message(saved,"Notificación enviada y guardada", TypesResponse.SUCCESS),
                        HttpStatus.OK);
            } else {
                return new ResponseEntity<>(new Message(saved,"Notificación guardada, pero no enviada (sin pushToken o error FCM)", TypesResponse.WARNING),
                        HttpStatus.OK);
            }

        } catch (Exception e) {
            e.printStackTrace();
            return new ResponseEntity<>(new Message("Error al guardar notificación", TypesResponse.ERROR),
                    HttpStatus.BAD_REQUEST);
        }
    }


    @Transactional(rollbackFor = {SQLException.class})
    public ResponseEntity<Message> update(NotificationDTO dto) {
        Optional<NotificationBean> notificationOptional = notificationRepository.findById(dto.getIdNotificacion());
        if (!notificationOptional.isPresent()) {
            return new ResponseEntity<>(new Message("Notificación no encontrada", TypesResponse.ERROR), HttpStatus.NOT_FOUND);
        }

        NotificationBean notification = notificationOptional.get();

        // Validaciones
        if (dto.getTitulo() == null || dto.getTitulo().trim().isEmpty()) {
            return new ResponseEntity<>(new Message("El título no puede estar vacío", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        if (dto.getTitulo().length() > 200) {
            return new ResponseEntity<>(new Message("El título no puede exceder 200 caracteres", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        if (dto.getMensaje() == null || dto.getMensaje().trim().isEmpty()) {
            return new ResponseEntity<>(new Message("El mensaje no puede estar vacío", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        if (dto.getMensaje().length() > 1000) {
            return new ResponseEntity<>(new Message("El mensaje no puede exceder 1000 caracteres", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        // Actualizar campos
        notification.setTitulo(dto.getTitulo());
        notification.setMensaje(dto.getMensaje());
        if (dto.getLeida() != null) {
            notification.setLeida(dto.getLeida());
        }

        notification = notificationRepository.saveAndFlush(notification);
        if (notification == null) {
            return new ResponseEntity<>(new Message("La notificación no se pudo actualizar", TypesResponse.ERROR), HttpStatus.BAD_REQUEST);
        }

        logger.info("Notificación actualizada correctamente - ID: {}", notification.getIdNotificacion());
        return new ResponseEntity<>(new Message(notification, "Notificación actualizada correctamente", TypesResponse.SUCCESS), HttpStatus.OK);
    }

    @Transactional(rollbackFor = {SQLException.class})
    public ResponseEntity<Message> delete(Integer id) {
        Optional<NotificationBean> notificationOptional = notificationRepository.findById(id);
        if (!notificationOptional.isPresent()) {
            return new ResponseEntity<>(new Message("Notificación no encontrada", TypesResponse.ERROR), HttpStatus.NOT_FOUND);
        }

        notificationRepository.deleteById(id);
        logger.info("Notificación eliminada correctamente - ID: {}", id);
        return new ResponseEntity<>(new Message("Notificación eliminada correctamente", TypesResponse.SUCCESS), HttpStatus.OK);
    }

    @Transactional(rollbackFor = {SQLException.class})
    public ResponseEntity<Message> markAsRead(Integer id) {
        Optional<NotificationBean> notificationOptional = notificationRepository.findById(id);
        if (!notificationOptional.isPresent()) {
            return new ResponseEntity<>(new Message("Notificación no encontrada", TypesResponse.ERROR), HttpStatus.NOT_FOUND);
        }

        NotificationBean notification = notificationOptional.get();
        if (notification.getLeida()) {
            return new ResponseEntity<>(new Message("La notificación ya estaba marcada como leída", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        notification.setLeida(true);
        notification = notificationRepository.saveAndFlush(notification);

        if (notification == null) {
            return new ResponseEntity<>(new Message("No se pudo marcar la notificación como leída", TypesResponse.ERROR), HttpStatus.BAD_REQUEST);
        }

        logger.info("Notificación marcada como leída - ID: {}", id);
        return new ResponseEntity<>(new Message(notification, "Notificación marcada como leída", TypesResponse.SUCCESS), HttpStatus.OK);
    }

    @Transactional(rollbackFor = {SQLException.class})
    public ResponseEntity<Message> markAllAsReadByUsuario(Integer userId) {
        Optional<UserBean> usuario = userRepository.findById(userId);
        if (!usuario.isPresent()) {
            return new ResponseEntity<>(new Message("Usuario no encontrado", TypesResponse.ERROR), HttpStatus.NOT_FOUND);
        }

        List<NotificationBean> unreadNotifications = notificationRepository.findByUsuarioAndLeidaFalse(usuario.get());
        if (unreadNotifications.isEmpty()) {
            return new ResponseEntity<>(new Message("No hay notificaciones sin leer", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        unreadNotifications.forEach(notification -> notification.setLeida(true));
        List<NotificationBean> updatedNotifications = notificationRepository.saveAll(unreadNotifications);

        logger.info("Todas las notificaciones marcadas como leídas - Usuario ID: {}", userId);
        return new ResponseEntity<>(new Message(updatedNotifications, "Todas las notificaciones marcadas como leídas", TypesResponse.SUCCESS), HttpStatus.OK);
    }

    @Transactional(readOnly = true)
    public ResponseEntity<Message> findByUsuario(Integer userId) {
        Optional<UserBean> usuario = userRepository.findById(userId);
        if (!usuario.isPresent()) {
            return new ResponseEntity<>(new Message("Usuario no encontrado", TypesResponse.ERROR), HttpStatus.NOT_FOUND);
        }

        List<NotificationBean> notifications = notificationRepository.findByUsuario(usuario.get());
        logger.info("Notificaciones del usuario encontradas correctamente - Usuario ID: {}", userId);
        return new ResponseEntity<>(new Message(notifications, "Notificaciones del usuario", TypesResponse.SUCCESS), HttpStatus.OK);
    }

    @Transactional(readOnly = true)
    public ResponseEntity<Message> findUnreadByUsuario(Integer userId) {
        Optional<UserBean> usuario = userRepository.findById(userId);
        if (!usuario.isPresent()) {
            return new ResponseEntity<>(new Message("Usuario no encontrado", TypesResponse.ERROR), HttpStatus.NOT_FOUND);
        }

        List<NotificationBean> notifications = notificationRepository.findByUsuarioAndLeidaFalse(usuario.get());
        return new ResponseEntity<>(new Message(notifications, "Notificaciones sin leer del usuario", TypesResponse.SUCCESS), HttpStatus.OK);
    }

    @Transactional(readOnly = true)
    public ResponseEntity<Message> countUnreadByUsuario(Integer userId) {
        Optional<UserBean> usuario = userRepository.findById(userId);
        if (!usuario.isPresent()) {
            return new ResponseEntity<>(new Message("Usuario no encontrado", TypesResponse.ERROR), HttpStatus.NOT_FOUND);
        }

        long count = notificationRepository.countByUsuarioAndLeidaFalse(usuario.get());
        return new ResponseEntity<>(new Message(count, "Cantidad de notificaciones sin leer", TypesResponse.SUCCESS), HttpStatus.OK);
    }

    @Transactional(readOnly = true)
    public ResponseEntity<Message> findByTipo(NotificationBean.TipoNotificacion tipo) {
        List<NotificationBean> notifications = notificationRepository.findByTipo(tipo);
        return new ResponseEntity<>(new Message(notifications, "Notificaciones por tipo", TypesResponse.SUCCESS), HttpStatus.OK);
    }

    @Transactional(readOnly = true)
    public ResponseEntity<Message> findByFechaCreacionBetween(LocalDateTime startDate, LocalDateTime endDate) {
        if (startDate == null || endDate == null) {
            return new ResponseEntity<>(new Message("Las fechas de inicio y fin son requeridas", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        if (startDate.isAfter(endDate)) {
            return new ResponseEntity<>(new Message("La fecha de inicio no puede ser posterior a la fecha de fin", TypesResponse.WARNING), HttpStatus.BAD_REQUEST);
        }

        List<NotificationBean> notifications = notificationRepository.findByFechaCreacionBetween(startDate, endDate);
        return new ResponseEntity<>(new Message(notifications, "Notificaciones por rango de fechas", TypesResponse.SUCCESS), HttpStatus.OK);
    }



    public boolean sendPush(UserBean usuario, NotificationBean noti) {
        try {
            if (usuario.getPushToken() == null || usuario.getPushToken().isEmpty()) {
                System.out.println("⚠ Usuario sin pushToken, no se envió push");
                return false;
            }

            com.google.firebase.messaging.Message message =
                    com.google.firebase.messaging.Message.builder()
                            .setToken(usuario.getPushToken())
                            .setNotification(
                                    com.google.firebase.messaging.Notification.builder()
                                            .setTitle(noti.getTitulo())
                                            .setBody(noti.getMensaje())
                                            .build()
                            )
                            .putData("tipo", noti.getTipo().name())
                            .putData("idNotificacion", noti.getIdNotificacion() + "")
                            .build();


            FirebaseMessaging.getInstance().send(message);
            return true;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }


}