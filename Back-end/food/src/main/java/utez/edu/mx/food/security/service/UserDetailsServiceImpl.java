package utez.edu.mx.food.security.service;


import org.springframework.context.annotation.Lazy;
import org.springframework.security.authentication.DisabledException;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import utez.edu.mx.food.model.user.UserBean;
import utez.edu.mx.food.security.entity.UserDetailsImpl;
import utez.edu.mx.food.service.user.UserService;

import java.util.Optional;

@Service
@Transactional
public class UserDetailsServiceImpl implements UserDetailsService {

    private final UserService service;

    public UserDetailsServiceImpl(@Lazy UserService service) {
        this.service = service;
    }

    @Override
    @Transactional(readOnly = true)
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        Optional<UserBean> foundUser = service.findByEmailSecurity(email);
        if (foundUser.isPresent()) {
            UserBean user = foundUser.get();

            // Verificar que el usuario esté activo
            if (!user.getActivo()) {
                throw new DisabledException("Usuario inactivo");
            }

            return UserDetailsImpl.build(user);
        }
        throw new UsernameNotFoundException("Usuario no encontrado: " + email);
    }
}
