package utez.edu.mx.food.service.user;


import utez.edu.mx.food.model.user.UserBean;

import java.time.LocalDateTime;

public class UserDTO {
    private Integer idUsuario;
    private String email;
    private String passwordHash;
    private UserBean.TipoUsuario tipoUsuario;
    private String nombre;
    private String apellido;
    private String telefono;
    private Boolean activo;

    public UserDTO() {
    }

    public UserDTO(Integer idUsuario, String email, String passwordHash, UserBean.TipoUsuario tipoUsuario,
                   String nombre, String apellido, String telefono, Boolean activo) {
        this.idUsuario = idUsuario;
        this.email = email;
        this.passwordHash = passwordHash;
        this.tipoUsuario = tipoUsuario;
        this.nombre = nombre;
        this.apellido = apellido;
        this.telefono = telefono;
        this.activo = activo;
    }

    public Integer getIdUsuario() {
        return idUsuario;
    }

    public void setIdUsuario(Integer idUsuario) {
        this.idUsuario = idUsuario;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public UserBean.TipoUsuario getTipoUsuario() {
        return tipoUsuario;
    }

    public void setTipoUsuario(UserBean.TipoUsuario tipoUsuario) {
        this.tipoUsuario = tipoUsuario;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getApellido() {
        return apellido;
    }

    public void setApellido(String apellido) {
        this.apellido = apellido;
    }

    public String getTelefono() {
        return telefono;
    }

    public void setTelefono(String telefono) {
        this.telefono = telefono;
    }

    public Boolean getActivo() {
        return activo;
    }

    public void setActivo(Boolean activo) {
        this.activo = activo;
    }
}
