IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[CompararBasesDeReplica]') AND type in (N'P'))
	DROP PROCEDURE [Funciones].[CompararBasesDeReplica];
GO;

SET ANSI_NULLS ON
GO;
SET QUOTED_IDENTIFIER ON
GO;
CREATE PROCEDURE [Funciones].[CompararBasesDeReplica]
	-- Add the parameters for the stored procedure here
	@NombreBaseLocal nvarchar(50),
	@ConnectionStringRemoto nvarchar(500)
WITH ENCRYPTION
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
          
	CREATE TABLE #Resultado(
		[Tabla] VARCHAR(MAX),
		[Reg_Local_Zoo] int,
		[Reg_Hub_Zoo] int,
		[Reg_Local_Track] int,
		[Reg_Hub_Track] int,
		[Estado] VARCHAR(MAX),
		[Reg_Local_Track_NotDeleted] int
	)
		  
	declare @str varchar(max)
	 
	set @str = @NombreBaseLocal + '.sys.sp_msforeachtable'

	create table #TempTableLocal (
								esquema sysname,
								tabla sysname,
								rows int
							)

	insert into #TempTableLocal (esquema, tabla, rows)
	exec @str 'select parsename(''?'', 2), parsename(''?'', 1), count(*) from ?'

	declare @sql varchar(max);  
	set @sql = 
	'
INSERT INTO #Resultado
select Tabla, 
             sum( Registros_Local_Zoo ) as [Reg_Local_Zoo], 
             Sum( Registros_Hub_Zoo) as [Reg_Hub_Zoo],
             sum( Registros_Local_Track ) as [Reg_Local_Track],  
             Sum( Registros_Hub_Track ) as [Reg_Hub_Track],
             case when (Sum( Registros_Hub_Zoo ) is null)  then ''Error Aprovisionamiento'' else  
             case when (Sum( Registros_Hub_Track) is null) then ''Error Aprovisionamiento'' else 
             case when (sum( Registros_Local_Track) <> Sum( Registros_Hub_track)) then ''Error DifTrack'' else
             case when (sum( Registros_Local_Zoo) <> Sum( Registros_Hub_Zoo)) then ''Advertencia DifZoo'' else ''OK'' end end end end as Estado,
			 CAST(NULL as int) as [Reg_Local_Track_NotDeleted]
