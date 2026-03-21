IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[sp_ObtenerLiquidacionConsignacionesDetalle]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT', N'P'))
DROP PROCEDURE [Funciones].[sp_ObtenerLiquidacionConsignacionesDetalle];
GO;

CREATE procedure [Funciones].[sp_ObtenerLiquidacionConsignacionesDetalle]
(
 @BaseConsignatario varchar(100),
 @BaseConsignador varchar(100),
 @ArticuloSena varchar(20),
 @PeriodoDesde char(8),
 @PeriodoHasta char(8),
 @WhereConsignador varchar(max),
 @Producto varchar(50),
 @CampoArt varchar(50),
 @CampoColor varchar(50),
 @CampoTalle varchar(50)
)

AS

BEGIN
declare @ConsultaSQL varchar(max)
declare @BDConsignatario varchar(max)
declare @Consignatario varchar(max)

	set @CampoArt = Funciones.Alltrim(@CampoArt)
	set @CampoColor = Funciones.Alltrim(@CampoColor)
	set @CampoTalle = Funciones.Alltrim(@CampoTalle)

	set @ConsultaSQL = 'declare Mi_CurBases cursor For 
		select item from Funciones.DividirLaCadenaPorElCaracterDelimitador( ''' + @BaseConsignatario + ''',' + ''','' ) '
		EXEC(@ConsultaSQL)

		open Mi_CurBases
		set @ConsultaSQL = 'declare Mi_CurConsignatario cursor For 		'

		FETCH Mi_CurBases INTO @BDConsignatario
		WHILE @@fetch_status = 0				
			begin

			set @Consignatario =  '[' + @Producto + '_' + @BDConsignatario + '].[ZooLogic]'
			select @ConsultaSQL = @ConsultaSQL + 

			' Select  ( Ventas.CantVendida - ISNULL(Liquidado.CantLiquidada,0 )) + ISNULL(Liquidado.afecant,0) as cantidad, Ventas.'+ @CampoArt +', Ventas.'+@CampoColor+', Ventas.'+@CampoTalle+'  		
			from (		
				Select sum(det.FCANT)  as CantVendida ,  det.'+ @CampoArt +', det.'+@CampoColor+', det.'+@CampoTalle+'				
				FROM ' + @Consignatario + '.[COMPROBANTEVDET] as det 				
				JOIN ( SELECT CODIGO FROM ' + @Consignatario + '.[COMPROBANTEV] 
						where FFCH between ''' + @PeriodoDesde + ''' and ''' + @PeriodoHasta + ''' and FACTTIPO in( 1, 2, 27, 54, 51 )) 
				as cabe on cabe.codigo = det.codigo 			
				where det.fcant > 0
				group by det.'+@CampoArt+', det.'+@CampoColor+', det.'+@CampoTalle+' 				
				 ) as Ventas
			left join (						
					select sum(afecant) as afecant, sum(CantLiquidada) as CantLiquidada, FART,CCOLOR,TALLE 
					from(
							select sum(afecant) as afecant, min(t1.cantidad) as CantLiquidada, t1.FART,t1.CCOLOR, t1.TALLE 
							 from ' + @BaseConsignador + '.[REGCONSIGNACION] as t1
								 join 
								( 
									SELECT iditemliq, max(FALTAFW) max_fecha,BLIQUIDADA , MOVTIPO,  min(AfeCant) as minafecant
										FROM ' + @BaseConsignador + '.[REGCONSIGNACION]							
										where   MOVTIPO = 1 and isnull ( anulado,0 ) = 0										
										GROUP BY iditemliq, BLIQUIDADA, MOVTIPO	
								union 
									SELECT iditemliq, max(FALTAFW) max_fecha,BLIQUIDADA , MOVTIPO,  min(AfeCant) as minafecant
										FROM ' + @BaseConsignador + '.[REGCONSIGNACION]							
										where   MOVTIPO = 3 and isnull ( anulado,0 ) = 0
										GROUP BY iditemliq,LiqIdItem,remafecod, BLIQUIDADA, MOVTIPO																		
								) as t2
								on t1.IDITEMLIQ = t2.IDITEMLIQ and t2.minafecant = t1.AfeCant and t2.max_fecha = t1.FALTAFW and  t2.BLIQUIDADA = '''+  @BDConsignatario + ''' 			
							group by  t1.iditemliq,t1.FART,t1.CCOLOR,t1.TALLE 
					  ) as t3 
					 group by t3.fart,t3.ccolor,t3.talle 

			) as Liquidado on Ventas.'+@CampoArt+' = Liquidado.'+@CampoArt+' and Ventas.'+@CampoColor+' = Liquidado.ccolor and Ventas.'+@CampoTalle+' = Liquidado.talle
			
			UNION ALL'
	
				FETCH next from Mi_CurBases INTO  @BDConsignatario
			end


			select @ConsultaSQL = substring( @ConsultaSQL,1, len(@ConsultaSQL)-9)  + '
				 order by Ventas.'+@CampoArt+', Ventas.'+@CampoColor+', Ventas.'+@CampoTalle+' asc '
	
		EXEC(@ConsultaSQL)

	OPEN Mi_CurConsignatario
			
	 IF OBJECT_ID('tempdb.dbo.#tablaConsignador', 'U') IS NOT NULL
		  --DROP TABLE ##tablaTemporal; 
		truncate table #tablaConsignador; 
		
	ELSE
		CREATE TABLE #tablaConsignador( RowNum int , articulo char(15), color char(20), talle char(20), cantidad numeric(9,3), idItem char(100), codigo char(100),afe_cod char(100))

	set @ConsultaSQL = 'insert into #tablaConsignador 
		select ROW_NUMBER() OVER(ORDER BY articulo, color, talle, cabe.faltafw, cabe.haltafw ASC) AS RowNum, sub2.ARTICULO as articulo, sub2.color as color, sub2.TALLE as talle, sub2.AFE_SALDO as cantidad, sub2.IDITEMARTICULOS as idItem, sub2.LGUID as Codigo, sub2.afe_cod as afe_cod
		from( SELECT sub1.Cantidad,sub1.AFE_SALDO, sub1.Articulo as Articulo, sub1.Color,sub1.TALLE,sub1.ARTICULODETALLE, sub1.lguid, sub1.IDITEMARTICULOS, sub1.afe_cod 
			  FROM ( select AFECANT as Cantidad, '+@CampoArt+' as Articulo, '+@CampoColor+' AS Color, '+@CampoTalle+' as Talle, FTXT AS ARTICULODETALLE, CODIGO as LGUID, IDITEM AS IDITEMARTICULOS, AFESALDO AS AFE_SALDO, SENIACANCE AS IDSENIACANCELADA, AFE_COD as afe_cod  
					 FROM ' + @BaseConsignador + '.[COMPROBANTEVDET]) as sub1 
					 inner join '+ @BaseConsignador + '.[ART] as ARTICULO on sub1.articulo=ARTICULO.ARTCOD 
					 WHERE sub1.afe_saldo<>0 and not ( sub1.Articulo = '''+ @ArticuloSena + ''' and sub1.IDSENIACANCELADA != '''') 
		) as sub2 
		join( SELECT  CODIGO,FALTAFW,HALTAFW FROM ' + @BaseConsignador + '.[COMPROBANTEV] 
		where ' + @WhereConsignador + ' ) as cabe on cabe.codigo = sub2.LGUID 
		order by  sub2.ARTICULO, sub2.COLOR, sub2.TALLE, cabe.FALTAFW, cabe.HALTAFW asc'

	EXEC(@ConsultaSQL)
	
	declare @art char(15)
	declare @cantidad numeric(9,3)
	declare @idItem char(100)
	declare @codigo char(100)
	declare @color char(20)
	declare @talle char(20)
	declare @afeCod char(100)

	declare @art2 char(15)
	declare @color2 char(20)
	declare @talle2 char(20)
	declare @cantidad2 numeric(9,3)

	set @art2 = ''       
	set @color2 = ''
	set @talle2 = ''
	set @cantidad2 = 0

	declare @AfeCant numeric(9,3)
	set @AfeCant = 0

	declare @finCiclo2 int
	set @finCiclo2 = 0
	declare @HuboDato int
	set @HuboDato = 0
	declare @Row int
	set @Row = 0
	declare @CantReg int
	select @CantReg = COUNT(1) from #tablaConsignador	

	 IF OBJECT_ID('tempdb.dbo.##tablaTemporal', 'U') IS NOT NULL
		truncate table ##tablaTemporal; 
		
	ELSE
		CREATE TABLE ##tablaTemporal( Cantidad numeric(9,3), IDItem VARCHAR(100), Codigo VARCHAR(100), afe_cod VARCHAR(100) )
	FETCH Mi_CurConsignatario INTO  @cantidad2, @art2, @color2, @talle2

		WHILE @@fetch_status = 0	
		begin
			select @finCiclo2 = 0	
			select @HuboDato = 0
			select @AfeCant = 0
			if @cantidad2 >0
			BEGIN
				while @finCiclo2 = 0 and @Row < @CantReg
				BEGIN   
				select @Row = @Row +1
					select @art = articulo, @color = color, @talle = talle, @cantidad = cantidad, @idItem = idItem, @codigo = codigo, @afeCod = afe_cod from #tablaConsignador where RowNum = @Row
					if (@art = @art2 and @color = @color2 and @talle = @talle2 and @cantidad > 0 ) and (@art = @art2 and @color = @color2 and @talle = @talle2 and @cantidad2 > 0)
						begin
							if @cantidad >= @cantidad2
								begin 
									select @cantidad = @cantidad - @cantidad2
									select @AfeCant = @cantidad2
									select @cantidad2 = 0
								end
							----
							else 
								begin							
									select @cantidad2 = @cantidad2 - @cantidad
									select @AfeCant = @cantidad
									select @cantidad = 0
								end
							insert into ##tablaTemporal (cantidad, idItem, Codigo,afe_cod) values (@AfeCant, @idItem, @codigo,@afeCod)
							select @AfeCant = 0
							update #tablaConsignador set cantidad = @cantidad where RowNum = @Row
							 select @HuboDato = 1
						end
					else				
				
					if @cantidad2 = 0
						begin
							select @finCiclo2 = 1						
						select @Row = @Row -1							
						end
				END
			END	
				select @Row = 0

			FETCH next from Mi_CurConsignatario INTO  @cantidad2, @art2, @color2, @talle2
		end

		CLOSE Mi_CurBases
		DEALLOCATE Mi_CurBases		
		CLOSE Mi_CurConsignatario
		DEALLOCATE Mi_CurConsignatario
END


