-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 17-12-2025 a las 22:10:05
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `taller`
--
CREATE DATABASE IF NOT EXISTS `taller` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE `taller`;

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_LISTAR_ADMINISTRADOR` ()   BEGIN
    SELECT
        u.id_usuario,
        u.nombre_usuario,
        CONCAT(u.nombres, ' ', u.apellidos) AS nombre_completo, -- Unimos nombres y apellidos
        u.rut,
        u.email,
        u.sexo,
        u.estado, -- Usamos la columna 'estado' de la tabla usuario
        r.nombre_rol AS rol_nombre
    FROM
        usuario AS u
    INNER JOIN
        rol AS r ON u.rol_id_rol = r.id_rol
    WHERE
        r.nombre_rol = 'Administrador'; -- Filtramos para obtener solo los administradores
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_LISTAR_COMBO_ADMINISTRADOR` ()   begin
select id_rol,
nombre_rol
from rol
where nombre_rol = 'administrador';
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_LISTAR_COMBO_MECANICO` ()   BEGIN
SELECT r.id_rol, r.nombre_rol 
FROM rol AS r
where r.nombre_rol = 'Mecanico';
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_LISTAR_COMBO_ROL` ()   BEGIN
    -- Selecciona los roles que están activos (donde estado = 1)
    SELECT id_rol,
    nombre_rol,
    estado FROM rol 
    WHERE estado = 1 and nombre_rol != 'mecanico';
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_LISTAR_MECANICO` ()   BEGIN 
    SELECT 
        u.id_usuario,
        u.nombre_usuario,
        CONCAT(u.nombres, ' ', u.apellidos) AS nombre_completo,
        u.rut,
        u.email,
        u.sexo,
        u.estado,
        r.nombre_rol AS rol_nombre,
        m.especialidad,
        t.nombre_taller
    FROM 
        usuario AS u
    INNER JOIN 
        rol AS r ON u.rol_id_rol = r.id_rol
    INNER JOIN
        mecanico AS m ON u.id_usuario = m.id_mecanico
    INNER JOIN 
        taller AS t ON m.taller_id_taller = t.id_taller
    WHERE
        r.nombre_rol = 'Mecanico'; 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_LISTAR_TALLER` ()   begin 
