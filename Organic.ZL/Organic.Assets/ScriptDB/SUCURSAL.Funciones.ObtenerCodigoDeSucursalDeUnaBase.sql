IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerCodigoDeSucursalDeUnaBase]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerCodigoDeSucursalDeUnaBase];
GO;
SET ANSI_NULLS ON
GO;
SET QUOTED_IDENTIFIER ON
GO;
CREATE FUNCTION [Funciones].[ObtenerCodigoDeSucursalDeUnaBase](@tcBaseDeDatos varchar(10)) 
RETURNS varchar(254)
AS begin
Declare @cRetorno varchar(254)
Set @cRetorno = (select top 1 d.valor from Parametros.Sucursal d where d.idUnico = '1C2D17A2C1F31514C5C1A25410222710684731' )
return isnull( @cRetorno, '' )
End
 

 
