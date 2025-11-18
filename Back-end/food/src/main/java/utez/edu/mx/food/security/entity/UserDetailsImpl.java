package utez.edu.mx.food.security.entity;


import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import utez.edu.mx.food.model.user.UserBean;

import java.util.Collection;
import java.util.Collections;

public class UserDetailsImpl implements UserDetails {

    private String username;
    private String password;
    private boolean isBlocked;
    private boolean isEnabled;
    private Collection<? extends GrantedAuthority> authorities;

    public UserDetailsImpl(String username, String password, boolean isBlocked, boolean isEnabled, Collection<? extends GrantedAuthority> authorities) {
        this.username = username;
        this.password = password;
        this.isBlocked = isBlocked;
        this.isEnabled = isEnabled;
        this.authorities = authorities;
    }

    public static UserDetailsImpl build(UserBean user) {
        // Convertir el tipo de usuario a un rol de Spring Security
        String role = "ROLE_" + user.getTipoUsuario().name();
        GrantedAuthority authority = new SimpleGrantedAuthority(role);

        return new UserDetailsImpl(
                user.getEmail(),
                user.getPasswordHash(),
                false, // No tenemos campo blocked en UserBean
                user.getActivo() != null ? user.getActivo() : true,
                Collections.singleton(authority)
        );
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return authorities;
    }

    @Override
    public String getPassword() {
        return password;
    }

    @Override
    public String getUsername() {
        return username;
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return !isBlocked;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return isEnabled;
    }
}
