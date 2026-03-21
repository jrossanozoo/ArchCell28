IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[sp_ObtenerResumenComisionesPorVentas]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT', N'P'))
DROP PROCEDURE [Funciones].[sp_ObtenerResumenComisionesPorVentas];
GO;

CREATE PROCEDURE [Funciones].[sp_ObtenerResumenComisionesPorVentas] 

	as
	begin
		set nocount on
		set ansi_warnings off
		
		IF OBJECT_ID('tempdb..#T') IS NOT NULL
			DROP TABLE #T;
		

		select * into #T from [Listados].[VistaComisionesPorVenta]
		
	Declare @Sql nvarchar(max) = ''
	set @Sql = @Sql + 'SELECT '
	set @Sql = @Sql + '	c_CV.ORIGEN'
	set @Sql = @Sql + '	, c_CV.CODIGO'
	set @Sql = @Sql + '	, c_CV.IDITEM'
	set @Sql = @Sql + '	, sum( c_CV.MONTOF ) MONTOF'
	set @Sql = @Sql + '	, sum( c_CV.MONTOF * c_CV.MAS_RECIENTE ) MONTOF_SOLOUNA'
	set @Sql = @Sql + '	, sum( c_CV.PORCENT ) PORCENT'
	set @Sql = @Sql + '	, sum( c_CV.PORCENT * c_CV.MAS_RECIENTE ) PORCENT_SOLOUNA'
	set @Sql = @Sql + '	, sum( c_CV.MONTOF * c_CV.MAYOR_MONTOF) MAYOR_MONTOF'
	set @Sql = @Sql + '	, sum( c_CV.PORCENT * c_CV.MAYOR_PORCENT ) MAYOR_PORCENT'
	set @Sql = @Sql + '	, cast( coalesce( sum( c_CV.MONTOF * c_CV.MAYOR_MONTOF), 0 ) / ( ( coalesce( sum( c_CV.PORCENT * c_CV.MAYOR_PORCENT ), 100 ) / 100 ) ) as numeric( 15, 2) ) MONTO_LIMITE_DEL_MAYOR'
	set @Sql = @Sql + '	, sum( c_CV.MONTOF * c_CV.MENOR_MONTOF) MENOR_MONTOF'
	set @Sql = @Sql + '	, sum( c_CV.PORCENT * c_CV.MENOR_PORCENT ) MENOR_PORCENT'
	set @Sql = @Sql + '	, cast( coalesce( sum( c_CV.MONTOF * c_CV.MENOR_MONTOF), 0 ) / ( ( coalesce( sum( c_CV.PORCENT * c_CV.MENOR_PORCENT ), 100 ) / 100 ) ) as numeric( 15, 2) ) MONTO_LIMITE_DEL_MENOR'

	set @Sql = @Sql + '	,(SELECT 
		  coalesce(stuff(
					( 
					SELECT ''; ''  + rtrim( c_CV1.COMISION ) 
						+ case when c_CV1.MONTOF != 0  then '' $'' + convert( varchar, c_CV1.MONTOF ) else '''' end 
						+ case when c_CV1.PORCENT != 0 then '' '' + convert( varchar, c_CV1.PORCENT ) + ''%'' else '''' end 
					from #T as c_CV1
					where 1=1
						and ( c_CV1.CODIGO = c_CV.CODIGO )
						and ( c_CV1.IDITEM = c_CV.iditem )
					FOR XML PATH('''') 
					), 1, 2, ''''), '''')
				
			) as infocom '
	set @Sql = @Sql + '	,(SELECT 
		  coalesce(stuff(
					( 
					SELECT ''; ''  + rtrim( c_CV1.COMISION ) 
						+ case when c_CV1.MONTOF != 0  then '' $'' + convert( varchar, c_CV1.MONTOF ) else '''' end 
						+ case when c_CV1.PORCENT != 0 then '' '' + convert( varchar, c_CV1.PORCENT ) + ''%'' else '''' end 
					from #T as c_CV1
					where 1=1
						and ( c_CV1.CODIGO = c_CV.CODIGO )
						and ( c_CV1.IDITEM = c_CV.iditem )
						and ( c_CV1.COMISION = C_CV1.descripMAS_RECIENTE )
					FOR XML PATH('''') 
					), 1, 2, ''''), '''')
				
			) as infocom_solouna '

	set @Sql = @Sql + ' from #T as c_CV '

	set @Sql = @Sql + ' group by c_CV.ORIGEN, c_CV.CODIGO, c_CV.IDITEM '
		
	exec sp_executesql @Sql
	end