USE [ZL]
GO

/****** Object:  StoredProcedure [ZL].[stp_Iyd_BuscadorFuncReq]    Script Date: 03/12/2013 09:54:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [ZL].[stp_Iyd_BuscadorFuncReq]
@Texto varchar(500)
,@TipoBusqueda smallint

AS
BEGIN
--declare @Texto varchar(100) 
--set @Texto = 'overflow numeric'

declare @sqlquery varchar(8000)
set @sqlquery = ''
declare @sqlFinal varchar(max) 
set @sqlFinal = ''
Declare @texo varchar(100)  
set @texo = @Texto --'filtros producto'
SET @texo = REPLACE(LTRIM(RTRIM(@texo)),'  ',' ')
declare @MasDe1Pala bit
set @MasDe1Pala = 0

if charindex(' ',@texo) > 0 begin set @MasDe1Pala = 1  end


--funcionalidad titulo tiene la frase
set @sqlquery = ' select ''Funcionalidad'' as Registro, f.codigo, f.nombre, f.descrip, f.obs, 199 as Ranking  from zl.fcomer as f ' 
set @sqlFinal = @sqlquery  + ' where f.nombre like ''%' +  @texo + '%'' collate SQL_LATIN1_GENERAL_CP1_CI_AI '

if @MasDe1Pala = 1
begin
--funcionalidad titulo tiene las palabras de la frase
set @sqlquery = ' select ''Funcionalidad'' as Registro, f.codigo, f.nombre, f.descrip, f.obs, 80 as Ranking  from zl.fcomer as f ' 
set @sqlFinal = @sqlFinal + ' union all ' + @sqlquery + ' where ' +  dbo.T_SQL_ArmaCondicionWhereLikes ('f.nombre',1,@texo) + ' and  f.nombre not like ''%' +  @texo + '%'' collate SQL_LATIN1_GENERAL_CP1_CI_AI ' 
end

--funcionalidad descripción tiene la frase
set @sqlquery = ' select ''Funcionalidad'' as Registro, f.codigo, f.nombre, f.descrip, f.obs, 198 as Ranking  from zl.fcomer as f ' 
set @sqlFinal = @sqlFinal + ' union all ' + @sqlquery  +  ' where  cast(f.descrip as varchar(4000)) like ''%' +  @texo + '%'' collate SQL_LATIN1_GENERAL_CP1_CI_AI '

if @MasDe1Pala = 1
begin
--funcionalidad descripción tiene las palabras de la frase
set @sqlquery = ' select ''Funcionalidad'' as Registro, f.codigo, f.nombre, f.descrip, f.obs, 70 as Ranking  from zl.fcomer as f ' 
set @sqlFinal = @sqlFinal + ' union all ' + @sqlquery  +  ' where ' +  dbo.T_SQL_ArmaCondicionWhereLikes ('cast(f.descrip as varchar(4000))',1,@texo) + ' and cast(f.descrip as varchar(4000)) not like ''%' +  @texo + '%'' collate SQL_LATIN1_GENERAL_CP1_CI_AI '
end

--funcionalidad observacion tiene la frase
set @sqlquery = ' select ''Funcionalidad'' as Registro, f.codigo, f.nombre, f.descrip, f.obs, 197 as Ranking  from zl.fcomer as f ' 
set @sqlFinal = @sqlFinal + ' union all ' + @sqlquery  +  ' where  cast(f.obs as varchar(4000))  like ''%' +  @texo + '%'' collate SQL_LATIN1_GENERAL_CP1_CI_AI '

if @MasDe1Pala = 1
begin
--funcionalidad observacion tiene las palabras de la frase
set @sqlquery = ' select ''Funcionalidad'' as Registro, f.codigo, f.nombre, f.descrip, f.obs, 60 as Ranking  from zl.fcomer as f ' 
set @sqlFinal = @sqlFinal + ' union all ' + @sqlquery  +  ' where ' +  dbo.T_SQL_ArmaCondicionWhereLikes ('cast(f.obs as varchar(4000))',1,@texo) + ' and cast(f.obs as varchar(4000)) not like ''%' +  @texo + '%'' collate SQL_LATIN1_GENERAL_CP1_CI_AI '
end



--Requerimiento de Clientes asunto tiene la frase
set @sqlquery =  ' select ''Requerimiento de Cliente'' as Registro, rc.codin, rc.asunto, rc.cmpconsult, '''' as obs, 196 as Ranking from zl.pncereq as rc 
				where	(	 
							( rc.[Cmpfecini] < ''20111001'' and codin in (select distinct numero	from [ZL].[REQCLIDET])  )
							or
							( rc.[NAPROV] = 0  and  rc.[Cmpfecini] > ''20111001'' )	 
						)
						'
				
set @sqlFinal = @sqlFinal + ' union all ' + @sqlquery  +  ' and  rc.asunto like ''%' + @texo +'%'' collate SQL_LATIN1_GENERAL_CP1_CI_AI '

if @MasDe1Pala = 1
begin
--Requerimiento de Clientes asunto tiene tiene las palabras de la  frase
set @sqlquery =  replace (@sqlquery, ',196 as Ranking' , ',50 as Ranking' )
set @sqlFinal = @sqlFinal + ' union all ' + @sqlquery  +  ' and ' + dbo.T_SQL_ArmaCondicionWhereLikes ('rc.asunto',1,@texo) + ' and rc.asunto not like ''%' +  @texo + '%'' collate SQL_LATIN1_GENERAL_CP1_CI_AI '
end


--Requerimiento de Clientes consulta tiene la  frase
set @sqlquery =  ' select ''Requerimiento de Cliente'' as Registro, rc.codin, rc.asunto, rc.cmpconsult, '''' as obs, 195 as Ranking from zl.pncereq as rc 
				where	(	 
							( rc.[Cmpfecini] < ''20111001'' and codin in (select distinct numero	from [ZL].[REQCLIDET])  )
							or
							( rc.[NAPROV] = 0  and  rc.[Cmpfecini] > ''20111001'' )	 
						) '
						
set @sqlFinal = @sqlFinal + ' union all ' + @sqlquery  +  ' and cast( rc.cmpconsult as varchar(4000))  like ''%' + @texo +'%'' collate SQL_LATIN1_GENERAL_CP1_CI_AI '

if @MasDe1Pala = 1
begin
--Requerimiento de Clientes consulta tiene las palabras de la frase
set @sqlquery =   replace (@sqlquery, ',195 as Ranking' , ',49 as Ranking' )
set @sqlFinal = @sqlFinal + ' union all ' + @sqlquery  +  +  ' and ' + dbo.T_SQL_ArmaCondicionWhereLikes ('cast( rc.cmpconsult as varchar(4000))',1,@texo) + ' and cast( rc.cmpconsult as varchar(4000))  not like ''%' +  @texo + '%'' collate SQL_LATIN1_GENERAL_CP1_CI_AI '
end


--Requerimiento de I+D titulo tiene la frase
set @sqlquery =  ' select ''Requerimiento de I+D'' as Registro, rid.codigo, rid.titulo, rid.descr, rid.obs,  194 as Ranking from zl.requer as rid '
set @sqlFinal = @sqlFinal + ' union all ' + @sqlquery  +  ' where rid.titulo  like ''%' + @texo +'%'' collate SQL_LATIN1_GENERAL_CP1_CI_AI '

if @MasDe1Pala = 1
begin
--Requerimiento de I+D titulo tiene las palabras de la frase
set @sqlquery =  ' select ''Requerimiento de I+D'' as Registro, rid.codigo, rid.titulo, rid.descr, rid.obs,  48 as Ranking from zl.requer as rid '
set @sqlFinal = @sqlFinal + ' union all ' + @sqlquery  +  ' where ' + dbo.T_SQL_ArmaCondicionWhereLikes ('rid.titulo ',1,@texo) + ' and rid.titulo  not like ''%' +  @texo + '%'' collate SQL_LATIN1_GENERAL_CP1_CI_AI '
end

--Requerimiento de I+D descripción tiene la frase
set @sqlquery =  ' select ''Requerimiento de I+D'' as Registro, rid.codigo, rid.titulo, rid.descr, rid.obs,  193 as Ranking from zl.requer as rid '
set @sqlFinal = @sqlFinal + ' union all ' + @sqlquery  +  ' where  cast(rid.descr as varchar(4000)) like ''%' + @texo +'%'' collate SQL_LATIN1_GENERAL_CP1_CI_AI '

if @MasDe1Pala = 1
begin
--Requerimiento de I+D descripción tiene las palabras de la frase
set @sqlquery =  ' select ''Requerimiento de I+D'' as Registro, rid.codigo, rid.titulo, rid.descr, rid.obs,  47 as Ranking from zl.requer as rid '
set @sqlFinal = @sqlFinal + ' union all ' + @sqlquery  +  ' where ' + dbo.T_SQL_ArmaCondicionWhereLikes ('cast(rid.descr as varchar(4000))',1,@texo) + ' and  cast(rid.descr as varchar(4000))  not like ''%' +  @texo + '%'' collate SQL_LATIN1_GENERAL_CP1_CI_AI '
end

--Requerimiento de I+D observación tiene la frase
set @sqlquery =  ' select ''Requerimiento de I+D'' as Registro, rid.codigo, rid.titulo, rid.descr, rid.obs,  192 as Ranking from zl.requer as rid '
set @sqlFinal = @sqlFinal + ' union all ' + @sqlquery  +  ' where cast(rid.obs as varchar(4000)) like ''%' + @texo +'%'' collate SQL_LATIN1_GENERAL_CP1_CI_AI '

if @MasDe1Pala = 1
begin
--Requerimiento de I+D observación tiene las palabras de la frase
set @sqlquery =  ' select ''Requerimiento de I+D'' as Registro, rid.codigo, rid.titulo, rid.descr, rid.obs,  46 as Ranking from zl.requer as rid '
set @sqlFinal = @sqlFinal + ' union all ' + @sqlquery  +  ' where ' + dbo.T_SQL_ArmaCondicionWhereLikes ('cast(rid.obs as varchar(4000))',1,@texo) + ' and  cast(rid.obs as varchar(4000))  not like ''%' +  @texo + '%'' collate SQL_LATIN1_GENERAL_CP1_CI_AI '
end

--Incidentes detalle de consulta tiene las palabras de la frase
set @sqlquery = ' select ''Incidente'' as Registro, i.codin, r.[Req Asunto/Título], i.cmpconsult, '''' as obs, 30 as Ranking from zl.incids as i join ZL.IyDRequerimientosIncidentes as r on i.codin = r.numero '	
set @sqlFinal = @sqlFinal + ' union all ' + @sqlquery  +  ' and ' + dbo.T_SQL_ArmaCondicionWhereLikes ('i.cmpconsult',1,@texo) 

/*
--Incidentes titulo tiene las palabras de la frase
set @sqlquery = ' select ''Incidente'' as Registr, oi.codin, r.[Req Asunto/Título], i.cmpconsult, 40 as from zl.incids as i join ZL.IyDRequerimientosIncidentes as r on i.codin = r.numero '	
set @sqlFinal = @sqlFinal + ' union all ' + @sqlquery  +  ' and ' + dbo.T_SQL_ArmaCondicionWhereLikes ('r.[Req Asunto/Título]',1,@texo) 
*/

