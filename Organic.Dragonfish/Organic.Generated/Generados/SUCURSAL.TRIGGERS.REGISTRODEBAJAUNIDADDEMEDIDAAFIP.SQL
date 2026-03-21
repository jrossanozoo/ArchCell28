
	DECLARE @EndLine nchar(2); SET @EndLine = NCHAR(13) + NCHAR(10);
	DECLARE @Instruccion nVarChar( 4000 )
	Set @Instruccion =  N'if OBJECTPROPERTY(OBJECT_ID(''[ZooLogic].[DELETE_REGISTRODEBAJA_UNIDADDEMEDIDAAFIP]''), ''IsTrigger'') = 1' + @EndLine + 
								N'drop trigger [ZooLogic].[DELETE_REGISTRODEBAJA_UNIDADDEMEDIDAAFIP]'
	Exec( @Instruccion )
	Set @Instruccion =  N'if OBJECTPROPERTY(OBJECT_ID(''[ZooLogic].[INSERT_REGISTRODEBAJA_UNIDADDEMEDIDAAFIP]''), ''IsTrigger'') = 1' + @EndLine + 
								N'drop trigger [ZooLogic].[INSERT_REGISTRODEBAJA_UNIDADDEMEDIDAAFIP]'
	Exec( @Instruccion )
	Set @Instruccion =  N'CREATE TRIGGER ZooLogic.DELETE_REGISTRODEBAJA_UNIDADDEMEDIDAAFIP' + @EndLine + 
		N'ON ZooLogic.UNIAF' + @EndLine + 
		N'AFTER DELETE' + @EndLine + 
	N'As' + @EndLine + 
	N'Begin' + @EndLine + 
		N'delete t' + @EndLine + 
			N'from ZooLogic.RegBaja t inner join deleted d' + @EndLine + 
				N'on t.Entidad = ''UNIDADDEMEDIDAAFIP'' and cast( t.idEntidad as Numeric( 2, 0 ) ) = d.COD' + @EndLine + 
		N'insert into ZooLogic.RegBaja ( Codigo, Entidad, idEntidad, idGlobal, FecBaja, FAltaFw, HoraBaja )' + @EndLine + 
			N'select Newid(), ''UNIDADDEMEDIDAAFIP'', d.COD,  Null , GetDate(), GetDate(), convert( char(8), getdate(), 108 )' + @EndLine + 
				N'from deleted d' + @EndLine + 
	N'End'
	Exec( @Instruccion )
	Set @Instruccion =  N'CREATE TRIGGER ZooLogic.INSERT_REGISTRODEBAJA_UNIDADDEMEDIDAAFIP' + @EndLine + 
		N'ON ZooLogic.UNIAF' + @EndLine + 
		N'AFTER INSERT' + @EndLine + 
	N'As' + @EndLine + 
	N'Begin' + @EndLine + 
		N'delete t' + @EndLine + 
			N'from ZooLogic.RegBaja t inner join inserted i' + @EndLine + 
				N'on t.Entidad = ''UNIDADDEMEDIDAAFIP'' and cast( t.idEntidad as Numeric( 2, 0 ) ) = i.COD' + @EndLine + 
	N'End'
	Exec( @Instruccion )