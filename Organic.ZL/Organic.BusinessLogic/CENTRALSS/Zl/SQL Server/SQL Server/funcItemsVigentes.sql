USE [ZL]
GO


IF NOT  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[funcItemsVigentes]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
EXECUTE ('CREATE FUNCTION [ZL].[funcItemsVigentes] ( ) RETURNS TABLE  AS RETURN  ( SELECT 0 as ccod)')
END
GO

USE [ZL]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		MatiasB
-- Create date: 29/12/2009
-- Description:	items vigentes
--	Ítem vigente es aquel que:
--  Alta Fecha Vigencia <= Hoy y  (Baja Fecha Vigencia > Hoy o  Baja Fecha Vigencia = Vacía).
--  Un ítem vigente no evalúa condiciones de la RZ a la cual está asociado.
-- Además sumo tomas de inventario activados pero sin fechas de vigencia definidas en la tabla de items
-- Ejemplo : select * from ZL.funcItemsVigentes()
-- =============================================
ALTER FUNCTION [ZL].[funcItemsVigentes]
(	
	
)
RETURNS TABLE 
AS
RETURN 
(
	
	SELECT i.ccod
	from zl.itemserv as i WITH (NOLOCK)
	where (fealvig between '19000102' and DATEADD(DAY, 0, DATEDIFF(DAY,0,CURRENT_TIMESTAMP)) )
		and (febavig >= DATEADD(DAY, 0, DATEDIFF(DAY,0,CURRENT_TIMESTAMP)) or febavig='19000101')
	
		
	union all
	
	SELECT i.ccod
	from zl.itemserv as i WITH (NOLOCK)
	join 
	zl.relaciontiis as ti  WITH (NOLOCK) on ti.ccod =  i.ccod
	where fealvig = '19000101' and febavig='19000101'
	
	and ti.fechaact > '19000101'
	and i.cmpfecdes = '19000101'
	
	
		
			
		
)

GO


