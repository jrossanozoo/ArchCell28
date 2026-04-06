USE [ZL]
GO

/****** Object:  UserDefinedFunction [ZL].[funcSerieValidarVersion]    Script Date: 03/16/2010 15:06:19 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[funcSerieValidarVersion]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	EXECUTE ('CREATE FUNCTION [ZL].[funcSerieValidarVersion] () RETURNS bit AS BEGIN RETURN 0 END' ) 
GO

USE [ZL]
GO

/****** Object:  UserDefinedFunction [ZL].[funcSerieValidarVersion]    Script Date: 03/16/2010 15:06:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		MatiasBuero
-- Create date: 16/03/2010 - última modificación 19/05/2010: Se agrega que al pasar versión 0.00 de ok.
-- Description:	Verifica si el serie tiene una versión no autorizada. 
--				Devuelve 1 en el caso de que esté autorizada o no requiera validar
--				Se verifica la versión en el caso de que la razon social del serie tenga al menos un item con contrato
--				Ejemplo: select  ZL.funcSerieValidarVersion ('109371','7.07')
-- =============================================
ALTER FUNCTION [ZL].[funcSerieValidarVersion]
(
	-- Add the parameters for the function here
	@NRO_SERIE  varchar(7), @VERSION numeric (5,2)
)
RETURNS bit
AS
BEGIN
	
	DECLARE @Resultado bit

	
	If Exists(
					select itemserv.ccod 
							from zl.itemserv with(nolock) JOIN zl.funcitemsvigentes() AS iv on iv.ccod = itemserv.ccod
								join zl.isarticu with(nolock) on itemserv.codart = isarticu.ccod
								join zl.contrato with(nolock) on isarticu.codcontr = contrato.codigo
							where 
								itemserv.crass in
								(select distinct crass from zl.itemserv  as i with(nolock) where nroserie = @NRO_SERIE)
								and contrato.conver = 1
				) 
				--HAY QUE VALIDAR VERSION
				
				If 	EXISTS	(select  razonsocial.versionsis 
									from zl.funcitemsvigentes() as iv 
										join zl.itemserv as i on iv.ccod = i.ccod
										join zl.razonsocial on razonsocial.cmpcod = i.crass
									where i.nroserie = @NRO_SERIE 
											and @VERSION <= razonsocial.versionsis 
							 )
				
							--TIENE VERSION AUTORIZADA
							SET @Resultado = 1
							
							ELSE  --VERION NO AUTORIZADA
								
								SET @Resultado = 0
				
				
			ELSE  --NO HAY QUE VALIDAR VERSION
							
					SET @Resultado = 1		

RETURN @Resultado
				
END

GO


