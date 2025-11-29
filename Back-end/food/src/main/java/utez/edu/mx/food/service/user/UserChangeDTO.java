package utez.edu.mx.food.service.user;


public class UserChangeDTO {
    private Integer id;
    private String password;

    public UserChangeDTO() {
    }

    public UserChangeDTO(String password, Integer id) {
        this.password = password;
        this.id = id;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
}
