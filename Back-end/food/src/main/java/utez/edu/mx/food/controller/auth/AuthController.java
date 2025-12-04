package utez.edu.mx.food.controller.auth;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import utez.edu.mx.food.security.jwt.JwtProvider;
import utez.edu.mx.food.service.user.UserDTO;
import utez.edu.mx.food.service.user.UserService;
import utez.edu.mx.food.utils.Message;
import utez.edu.mx.food.utils.TypesResponse;

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
    public ResponseEntity<Message> login(@RequestBody LoginDTO loginDTO) {
        try {
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(loginDTO.getEmail(), loginDTO.getPassword())
            );
            SecurityContextHolder.getContext().setAuthentication(authentication);
            String token = jwtProvider.generateToken(authentication);

            return ResponseEntity.ok(new Message(token, "Login exitoso", TypesResponse.SUCCESS));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(new Message("Credenciales incorrectas", TypesResponse.ERROR));
        }
    }

    @PostMapping("/register")
    public ResponseEntity<Message> register(@RequestBody UserDTO userDTO) {
        userDTO.setTipoUsuario(utez.edu.mx.food.model.user.UserBean.TipoUsuario.NORMAL);
        userDTO.setActivo(true);

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
