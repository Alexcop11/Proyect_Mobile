package utez.edu.mx.food.controller.auth;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import utez.edu.mx.food.config.ApiResponse;
import utez.edu.mx.food.security.entity.UserDetailsImpl;
import utez.edu.mx.food.security.jwt.JwtProvider;
import utez.edu.mx.food.service.user.UserDTO;
import utez.edu.mx.food.service.user.UserService;
import utez.edu.mx.food.utils.Message;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = {"*"})
public class AuthController {

    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private JwtProvider jwtProvider;

    @Autowired
    private UserService userService;

    @PostMapping("/login")
    public ResponseEntity<ApiResponse> login(@RequestBody LoginDTO loginDTO) {
        try {
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(loginDTO.getEmail(), loginDTO.getPassword())
            );
            SecurityContextHolder.getContext().setAuthentication(authentication);

            UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
            String token = jwtProvider.generateToken(authentication);

            Map<String, Object> responseData = new HashMap<>();
            responseData.put("token", token);
            responseData.put("type", "Bearer");
            responseData.put("email", userDetails.getUsername());

            String role = userDetails.getAuthorities().stream()
                    .map(authority -> authority.getAuthority().replace("ROLE_", ""))
                    .findFirst()
                    .orElse("NORMAL");
            responseData.put("role", role);

            return ResponseEntity.ok(new ApiResponse(responseData, HttpStatus.OK));

        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(new ApiResponse(HttpStatus.UNAUTHORIZED, "Credenciales incorrectas"));
        }
    }

    @PostMapping("/register")
    public ResponseEntity<Message> register(@RequestBody UserDTO userDTO) {
        userDTO.setActivo(Boolean.valueOf(true));

        return userService.save(userDTO);
    }

    public static class LoginDTO {
        private String email;
        private String password;

        public String getEmail() {
            return email;
        }

        public void setEmail(String email) {
            this.email = email;
        }

        public String getPassword() {
            return password;
        }

        public void setPassword(String password) {
            this.password = password;
        }
    }
}
