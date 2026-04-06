IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[stp_Iyd_BuscadorFuncionalidadesRequerimientosYBugsFTS]') AND type in (N'P', N'PC'))
DROP PROCEDURE [ZL].[stp_Iyd_BuscadorFuncionalidadesRequerimientosYBugsFTS]
GO

create procedure [ZL].[stp_Iyd_BuscadorFuncionalidadesRequerimientosYBugsFTS]
  @Texto varchar(500)
  , @TipoBusqueda smallint
  , @AlcanceBusqueda as varchar(1000)

AS

--BEGIN

DECLARE @SQLFINAL VARCHAR(MAX);
DECLARE @BUSQUEDA VARCHAR(MAX);
SET @SQLFINAL = ''; /*QUERY A ARMAR*/
SET @BUSQUEDA = @Texto; /*TRANSFORMAMOS EL PARAMETRO TEXTO A NVARCHAR*/
SET @BUSQUEDA = REPLACE(LTRIM(RTRIM(@BUSQUEDA)),'  ',' '); /*REEMPLAZAMOS ESPACIOS MULTIPLES POR UNO SOLO*/

	-------------
	DECLARE @Posicion int
	DECLARE @Parametros varchar(255)
	DECLARE @Parametro varchar(254)

	SET @Parametros = @AlcanceBusqueda + ','
	CREATE TABLE #parametros (parametro varchar(1000))

	WHILE patindex('%,%' , @Parametros) <> 0

	BEGIN
	  SELECT @Posicion =  patindex('%,%' , @Parametros)
	  SELECT @Parametro = left(@Parametros, @Posicion - 1)

	  INSERT INTO #parametros values (@Parametro)
	  SELECT @Parametros = stuff(@Parametros, 1, @Posicion, '')
	END
	--GO
	--------

	IF @BUSQUEDA <> '' /*TEXTO LLENO DE ESPACIOS*/
	BEGIN
		/*SETEAMOS EL CATALOGO A USAR*/
	    
		IF @TipoBusqueda = 1
		/*DEBE CONTENER TODAS LA PALABRAS*/
		BEGIN
			SET @BUSQUEDA = REPLACE(@BUSQUEDA, ' ', ' AND ')
		END
		ELSE
		BEGIN
			IF @TipoBusqueda = 0
			/*DEBE CONTENER AL MENOS UNA PALABRA*/
			BEGIN
				SET @BUSQUEDA = REPLACE(@BUSQUEDA, ' ', ' OR ')
			END
			ELSE 
			/*PARAMETRO ERRONEO NI 1 NI 0 SE TOMA 1 POR DEFAULT*/
			BEGIN
				SET @BUSQUEDA = REPLACE(@BUSQUEDA, ' ', ' AND ')
			END
		end  

		if rtrim(ltrim(@AlcanceBusqueda)) = '' or 1 = ( select 1 where 'FUNCIONALIDADES' in  ( select parametro from #parametros ) )
		begin
			set @SQLFINAL = [ZL].[Func_IyD_BuscadorFunc]( @BUSQUEDA )
		end 
		

		if rtrim(ltrim(@AlcanceBusqueda)) = '' or 1=( select 1 where 'BUGS' in  (  select parametro from #parametros ) ) 
		begin
			if rtrim(ltrim(@SQLFINAL)) <> '' 
			begin 
				set @SQLFINAL = @SQLFINAL + ' UNION ALL '
			end
			set @SQLFINAL = @SQLFINAL + [ZL].[Func_IyD_BuscadorBugs]( @BUSQUEDA )
		end  


		if rtrim(ltrim(@AlcanceBusqueda)) = '' or 1=( select 1 where 'REQUERIMIENTOS' in  (  select parametro from #parametros ) ) 
		begin
			if rtrim(ltrim(@SQLFINAL)) <> '' 
			begin 
				set @SQLFINAL = @SQLFINAL + ' UNION ALL '
			end
			set @SQLFINAL = @SQLFINAL + [ZL].Func_IyD_BuscadorReqs( @BUSQUEDA )
		end 
	   
		set @SQLFINAL = @SQLFINAL + ' ORDER BY KEY_TBL.[RANK] DESC'
		EXEC (@SQLFINAL)
		--SELECT @SQLFINAL
	END
	
	
    
GO
 

