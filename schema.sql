-- =========================================================
-- Sistema POS - doña Magnolia
-- Modelo relacional (3FN) - PostgreSQL
-- =========================================================

CREATE TABLE ciudad (
    id_ciudad     SERIAL PRIMARY KEY,
    nombre        VARCHAR(80) NOT NULL,
    departamento  VARCHAR(80) NOT NULL,
    UNIQUE (nombre, departamento)
);

CREATE TABLE categoria (
    id_categoria  SERIAL PRIMARY KEY,
    nombre        VARCHAR(60) NOT NULL UNIQUE
);

CREATE TABLE metodo_pago (
    id_metodo     SERIAL PRIMARY KEY,
    nombre        VARCHAR(40) NOT NULL UNIQUE
);

CREATE TABLE banco (
    id_banco      SERIAL PRIMARY KEY,
    nombre        VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE cliente (
    documento     VARCHAR(20) PRIMARY KEY,
    nombre        VARCHAR(120) NOT NULL,
    telefono      VARCHAR(20),
    id_ciudad     INT NOT NULL REFERENCES ciudad(id_ciudad)
);

CREATE TABLE sucursal (
    id_sucursal   SERIAL PRIMARY KEY,
    nombre        VARCHAR(80) NOT NULL,
    id_ciudad     INT NOT NULL REFERENCES ciudad(id_ciudad)
);

CREATE TABLE vendedor (
    documento     VARCHAR(20) PRIMARY KEY,
    nombre        VARCHAR(120) NOT NULL,
    id_sucursal   INT NOT NULL REFERENCES sucursal(id_sucursal)
);

CREATE TABLE proveedor (
    id_proveedor  SERIAL PRIMARY KEY,
    nombre        VARCHAR(120) NOT NULL,
    id_ciudad     INT NOT NULL REFERENCES ciudad(id_ciudad)
);

CREATE TABLE producto (
    codigo        VARCHAR(20) PRIMARY KEY,
    nombre        VARCHAR(120) NOT NULL,
    id_categoria  INT NOT NULL REFERENCES categoria(id_categoria)
);

CREATE TABLE venta (
    id_venta            SERIAL PRIMARY KEY,
    fecha                TIMESTAMP NOT NULL DEFAULT now(),
    documento_cliente    VARCHAR(20) NOT NULL REFERENCES cliente(documento),
    documento_vendedor   VARCHAR(20) NOT NULL REFERENCES vendedor(documento),
    id_metodo            INT NOT NULL REFERENCES metodo_pago(id_metodo),
    id_banco             INT REFERENCES banco(id_banco)  -- nulo si el pago fue en efectivo
);

CREATE TABLE detalle_venta (
    id_detalle       SERIAL PRIMARY KEY,
    id_venta         INT NOT NULL REFERENCES venta(id_venta) ON DELETE CASCADE,
    codigo_producto  VARCHAR(20) NOT NULL REFERENCES producto(codigo),
    id_proveedor     INT NOT NULL REFERENCES proveedor(id_proveedor),
    cantidad         INT NOT NULL CHECK (cantidad > 0),
    precio_unitario  NUMERIC(12,2) NOT NULL CHECK (precio_unitario >= 0),
    garantia_meses   INT NOT NULL DEFAULT 0 CHECK (garantia_meses >= 0),
    UNIQUE (id_venta, codigo_producto, id_proveedor)
);

-- Índices de apoyo para las consultas de negocio más frecuentes
CREATE INDEX idx_venta_cliente   ON venta(documento_cliente);
CREATE INDEX idx_venta_vendedor  ON venta(documento_vendedor);
CREATE INDEX idx_detalle_venta   ON detalle_venta(id_venta);
CREATE INDEX idx_detalle_prod    ON detalle_venta(codigo_producto);
CREATE INDEX idx_detalle_prov    ON detalle_venta(id_proveedor);
