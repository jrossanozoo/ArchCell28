IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerIdComprobanteFlujoStock]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerIdComprobanteFlujoStock];
GO;
CREATE FUNCTION [Funciones].[ObtenerIdComprobanteFlujoStock]
( @Entidad varchar(36) )
RETURNS varchar (36)
AS
BEGIN
declare @retorno varchar (36)
declare @resultado varchar (36)
declare @numcomprobante varchar(16)

set @resultado = substring(@Entidad,1,CHARINDEX(' ',@Entidad) - 1 )
set @numcomprobante = substring(@Entidad, CHARINDEX(' ',@Entidad) + 1, 16 )
set @retorno = 
case upper(@resultado)
	when 'MOVIMIENTODESTOCK' then 'MDS ' + @numcomprobante
	when 'MERCADERIAENTRANSITO' then 'MTR '+ @numcomprobante
	when 'REMITO' then 'RMV ' + @numcomprobante
	when 'REMITODECOMPRA' then 'RDC ' + @numcomprobante
	when 'PEDIDODECOMPRA' then 'PCO ' + @numcomprobante
	else NULL
end
return @retorno

END


