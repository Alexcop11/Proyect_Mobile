package utez.edu.mx.food.controller.notification;

import utez.edu.mx.food.service.notification.NotificationDTO;
import utez.edu.mx.food.service.notification.NotificationService;
import utez.edu.mx.food.utils.Message;
import utez.edu.mx.food.utils.TypesResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;

@RestController
@RequestMapping("/api/notifications")
@CrossOrigin(origins = {"*"})
public class NotificationController {

    private static final Logger logger = LoggerFactory.getLogger(NotificationController.class);

    @Autowired
    private NotificationService notificationService;

    @GetMapping("/")
    public ResponseEntity<Message> getAllNotifications() {
        logger.info("Solicitando listado de todas las notificaciones");
        return notificationService.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Message> getNotificationById(@PathVariable Integer id) {
        logger.info("Solicitando notificación con ID: {}", id);
        return notificationService.findById(id);
    }

    @PostMapping("/")
    public ResponseEntity<Message> createNotification(@RequestBody NotificationDTO notificationDTO) {
        logger.info("Creando nueva notificación: {}", notificationDTO.getTitulo());
        return notificationService.save(notificationDTO);
    }

    @PutMapping("/")
    public ResponseEntity<Message> updateNotification(@RequestBody NotificationDTO notificationDTO) {
        logger.info("Actualizando notificación con ID: {}", notificationDTO.getIdNotificacion());
        return notificationService.update(notificationDTO);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Message> deleteNotification(@PathVariable Integer id) {
        logger.info("Eliminando notificación con ID: {}", id);
        return notificationService.delete(id);
    }

    @PatchMapping("/{id}/read")
    public ResponseEntity<Message> markAsRead(@PathVariable Integer id) {
        logger.info("Marcando notificación como leída - ID: {}", id);
        return notificationService.markAsRead(id);
    }

    @PatchMapping("/user/{userId}/read-all")
    public ResponseEntity<Message> markAllAsReadByUser(@PathVariable Integer userId) {
        logger.info("Marcando todas las notificaciones como leídas para el usuario: {}", userId);
        return notificationService.markAllAsReadByUsuario(userId);
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<Message> getNotificationsByUser(@PathVariable Integer userId) {
        logger.info("Solicitando notificaciones del usuario con ID: {}", userId);
        return notificationService.findByUsuario(userId);
    }

    @GetMapping("/user/{userId}/unread")
    public ResponseEntity<Message> getUnreadNotificationsByUser(@PathVariable Integer userId) {
        logger.info("Solicitando notificaciones no leídas del usuario con ID: {}", userId);
        return notificationService.findUnreadByUsuario(userId);
    }

    @GetMapping("/user/{userId}/unread/count")
    public ResponseEntity<Message> countUnreadNotificationsByUser(@PathVariable Integer userId) {
        logger.info("Contando notificaciones no leídas del usuario con ID: {}", userId);
        return notificationService.countUnreadByUsuario(userId);
    }

    @GetMapping("/type/{tipo}")
    public ResponseEntity<Message> getNotificationsByType(@PathVariable String tipo) {
        logger.info("Solicitando notificaciones por tipo: {}", tipo);
        try {
            utez.edu.mx.food.model.notification.NotificationBean.TipoNotificacion tipoNotificacion =
                    utez.edu.mx.food.model.notification.NotificationBean.TipoNotificacion.valueOf(tipo.toUpperCase());
            return notificationService.findByTipo(tipoNotificacion);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(new Message("Tipo de notificación no válido", TypesResponse.WARNING));
        }
    }

    @GetMapping("/date-range")
    public ResponseEntity<Message> getNotificationsByDateRange(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endDate) {
        logger.info("Solicitando notificaciones entre {} y {}", startDate, endDate);
        return notificationService.findByFechaCreacionBetween(startDate, endDate);
    }
}
