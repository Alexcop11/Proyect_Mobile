package utez.edu.mx.food.service.rating;


public class RatingDTO {
    private Integer idCalificacion;
    private Integer idUsuario;
    private Integer idRestaurante;
    private Byte puntuacionComida;
    private Byte puntuacionServicio;
    private Byte puntuacionAmbiente;
    private String comentario;

    public RatingDTO() {
    }

    public RatingDTO(Integer idCalificacion, Integer idUsuario, Integer idRestaurante, Byte puntuacionComida, Byte puntuacionServicio, Byte puntuacionAmbiente, String comentario) {
        this.idCalificacion = idCalificacion;
        this.idUsuario = idUsuario;
        this.idRestaurante = idRestaurante;
        this.puntuacionComida = puntuacionComida;
        this.puntuacionServicio = puntuacionServicio;
        this.puntuacionAmbiente = puntuacionAmbiente;
        this.comentario = comentario;
    }

    public Integer getIdCalificacion() {
        return idCalificacion;
    }

    public void setIdCalificacion(Integer idCalificacion) {
        this.idCalificacion = idCalificacion;
    }

    public Integer getIdUsuario() {
        return idUsuario;
    }

    public void setIdUsuario(Integer idUsuario) {
        this.idUsuario = idUsuario;
    }

    public Integer getIdRestaurante() {
        return idRestaurante;
    }

    public void setIdRestaurante(Integer idRestaurante) {
        this.idRestaurante = idRestaurante;
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
}