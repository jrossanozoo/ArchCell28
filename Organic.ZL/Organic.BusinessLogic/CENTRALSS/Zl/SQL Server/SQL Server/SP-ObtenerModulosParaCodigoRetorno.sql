set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO

-- =============================================
CREATE PROCEDURE [ZL].[SP-ObtenerModulosParaCodigoRetorno]( @NroSerie varchar(7) )
            
AS
BEGIN

select codart, descr 
	from zl.itemserv it 
	inner join zl.dmodart dm on it.codart = dm.codigo 
	INNER join ZL.AdmEstadoRS() as Estado on Estado.nrz = it.crass  
		and Estado.[Dar Código] = 1  --La rz puede obtener códigos de desactivación
	where 
	[ZL].[func-EsItemActivo](it.ccod, getdate() ) = 1
    and Funciones.dtos( Febavig ) = '19000101'
	and Nroserie = @NroSerie 
	and codart not like '%-TI'
 end

