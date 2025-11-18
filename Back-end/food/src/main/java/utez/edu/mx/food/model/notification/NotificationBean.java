package utez.edu.mx.food.model.notification;


import jakarta.persistence.*;
import utez.edu.mx.food.model.restaurant.RestaurantBean;
import utez.edu.mx.food.model.user.UserBean;

import java.time.LocalDateTime;

@Entity
@Table(name = "NOTIFICACION")
public class NotificationBean {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_notificacion")
    private Integer idNotificacion;

    @ManyToOne
    @JoinColumn(name = "id_usuario", nullable = false)
    private UserBean usuario;

    @Column(name = "titulo", nullable = false, length = 200)
    private String titulo;

    @Column(name = "mensaje", nullable = false, columnDefinition = "TEXT")
    private String mensaje;

    @Enumerated(EnumType.STRING)
    @Column(name = "tipo", nullable = false)
    private TipoNotificacion tipo;

    @ManyToOne
    @JoinColumn(name = "id_restaurante")
    private RestaurantBean restaurante;

    @Column(name = "leida")
    private Boolean leida;

    @Column(name = "fecha_creacion")
    private LocalDateTime fechaCreacion;

    @Column(name = "fecha_envio")
    private LocalDateTime fechaEnvio;

    public NotificationBean() {
    }

    public NotificationBean(Integer idNotificacion, UserBean usuario, String titulo, String mensaje,
                        TipoNotificacion tipo, RestaurantBean restaurante, Boolean leida,
                        LocalDateTime fechaCreacion, LocalDateTime fechaEnvio) {
        this.idNotificacion = idNotificacion;
        this.usuario = usuario;
        this.titulo = titulo;
        this.mensaje = mensaje;
        this.tipo = tipo;
        this.restaurante = restaurante;
        this.leida = leida;
        this.fechaCreacion = fechaCreacion;
        this.fechaEnvio = fechaEnvio;
    }

    public Integer getIdNotificacion() {
        return idNotificacion;
    }

    public void setIdNotificacion(Integer idNotificacion) {
        this.idNotificacion = idNotificacion;
    }

    public UserBean getUsuario() {
        return usuario;
    }

    public void setUsuario(UserBean usuario) {
        this.usuario = usuario;
    }

    public String getTitulo() {
        return titulo;
    }

    public void setTitulo(String titulo) {
        this.titulo = titulo;
    }

    public String getMensaje() {
        return mensaje;
    }

    public void setMensaje(String mensaje) {
        this.mensaje = mensaje;
    }

    public TipoNotificacion getTipo() {
        return tipo;
    }

    public void setTipo(TipoNotificacion tipo) {
        this.tipo = tipo;
    }

    public RestaurantBean getRestaurante() {
        return restaurante;
    }

    public void setRestaurante(RestaurantBean restaurante) {
        this.restaurante = restaurante;
    }

    public Boolean getLeida() {
        return leida;
    }

    public void setLeida(Boolean leida) {
        this.leida = leida;
    }

    public LocalDateTime getFechaCreacion() {
        return fechaCreacion;
    }

    public void setFechaCreacion(LocalDateTime fechaCreacion) {
        this.fechaCreacion = fechaCreacion;
    }

    public LocalDateTime getFechaEnvio() {
        return fechaEnvio;
    }

    public void setFechaEnvio(LocalDateTime fechaEnvio) {
        this.fechaEnvio = fechaEnvio;
    }

    public enum TipoNotificacion {
        NUEVO_RESTAURANTE, ACTUALIZACION_MENU, PROMOCION, SISTEMA
    }
}