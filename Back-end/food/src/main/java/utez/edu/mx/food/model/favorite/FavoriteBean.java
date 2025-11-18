package utez.edu.mx.food.model.favorite;


import jakarta.persistence.*;
import utez.edu.mx.food.model.restaurant.RestaurantBean;
import utez.edu.mx.food.model.user.UserBean;

import java.time.LocalDateTime;

@Entity
@Table(name = "FAVORITO",
        uniqueConstraints = @UniqueConstraint(columnNames = {"id_usuario", "id_restaurante"}))
public class FavoriteBean {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_favorito")
    private Integer idFavorito;

    @ManyToOne
    @JoinColumn(name = "id_usuario", nullable = false)
    private UserBean usuario;

    @ManyToOne
    @JoinColumn(name = "id_restaurante", nullable = false)
    private RestaurantBean restaurante;

    @Column(name = "fecha_agregado")
    private LocalDateTime fechaAgregado;

    // Constructores
    public FavoriteBean() {
    }

    public FavoriteBean(Integer idFavorito, UserBean usuario, RestaurantBean restaurante, LocalDateTime fechaAgregado) {
        this.idFavorito = idFavorito;
        this.usuario = usuario;
        this.restaurante = restaurante;
        this.fechaAgregado = fechaAgregado;
    }

    // Getters y Setters
    public Integer getIdFavorito() {
        return idFavorito;
    }

    public void setIdFavorito(Integer idFavorito) {
        this.idFavorito = idFavorito;
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

    public LocalDateTime getFechaAgregado() {
        return fechaAgregado;
    }

    public void setFechaAgregado(LocalDateTime fechaAgregado) {
        this.fechaAgregado = fechaAgregado;
    }
}
