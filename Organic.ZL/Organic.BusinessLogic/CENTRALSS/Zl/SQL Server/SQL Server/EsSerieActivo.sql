USE [ZL]
GO
/****** Object:  UserDefinedFunction [ZL].[EsSerieActivo]    Script Date: 11/02/2009 10:16:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Equipo Verde
-- Create date: 03-09-2009
-- Description:	Devuelve si el serie tiene algun IS activo
-- =============================================
ALTER FUNCTION [ZL].[EsSerieActivo]
(
	@NroSerie varchar( 6 )
)
RETURNS bit
AS
BEGIN

	DECLARE  @EsActivo bit

	if exists (	select *  
				from zl.itemserv 
				where [zl].[func-EsItemActivoSINActDesact] ( ccod, GETDATE() ) = 1 and
						 itemserv.nroserie = @NroSerie )
		set @EsActivo = 1
	else
		set @EsActivo = 0
	
	RETURN @EsActivo

END


--	if exists (	select [zl].[func-EsItemActivo] ( ccod, GETDATE() )  as ItemAct
--					from zl.itemserv 
--					where itemserv.nroserie = @NroSerie and [zl].[func-EsItemPendienteDeActivacion] ( ccod, GETDATE() ) = 1 )
