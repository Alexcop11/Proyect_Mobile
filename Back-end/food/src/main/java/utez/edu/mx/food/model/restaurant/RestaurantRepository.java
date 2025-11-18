package utez.edu.mx.food.model.restaurant;


import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import utez.edu.mx.food.model.user.UserBean;

import java.util.List;
import java.util.Optional;

@Repository
public interface RestaurantRepository extends JpaRepository<RestaurantBean, Integer> {

    List<RestaurantBean> findByUsuarioPropietario(UserBean usuarioPropietario);

    Optional<RestaurantBean> findByUsuarioPropietarioEmail(String email);

    List<RestaurantBean> findByActivoTrue();

    List<RestaurantBean> findByActivoFalse();

    List<RestaurantBean> findByCategoria(String categoria);

    @Query("SELECT r FROM RestaurantBean r WHERE r.nombre LIKE %:nombre%")
    List<RestaurantBean> findByNombreContaining(@Param("nombre") String nombre);

    @Query("SELECT r FROM RestaurantBean r WHERE r.precioPromedio BETWEEN :precioMin AND :precioMax")
    List<RestaurantBean> findByPrecioPromedioBetween(@Param("precioMin") Double precioMin, @Param("precioMax") Double precioMax);

    List<RestaurantBean> findByUsuarioPropietarioAndActivoTrue(UserBean usuarioPropietario);

    long countByUsuarioPropietario(UserBean usuarioPropietario);
}