select * from taller;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_LISTAR_TALLERPrueba` ()   BEGIN
    SELECT
        t.id_taller,
        t.nombre_taller,
        t.direccion_taller,
        t.email,
        t.telefono,
        CONCAT(u.nombres, ' ', u.apellidos) AS nombre_dueno
    FROM taller AS t
    INNER JOIN dueno_taller AS dt ON t.dueno_taller_id_dueno_taller = dt.id_dueno_taller
    INNER JOIN usuario AS u ON dt.id_dueno_taller = u.id_usuario;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_LISTAR_USUARIO` ()   BEGIN
	select u.id_usuario,
    u.nombre_usuario,
    CONCAT(u.nombres, ' ', u.apellidos) AS nombre_completo, -- Unimos nombres y apellidos
    u.rut,
    u.email,
    u.sexo,
    u.estado,
    r.nombre_rol as rol_nombre
    from usuario as u
    inner join
    rol as r on u.rol_id_rol =r.id_rol;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_MODIFICAR_ESTADO` (IN `p_id_usuario` INT, IN `p_estado` TINYINT)   begin
update usuario
set estado=p_estado
where id_usuario = p_id_usuario; 
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_MODIFICAR_USUARIO` (IN `p_id_usuario` INT, IN `p_nombres` VARCHAR(150), IN `p_apellidos` VARCHAR(150), IN `p_email` VARCHAR(150), IN `p_telefono` VARCHAR(25), IN `p_sexo` CHAR(1), IN `p_nueva_clave` VARCHAR(250))   BEGIN
    -- Verificar si el email ya existe en otro usuario
    IF EXISTS (SELECT 1 FROM usuario WHERE email = p_email AND id_usuario != p_id_usuario) THEN
        SELECT 2 AS resultado; -- 2: Email duplicado
    ELSE
        UPDATE usuario
        SET
            nombres = p_nombres,
            apellidos = p_apellidos,
            email = p_email,
            telefono = p_telefono,
            sexo = p_sexo,
            -- Si se proporciona una nueva clave (no es NULL o vacía), la actualiza. Si no, deja la existente.
            clave = IF(p_nueva_clave IS NOT NULL AND p_nueva_clave != '', p_nueva_clave, clave)
        WHERE id_usuario = p_id_usuario;
        SELECT 1 AS resultado; -- 1: Éxito
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_OBTENER_INFO_USUARIO` (IN `p_id_usuario` INT)   BEGIN
    SELECT
        u.id_usuario,
        u.nombre_usuario,
        r.nombre_rol,
        -- Concatenamos el nombre y apellido, ya que están centralizados en la tabla 'usuario'.
        CONCAT(u.nombres, ' ', u.apellidos) AS nombre_completo,
        -- Opcional: Mostrar la especialidad si es un Mecánico
        CASE r.nombre_rol
            WHEN 'Mecanico' THEN m.especialidad
            ELSE NULL
        END AS especialidad_o_rol_secundario
    FROM
        usuario u
    -- 1. Unir con ROL (Obligatoria)
    JOIN
        rol r ON u.rol_id_rol = r.id_rol
    -- 2. LEFT JOINs a todas las tablas de rol, aunque no se usen para el nombre,
    --    son necesarias para obtener datos específicos (como la especialidad del mecánico).
    LEFT JOIN
        cliente c ON u.id_usuario = c.id_cliente
    LEFT JOIN
        mecanico m ON u.id_usuario = m.id_mecanico
    LEFT JOIN
        administrador_usuario a ON u.id_usuario = a.id_administrador
    LEFT JOIN
        dueno_taller d ON u.id_usuario = d.id_dueno_taller
    WHERE
        u.id_usuario = p_id_usuario;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_REGISTRAR_USUARIO` (IN `p_nombre_usuario` VARCHAR(150), IN `p_clave` VARCHAR(250), IN `p_estado` TINYINT, IN `p_nombres` VARCHAR(150), IN `p_apellidos` VARCHAR(150), IN `p_rut` VARCHAR(45), IN `p_email` VARCHAR(150), IN `p_telefono` VARCHAR(25), IN `p_sexo` CHAR(1), IN `p_rol_id` INT)   BEGIN
    DECLARE new_user_id INT;

    -- Verificamos si ya existe un usuario con el mismo nombre, rut o email.
    IF EXISTS (SELECT 1 FROM usuario WHERE nombre_usuario = p_nombre_usuario) THEN
        SELECT 2 AS resultado; -- 2: Nombre de usuario duplicado
    ELSEIF EXISTS (SELECT 1 FROM usuario WHERE rut = p_rut) THEN
        SELECT 3 AS resultado; -- 3: RUT duplicado
    ELSEIF EXISTS (SELECT 1 FROM usuario WHERE email = p_email) THEN
        SELECT 4 AS resultado; -- 4: Email duplicado
    ELSE
        -- Usamos una transacción para asegurar la integridad de los datos.
        START TRANSACTION;

        -- 1. Insertamos el nuevo usuario en la tabla principal.
        INSERT INTO usuario (nombre_usuario, clave, estado, nombres, apellidos, rut, email, telefono, sexo, rol_id_rol)
        VALUES (p_nombre_usuario, p_clave, p_estado, p_nombres, p_apellidos, p_rut, p_email, p_telefono, p_sexo, p_rol_id);

        -- 2. Obtenemos el ID del usuario que acabamos de crear.
        SET new_user_id = LAST_INSERT_ID();

        -- 3. Según el rol, insertamos en la tabla correspondiente.
        -- Rol 1 = Administrador
        -- Rol 2 = Cliente
        -- Rol 3 = Mecanico
        -- Rol 4 = DuenoTaller
        IF p_rol_id = 1 THEN
            INSERT INTO administrador_usuario (id_administrador) VALUES (new_user_id);
        ELSEIF p_rol_id = 2 THEN
            INSERT INTO cliente (id_cliente) VALUES (new_user_id);
        ELSEIF p_rol_id = 3 THEN
            -- Para el mecánico, asumimos valores por defecto o que se llenarán después.
            -- Si la especialidad es obligatoria, este enfoque debe cambiar.
            INSERT INTO mecanico (id_mecanico, especialidad, taller_id_taller) VALUES (new_user_id, 'General', 1); -- Asumiendo taller_id=1 como default
        ELSEIF p_rol_id = 4 THEN
            INSERT INTO dueno_taller (id_dueno_taller) VALUES (new_user_id);
        END IF;

        -- Verificamos si la última inserción (en la tabla de rol) fue exitosa.
        IF ROW_COUNT() > 0 THEN
            -- Si todo salió bien, confirmamos la transacción.
            COMMIT;
            SELECT 1 AS resultado; -- 1: Éxito
        ELSE
            -- Si algo falló (ej. el rol no existe), revertimos todo.
            ROLLBACK;
            SELECT 0 AS resultado; -- 0: Error
        END IF;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_REGISTRAR_MECANICO`(
    IN p_nombre_usuario VARCHAR(150),
    IN p_clave VARCHAR(250),
    IN p_estado TINYINT,
    IN p_nombres VARCHAR(150),
    IN p_apellidos VARCHAR(150),
    IN p_rut VARCHAR(45),
    IN p_email VARCHAR(150),
    IN p_telefono VARCHAR(25),
    IN p_sexo CHAR(1),
    IN p_rol_id INT,
    IN p_especialidad VARCHAR(45),
    IN p_taller_id INT
)
BEGIN
    DECLARE nuevo_usuario_id INT;

    -- Validaciones de duplicados
    IF EXISTS (SELECT 1 FROM usuario WHERE nombre_usuario = p_nombre_usuario) THEN
        SELECT 2 AS resultado; -- 2: Nombre de usuario duplicado
    ELSEIF EXISTS (SELECT 1 FROM usuario WHERE rut = p_rut) THEN
        SELECT 3 AS resultado; -- 3: RUT duplicado
    ELSEIF EXISTS (SELECT 1 FROM usuario WHERE email = p_email) THEN
        SELECT 4 AS resultado; -- 4: Email duplicado
    ELSE
        START TRANSACTION;

        -- 1. Insertar en la tabla usuario
        INSERT INTO usuario(
            nombre_usuario, 
            clave, 
            estado, 
            nombres, 
            apellidos, 
            rut, 
            email, 
            telefono, 
            sexo, 
            rol_id_rol
        ) 
        VALUES (
            p_nombre_usuario, 
            p_clave, 
            p_estado, 
            p_nombres, 
            p_apellidos, 
            p_rut, 
            p_email, 
            p_telefono, 
            p_sexo, 
            p_rol_id
        );

        -- Obtener el ID del usuario recién creado
        SET nuevo_usuario_id = LAST_INSERT_ID();

        -- 2. Insertar en la tabla mecanico usando el ID recuperado
        INSERT INTO mecanico(id_mecanico, especialidad, taller_id_taller)
        VALUES (nuevo_usuario_id, p_especialidad, p_taller_id);

        -- Verificar si se insertó correctamente y confirmar transacción
        IF ROW_COUNT() > 0 THEN
            COMMIT;
            SELECT 1 AS resultado; -- Éxito
        ELSE
            ROLLBACK;
            SELECT 0 AS resultado; -- Error al insertar en mecanico
        END IF;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_VERIFICAR_USUARIO` (IN `p_nombre_usuario` VARCHAR(150))   BEGIN
	SELECT 
    u.id_usuario,
    u.rut,
    u.nombre_usuario,
    u.nombres,
    u.apellidos,
    u.email,
    u.telefono,
    u.clave,
    u.rol_id_rol,
    u.estado,
    r.nombre_rol,
    u.sexo
    FROM usuario u
    inner join rol r on u.rol_id_rol = r.id_rol
    where u.nombre_usuario = p_nombre_usuario;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `administrador_usuario`
