package utez.edu.mx.food.model.user;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<UserBean, Integer> {

    Optional<UserBean> findByEmail(String email);

    List<UserBean> findByTipoUsuario(UserBean.TipoUsuario tipoUsuario);

    List<UserBean> findByActivoTrue();

    List<UserBean> findByActivoFalse();

    @Query("SELECT u FROM UserBean u WHERE u.nombre LIKE %:nombre% OR u.apellido LIKE %:apellido%")
    List<UserBean> findByNombreOrApellidoContaining(@Param("nombre") String nombre, @Param("apellido") String apellido);

    boolean existsByEmail(String email);

    long countByTipoUsuario(UserBean.TipoUsuario tipoUsuario);
}
