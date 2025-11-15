package utez.edu.mx.food.model.photo;

import jakarta.persistence.*;
import utez.edu.mx.food.model.restaurant.RestaurantBean;

import java.time.LocalDateTime;

@Entity
@Table(name = "FOTO")
public class PhotoBean {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_foto")
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "id_restaurante", nullable = false)
    private RestaurantBean restaurante;

    @Column(name = "url", nullable = false, length = 500)
    private String url;

    @Column(name = "descripcion", length = 300)
    private String descripcion;

    @Column(name = "es_portada")
    private Boolean esPortada;

    @Column(name = "fecha_subida")
    private LocalDateTime fechaSubida;

    public PhotoBean() {
    }

    public PhotoBean(Integer id, RestaurantBean restaurante, String url, String descripcion, Boolean esPortada, LocalDateTime fechaSubida) {
        this.id = id;
        this.restaurante = restaurante;
        this.url = url;
        this.descripcion = descripcion;
        this.esPortada = esPortada;
        this.fechaSubida = fechaSubida;
    }

    public Integer getIdFoto() {
        return id;
    }

    public void setIdFoto(Integer id) {
        this.id = id;
    }

    public RestaurantBean getRestaurante() {
        return restaurante;
    }

    public void setRestaurante(RestaurantBean restaurante) {
        this.restaurante = restaurante;
    }

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public Boolean getEsPortada() {
        return esPortada;
    }

    public void setEsPortada(Boolean esPortada) {
        this.esPortada = esPortada;
    }

    public LocalDateTime getFechaSubida() {
        return fechaSubida;
    }

    public void setFechaSubida(LocalDateTime fechaSubida) {
        this.fechaSubida = fechaSubida;
    }
}