USE [ZL]
GO
--/****** Objeto:  StoredProcedure [ZL].[Conexiones_Listados]    Fecha de la secuencia de comandos: 05/13/2009 11:30:43 ******/
IF  NOT EXISTS (
 SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[Conexiones_Listados]') AND type in (N'P', N'PC'))
  begin  
    exec('create proc [ZL].[Conexiones_Listados] as ')
  end   


/****** Object:  StoredProcedure [ZL].[Conexiones_Listados]    Script Date: 06/26/2009 13:15:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [ZL].[Conexiones_Listados] 
(@serieorigen varchar(6), 
 @codrz varchar(5),
 @codcli varchar(5),
 @desrz varchar(100),
 @descl varchar(100))

AS

DECLARE @SQLString NVARCHAR(4000)

-- si el serie origen por parametro no esta vacio y si el codigo de rz y cod de cliente
if @serieorigen <> '' and  @codrz = ' ' and @codcli = ' '
begin
	select @serieorigen as Serie_Origen, conexion as Conexión, crass as RZ_Origen, descrip as RZ_Origen_Descripción, 
		cliente as Cliente_Origen, cmpnombre as Cliente_Origen_Descripción,
		serie as Serie_Destino 
		from ZL.funcSerieConex(@serieorigen) fsc
		cross apply zl.funcRzCliente(@serieorigen) frc
	order by fsc.serie

end
else
begin
	SET @SQLString = N'select distinct nroserie as Serie_Origen, conexion as Conexión, crass as RZ_Origen, '
	SET @SQLString=@SQLString + 'descrip as RZ_Origen_Descripción, cliente as Cliente_Origen, cmpnombre as Cliente_Origen_Descripción, '
	SET @SQLString=@SQLString + 'st.serie as Serie_Destino ' 
	if  @codrz <> ' ' and @codcli <> ' ' 
	begin
		SET @SQLString = + @SQLString + 'from ZL.funcRzxClienteSerie(''' + @codrz + ''',''' + @codcli + ''') fsr '
	end
	else
	begin
		if  @codrz <> ' '
		begin
			SET @SQLString = + @SQLString + 'from ZL.funcSeriesxRz(''' + @codrz + ''') fsr '
		end
		else
		begin
			SET @SQLString = + @SQLString + 'from ZL.funcClientexSerie(''' + @codcli + ''') fsr '
		end
	end
	SET @SQLString = + @SQLString + 'cross apply ZL.funcSerieConex(fsr.nroserie) as st '
	-- Si el serieorgen no esta vacio por parametro 
	if  @serieorigen <> ' '
	begin
		SET @SQLString = + @SQLString + 'where fsr.nroserie = ' + @serieorigen + ''
	end	
	SET @SQLString = + @SQLString + 'order by nroserie, st.serie '

	Exec sp_executesql @SQLString
end


