package utez.edu.mx.food.model.rating;


import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import utez.edu.mx.food.model.restaurant.RestaurantBean;
import utez.edu.mx.food.model.user.UserBean;

import java.util.List;
import java.util.Optional;

@Repository
public interface RatingRepository extends JpaRepository<RatingBean, Integer> {

    List<RatingBean> findByUsuario(UserBean usuario);

    List<RatingBean> findByRestaurante(RestaurantBean restaurante);

    List<RatingBean> findByRestaurante_IdRestaurante(Integer idRestaurante);

    Optional<RatingBean> findByUsuarioAndRestaurante(UserBean usuario, RestaurantBean restaurante);

    @Query("SELECT AVG((r.puntuacionComida + r.puntuacionServicio + r.puntuacionAmbiente) / 3.0) FROM RatingBean r WHERE r.restaurante.idRestaurante = :idRestaurante")
    Double findAverageRatingByRestauranteId(@Param("idRestaurante") Integer idRestaurante);

    @Query("SELECT COUNT(r) FROM RatingBean r WHERE r.restaurante.idRestaurante = :idRestaurante")
    Long countByRestauranteId(@Param("idRestaurante") Integer idRestaurante);

    boolean existsByUsuarioAndRestaurante(UserBean usuario, RestaurantBean restaurante);

    @Query("SELECT r FROM RatingBean r WHERE r.restaurante.idRestaurante = :idRestaurante ORDER BY r.fechaCalificacion DESC")
    List<RatingBean> findLatestByRestauranteId(@Param("idRestaurante") Integer idRestaurante, org.springframework.data.domain.Pageable pageable);
}