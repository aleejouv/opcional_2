-- =========================================
-- FUNCIONES Y PROCEDIMIENTOS (PUNTO 4 - OPCIONAL 2)
-- =========================================

-- 1. FUNCIÓN: Calcular la comisión de un vendedor en un rango de fechas
-- Utilidad: Permite a Magnolia saber cuánto pagarle de incentivo a sus empleados.
CREATE OR REPLACE FUNCTION calcular_comision_vendedor(
    p_vendedor_doc VARCHAR(20),
    p_fecha_inicio TIMESTAMP,
    p_fecha_fin TIMESTAMP,
    p_porcentaje_comision NUMERIC(4,2) DEFAULT 0.05
)
RETURNS NUMERIC(12,2)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_vendido NUMERIC(12,2) := 0;
    v_comision NUMERIC(12,2) := 0;
BEGIN
    SELECT COALESCE(SUM(cantidad * precio_unitario), 0)
    INTO v_total_vendido
    FROM pos_general
    WHERE vendedor_documento = p_vendedor_doc
      AND fecha BETWEEN p_fecha_inicio AND p_fecha_fin;
      
    v_comision := v_total_vendido * p_porcentaje_comision;
    RETURN v_comision;
END;
$$;


-- 2. FUNCIÓN: Total de unidades vendidas de un producto en el último mes
-- Utilidad: Alerta a la tienda sobre la rotación rápida de un producto para planear recompras.
CREATE OR REPLACE FUNCTION unidades_vendidas_mes_producto(
    p_producto_cod VARCHAR(20)
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_unidades INTEGER := 0;
BEGIN
    SELECT COALESCE(SUM(cantidad), 0)
    INTO v_total_unidades
    FROM pos_general
    WHERE producto_codigo = p_producto_cod
      AND fecha >= CURRENT_TIMESTAMP - INTERVAL '1 month';
      
    RETURN v_total_unidades;
END;
$$;


-- 3. PROCEDIMIENTO: Aplicar un descuento masivo a una categoría de producto
-- Utilidad: Permite bajar los precios de manera masiva por campañas de promoción (ej. Todo Mercado con 10% de descuento).
CREATE OR REPLACE PROCEDURE aplicar_descuento_categoria(
    p_categoria VARCHAR(50),
    p_porcentaje_descuento NUMERIC(4,2)
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE pos_general
    SET precio_unitario = precio_unitario * (1 - p_porcentaje_descuento)
    WHERE categoria = p_categoria;
    
    COMMIT;
END;
$$;