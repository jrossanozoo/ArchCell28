IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerTipoComprobantesYGruposDeCaja]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerTipoComprobantesYGruposDeCaja];
GO;

CREATE FUNCTION [Funciones].[ObtenerTipoComprobantesYGruposDeCaja]
( @TipoDeComprobante varchar(2) )
RETURNS numeric (4,0)
AS
BEGIN
declare @retorno numeric (4,0)
set @retorno = 
case @TipoDeComprobante
	 when '00' then 1
	 when '01' then 1
	 when '23' then 1
	 when '02' then 3
	 when '03' then 3
	 when '24' then 3
	 when '04' then 4
	 when '05' then 4
	 when '25' then 4
	 when '07' then 2
	 when '08' then 2
	 when '26' then 2
	 when '40' then 2
	 when '09' then 5
	 when '10' then 5
	 when '27' then 5
	 when '41' then 5
	 when '11' then 6
	 when '12' then 6
	 when '28' then 6
	 when '50' then 8
	 when '51' then 8
	 when '52' then 8
	 when '70' then 8
	 when '42' then 8
	 when '44' then 8
	 when '64' then 9
	 when '65' then 9
	 when '66' then 9
	 when '71' then 9
	 when '45' then 9
	 when '67' then 10
	 when '68' then 10
	 when '69' then 10
	 when '72' then 10
	 when '43' then 10
	 when '46' then 10
	 when '53' then 27
	 when '54' then 27
	 when '55' then 27
	 when '56' then 28
	 when '57' then 28
	 when '58' then 28
	 when '59' then 29
	 when '60' then 29
	 when '61' then 29
	 when '83' then 54
	 when '84' then 54
	 when '85' then 54
	 when '86' then 55
	 when '87' then 55
	 when '88' then 55
	 when '89' then 56
	 when '90' then 56
	 when '91' then 56
	 when '76' then 33
	 when '77' then 35
	 when '78' then 36
	 when '79' then 47
	 when '80' then 48
	 when '81' then 49
	 when '13' then 13
	 when '14' then 14
	 when '15' then 15
	 when '16' then 16
	 when '17' then 17
	 when '18' then 18
	 when '20' then 20
	 when '21' then 21
	 when '06' then 98
	 when '63' then 31
	 when '62' then 37
	 when '82' then 50
	 when '99' then 99
	 when '96' then 96
	 when '97' then 32
	 when '31' then 1
	 when '32' then 3
	 when '33' then 4
	 when '34' then 27
	 when '35' then 28
	 when '36' then 29
	 when '37' then 2
	 when '38' then 5
	 when '39' then 6
	else 0
end
return @retorno
END