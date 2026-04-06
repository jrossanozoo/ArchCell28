USE [ZL]
GO

/****** Object:  UserDefinedFunction [ZL].[funcRangoEntradasxSerie]    Script Date: 12/11/2009 11:44:21 ******/
IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[funcRangoEntradasxSerie]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	BEGIN
	EXEC ('CREATE FUNCTION [ZL].[funcRangoEntradasxSerie] ( @NRO_SERIE  varchar(7),@CAMBIODEHARDWARE  BIT ) RETURNS varchar(2) AS BEGIN DECLARE @Resultado varchar(2)  RETURN @Resultado END')
	END
GO

USE [ZL]
GO

/****** Object:  UserDefinedFunction [ZL].[funcRangoEntradasxSerie]    Script Date: 12/11/2009 11:44:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER FUNCTION [ZL].[funcRangoEntradasxSerie] 

-- =============================================
-- Author:		MatiasB
-- Create date: 25/11/2009
-- Description:	En base a los itmes vigentes de un serie, busca las razones sociales y las franjas de entradas
--				asignadas en el útimo comprobante de asignacón de estado. Si el serie tuviese dos razones sociales asociadas, elige la
--				franja de menor cantidad de entradas.	
--				Si la RZ estuviese bloqueada para dar códigos y se ha asignado un permisos, 
--				entonces devuelve la franja del estado declarado en el permiso. 
-- Ejemplo :	select ZL.funcRangoEntradasxSerie ('200146',0)
-- =============================================
(
	-- Add the parameters for the function here
	@NRO_SERIE  varchar(7),
	@CAMBIODEHARDWARE  BIT
)

RETURNS varchar(2)
AS
BEGIN
	-- Declare the return variable here


	DECLARE @Resultado varchar(2)
 
	
	--*****************************************************************
	
	declare @tablaRs table (codRs char(5) )


	-- Razones sociales asociadas a Items Vigentes

	insert into @tablaRs
	select distinct itemserv.crass
	from  zl.itemserv --on  =  ultestado.nrz
	join zl.funcitemsvigentes() as iv on iv.ccod = itemserv.ccod
	left join zl.relaciontiis as ti on ti.ccod = itemserv.ccod
	where (itemserv.nroserie = @NRO_SERIE or ti.nroserie = @NRO_SERIE)
	
	
	--*****************************************************************
	
	Declare @franjas table (codigo char(2), entradas int)

	-- Permisos temporarios, Franja de entradas

	insert into @franjas
	SELECT zl.FRAENT.ccod, zl.FRAENT.entdef		
			FROM zl.aatmda as permiso
			join zl.estado as esta on esta.codigo = permiso.cestado	
			left join zl.FRAENT on esta.fraent = zl.FRAENT.ccod							
			where permiso.razonsoc in (	select codRs from @tablaRs )													

			and permiso.cmpfecfin  >= DATEADD(DAY, 0, DATEDIFF(DAY,0,CURRENT_TIMESTAMP)) 	
			and IsNull(esta.fraent,'') <> '' 
			
    --*****************************************************************			
	
IF	EXISTS		(		
					--si existe alguna razón social con un estado sin franja asociada
					
					SELECT		ultestado.NRZ FROM
							Zl.admestadoRS() as ultestado 
							join zl.estado as e on e.codigo = ultestado.cestado 
					where 	
					ultestado.nrz in  
										(	select codRs from @tablaRs )			
														
							group by ultestado.NRZ 
							having 	max( IsNull(e.fraent,'')) = ''   
				)
							
	
		AND	EXISTS (	
				    -- pero tiene permisos				
					select codigo from @franjas										
					) 	    
		
		BEGIN
		Select @Resultado = codigo from @franjas where entradas = (select min(entradas) from @franjas where codigo is not null and entradas <> 0 )
		END
				
				
ELSE 
		BEGIN
			--está bloqueada y no tiene permiso, no está bloqueada, cualquier caso se obtiene de la asignación del estado actual.

			Insert Into @franjas	
				SELECT	zl.FRAENT.ccod, zl.FRAENT.entdef
				FROM Zl.admestadoRS() as ultestado 
				join zl.estado as esta on esta.codigo = ultestado.cestado
				left join zl.FRAENT on esta.fraent = zl.FRAENT.ccod
				where ultestado.nrz in  ( select codRs from @tablaRs )		
				group by zl.FRAENT.ccod, zl.FRAENT.entdef
			
			if @CAMBIODEHARDWARE=1
				begin
					Insert Into @franjas SELECT	zl.FRAENT.ccod, zl.FRAENT.entdef FROM zl.FRAENT where Ccod = '08'
				end
			
			
			Select @Resultado = codigo 
				from @franjas 
				where entradas = (select min(entradas) from @franjas where codigo is not null and entradas <> 0 )
		
		--modif 25/08/2011 fernando solicitó que no se devolvieran más entradas por default
		--	SET @Resultado = IsNull( @Resultado ,'01')	
		
		END
		
	RETURN @Resultado 	

end

GO
