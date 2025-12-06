package utez.edu.mx.food.service.user;

public class UserPushTokenDTO {
    private Integer id;
    private String pushToken;

    public UserPushTokenDTO() {}

    public UserPushTokenDTO(Integer id, String pushToken) {
        this.id = id;
        this.pushToken = pushToken;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getPushToken() {
        return pushToken;
    }

    public void setPushToken(String pushToken) {
        this.pushToken = pushToken;
    }
}
