CREATE TABLE productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50),
    stock INT
);

CREATE TABLE ventas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_producto INT,
    cantidad INT,
    FOREIGN KEY (id_producto) REFERENCES productos(id)
);
INSERT INTO productos(nombre,stock) VALUES ('LAPTOP LENOVO', 0),('PLAYSTATION 5', 6);

DELIMITER //

CREATE TRIGGER checkstock
BEFORE INSERT ON ventas
FOR EACH ROW
BEGIN
    DECLARE stock_actual INT;
    SELECT stock INTO stock_actual
    FROM productos
    WHERE id = NEW.id_producto;
    IF stock_actual < NEW.cantidad THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'NO SE PUEDE REALIZAR LA VENTA, NO HAY STOCK DE ESTE PRODUCTO';
    END IF;
END;
//

DELIMITER ;
INSERT INTO ventas(id_producto, cantidad) VALUES (1, 1);
--esto deberia validar el trigger
INSERT INTO ventas(id_producto, cantidad) VALUES (2, 1);
--y aqui funciona normal con un producto que si tinee stock



CREATE TABLE empleados (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50),
    salario DECIMAL(10,2)
);

CREATE TABLE historial_salarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_empleado INT,
    salario_anterior DECIMAL(10,2),
    salario_nuevo DECIMAL(10,2),
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_empleado) REFERENCES empleados(id)
);
INSERT INTO empleados (nombre, salario) VALUES ('carlos gomez', 3000.00);


DELIMITER //

CREATE TRIGGER cambio_salario
BEFORE UPDATE ON empleados
FOR EACH ROW
BEGIN
   INSERT INTO historial_salarios (id_empleado, salario_anterior, salario_nuevo)
    VALUES (OLD.id, OLD.salario,NEW.salario);
END;

//

DELIMITER ;
UPDATE empleados SET salario = 3500.00 WHERE id = 1;
select id_empleado,salario_anterior,salario_nuevo,fecha from historial_salarios;


CREATE TABLE clientes (
    id INT PRIMARY KEY,
    nombre VARCHAR(50),
    email VARCHAR(50)
);

CREATE TABLE clientes_auditoria (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_cliente INT,
    nombre VARCHAR(50),
    email VARCHAR(50),
    fecha_eliminacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO clientes(id, nombre,email) VALUES (1,'juan emiliano','123@gmail.com'),(2,'Cristian PEREZ','cristianperez@elmejorjugadordeleagueoflegends');
DELIMITER //
CREATE TRIGGER usuarios_eliminados
BEFORE DELETE ON clientes
FOR EACH ROW
BEGIN 
    INSERT INTO clientes_auditoria(id_cliente,nombre,email)
    VALUES (OLD.id, OLD.nombre,OLD.email);
END ;
DELIMITER ;

DELETE FROM clientes WHERE id=2;

CREATE TABLE pedidos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cliente VARCHAR(100),
    estado ENUM('pendiente', 'completado')
);

INSERT INTO pedidos(cliente,estado) VALUES ('EL CLIENTE CANSON','pendiente'),('MARIA ANA', 'completado');
DELIMITER //
CREATE TRIGGER confirmacion_estado
BEFORE DELETE ON pedidos
FOR EACH ROW
BEGIN
    IF OLD.estado='pendiente' THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT='EL PEDIDO TODAVIA TIENE EL ESTADO PENDIENTE Y NO ES POSIBLE ELIMINARLO ';
    END IF;
END;
//
DELIMITER ;
DELETE FROM pedidos WHERE id=1;
--prueba del trigger
DELETE FROM pedidos WHERE id=2;
--y una prueba donde si elimina