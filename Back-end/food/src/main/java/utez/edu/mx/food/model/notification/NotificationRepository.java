package utez.edu.mx.food.model.notification;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import utez.edu.mx.food.model.user.UserBean;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface NotificationRepository extends JpaRepository<NotificationBean, Integer> {

    List<NotificationBean> findByUsuario(UserBean usuario);

    List<NotificationBean> findByUsuarioAndLeidaFalse(UserBean usuario);

    List<NotificationBean> findByUsuarioAndLeidaTrue(UserBean usuario);

    List<NotificationBean> findByTipo(NotificationBean.TipoNotificacion tipo);

    @Query("SELECT n FROM NotificationBean n WHERE n.fechaCreacion BETWEEN :startDate AND :endDate")
    List<NotificationBean> findByFechaCreacionBetween(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);

    long countByUsuarioAndLeidaFalse(UserBean usuario);

    @Query("SELECT n FROM NotificationBean n WHERE n.usuario.idUsuario = :userId ORDER BY n.fechaCreacion DESC")
    List<NotificationBean> findByUserIdOrderByFechaCreacionDesc(@Param("userId") Integer userId);
}