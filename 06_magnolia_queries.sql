--Requisito 1: Total de ventas por mes y año
--la evolución de los ingresos de la tienda en el tiempo.

SELECT 
    EXTRACT(YEAR FROM fecha) AS anio,
    EXTRACT(MONTH FROM fecha) AS mes,
    COUNT(DISTINCT id_venta) AS total_facturas,
    SUM(cantidad * precio_unitario) AS total_ingresos
FROM pos_general
GROUP BY anio, mes
ORDER BY anio DESC, mes DESC;
--Requisito 2: Top 5 de productos más vendidos
--Para saber cuáles son los productos estrella de Doña Magnolia.

SELECT 
    producto_codigo,
    producto_nombre,
    SUM(cantidad) AS total_unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_recaudado
FROM pos_general
GROUP BY producto_codigo, producto_nombre
ORDER BY total_unidades_vendidas DESC
LIMIT 5;

--Requisito 3: Clientes más fieles (Top 5 que más compran)
--Para identificar a los mejores clientes del negocio.

SELECT 
    cliente_documento,
    cliente_nombre,
    COUNT(DISTINCT id_venta) AS visitas_tienda,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM pos_general
GROUP BY cliente_documento, cliente_nombre
ORDER BY total_gastado DESC
LIMIT 5;

--Requisito 4: Rendimiento de las Sucursales
--Para saber cuál sede de la tienda vende más.

SELECT 
    vendedor_sucursal AS sucursal,
    COUNT(DISTINCT id_venta) AS total_ventas_realizadas,
    SUM(cantidad * precio_unitario) AS ingresos_totales
FROM pos_general
GROUP BY vendedor_sucursal
ORDER BY ingresos_totales DESC;

-- Requisito 5: Uso de Métodos de Pago
-- Para analizar cómo prefiere pagar la gente (Efectivo, Tarjeta, etc.).

SELECT 
    metodo_pago,
    COUNT(DISTINCT id_venta) AS cantidad_transacciones,
    SUM(cantidad * precio_unitario) AS total_dinero_movido
FROM pos_general
GROUP BY metodo_pago
ORDER BY cantidad_transacciones DESC;


--Requisito 6: Proveedores clave por volumen de ventas
--Para ver qué proveedores sostienen el inventario.

SELECT 
    proveedor_nombre,
    COUNT(DISTINCT producto_codigo) AS cantidad_productos_provistos,
    SUM(cantidad) AS total_articulos_vendidos
FROM pos_general
GROUP BY proveedor_nombre
ORDER BY total_articulos_vendidos DESC
LIMIT 5;


SELECT * FROM pos_general LIMIT 10;