from 
(
SELECT zoo.Tabla, zoo.[Registros_Local_Zoo],table_tracking.[rows] as [Registros_Local_Track],  cast(null as bigint) as Registros_Hub_Zoo,  cast(null as bigint) as Registros_Hub_Track
from 
 (select  p.tabla COLLATE SQL_Latin1_General_CP1_CI_AS as tabla, p.[rows] as [Registros_Local_Zoo]
             from #TempTableLocal as p 
             where p.esquema = ''ZooLogic'' ) as zoo
             full outer  join 
                    (select  substring(p.tabla, 13, charindex(''_tracking'', p.tabla) - 13) COLLATE SQL_Latin1_General_CP1_CI_AS as Tabla, p.[rows]
                    from #TempTableLocal as p 
                    where p.esquema = ''SyncZooLogic'' 
                              and charindex(''_tracking'', p.tabla) > 0 
                              ) as table_tracking on table_tracking.tabla  = zoo.tabla --COLLATE SQL_Latin1_General_CP1_CI_AS                      
		            
	union all ';
	
	declare @sql2 varchar(max);  
	set @sql2 = 
	'select Tabla, Registros_Local_Zoo, Registros_Local_Track, Registros_Hub_Zoo, Registros_Hub_Track from
		OPENROWSET(''SQLNCLI'', ''' + @ConnectionStringRemoto + ''',
			''
			select t.name COLLATE SQL_Latin1_General_CP1_CI_AS as Tabla , null as [Registros_Local_Zoo], null as [Registros_Local_Track], p.rows as [Registros_Hub_Zoo], table_tracking.rows as [Registros_Hub_Track] 
					from sys.tables as t
					inner join sys.schemas as s on s.schema_id = t.schema_id 
					left join sys.partitions as p on p.object_id = t.object_id
					left join 
						(select  substring(t.name, 13, charindex(''''_tracking'''', t.name) - 13) COLLATE SQL_Latin1_General_CP1_CI_AS as Tabla, p.rows 
						 from  sys.tables as t 
								inner join sys.schemas as s on s.schema_id = t.schema_id 
								left join sys.partitions as p on p.object_id = t.object_id
						 where p.index_id in ( 0, 1 ) and s.name = ''''SyncZooLogic'''' 
								and charindex(''''_tracking'''', t.name) > 0) as table_tracking on table_tracking.tabla = t.name
					where p.index_id in ( 0, 1 ) and s.name = ''''ZooLogic''''
			'' ) as r  
			) resultado 
			group by tabla
			having sum( Registros_Local_Zoo ) is not null					
	';
	
	EXEC (@sql + @sql2); 
	--print @sql + @sql2;
	
	/*-----------------------------------------------------------------------------------------------------------*/
	/*
		Actualizo Reg_Local_Track_NotDeleted con la cantidad de registro de tracking local que no fueron borrados,
		solo cuando el estado es "Error DifTrack" o "Advertencia DifZoo"
	*/
	CREATE TABLE #TablasDiferenciaDeTracking
	(
		[TablaId] int identity(1,1) not null,
		[Tabla] VARCHAR(255),
		[Reg_Local_Track_NotDeleted] int,
	)
	
	INSERT INTO #TablasDiferenciaDeTracking
	SELECT DISTINCT Tabla, NULL as [Reg_Local_Track_NotDeleted] FROM #Resultado WHERE Estado IN ('Error DifTrack', 'Advertencia DifZoo') AND [Reg_Local_Track_NotDeleted] IS NULL AND Tabla IS NOT NULL

	DECLARE @tablaId int = (SELECT MIN(TablaId) FROM #TablasDiferenciaDeTracking)
	DECLARE @maxTablaId int = (SELECT MAX(TablaId) FROM #TablasDiferenciaDeTracking)
	
	WHILE (@tablaId <= @maxTablaId)
	BEGIN

		DECLARE @esquemaSync Varchar(255)
		DECLARE @esquemaZoo Varchar(255)
		DECLARE @tabla Varchar(255)
		DECLARE @UpdateRegOnDifQuery Varchar(MAX)

		SET @esquemaSync = 'SyncZoologic'
		SET @esquemaZoo = 'Zoologic'
		SET @tabla = (SELECT Tabla FROM #TablasDiferenciaDeTracking WHERE [TablaId] = @tablaId)
		
		SET @UpdateRegOnDifQuery = 'UPDATE #Resultado 
				SET  [Reg_Local_Track_NotDeleted] = RecountTrackNotDeleted,
					 [Reg_Local_Track] = RecountTrack,
					 [Reg_Local_Zoo] = RecountZoo
				FROM 
			
			   ( SELECT COUNT(*) as [RecountTrack], 
				        SUM ( CASE WHEN sync_row_is_tombstone = 0 THEN 1 ELSE 0 END ) as [RecountTrackNotDeleted],
						(SELECT COUNT(*) FROM [' + @esquemaZoo + '].['+ @tabla + '] )  as RecountZoo
				from [' + @esquemaSync + '].[Sql_Replica_' + @tabla + '_tracking]
		     )
			 as a join #Resultado on #Resultado.Tabla = '''+ @tabla +''''
		
		EXEC (@UpdateRegOnDifQuery)

		SET @tablaId = @tablaId + 1
	END
	/*-----------------------------------------------------------------------------------------------------------*/
	
	SELECT 	
		[Tabla],
		[Reg_Local_Zoo],
		[Reg_Hub_Zoo],
		[Reg_Local_Track],
		[Reg_Hub_Track],
		[Estado],
		[Reg_Local_Track_NotDeleted] 
	FROM #Resultado
	
END
GO;
