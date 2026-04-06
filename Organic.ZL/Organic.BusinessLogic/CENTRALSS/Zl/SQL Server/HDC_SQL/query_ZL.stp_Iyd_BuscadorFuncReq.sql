USE [ZL]
GO

/****** Object:  StoredProcedure [ZL].[stp_Iyd_BuscadorFunc]    Script Date: 03/12/2013 09:54:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [ZL].stp_Iyd_BuscadorFunc
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


exec (@sqlFinal )

END

		
GO


