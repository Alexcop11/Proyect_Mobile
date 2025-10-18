package utez.edu.mx.food.security;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.web.access.AccessDeniedHandler;
import utez.edu.mx.food.config.ApiResponse;

import java.io.IOException;

public class CustomAccessDeniedHandler implements AccessDeniedHandler {

    @Override
    public void handle(HttpServletRequest request, HttpServletResponse response, AccessDeniedException accessDeniedException) throws IOException {
        ApiResponse apiResponse = new ApiResponse(HttpStatus.FORBIDDEN, "Acceso denegado: No tienes permisos para acceder a este recurso");

        response.setContentType("application/json");
        response.setStatus(HttpStatus.FORBIDDEN.value());

        ObjectMapper objectMapper = new ObjectMapper();
        response.getWriter().write(objectMapper.writeValueAsString(apiResponse));
    }
}
