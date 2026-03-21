IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerIdentificadorDeComprobante]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerIdentificadorDeComprobante];
GO;

CREATE FUNCTION [Funciones].[ObtenerIdentificadorDeComprobante]
( @TipoDeComprobante int )
RETURNS varchar (3)
AS
BEGIN
declare @retorno varchar(3)
set @retorno =
case @TipoDeComprobante
	when 1 then 'FCV'
	when 2 then 'TFC'
	when 3 then 'NCV'
	when 4 then 'NDV'
	when 5 then 'TNC'
	when 6 then 'TND'
	when 8 then 'FDC'
	when 9 then 'NDC'
	when 10 then 'NCC'
	when 11 then 'RMV'
	when 12 then 'DEV'
	when 13 then 'REC'
	when 23 then 'PED'
	when 25 then 'PR1'
	when 27 then 'FEN'
	when 28 then 'CEN'
	when 29 then 'DEN'
	when 30 then 'PDC'
	when 31 then 'ODP'
	when 32 then 'CDV'
	when 33 then 'FEE'
	when 35 then 'CEE'
	when 36 then 'DEE'
	when 37 then 'PAG'
	when 38 then 'PCO'
	when 39 then 'SOC'
	when 40 then 'RDC'
	when 41 then 'CAC'
	when 42 then 'REQ'
	when 43 then 'AJU'
	when 44 then 'AJP'
	when 45 then 'CDS'
	when 46 then 'DCT'
	when 47 then 'FMX'
	when 48 then 'NCX'
	when 49 then 'NDX'
	when 50 then 'COP'
	when 51 then 'FAG'
	when 52 then 'NAG'
	when 53 then 'XAD'
	when 54 then 'FEM'
	when 55 then 'CEM'
	when 56 then 'DEM'
	when 57 then 'PRM'
	when 58 then 'SEN'
	when 96 then 'AJC'
	when 98 then 'CC'
	when 99 then 'ADC'
	when 999 then 'LIQ'
	when 888 then 'COP'
	else 'XXX'
end
return @retorno

END