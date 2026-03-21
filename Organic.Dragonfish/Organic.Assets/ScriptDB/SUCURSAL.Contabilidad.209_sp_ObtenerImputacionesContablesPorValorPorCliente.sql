IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[ObtenerImputacionesContablesPorValorPorCliente]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[ObtenerImputacionesContablesPorValorPorCliente];
GO;
Create Function [Contabilidad].[ObtenerImputacionesContablesPorValorPorCliente]
	(
		@tblImpdircli as Contabilidad.udt_TableType_Impdircli ReadOnly,
		@tblBasesAgrup as Contabilidad.udt_TableType_BasesAgrup ReadOnly,
		@BaseDeDatosActual char(8), 
		@SucursalActual char(10), 
		@TipoSucursalActual char(10)
	)
	returns @imputaciones table
	(	Cod char(10),
		NumeroImpValor numeric(8),
		PCuenta varchar(30)
	)
	as
	begin

		declare @CodAnterior char(10) = ''
		declare @NumeroImpValorAnterior numeric(8)
		declare @Cod char(10)
		declare @NumeroImpValor numeric(8)
		Declare @PCuenta varchar( 30 )
		Declare @Importancia varchar( 40 )

		Declare cImpDir Cursor for
			select  entidad.clcod, 
					i.impval NumeroImpValor, 
					i.pcuenta,
					isnull( replicate ('0',(10 - len(i.importanci))) + convert(varchar, i.importanci) + convert(char(8),i.FMODIFW,112) + i.HMODIFW, '' ) as Importancia
 				from zoologic.cli as entidad
					inner join @tblImpdircli i on   ( entidad.clcod between i.clidesde and i.clihasta )
												and ( i.sitfis = 0 or i.sitfis = entidad.cliva )
												and ( entidad.clvend between i.vendesde and i.venhasta )
												and ( entidad.cllisprec between i.lisdesde and i.lishasta )
												and ( entidad.clclas between i.cladesde and i.clahasta )
												and ( entidad.cltipocli between i.tipdesde and i.tiphasta )
												and ( entidad.clcategcli between i.catdesde and i.cathasta )
												and ( entidad.clprv between i.prodesde and i.prohasta )
												and ( entidad.clpais between i.paidesde and i.paihasta )
												and ( entidad.globalid between i.glodesde and i.glohasta )
												and ( @SucursalActual between i.sucdesde and i.suchasta )
												and ( @TipoSucursalActual between i.tsucdesde and i.tsuchasta )
												and ( i.base = ''
													or ( substring( i.base, 1, 1 ) <> '[' and i.base = @BaseDeDatosActual )
													or ( substring( i.base, 1, 1 ) = '['
														and replace(replace(i.base,'[',''),']','') in ( Select agrupamiento from @tblBasesAgrup where basededatos = @BaseDeDatosActual ) )
													)
				order by entidad.clcod, Importancia desc

		Open cImpDir
		Fetch Next From cImpDir Into @Cod, @NumeroImpValor, @PCuenta, @Importancia
		while @@FETCH_STATUS = 0
		begin
			if @Cod <> @CodAnterior or @NumeroImpValor <> @NumeroImpValorAnterior
			begin
				Insert into @imputaciones ( Cod, NumeroImpValor, pCuenta )
				Select @Cod, @NumeroImpValor, @pCuenta
			end
			set @CodAnterior = @Cod
			set @NumeroImpValorAnterior = @NumeroImpValor
			Fetch Next From cImpDir Into @Cod, @NumeroImpValor, @pCuenta, @Importancia
		end
		close cImpDir
		Deallocate cImpDir

		return
	end
