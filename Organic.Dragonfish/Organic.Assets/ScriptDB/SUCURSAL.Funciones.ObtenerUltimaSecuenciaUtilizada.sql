IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerUltimaSecuenciaUtilizada]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerUltimaSecuenciaUtilizada];
GO;

CREATE FUNCTION [Funciones].[ObtenerUltimaSecuenciaUtilizada]
	(
	@PtoVen int,
	@Tipos varchar(100)
	)
returns varchar(50)
AS
begin
	declare @retorno varchar(50)

select  @retorno = (Usado.factsec + ',' + convert(varchar(10),FALTAFW, 103)) from (select top 1 factsec as factsec, faltafw, faltafw+haltafw as fecha from ZooLogic.COMPROBANTEV where anulado = 0 and fptoven = @PtoVen and CHARINDEX ( RTRIM( CAST( FACTTIPO AS varchar(2) ) ) ,@Tipos ) = 1 order by fecha desc) as Usado
	
	return isnull(@retorno, '')
END