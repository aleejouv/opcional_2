
-- 1. Trigger de Auditoría (Para seguridad)Cada vez que alguien borre o modifique una venta vieja en pos_general, 
--necesitamos que quede guardado en una tabla de auditoría para que nadie borre plata por debajo de la mesa.Primero, 
--creamos la tabla donde se guardan los cambios:SQLCREATE TABLE IF NOT EXISTS auditoria_ventas 
(
    id_auditoria SERIAL PRIMARY KEY,
    id_venta INTEGER,
    accion_realizada VARCHAR(20),
    usuario_bd VARCHAR(50) DEFAULT CURRENT_USER,
    fecha_cambio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    monto_anterior NUMERIC(10,2)
);
Y aquí va la función y el trigger:SQLCREATE OR REPLACE FUNCTION log_cambios_ventas()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO auditoria_ventas(id_venta, accion_realizada, monto_anterior)
        VALUES (OLD.id_venta, 'ELIMINACIÓN', OLD.cantidad * OLD.precio_unitario);
        RETURN OLD;
    ELIF (TG_OP = 'UPDATE') THEN
        INSERT INTO auditoria_ventas(id_venta, accion_realizada, monto_anterior)
        VALUES (NEW.id_venta, 'ACTUALIZACIÓN', OLD.cantidad * OLD.precio_unitario);
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_auditoria_ventas
AFTER UPDATE OR DELETE ON pos_general
FOR EACH ROW
EXECUTE FUNCTION log_cambios_ventas();
--2. Trigger de Validación (Regla de negocio)Un trigger que impida registrar ventas con fecha en el futuro 
--(por si hay un error en el reloj del POS) o que valide que si el método de pago es tarjeta o transferencia, 
--el campo banco no venga vacío.  
SQLCREATE OR REPLACE FUNCTION validar_metodo_pago()
RETURNS TRIGGER AS $$
BEGIN
    -- Si paga con tarjeta o transferencia, obligar a que ponga el banco
    IF NEW.metodo_pago IN ('tarjeta Crédito', 'tarjeta Débito', 'transferencia') AND (NEW.banco IS NULL OR NEW.banco = '') THEN
        RAISE EXCEPTION 'Para pagos electrónicos (tarjeta/transferencia) debe especificar el banco.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_pago
BEFORE INSERT OR UPDATE ON pos_general
FOR EACH ROW
EXECUTE FUNCTION validar_metodo_pago();