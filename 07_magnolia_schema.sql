-- =====================================================================
-- 01_MAGNOLIA_SCHEMA.SQL - CREACIÓN DE TABLAS (3FN) Y MIGRACIÓN DE DATOS
-- =====================================================================

-- ---------------------------------------------------------------------
-- PARTE A: CREACIÓN DE ESTRUCTURAS DE TABLAS (3FN)
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS ciudades (
    id_ciudad SERIAL PRIMARY KEY,
    nombre_ciudad VARCHAR(100) UNIQUE,
    departamento VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS proveedores (
    id_proveedor SERIAL PRIMARY KEY,
    nombre VARCHAR(150) UNIQUE,
    id_ciudad INT REFERENCES ciudades(id_ciudad)
);

CREATE TABLE IF NOT EXISTS categorias (
    id_categoria SERIAL PRIMARY KEY,
    nombre_categoria VARCHAR(100) UNIQUE,
    subcategoria VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS productos (
    producto_codigo VARCHAR(50) PRIMARY KEY,
    nombre VARCHAR(200),
    id_categoria INT REFERENCES categorias(id_categoria),
    id_proveedor INT REFERENCES proveedores(id_proveedor),
    precio_base NUMERIC(12,2)
);

CREATE TABLE IF NOT EXISTS clientes (
    cliente_documento VARCHAR(20) PRIMARY KEY,
    nombre VARCHAR(150),
    id_ciudad INT REFERENCES ciudades(id_ciudad),
    telefono VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS vendedores (
    vendedor_documento VARCHAR(20) PRIMARY KEY,
    nombre VARCHAR(150),
    sucursal VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS ventas_cabecera (
    id_venta INT PRIMARY KEY,
    fecha TIMESTAMP,
    cliente_documento VARCHAR(20) REFERENCES clientes(cliente_documento),
    vendedor_documento VARCHAR(20) REFERENCES vendedores(vendedor_documento),
    metodo_pago VARCHAR(50),
    banco VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS ventas_detalle (
    id_venta INT REFERENCES ventas_cabecera(id_venta),
    producto_codigo VARCHAR(50) REFERENCES productos(producto_codigo),
    cantidad INT,
    precio_unitario NUMERIC(12,2),
    garantia_meses INT,
    PRIMARY KEY (id_venta, producto_codigo)
);

-- ---------------------------------------------------------------------
-- PARTE B: MIGRACIÓN DE LOS 3.3 MILLONES DE REGISTROS (PROCESO ETL)
-- ---------------------------------------------------------------------

-- 1. Poblamos Ciudades (Evitando duplicar por nombre)
INSERT INTO ciudades (nombre_ciudad, departamento)
SELECT DISTINCT cliente_ciudad, 'Valle del Cauca' -- Se asume por defecto el dpto del enunciado
FROM pos_general
WHERE cliente_ciudad IS NOT NULL
ON CONFLICT (nombre_ciudad) DO NOTHING;

-- 2. Poblamos Proveedores vinculándolos con la ciudad creada
INSERT INTO proveedores (nombre, id_ciudad)
SELECT DISTINCT p.proveedor_nombre, c.id_ciudad
FROM pos_general p
JOIN ciudades c ON p.cliente_ciudad = c.nombre_ciudad -- Mapeo inicial
WHERE p.proveedor_nombre IS NOT NULL
ON CONFLICT (nombre) DO NOTHING;

-- 3. Poblamos Categorías
INSERT INTO categorias (nombre_categoria)
SELECT DISTINCT categoria
FROM pos_general
WHERE categoria IS NOT NULL
ON CONFLICT (nombre_categoria) DO NOTHING;

-- 4. Poblamos Productos vinculando Categoría y Proveedor
INSERT INTO productos (producto_codigo, nombre, id_categoria, id_proveedor, precio_base)
SELECT DISTINCT ON (p.producto_codigo) 
    p.producto_codigo, p.producto_nombre, cat.id_categoria, prov.id_proveedor, p.precio_unitario
FROM pos_general p
LEFT JOIN categorias cat ON p.categoria = cat.nombre_categoria
LEFT JOIN proveedores prov ON p.proveedor_nombre = prov.nombre
WHERE p.producto_codigo IS NOT NULL;

-- 5. Poblamos Clientes vinculando su ciudad correspondiente
INSERT INTO clientes (cliente_documento, nombre, id_ciudad)
SELECT DISTINCT ON (p.cliente_documento) 
    p.cliente_documento, p.cliente_nombre, c.id_ciudad
FROM pos_general p
LEFT JOIN ciudades c ON p.cliente_ciudad = c.nombre_ciudad
WHERE p.cliente_documento IS NOT NULL
ON CONFLICT (cliente_documento) DO NOTHING;

-- 6. Poblamos Vendedores
INSERT INTO vendedores (vendedor_documento, nombre, sucursal)
SELECT DISTINCT ON (vendedor_documento) 
    vendedor_documento, vendedor_nombre, vendedor_sucursal
FROM pos_general
WHERE vendedor_documento IS NOT NULL
ON CONFLICT (vendedor_documento) DO NOTHING;

-- 7. Poblamos Ventas Cabecera (El encabezado único de cada factura)
INSERT INTO ventas_cabecera (id_venta, fecha, cliente_documento, vendedor_documento, metodo_pago, banco)
SELECT DISTINCT ON (id_venta) 
    id_venta, fecha, cliente_documento, vendedor_documento, metodo_pago, banco
FROM pos_general
WHERE id_venta IS NOT NULL;

-- 8. Poblamos Ventas Detalle (Los artículos de cada factura)
INSERT INTO ventas_detalle (id_venta, producto_codigo, cantidad, precio_unitario, garantia_meses)
SELECT id_venta, producto_codigo, cantidad, precio_unitario, 3 -- Garantía por defecto estipulada
FROM pos_general
WHERE id_venta IS NOT NULL AND producto_codigo IS NOT NULL
ON CONFLICT (id_venta, producto_codigo) DO NOTHING;


SELECT * FROM pos_general LIMIT 10;