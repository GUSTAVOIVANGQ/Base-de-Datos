use Aerolineas
--* Instrucciones, si en la base de datos no existen valores que devolver, insertar registro que cumplan con la condición, para ver la funcionalidad del SP. 

--1. Obtener todos los empleados que se dieron de alta entre una determinada fecha inicial y
--fecha final y que pertenecen a un determinada aerolinea  usando un store procedure.
CREATE PROCEDURE ObtenerEmpleadosPorFechaYAerolinea
    @FechaInicio datetime,
    @FechaFinal datetime,
    @AerolineaId int
AS
BEGIN
    SELECT *
    FROM Empleado
    WHERE fechaIngreso BETWEEN @FechaInicio AND @FechaFinal
    AND AerolineaId = @AerolineaId
END

EXEC ObtenerEmpleadosPorFechaYAerolinea '2000-01-01', '2022-12-31', 3

--2. Crear un procedimiento que inserte un empleado y valide su previa existencia, si existe no lo inserte. 
CREATE PROCEDURE InsertarEmpleado
    @idPersona int,
    @idTipoEmpleado int,
    @AerolineaId int,
    @fechaIngreso datetime,
    @sueldo money,
    @idJefe int
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Empleado WHERE idPersona = @idPersona)
    BEGIN
        INSERT INTO Empleado (idPersona, idTipoEmpleado, AerolineaId, fechaIngreso, sueldo, idJefe)
        VALUES (@idPersona, @idTipoEmpleado, @AerolineaId, @fechaIngreso, @sueldo, @idJefe)
    END
END

EXEC InsertarEmpleado 10, 3, 3, '2022-01-01', 50000, 5
--3. Crear un procemimiento que recupere el nombre de aerolínea, cantidad de empleados y 
--idEmpleado, id TipoEmpleado a partir del idAerolinea.
CREATE PROCEDURE ObtenerInfoAerolinea
    @AerolineaId int
AS
BEGIN
    SELECT a.Nombre, COUNT(e.idEmpleado) as CantidadEmpleados, e.idEmpleado, e.idTipoEmpleado
    FROM Aerolinea a
    JOIN Empleado e ON a.AerolineaId = e.AerolineaId
    WHERE a.AerolineaId = @AerolineaId
    GROUP BY a.Nombre, e.idEmpleado, e.idTipoEmpleado
END
EXEC ObtenerInfoAerolinea 3


--4. Crear un procedimiento igual que el anterior, pero que recupera también las personas que
--trabajan en dicha aerolinea, pasandole como parámetro el nombre y apellido. 
CREATE PROCEDURE ObtenerInfoAerolineaYPersona
    @nombre varchar(50),
    @apellido varchar(50)
AS
BEGIN
    SELECT a.Nombre, COUNT(e.idEmpleado) as CantidadEmpleados, e.idEmpleado, e.idTipoEmpleado, p.nombre, p.paterno
    FROM Aerolinea a
    JOIN Empleado e ON a.AerolineaId = e.AerolineaId
    JOIN Persona p ON e.idPersona = p.IdPersona
    WHERE p.nombre = @nombre AND p.paterno = @apellido
    GROUP BY a.Nombre, e.idEmpleado, e.idTipoEmpleado, p.nombre, p.paterno
END

EXEC ObtenerInfoAerolineaYPersona 'Eduardo', 'Ortiz'
--5. Crear un procedimiento para devolver sueldo, tipo de empleado y jefe pasándole el apellido.
CREATE PROCEDURE ObtenerInfoEmpleadoPorApellido
    @apellido varchar(50)
AS
BEGIN
    SELECT e.sueldo, te.tipoEmpleado, j.nombre + ' ' + j.paterno as NombreJefe
    FROM Empleado e
    JOIN Persona p ON e.idPersona = p.IdPersona
    JOIN TipoEmpleado te ON e.idTipoEmpleado = te.idTipoEmpleado
    LEFT JOIN Empleado ej ON e.idJefe = ej.idEmpleado
    LEFT JOIN Persona j ON ej.idPersona = j.IdPersona
    WHERE p.paterno = @apellido
END

EXEC ObtenerInfoEmpleadoPorApellido 'Ortiz'
--6. Crear un procedimiento igual al anterior, pero si no le pasamos ningún valor,
--mostrará los datos de todos los empleados, incluyendo su nombre, dirección, teléfono, etc.
CREATE PROCEDURE ObtenerInfoEmpleadoOpcional
    @apellido varchar(50) = NULL
AS
BEGIN
    SELECT p.nombre, p.paterno, p.materno, p.direccionId, p.telefono, e.sueldo, te.tipoEmpleado, j.nombre + ' ' + j.paterno as NombreJefe
    FROM Empleado e
    JOIN Persona p ON e.idPersona = p.IdPersona
    JOIN TipoEmpleado te ON e.idTipoEmpleado = te.idTipoEmpleado
    JOIN Direccion d ON p.direccionId = d.direccionId
    LEFT JOIN Empleado ej ON e.idJefe = ej.idEmpleado
    LEFT JOIN Persona j ON ej.idPersona = j.IdPersona
    WHERE (@apellido IS NULL OR p.paterno = @apellido)
