IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerDireccionCliente]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[ObtenerDireccionCliente];
GO;

CREATE FUNCTION [Funciones].[ObtenerDireccionCliente]( @Calle varchar(70), @Numero varchar(5), @Piso char(3), @Dpto char(3))
returns varchar(100)
begin
	declare @Direccion varchar(100)

	set @Direccion = rtrim( ltrim( @Calle ) )
	set @Direccion = @Direccion + case when @Numero = '' then '' else ' ' + @Numero end
	set @Direccion = @Direccion + case when @Piso = '' then '' else ' ' + @Piso end
	set @Direccion = @Direccion + case when @Dpto = '' then '' else ' ' + @Dpto end
	
	return @Direccion
end
