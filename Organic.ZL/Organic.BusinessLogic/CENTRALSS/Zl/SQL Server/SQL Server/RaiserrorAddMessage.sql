/*
Autor: Mbuero
Fecha: 18/01/2009
Det: mensaje de error cuando se ingresa un serie incorrecto
*/

USE master;
GO
If not exists (select * from sys.messages where message_id = 60001)
	begin			
	EXEC sp_addmessage @msgnum = 60001, @severity = 16, @msgtext = N'Número de serie incorrecto.'
	end
	
	ELSE 
		BEGIN
		EXEC sp_addmessage @msgnum = 60001, @severity = 16, @replace = 'replace', @msgtext = N'Número de serie incorrecto.'		
		END
GO

 --test
 /*
raiserror (50102, 16,1);
*/


/*
Autor: Mbuero
Fecha: 18/01/2009
Det: mensaje de error multiuso. Ejemplo: se intenta obtener un código con cambio de HW y no se tiene permiso, 
											letra de código para el cual tampoco se tiene permisos, etc.
*/

USE master;
GO
If not exists (select * from sys.messages where message_id = 70001)
	BEGIN			
	EXEC sp_addmessage @msgnum = 70001, @severity = 16, @msgtext = N'Permisos insuficientes para obtener el código de retorno. (IDHW)'
	END
	
	ELSE 
		BEGIN
		EXEC sp_addmessage @msgnum = 70001, @severity = 16, @replace = 'replace', @msgtext = N'Permisos insuficientes para obtener el código de retorno. (IDHW)'	
		END
GO
 --test
 /*
raiserror (70001, 16,1);
*/





/*
Autor: Mbuero
Fecha: 18/01/2009
Det: mensaje de error para datos mal cargados. Se usa para validar que no haya caracteres especiales 
	ingresados ni espacios en usuarios, contraseñas, series, etc.
*/



USE master;
GO
If not exists (select * from sys.messages where message_id = 50001)
	BEGIN			
	EXEC sp_addmessage @msgnum = 50001, @severity = 16, @msgtext = N'Verifique la información ingresada.'
	END
	
	ELSE 
		BEGIN
		EXEC sp_addmessage @msgnum = 50001, @severity = 16, @replace = 'replace', @msgtext = N'Verifique la información ingresada.'	
		END
GO
 --test
 /*
raiserror (50001, 16,1);
*/

/*
Autor: Mbuero.
Fecha: 20/01/2010
Det: Validación de usuario
*/


 USE master;
 GO
 
 if not exists (select * from sys.messages where message_id = 50002)
	begin			
	EXEC sp_addmessage @msgnum = 50002, @severity = 16, @msgtext = N'Nombre de usuario desconocido y/o contraseña incorrecta.'
	end
	
	ELSE 
		BEGIN
		EXEC sp_addmessage @msgnum = 50002, @severity = 16,  @replace = 'replace', @msgtext = N'Nombre de usuario desconocido y/o contraseña incorrecta.'	
		END

GO

--test
/*
raiserror (50002, 16,1);
*/


 if not exists (select * from sys.messages where message_id = 70002)
	begin			
	EXEC sp_addmessage @msgnum = 70002, @severity = 16, @msgtext = N'Versión no registrada.'
	end
	
	ELSE 
		BEGIN
		EXEC sp_addmessage @msgnum = 70002, @severity = 16,  @replace = 'replace', @msgtext = N'Versión no registrada.'	
		END
--test
 /*
raiserror (50106, 16,1);
*/

/*
Autor: GaVALOS.
Fecha: 18/02/2010
Det: Aparecera este error en caso de que no exita una version cargada para el codigo.
*/


--MBUERO, SERIE SIN ITEMS VIGENTES
-- raiserror (50107,16,1)
USE master;
GO
If not exists (select * from sys.messages where message_id = 60002)
	BEGIN			
	EXEC sp_addmessage @msgnum = 60002, @severity = 16, @msgtext = N'El número de serie no se encuentra vigente.'
	END
	
	ELSE 
		BEGIN
		EXEC sp_addmessage @msgnum = 60002, @severity = 16, @replace = 'replace', @msgtext = N'El número de serie no se encuentra vigente.'	
		END
GO