--

CREATE TABLE `administrador_usuario` (
  `id_administrador` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cliente`
--

CREATE TABLE `cliente` (
  `id_cliente` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `cliente`
--

INSERT INTO `cliente` (`id_cliente`) VALUES
(2);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `dueno_taller`
--

CREATE TABLE `dueno_taller` (
  `id_dueno_taller` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `dueno_taller`
--

INSERT INTO `dueno_taller` (`id_dueno_taller`) VALUES
(3);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `historial`
--

CREATE TABLE `historial` (
  `id_historial` int(11) NOT NULL,
  `fecha_cambio` datetime NOT NULL,
  `observaciones` text NOT NULL,
  `cliente_id_cliente` int(11) NOT NULL,
  `vehiculo_id_vehiculo` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `mecanico`
--

CREATE TABLE `mecanico` (
  `id_mecanico` int(11) NOT NULL,
  `especialidad` varchar(45) NOT NULL,
  `taller_id_taller` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `rol`
--

CREATE TABLE `rol` (
  `id_rol` int(11) NOT NULL,
  `nombre_rol` varchar(45) NOT NULL,
  `estado` char(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `rol`
--

INSERT INTO `rol` (`id_rol`, `nombre_rol`, `estado`) VALUES
(1, 'Administrador', '1'),
(2, 'Cliente', '1'),
(3, 'Mecanico', '1'),
(4, 'DuenoTaller', '1');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `servicio`
--

CREATE TABLE `servicio` (
  `id_servicio` int(11) NOT NULL,
  `fecha_servicio` datetime NOT NULL,
  `descripcion_servicio` text NOT NULL,
  `costo` int(11) NOT NULL,
  `taller_id_taller` int(11) NOT NULL,
  `mecanico_id_mecanico` int(11) NOT NULL,
  `vehiculo_id_vehiculo` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `taller`
--

CREATE TABLE `taller` (
  `id_taller` int(11) NOT NULL,
  `nombre_taller` varchar(100) NOT NULL,
  `direccion_taller` varchar(150) NOT NULL,
  `email` varchar(150) NOT NULL,
  `telefono` varchar(15) NOT NULL,
  `dueno_taller_id_dueno_taller` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `taller`
--

INSERT INTO `taller` (`id_taller`, `nombre_taller`, `direccion_taller`, `email`, `telefono`, `dueno_taller_id_dueno_taller`) VALUES
(1, 'Sanpeter', 'las portulacas 62', 'sanpeter@gmail.com', '965636261', 3);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `id_usuario` int(11) NOT NULL,
  `nombre_usuario` varchar(150) NOT NULL,
  `clave` varchar(250) NOT NULL,
  `fecha_de_creacion` datetime NOT NULL DEFAULT current_timestamp(),
  `estado` tinyint(1) NOT NULL COMMENT '1=Activo, 0=Inactivo',
  `nombres` varchar(150) NOT NULL,
  `apellidos` varchar(150) NOT NULL,
  `rut` varchar(45) NOT NULL,
  `email` varchar(150) NOT NULL,
  `telefono` varchar(25) NOT NULL,
  `sexo` char(1) NOT NULL COMMENT 'M=Masculino, F=Femenino',
  `rol_id_rol` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`id_usuario`, `nombre_usuario`, `clave`, `fecha_de_creacion`, `estado`, `nombres`, `apellidos`, `rut`, `email`, `telefono`, `sexo`, `rol_id_rol`) VALUES
(1, 'acartes4', '$2y$10$RWNK5OBmX1iXpCpvYODHVeaAQHU/KHkL4TCl5n9s9mkNmEr2SlHWK', '2025-12-01 10:20:00', 1, 'Ariel Alexander', 'Cartes Burgos', '18978569-0', 'acartes4@gmail.com', '964279810', 'M', 1),
(2, 'm.burgos1', '$2y$10$SXiEagZx/UUn41EY8Yf5aea28Dae16mGuUmSFvt1m41BcB6qoZt52', '2025-12-04 17:58:25', 1, 'Marta Iris', 'Burgos Muñoz', '5915750-4', 'm.burgos1@gmail.com', '964279810', 'F', 2),
(3, 'm.muñoz1', '$2y$10$KmTMb2T4so.vA0t7cUcR0OBYLn0B7RXzzB2kQCzgD/2PCxjp5G9Sy', '2025-12-09 15:01:23', 1, 'Matias Alexis', 'Muñoz Lozano', '18965847-5', 'm.muñoz1@gmail.com', '965626387', 'M', 4);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `vehiculo`
--

CREATE TABLE `vehiculo` (
  `id_vehiculo` int(11) NOT NULL,
  `vin` varchar(150) NOT NULL,
  `marca` varchar(45) NOT NULL,
  `modelo` varchar(45) NOT NULL,
  `anio` year(4) NOT NULL,
  `color` varchar(45) NOT NULL,
  `cliente_id_cliente` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `administrador_usuario`
--
ALTER TABLE `administrador_usuario`
  ADD PRIMARY KEY (`id_administrador`),
  ADD KEY `fk_administrador_usuario_usuario1_idx` (`id_administrador`);

--
-- Indices de la tabla `cliente`
--
ALTER TABLE `cliente`
  ADD PRIMARY KEY (`id_cliente`),
  ADD KEY `fk_cliente_usuario1_idx` (`id_cliente`);

--
-- Indices de la tabla `dueno_taller`
--
ALTER TABLE `dueno_taller`
  ADD PRIMARY KEY (`id_dueno_taller`),
  ADD KEY `fk_dueno_taller_usuario1_idx` (`id_dueno_taller`);

--
-- Indices de la tabla `historial`
--
ALTER TABLE `historial`
  ADD PRIMARY KEY (`id_historial`),
  ADD KEY `fk_historial_cliente1_idx` (`cliente_id_cliente`),
  ADD KEY `fk_historial_vehiculo1_idx` (`vehiculo_id_vehiculo`);

--
-- Indices de la tabla `mecanico`
--
ALTER TABLE `mecanico`
  ADD PRIMARY KEY (`id_mecanico`),
  ADD KEY `fk_mecanico_usuario1_idx` (`id_mecanico`),
  ADD KEY `fk_mecanico_taller1_idx` (`taller_id_taller`);

--
-- Indices de la tabla `rol`
--
ALTER TABLE `rol`
  ADD PRIMARY KEY (`id_rol`);

--
-- Indices de la tabla `servicio`
--
ALTER TABLE `servicio`
  ADD PRIMARY KEY (`id_servicio`),
  ADD KEY `fk_servicio_taller1_idx` (`taller_id_taller`),
  ADD KEY `fk_servicio_mecanico1_idx` (`mecanico_id_mecanico`),
  ADD KEY `fk_servicio_vehiculo1_idx` (`vehiculo_id_vehiculo`);

--
-- Indices de la tabla `taller`
--
ALTER TABLE `taller`
  ADD PRIMARY KEY (`id_taller`),
  ADD KEY `fk_taller_dueno_taller1_idx` (`dueno_taller_id_dueno_taller`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`id_usuario`),
  ADD UNIQUE KEY `n_usuario_UNIQUE` (`nombre_usuario`),
  ADD UNIQUE KEY `email_UNIQUE` (`email`),
  ADD UNIQUE KEY `rut_UNIQUE` (`rut`),
  ADD KEY `fk_usuario_rol_idx` (`rol_id_rol`);

--
-- Indices de la tabla `vehiculo`
--
ALTER TABLE `vehiculo`
  ADD PRIMARY KEY (`id_vehiculo`),
  ADD UNIQUE KEY `vin_UNIQUE` (`vin`),
  ADD KEY `fk_vehiculo_cliente1_idx` (`cliente_id_cliente`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `historial`
--
ALTER TABLE `historial`
  MODIFY `id_historial` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `rol`
--
ALTER TABLE `rol`
  MODIFY `id_rol` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `servicio`
--
ALTER TABLE `servicio`
  MODIFY `id_servicio` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `taller`
--
ALTER TABLE `taller`
  MODIFY `id_taller` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `id_usuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `vehiculo`
--
ALTER TABLE `vehiculo`
  MODIFY `id_vehiculo` int(11) NOT NULL AUTO_INCREMENT;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `administrador_usuario`
--
ALTER TABLE `administrador_usuario`
  ADD CONSTRAINT `fk_administrador_usuario_usuario1` FOREIGN KEY (`id_administrador`) REFERENCES `usuario` (`id_usuario`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `cliente`
--
ALTER TABLE `cliente`
  ADD CONSTRAINT `fk_cliente_usuario1` FOREIGN KEY (`id_cliente`) REFERENCES `usuario` (`id_usuario`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `dueno_taller`
--
ALTER TABLE `dueno_taller`
  ADD CONSTRAINT `fk_dueno_taller_usuario1` FOREIGN KEY (`id_dueno_taller`) REFERENCES `usuario` (`id_usuario`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `historial`
--
ALTER TABLE `historial`
  ADD CONSTRAINT `fk_historial_cliente1` FOREIGN KEY (`cliente_id_cliente`) REFERENCES `cliente` (`id_cliente`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_historial_vehiculo1` FOREIGN KEY (`vehiculo_id_vehiculo`) REFERENCES `vehiculo` (`id_vehiculo`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `mecanico`
--
ALTER TABLE `mecanico`
  ADD CONSTRAINT `fk_mecanico_taller1` FOREIGN KEY (`taller_id_taller`) REFERENCES `taller` (`id_taller`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_mecanico_usuario1` FOREIGN KEY (`id_mecanico`) REFERENCES `usuario` (`id_usuario`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `servicio`
--
ALTER TABLE `servicio`
  ADD CONSTRAINT `fk_servicio_mecanico1` FOREIGN KEY (`mecanico_id_mecanico`) REFERENCES `mecanico` (`id_mecanico`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_servicio_taller1` FOREIGN KEY (`taller_id_taller`) REFERENCES `taller` (`id_taller`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_servicio_vehiculo1` FOREIGN KEY (`vehiculo_id_vehiculo`) REFERENCES `vehiculo` (`id_vehiculo`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `taller`
--
ALTER TABLE `taller`
  ADD CONSTRAINT `fk_taller_dueno_taller1` FOREIGN KEY (`dueno_taller_id_dueno_taller`) REFERENCES `dueno_taller` (`id_dueno_taller`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD CONSTRAINT `fk_usuario_rol` FOREIGN KEY (`rol_id_rol`) REFERENCES `rol` (`id_rol`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `vehiculo`
--
ALTER TABLE `vehiculo`
  ADD CONSTRAINT `fk_vehiculo_cliente1` FOREIGN KEY (`cliente_id_cliente`) REFERENCES `cliente` (`id_cliente`) ON DELETE NO ACTION ON UPDATE NO ACTION;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
