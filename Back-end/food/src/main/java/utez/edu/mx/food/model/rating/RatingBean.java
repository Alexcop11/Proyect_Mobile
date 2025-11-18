package utez.edu.mx.food.model.rating;

import jakarta.persistence.*;
import org.springframework.security.core.userdetails.User;
import utez.edu.mx.food.model.restaurant.RestaurantBean;
import utez.edu.mx.food.model.user.UserBean;

import java.time.LocalDateTime;

@Entity
@Table(name = "CALIFICACION",
        uniqueConstraints = @UniqueConstraint(columnNames = {"id_usuario", "id_restaurante"}))
public class RatingBean {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_calificacion")
    private Integer idCalificacion;

    @ManyToOne
    @JoinColumn(name = "id_usuario", nullable = false)
    private UserBean usuario;

    @ManyToOne
    @JoinColumn(name = "id_restaurante", nullable = false)
    private RestaurantBean restaurante;

    @Column(name = "puntuacion_comida", nullable = false)
    private Byte puntuacionComida;

    @Column(name = "puntuacion_servicio", nullable = false)
    private Byte puntuacionServicio;

    @Column(name = "puntuacion_ambiente", nullable = false)
    private Byte puntuacionAmbiente;

    @Column(name = "comentario", columnDefinition = "TEXT")
    private String comentario;

    @Column(name = "fecha_calificacion")
    private LocalDateTime fechaCalificacion;

    // Constructores
    public RatingBean() {
    }

    public RatingBean(Integer idCalificacion, UserBean usuario, RestaurantBean restaurante,
                        Byte puntuacionComida, Byte puntuacionServicio, Byte puntuacionAmbiente,
                        String comentario, LocalDateTime fechaCalificacion) {
        this.idCalificacion = idCalificacion;
        this.usuario = usuario;
        this.restaurante = restaurante;
        this.puntuacionComida = puntuacionComida;
        this.puntuacionServicio = puntuacionServicio;
        this.puntuacionAmbiente = puntuacionAmbiente;
        this.comentario = comentario;
        this.fechaCalificacion = fechaCalificacion;
    }

    // Getters y Setters
    public Integer getIdCalificacion() {
        return idCalificacion;
    }

    public void setIdCalificacion(Integer idCalificacion) {
        this.idCalificacion = idCalificacion;
    }

    public UserBean getUsuario() {
        return usuario;
    }

    public void setUsuario(UserBean usuario) {
        this.usuario = usuario;
    }

    public RestaurantBean getRestaurante() {
        return restaurante;
    }

    public void setRestaurante(RestaurantBean restaurante) {
        this.restaurante = restaurante;
    }

    public Byte getPuntuacionComida() {
        return puntuacionComida;
    }

    public void setPuntuacionComida(Byte puntuacionComida) {
        this.puntuacionComida = puntuacionComida;
    }

    public Byte getPuntuacionServicio() {
        return puntuacionServicio;
    }

    public void setPuntuacionServicio(Byte puntuacionServicio) {
        this.puntuacionServicio = puntuacionServicio;
    }

    public Byte getPuntuacionAmbiente() {
        return puntuacionAmbiente;
    }

    public void setPuntuacionAmbiente(Byte puntuacionAmbiente) {
        this.puntuacionAmbiente = puntuacionAmbiente;
    }

    public String getComentario() {
        return comentario;
    }

    public void setComentario(String comentario) {
        this.comentario = comentario;
    }

    public LocalDateTime getFechaCalificacion() {
        return fechaCalificacion;
    }

    public void setFechaCalificacion(LocalDateTime fechaCalificacion) {
        this.fechaCalificacion = fechaCalificacion;
    }
}