END

EXEC ObtenerInfoEmpleadoOpcional 'Ortiz'

--7. Crear un procedimiento para mostrar el sueldo, tipo de empleado y nombre de la aerolinea 
--de todos los empleados que contengan en su apellido el valor que le pasemos como
--parámetro. 
CREATE PROCEDURE ObtenerInfoEmpleadoPorApellidoX
    @valor varchar(50)
AS
BEGIN
    SELECT e.sueldo, te.tipoEmpleado, a.Nombre
    FROM Empleado e
    JOIN Persona p ON e.idPersona = p.IdPersona
    JOIN TipoEmpleado te ON e.idTipoEmpleado = te.idTipoEmpleado
    JOIN Aerolinea a ON e.AerolineaId = a.AerolineaId
    WHERE p.paterno LIKE '%' + @valor + '%'
END
EXEC ObtenerInfoEmpleadoPorApellido 'Ortiz'
--8. Crear un procedimiento para mostrar las ventas de un rango de fechas, 
--indicando fecha compra, vendedor, aerolinea,idvuelo, número de boletos, total de compra , pasando
--como parámetro el rango de fechas.
CREATE PROCEDURE ObtenerVentasPorRangoFechaX
    @fechaInicio datetime,
    @fechaFin datetime
AS
BEGIN
    SELECT v.fechaCompra, ve.personaId, a.Nombre, v.idVuelo, v.numAsientos, v.numAsientos * vu.precioPorAsiento as totalCompra
    FROM Venta v
    JOIN Vendedor ve ON v.idVendedor = ve.vendedorId
    JOIN Vuelo vu ON v.idVuelo = vu.idVuelo
    JOIN Avion av ON vu.matriculaAvion = av.matricula
    JOIN Aerolinea a ON av.aerolineaId = a.AerolineaId
    WHERE v.fechaCompra BETWEEN @fechaInicio AND @fechaFin
END
EXEC ObtenerVentasPorRangoFechaX '2014-01-01', '2022-12-31'
--9. Crear un procedimiento para mostrar los datos completos de los 3 clientes que más han comprado en un determinado año, 
--pasando como parámetro el tipo de cliente y el año.*
CREATE PROCEDURE ObtenerTopClientesPorAño
    @tipoCliente varchar(50),
    @año int
AS
BEGIN
    SELECT TOP 3 p.nombre, p.paterno, p.materno, p.telefono, SUM(v.numAsientos) as totalCompras
    FROM Cliente c
    JOIN Persona p ON c.personaId = p.IdPersona
    JOIN TipoCliente tc ON c.idTipoCliente = tc.idTipoCliente
    JOIN Venta v ON c.clienteId = v.idCliente
    WHERE tc.tipoCliente = @tipoCliente AND YEAR(v.fechaCompra) = @año
    GROUP BY p.nombre, p.paterno, p.materno, p.telefono
    ORDER BY totalCompras DESC
END
EXEC ObtenerTopClientesPorAño 'Nuevo', 2014
SELECT * FROM TipoCliente
--10. Crear un procedimiento para mostrar el total de comisión a cobrar por un empleado, de las ventas realizadas en un determinado mes,
--pasando como parámetro su IdEmpleado, el mes y año la de venta.* 
CREATE PROCEDURE ObtenerComisionPorMes
    @idEmpleado int,
    @mes int,
    @año int
AS
BEGIN
    SELECT SUM(v.numAsientos * ve.porcentajeComision / 100) as totalComision
    FROM Venta v
    JOIN Vendedor ve ON v.idVendedor = ve.vendedorId
    JOIN Empleado e ON ve.personaId = e.idPersona
    WHERE e.idEmpleado = @idEmpleado AND MONTH(v.fechaCompra) = @mes AND YEAR(v.fechaCompra) = @año
END

EXEC ObtenerComisionPorMes 1, 1, 20122
SELECT * FROM Venta
--11. Crear un procedimiento para mostrar, cuántos vuelos a realizado el "personal de vuelo" de una aerolinea en especifico, mostrar Aerolínea,nombre completo del
--personal, TipoEmpleado, número de vuelos. Pasando como parámetro el nombre de la Aerolínea. 
CREATE PROCEDURE ObtenerVuelosPorAerolineaX
    @nombreAerolinea varchar(50)
AS
BEGIN
    SELECT a.Nombre, p.nombre, p.paterno, p.materno, te.tipoEmpleado, COUNT(ve.idVuelo) as numeroVuelos
    FROM Empleado e
    JOIN Persona p ON e.idPersona = p.IdPersona
    JOIN TipoEmpleado te ON e.idTipoEmpleado = te.idTipoEmpleado
    JOIN VueloEmpleado ve ON e.idEmpleado = ve.idEmpleado
    JOIN Aerolinea a ON e.AerolineaId = a.AerolineaId
    WHERE a.Nombre = @nombreAerolinea AND te.esDeVuelo = 1
    GROUP BY a.Nombre, p.nombre, p.paterno, p.materno, te.tipoEmpleado
END
EXEC ObtenerVuelosPorAerolineaX 'Volaris'

