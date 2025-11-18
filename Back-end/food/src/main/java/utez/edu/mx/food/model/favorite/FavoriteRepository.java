package utez.edu.mx.food.model.favorite;


import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import utez.edu.mx.food.model.restaurant.RestaurantBean;
import utez.edu.mx.food.model.user.UserBean;

import java.util.List;
import java.util.Optional;

@Repository
public interface FavoriteRepository extends JpaRepository<FavoriteBean, Integer> {

    List<FavoriteBean> findByUsuario(UserBean usuario);

    List<FavoriteBean> findByRestaurante(RestaurantBean restaurante);

    Optional<FavoriteBean> findByUsuarioAndRestaurante(UserBean usuario, RestaurantBean restaurante);

    boolean existsByUsuarioAndRestaurante(UserBean usuario, RestaurantBean restaurante);

    long countByUsuario(UserBean usuario);

    long countByRestaurante(RestaurantBean restaurante);

    @Query("SELECT f FROM FavoriteBean f WHERE f.usuario.idUsuario = :userId ORDER BY f.fechaAgregado DESC")
    List<FavoriteBean> findByUserIdOrderByFechaAgregadoDesc(@Param("userId") Integer userId);
}