IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerDescripcionDocumentoAfip]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerDescripcionDocumentoAfip];
GO;

CREATE FUNCTION [Funciones].[ObtenerDescripcionDocumentoAfip]
( @CodigoDocumentoAfip varchar(3))
RETURNS varchar(40)
AS
BEGIN
	declare @retorno varchar(40)
	set @retorno =( select REPLACE(CODIGO,'CODIGODOCUMENTO','')
					from [ORGANIZACION].[CONVERVAL] 
					where VALORIG = @CodigoDocumentoAfip AND
					CONVERSION = 'CODIGODOCUMENTO' )

	if left( @retorno, 2 ) = 'CI'
		set @retorno = 'CI ' + substring( @retorno, 3 , 40)

	return @retorno
END