--MBUERO, CLIENTE BLOQUEADO, ante logueo de usuario
-- raiserror (60003,16,1)
USE master;
GO
If not exists (select * from sys.messages where message_id = 60003)
	BEGIN			
	EXEC sp_addmessage @msgnum = 60003, @severity = 16, @msgtext = N'Su servicio se encuentra suspendido.'
	END
	
	ELSE 
		BEGIN
		EXEC sp_addmessage @msgnum = 60003, @severity = 16, @replace = 'replace', @msgtext = N'Su servicio se encuentra suspendido.'
		END
GO




--MBUERO, USUARIO BLOQUEADO
-- raiserror (50109,16,1)
USE master;
GO
If not exists (select * from sys.messages where message_id = 60004)
	BEGIN			
	EXEC sp_addmessage @msgnum = 60004, @severity = 16, @msgtext = N'Usuario bloqueado.'
	END
	
	ELSE 
		BEGIN
		EXEC sp_addmessage @msgnum = 60004, @severity = 16, @replace = 'replace', @msgtext = N'Usuario bloqueado.'	
		END
GO

--MBUERO, USUARIO SE BLOQUEA
-- raiserror (50110,16,1)
USE master;
GO
If not exists (select * from sys.messages where message_id = 60005)
	BEGIN			
	EXEC sp_addmessage @msgnum = 60005, @severity = 16, @msgtext = N'Se ha superado la cantidad de reintentos. Se ha bloqueado el usuario.'
	END
	
	ELSE 
		BEGIN
		EXEC sp_addmessage @msgnum = 60005, @severity = 16, @replace = 'replace', @msgtext = N'Se ha superado la cantidad de reintentos. Se ha bloqueado el usuario.'
		END
GO

/*
MBUERO 16/03/2010: Version NO autorizada. 

*/
USE master;
GO

if not exists (select * from sys.messages where message_id = 60006)
	begin			
	EXEC sp_addmessage @msgnum = 60006, @severity = 16, @msgtext = N'Versión no autorizada.'
	end
	
	ELSE 
		BEGIN
		EXEC sp_addmessage @msgnum = 60006, @severity = 16,  @replace = 'replace', @msgtext = N'Versión no autorizada.'	
		END
		
GO


/*
GAVALOS 22/03/2010: Error Crítico SP
Usado en la DLL
*/
USE master;
GO

if not exists (select * from sys.messages where message_id = 70003)
	begin			
	EXEC sp_addmessage @msgnum = 70003, @severity = 16, @msgtext = N'Error Crítico.'
	end
	
	ELSE 
		BEGIN
		EXEC sp_addmessage @msgnum = 70003, @severity = 16,  @replace = 'replace', @msgtext = N'Error Crítico.'	
		END
		
GO



/*
GAVALOS 29/03/2010: Error Generado desde la DLL.
Usado en la DLL
*/
USE master;
GO

if not exists (select * from sys.messages where message_id = 50003)
	begin			
	EXEC sp_addmessage @msgnum = 50003, @severity = 16, @msgtext = N'El CODIGO DE RETORNO tiene una longitud inválida.'
	end
	
	ELSE 
		BEGIN
		EXEC sp_addmessage @msgnum = 50003, @severity = 16,  @replace = 'replace', @msgtext = N'El CODIGO DE RETORNO tiene una longitud inválida.'	
		END
		
GO



/*
GAVALOS 29/03/2010: Error Generado desde la DLL.
Usado en la DLL
*/
USE master;
GO

if not exists (select * from sys.messages where message_id = 50004)
	begin			
	EXEC sp_addmessage @msgnum = 50004, @severity = 16, @msgtext = N'Número de Serie inexistente.'
	end
	
	ELSE 
		BEGIN
		EXEC sp_addmessage @msgnum = 50004, @severity = 16,  @replace = 'replace', @msgtext = N'Número de Serie inexistente.'	
		END
		
GO




/*
GAVALOS 29/03/2010: Error Generado desde la DLL.
Usado en la DLL
*/
USE master;
GO

if not exists (select * from sys.messages where message_id = 60007)
	begin			
	EXEC sp_addmessage @msgnum = 60007, @severity = 16, @msgtext = N'El número de serie no está asociado a una franja.'
	end
	
	ELSE 
		BEGIN
		EXEC sp_addmessage @msgnum = 60007, @severity = 16,  @replace = 'replace', @msgtext = N'El número de serie no está asociado a una franja.'	
		END
		
GO




/*
GAVALOS 29/03/2010: Error Generado desde la DLL.
Usado en la DLL
*/
USE master;
GO

