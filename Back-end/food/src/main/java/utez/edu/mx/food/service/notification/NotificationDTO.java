package utez.edu.mx.food.service.notification;


import utez.edu.mx.food.model.notification.NotificationBean;

public class NotificationDTO {
    private Integer idNotificacion;
    private Integer idUsuario;
    private String titulo;
    private String mensaje;
    private NotificationBean.TipoNotificacion tipo;
    private Integer idRestaurante;
    private Boolean leida;

    public NotificationDTO() {
    }

    public NotificationDTO(Integer idNotificacion, Integer idUsuario, String titulo, String mensaje, NotificationBean.TipoNotificacion tipo, Integer idRestaurante, Boolean leida) {
        this.idNotificacion = idNotificacion;
        this.idUsuario = idUsuario;
        this.titulo = titulo;
        this.mensaje = mensaje;
        this.tipo = tipo;
        this.idRestaurante = idRestaurante;
        this.leida = leida;
    }

    public Integer getIdNotificacion() {
        return idNotificacion;
    }

    public void setIdNotificacion(Integer idNotificacion) {
        this.idNotificacion = idNotificacion;
    }

    public Integer getIdUsuario() {
        return idUsuario;
    }

    public void setIdUsuario(Integer idUsuario) {
        this.idUsuario = idUsuario;
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

    public NotificationBean.TipoNotificacion getTipo() {
        return tipo;
    }

    public void setTipo(NotificationBean.TipoNotificacion tipo) {
        this.tipo = tipo;
    }

    public Integer getIdRestaurante() {
        return idRestaurante;
    }

    public void setIdRestaurante(Integer idRestaurante) {
        this.idRestaurante = idRestaurante;
    }

    public Boolean getLeida() {
        return leida;
    }

    public void setLeida(Boolean leida) {
        this.leida = leida;
    }
}