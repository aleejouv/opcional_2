-- =====================================================================
-- OPTIMIZACIÓN DE CONSULTAS - ÍNDICES (PUNTO 6 - OPCIONAL 2)
-- =====================================================================

-- 1. Índice para acelerar los reportes por ciudad (Requisitos 1, 3 y 5)
CREATE INDEX IF NOT EXISTS idx_pos_cliente_ciudad 
ON pos_general (cliente_ciudad);

-- 2. Índice para acelerar las búsquedas de facturación por proveedor (Requisitos 2, 4 y 5)
CREATE INDEX IF NOT EXISTS idx_pos_proveedor_nombre 
ON pos_general (proveedor_nombre);

-- 3. Índice compuesto para optimizar el rendimiento del ranking de mejores vendedores por sucursal (Requisition 6)
CREATE INDEX IF NOT EXISTS idx_pos_vendedor_sucursal_nombre 
ON pos_general (vendedor_sucursal, vendedor_nombre);

-- 4. Índice para agilizar las búsquedas por códigos de producto en cruces de datos (Requisito 4)
CREATE INDEX IF NOT EXISTS idx_pos_producto_codigo 
ON pos_general (producto_codigo);