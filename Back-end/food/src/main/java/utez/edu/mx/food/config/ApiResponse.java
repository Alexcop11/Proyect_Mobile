package utez.edu.mx.food.config;


import org.springframework.http.HttpStatus;


public class ApiResponse {

    private Object data;
    private HttpStatus status;
    private boolean error;
    private String message;

    public ApiResponse(Object data, HttpStatus status) {
        this.data = data;
        this.status = status;
    }

    public ApiResponse(HttpStatus status, String message) {
        this.status = status;
        this.message = message;
        this.error = status.isError();
    }

    public ApiResponse(HttpStatus status, String message, Object data) {
        this.status = status;
        this.message = message;
        this.data = data;
        this.error = status.isError();
    }

    public ApiResponse() {
    }

    public Object getData() {
        return data;
    }

    public void setData(Object data) {
        this.data = data;
    }

    public HttpStatus getStatus() {
        return status;
    }

    public void setStatus(HttpStatus status) {
        this.status = status;
    }

    public boolean isError() {
        return error;
    }

    public void setError(boolean error) {
        this.error = error;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}