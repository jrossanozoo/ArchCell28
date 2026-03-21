IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerIndiceInflacion]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[ObtenerIndiceInflacion];
GO;

CREATE FUNCTION [Funciones].[ObtenerIndiceInflacion]
	( 
	@Cuenta char(30),
	@IndiceCuenta  char(10),
	@IndiceCierre char(10),
	@MesAsiento  numeric(2),
	@AnioAsiento  numeric(4),
	@Ejercicio numeric(8)
	)
	returns numeric(12,4)
AS
	begin
	
		declare @Indice numeric(12,4) ;
				
		set @Indice =	
			case when @IndiceCuenta is null or @IndiceCuenta = ''
				then 
					cast(( select indicesdet.indice 
								from zoologic.indicesdet 
								inner join zoologic.cierreej  on indicesdet.codigo = indiceinf 
									and indicesdet.mes = @MesAsiento and indicesdet.anio = @AnioAsiento and cierreej.ejercicio = @Ejercicio
					) as numeric( 15, 4 ) )

				else 
					cast(( select indicesdet.indice 
								from zoologic.indicesdet 
								inner join zoologic.plancuenta  on indicesdet.codigo = indiceaju 
								and indicesdet.mes = @MesAsiento and indicesdet.anio = @AnioAsiento and plancuenta.CTACODIGO =  @Cuenta
					) as numeric( 15, 4 ) ) 
			end

		return @Indice
	end


	