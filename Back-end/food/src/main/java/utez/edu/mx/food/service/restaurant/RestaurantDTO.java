package utez.edu.mx.food.service.restaurant;


import java.math.BigDecimal;
import java.time.LocalTime;

public class RestaurantDTO {
    private Integer idRestaurante;
    private Integer idUsuarioPropietario;
    private String nombre;
    private String descripcion;
    private String direccion;
    private BigDecimal latitud;
    private BigDecimal longitud;
    private String telefono;
    private LocalTime horarioApertura;
    private LocalTime horarioCierre;
    private BigDecimal precioPromedio;
    private String categoria;
    private String menuUrl;
    private Boolean activo;

    public RestaurantDTO() {
    }

    public RestaurantDTO(Integer idRestaurante, Integer idUsuarioPropietario, String nombre, String descripcion, String direccion, BigDecimal latitud, BigDecimal longitud, String telefono, LocalTime horarioApertura, LocalTime horarioCierre, BigDecimal precioPromedio, String categoria, String menuUrl, Boolean activo) {
        this.idRestaurante = idRestaurante;
        this.idUsuarioPropietario = idUsuarioPropietario;
        this.nombre = nombre;
        this.descripcion = descripcion;
        this.direccion = direccion;
        this.latitud = latitud;
        this.longitud = longitud;
        this.telefono = telefono;
        this.horarioApertura = horarioApertura;
        this.horarioCierre = horarioCierre;
        this.precioPromedio = precioPromedio;
        this.categoria = categoria;
        this.menuUrl = menuUrl;
        this.activo = activo;
    }

    public Integer getIdRestaurante() {
        return idRestaurante;
    }

    public void setIdRestaurante(Integer idRestaurante) {
        this.idRestaurante = idRestaurante;
    }

    public Integer getIdUsuarioPropietario() {
        return idUsuarioPropietario;
    }

    public void setIdUsuarioPropietario(Integer idUsuarioPropietario) {
        this.idUsuarioPropietario = idUsuarioPropietario;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public String getDireccion() {
        return direccion;
    }

    public void setDireccion(String direccion) {
        this.direccion = direccion;
    }

    public BigDecimal getLatitud() {
        return latitud;
    }

    public void setLatitud(BigDecimal latitud) {
        this.latitud = latitud;
    }

    public BigDecimal getLongitud() {
        return longitud;
    }

    public void setLongitud(BigDecimal longitud) {
        this.longitud = longitud;
    }

    public String getTelefono() {
        return telefono;
    }

    public void setTelefono(String telefono) {
        this.telefono = telefono;
    }

    public LocalTime getHorarioApertura() {
        return horarioApertura;
    }

    public void setHorarioApertura(LocalTime horarioApertura) {
        this.horarioApertura = horarioApertura;
    }

    public LocalTime getHorarioCierre() {
        return horarioCierre;
    }

    public void setHorarioCierre(LocalTime horarioCierre) {
        this.horarioCierre = horarioCierre;
    }

    public BigDecimal getPrecioPromedio() {
        return precioPromedio;
    }

    public void setPrecioPromedio(BigDecimal precioPromedio) {
        this.precioPromedio = precioPromedio;
    }

    public String getCategoria() {
        return categoria;
    }

    public void setCategoria(String categoria) {
        this.categoria = categoria;
    }

    public String getMenuUrl() {
        return menuUrl;
    }

    public void setMenuUrl(String menuUrl) {
        this.menuUrl = menuUrl;
    }

    public Boolean getActivo() {
        return activo;
    }

    public void setActivo(Boolean activo) {
        this.activo = activo;
    }
}
