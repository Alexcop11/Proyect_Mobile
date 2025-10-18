package utez.edu.mx.food.security.jwt;


import io.jsonwebtoken.*;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

import java.security.Key;
import java.util.Date;

@Service
public class JwtProvider {

    @Value("${jwt.secret}")
    private String secret;

    @Value("${jwt.expiration}")
    private long expiration;

    private static final String TOKEN_HEADER = "Authorization";
    private static final String TOKEN_TYPE = "Bearer ";

    public String generateToken(Authentication auth) {
        UserDetails user = (UserDetails) auth.getPrincipal();
        Claims claims = Jwts.claims().setSubject(user.getUsername());
        claims.put("roles", user.getAuthorities());

        Date tokenCreateTime = new Date();
        Date tokenValidity = new Date(tokenCreateTime.getTime() + expiration * 1000);

        return Jwts.builder()
                .setClaims(claims)
                .setSubject(user.getUsername())
                .setIssuedAt(tokenCreateTime)
                .setExpiration(tokenValidity)
                .signWith(getSignKey(), SignatureAlgorithm.HS256)
                .compact();
    }

    private Key getSignKey() {
        byte[] keyBytes = Decoders.BASE64.decode(secret);
        return Keys.hmacShaKeyFor(keyBytes);
    }

    public String resolveToken(HttpServletRequest req) {
        String bearerToken = req.getHeader(TOKEN_HEADER);
        if (bearerToken != null && bearerToken.startsWith(TOKEN_TYPE)) {
            return bearerToken.substring(TOKEN_TYPE.length());
        }
        return null;
    }

    public boolean validateToken(String token) {
        try {
            getClaims(token);
            return true;
        } catch (ExpiredJwtException e) {
            System.err.println("El token ha expirado: " + e.getMessage());
        } catch (MalformedJwtException | UnsupportedJwtException | IllegalArgumentException e) {
            System.err.println("Token inválido: " + e.getMessage());
        }
        return false;
    }

    public Claims getClaims(String token) {
        try {
            return Jwts.parserBuilder()
                    .setSigningKey(getSignKey())
                    .build()
                    .parseClaimsJws(token)
                    .getBody();
        } catch (JwtException e) {
            throw new RuntimeException("Error al obtener los claims del token: " + e.getMessage());
        }
    }
}