if not exists (select * from sys.messages where message_id = 60008)
	begin			
	EXEC sp_addmessage @msgnum = 60008, @severity = 16, @msgtext = N'Servicio suspendido ó el número de serie no se encuentra vigente.'
	end
	
	ELSE 
		BEGIN
		EXEC sp_addmessage @msgnum = 60008, @severity = 16,  @replace = 'replace', @msgtext = N'Servicio suspendido ó el número de serie no se encuentra vigente.'	
		END
		
GO




/*
GAVALOS 29/03/2010: Error Generado desde la DLL.
Usado en la DLL
*/
USE master;
GO

if not exists (select * from sys.messages where message_id = 50006)
	begin			
	EXEC sp_addmessage @msgnum = 50006, @severity = 16, @msgtext = N'CODIGO DE RETORNO INCORRECTO verificar digito a digito o pedir uno nuevo.'
	end
	
	ELSE 
		BEGIN
		EXEC sp_addmessage @msgnum = 50006, @severity = 16,  @replace = 'replace', @msgtext = N'CODIGO DE RETORNO INCORRECTO verificar digito a digito o pedir uno nuevo.'	
		END
GO

/*
GAVALOS 29/03/2010: Error Generado desde la DLL.
Usado en la DLL
*/
USE master;
GO

if not exists (select * from sys.messages where message_id = 50007)
	begin			
	EXEC sp_addmessage @msgnum = 50007, @severity = 16, @msgtext = N'Solo se permiten valores numéricos.'
	end
	
	ELSE 
		BEGIN
		EXEC sp_addmessage @msgnum = 50007, @severity = 16,  @replace = 'replace', @msgtext = N'Solo se permiten valores numéricos.'
		END
		
GO


/*
GAVALOS 29/03/2010: Error Generado desde la DLL.
Usado en la DLL
*/
USE master;
GO

if not exists (select * from sys.messages where message_id = 50008)
	begin			
	EXEC sp_addmessage @msgnum = 50008, @severity = 16, @msgtext = N'Letra no validada. Primero valide la letra.'
	end
	
	ELSE 
		BEGIN
		EXEC sp_addmessage @msgnum = 50008, @severity = 16,  @replace = 'replace', @msgtext = N'Letra no validada. Primero valide la letra.'	
		END
GO




/*
GAVALOS 29/03/2010: Error Generado desde la DLL.
Usado en la DLL
*/
USE master;
GO

if not exists (select * from sys.messages where message_id = 50009)
	begin			
	EXEC sp_addmessage @msgnum = 50009, @severity = 16, @msgtext = N'Solo se permite recibir 1 letra de longitud.'
	end
	
	ELSE 
		BEGIN
		EXEC sp_addmessage @msgnum = 50009, @severity = 16,  @replace = 'replace', @msgtext = N'Solo se permite recibir 1 letra de longitud.'	
		END
GO


/*
GAVALOS 29/03/2010: Error Generado desde la DLL.
Usado en la DLL
*/
USE master;
GO

if not exists (select * from sys.messages where message_id = 50010)
	begin			
	EXEC sp_addmessage @msgnum = 50010, @severity = 16, @msgtext = N'Letra X no programada.'
	end
	
	ELSE 
		BEGIN
		EXEC sp_addmessage @msgnum = 50010, @severity = 16,  @replace = 'replace', @msgtext = N'Letra X no programada.'
		END
GO


/*
GAVALOS 29/03/2010: Error Generado desde la DLL.
Usado en la DLL
*/
USE master;
GO

if not exists (select * from sys.messages where message_id = 50011)
	begin			
	EXEC sp_addmessage @msgnum = 50011, @severity = 16, @msgtext = N'Letra X no válida. Primero valide una letra válida.'
	end
	
	ELSE 
		BEGIN
		EXEC sp_addmessage @msgnum = 50011, @severity = 16,  @replace = 'replace', @msgtext = N'Letra X no válida. Primero valide una letra válida.'
		END
GO




/*
Autor: Mbuero
Fecha: 05/04/2010
Det: se intenta obtener un código con cambio de HW y no se tiene permiso, 
											
*/


USE master;
GO
If not exists (select * from sys.messages where message_id = 70004)
	BEGIN			
	EXEC sp_addmessage @msgnum = 70004, @severity = 16, @msgtext = N'Permisos insuficientes para obtener el código de retorno (L).'
	END
	
	ELSE 
		BEGIN
		EXEC sp_addmessage @msgnum = 70004, @severity = 16, @replace = 'replace', @msgtext = N'Permisos insuficientes para obtener el código de retorno (L).'	
		END
GO
 --test
 /*
raiserror (70004, 16,1);
*/