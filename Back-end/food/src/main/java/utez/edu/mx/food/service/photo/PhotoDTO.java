package utez.edu.mx.food.service.photo;

public class PhotoDTO {
    private Integer idFoto;
    private Integer idRestaurante;
    private String url;
    private String descripcion;
    private Boolean esPortada;

    public PhotoDTO() {}

    public PhotoDTO(Integer idRestaurante, String descripcion, Boolean esPortada) {
        this.idRestaurante = idRestaurante;
        this.descripcion = descripcion;
        this.esPortada = esPortada;
    }

    public Integer getIdFoto() { return idFoto; }
    public void setIdFoto(Integer idFoto) { this.idFoto = idFoto; }

    public Integer getIdRestaurante() { return idRestaurante; }
    public void setIdRestaurante(Integer idRestaurante) { this.idRestaurante = idRestaurante; }

    public String getUrl() { return url; }
    public void setUrl(String url) { this.url = url; }

    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }

    public Boolean getEsPortada() { return esPortada; }
    public void setEsPortada(Boolean esPortada) { this.esPortada = esPortada; }
}