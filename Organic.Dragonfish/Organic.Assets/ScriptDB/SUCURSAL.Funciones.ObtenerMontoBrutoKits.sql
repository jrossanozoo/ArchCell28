IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerMontoBrutoKits]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerMontoBrutoKits];
GO;

CREATE FUNCTION [Funciones].[ObtenerMontoBrutoKits](@codigokit char(38)) 
RETURNS numeric(15,4)
AS begin
Declare @cRetorno numeric(15,4)
Set @cRetorno = (select fbruto from zoologic.kitdet where idkit = @codigokit )
return isnull( @cRetorno, 0 )
End
 

 