--Bug Titulo tiene la frase
set @sqlquery = ' select ''Bug'' as Registro, codin, titulo, desbug, msgsis ,190 as Ranking from zl.regbug '
set @sqlFinal = @sqlFinal + ' union all ' + @sqlquery + ' where  titulo like ''%' + @texo +'%'' collate SQL_LATIN1_GENERAL_CP1_CI_AI '

if @MasDe1Pala = 1
begin
--Bug Titulo tiene las palabras de la frase
set @sqlquery= replace (@sqlquery, ',190 as Ranking' , ',44 as Ranking' )	
set @sqlFinal = @sqlFinal + ' union all ' + @sqlquery + ' where ' + dbo.T_SQL_ArmaCondicionWhereLikes ('titulo',1,@texo) + ' and  titulo not like ''%' +  @texo + '%'' collate SQL_LATIN1_GENERAL_CP1_CI_AI '
end


--Bug descripción tiene la frase
set @sqlquery= replace (@sqlquery, ',44 as Ranking' , ',189 as Ranking' )
set @sqlFinal = @sqlFinal + ' union all ' + @sqlquery + ' where cast(desbug as varchar(4000))  like ''%' +  @texo + '%'' collate SQL_LATIN1_GENERAL_CP1_CI_AI '

if @MasDe1Pala = 1
begin
--Bug descripción tiene las palabras de la frase
set @sqlquery= replace (@sqlquery, ',189 as Ranking' , ',43 as Ranking' )
set @sqlFinal = @sqlFinal + ' union all ' + @sqlquery + ' where ' + dbo.T_SQL_ArmaCondicionWhereLikes ('cast(desbug as varchar(4000))',1,@texo) + ' and  cast(desbug as varchar(4000))   not like ''%' +  @texo + '%'' collate SQL_LATIN1_GENERAL_CP1_CI_AI '
end

--Bug mensajeSistema  tiene la frase
set @sqlquery= replace (@sqlquery, ',44 as Ranking' , ',189 as Ranking' )
set @sqlFinal = @sqlFinal + ' union all ' + @sqlquery + ' where cast(msgsis as varchar(4000))  like ''%' +  @texo + '%'' collate SQL_LATIN1_GENERAL_CP1_CI_AI '

if @MasDe1Pala = 1
begin
--Bug mensajeSistema tiene las palabras de la frase
set @sqlquery= replace (@sqlquery, ',189 as Ranking' , ',43 as Ranking' )
set @sqlFinal = @sqlFinal + ' union all ' + @sqlquery + ' where ' + dbo.T_SQL_ArmaCondicionWhereLikes ('cast(msgsis as varchar(4000))',1,@texo) + ' and  cast(msgsis as varchar(4000))   not like ''%' +  @texo + '%'' collate SQL_LATIN1_GENERAL_CP1_CI_AI '
end

exec (@sqlFinal )

END

		
GO


