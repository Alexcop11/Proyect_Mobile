package utez.edu.mx.food.model.photo;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface PhotoRepository extends JpaRepository<PhotoBean, Integer> {

    List<PhotoBean> findByRestauranteIdRestaurante(Integer idRestaurante);

    Optional<PhotoBean> findByRestauranteIdRestauranteAndEsPortadaTrue(Integer idRestaurante);

    @Query("SELECT p FROM PhotoBean p WHERE p.restaurante.idRestaurante = :idRestaurante ORDER BY p.esPortada DESC")
    List<PhotoBean> findByRestauranteWithPortadaFirst(@Param("idRestaurante") Integer idRestaurante);

    Long countByRestauranteIdRestaurante(Integer idRestaurante);
}