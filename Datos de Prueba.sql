USE eventos_premier;

SHOW TABLES;
DESCRIBE reservas;

-- Pruebas de la función de cálculo con recargo
SELECT calcular_total_reserva(100000, 3);   

-- Pruebas de la función que valida disponibilidad de salones
SELECT verificar_disponibilidad(1, '2026-10-25 16:00', '2026-10-25 20:00');  
SELECT verificar_disponibilidad(1, '2026-10-25 18:00', '2026-10-25 22:00');  
SELECT verificar_disponibilidad(1, '2026-10-26 10:00', '2026-10-26 12:00');  
SELECT verificar_disponibilidad(3, '2026-10-26 10:00', '2026-10-26 12:00');  

SHOW TRIGGERS;
SHOW CREATE TRIGGER actualizar_estado_salon_trigger;

-- =========================================================================
-- REQUERIMIENTOS DEL EXAMEN (CONSULTAS Y VISTA)
-- =========================================================================

-- EXAMEN PUNTO 1: Consulta de salones disponibles (usando NOT IN) para una fecha específica ('2025-11-15')
SELECT nombre, capacidad, precio_hora
FROM salones
WHERE id_salon NOT IN (
    SELECT id_salon 
    FROM reservas 
    WHERE DATE(fecha_inicio) = '2025-11-15' 
      AND estado != 'Cancelada'
);

-- EXAMEN PUNTO 2: Consulta de salones por capacidad (entre 50 y 150) y tarifa (< 500000), ordenados de menor a mayor
SELECT nombre, capacidad, precio_hora, estado, ubicacion
FROM salones
WHERE capacidad BETWEEN 50 AND 150
  AND precio_hora < 500000
ORDER BY precio_hora ASC;

-- EXAMEN PUNTO 3: Creación de la vista obligatoria (vista_salones_disponibles)
CREATE OR REPLACE VIEW vista_salones_disponibles AS
SELECT 
    nombre, 
    capacidad, 
    ubicacion, 
    precio_hora, 
    estado
FROM salones
WHERE estado != 'En mantenimiento';

-- Probando la vista creada
SELECT * FROM vista_salones_disponibles;

-- =========================================================================
-- OTRAS CONSULTAS DE APOYO
-- =========================================================================

CREATE OR REPLACE VIEW vista_resumen_reservas AS
SELECT
  r.id_reserva,
  c.nombre_completo AS cliente,
  s.nombre          AS salon,
  r.fecha_inicio,
  r.fecha_fin,
  r.valor_total     AS total,
  r.estado
FROM reservas r
JOIN clientes c ON c.id_cliente = r.id_cliente
JOIN salones  s ON s.id_salon   = r.id_salon;

SELECT *
FROM vista_resumen_reservas
WHERE fecha_inicio BETWEEN '2026-10-01 00:00:00' AND '2026-10-31 23:59:59';

-- Clientes corporativos con más de 3 reservas
SELECT c.id_cliente, c.nombre_completo, COUNT(r.id_reserva) AS total_reservas
FROM clientes c
JOIN reservas r ON r.id_cliente = c.id_cliente
WHERE c.tipo_cliente = 'Corporativo'
GROUP BY c.id_cliente, c.nombre_completo
HAVING COUNT(r.id_reserva) > 3;