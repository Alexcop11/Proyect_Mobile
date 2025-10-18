package utez.edu.mx.food.service.favorite;


public class FavoriteDTO {
    private Integer idFavorito;
    private Integer idUsuario;
    private Integer idRestaurante;

    public FavoriteDTO() {
    }

    public FavoriteDTO(Integer idFavorito, Integer idUsuario, Integer idRestaurante) {
        this.idFavorito = idFavorito;
        this.idUsuario = idUsuario;
        this.idRestaurante = idRestaurante;
    }

    public Integer getIdFavorito() {
        return idFavorito;
    }

    public void setIdFavorito(Integer idFavorito) {
        this.idFavorito = idFavorito;
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
}