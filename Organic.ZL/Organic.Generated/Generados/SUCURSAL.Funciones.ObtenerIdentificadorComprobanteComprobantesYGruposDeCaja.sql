IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerIdentificadorComprobanteComprobantesYGruposDeCaja]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerIdentificadorComprobanteComprobantesYGruposDeCaja];
GO;

CREATE FUNCTION [Funciones].[ObtenerIdentificadorComprobanteComprobantesYGruposDeCaja]
( @TipoDeComprobante varchar(2) )
RETURNS varchar (3)
AS
BEGIN
declare @retorno varchar (3)
set @retorno = 
case @TipoDeComprobante
	 when '00' then 'FAC'
	 when '01' then 'FAC'
	 when '23' then 'FAC'
	 when '02' then ' NC'
	 when '03' then ' NC'
	 when '24' then ' NC'
	 when '04' then ' ND'
	 when '05' then ' ND'
	 when '25' then ' ND'
	 when '07' then ' TF'
	 when '08' then ' TF'
	 when '26' then ' TF'
	 when '09' then 'TNC'
	 when '10' then 'TNC'
	 when '27' then 'TNC'
	 when '11' then 'TND'
	 when '12' then 'TND'
	 when '28' then 'TND'
	 when '13' then 'REC'
	 when '06' then ' CC'
	 when '99' then 'ADC'
	 when '50' then 'FDC'
	 when '51' then 'FDC'
	 when '52' then 'FDC'
	 when '70' then 'FDC'
	 when '63' then 'NDC'
	 when '64' then 'NDC'
	 when '65' then 'NDC'
	 when '71' then 'NDC'
	 when '66' then 'NCC'
	 when '67' then 'NCC'
	 when '68' then 'NCC'
	 when '72' then 'NCC'
	 when '53' then 'FEL'
	 when '54' then 'FEL'
	 when '55' then 'FEL'
	 when '56' then 'NCE'
	 when '57' then 'NCE'
	 when '58' then 'NCE'
	 when '59' then 'NDE'
	 when '60' then 'NDE'
	 when '61' then 'NDE'
	 when '62' then 'ODP'
	 when '97' then 'CDC'
	 when '76' then 'FEE'
	 when '77' then 'NCE'
	 when '78' then 'NDE'
	else ''
end
return @retorno
END