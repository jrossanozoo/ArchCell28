IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerDisponibilidadSecuencia]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerDisponibilidadSecuencia];
GO;

CREATE FUNCTION [Funciones].[ObtenerDisponibilidadSecuencia]
	(
	@cSec varchar(2),
	@PtoVen int
	)
returns int
AS
begin
	declare @lnRetorno int;
	declare @lcSec int;

	select top 1 @lcSec = count( Comprobantev.FACTSEC ) from Zoologic.ComprobanteV where Comprobantev.FACTSEC = @cSec and ComprobanteV.FPTOVEN = @PtoVen and ComprobanteV.Anulado = 0;
	
	if( @lcSec  = 0)
		set @lnRetorno = 1
	else
		set @lnRetorno = 0
	return @lnRetorno
END