Use [ZL]
go 

--/****** Objeto:  StoredProcedure [ZL].[FotoZooLogic]    Fecha de la secuencia de comandos: 05/13/2009 11:30:43 ******/
IF  NOT EXISTS (
 SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[FotoZooLogic]') AND type in (N'P', N'PC'))
  begin  
    exec('create proc [ZL].[FotoZooLogic] as ')
  end   

/****** Objeto:  StoredProcedure [ZL].[FotoZooLogic]    Fecha de la secuencia de comandos: 05/13/2009 11:30:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [ZL].[FotoZooLogic]
	@FechaFoto datetime ,
	@EstadoNO varchar( 2 ) , 
	@EstadoNI varchar( 2 ) ,
	@EstadoSI varchar( 2 ) ,
	@EstadoMR varchar( 2 ) 

AS
BEGIN

select convert( char(8), getdate(), 112 ) + '_' + I.nroserie as CMPCLA, 
		@FechaFoto as FEC_FO1, 
		cast(funciones.padl( year( @FechaFoto ), 4 , '0') + '-' + 
				funciones.padl( Month( @FechaFoto ), 2 , '0') as char(7)) as FEC_FO2, 
		isnull( case when right( I.Codart, 3 ) = '-TI' then RIS.nroSerie else I.nroserie end, '' ) as Serie,
		'01' as Orden,
		SE.puesto as C_SUC,
		isnull(I.crass, '') as C_RZ_COD,
		isnull(RZ.Descrip, '') as C_RZ_NOM,
		AC.cRegimen as RZCORCOD,
		Eq.Descr as RZCORNOM,
		isnull(RZ.Cliente, '') as CLICOD,
		isnull(CLI.cmpNombre, '') as CLINOM,
		getdate() as CLFCHAL1,
		cast( funciones.padl( year( I.cmpFeCAlt ), 4 , '0') + '-' + 
				funciones.padl( Month( I.cmpFeCAlt ), 2 , '0') as char(7) ) as CLFCHAL2,
		replicate( ' ', 2 ) as CLICORIN1,
		replicate( ' ', 20 ) as CLICORIN2,
		isnull(CLI.cmpClasif,'') as CLICLCL1,
		isnull(CLA.Nombre,'') as CLICLCL2,
		'' as C_PRINCI,
		'' as C_USO,
		isnull( USO.Nombre, '' ) as CUSODESC,
		isnull( SE.cDir, 0 ) as CSERIEDI,
		'' as CCLIDIR,
		isnull(rz.cDir,0) as CRZDIR,
		isnull( case when upper( left( rz.Lstprecios, 5) ) = 'ZOO00' 
				Then right( rz.Lstprecios, 1 ) else rz.Lstprecios end, '' )as CRZLISTA,
		CD.cRegimen as CORCOD,
		EQ2.Descr as CORNOM,
		cast( funciones.padl( Case When isnull( I.Contadm, '' ) = '' or  isnull( I.Contadm, '' ) = '00' Then '0' 
				else Replace( I.Contadm, '0', '' ) end, 2, ' '  ) as char(2) )  as va,

		isnull(CON.Nombre,'') as VADESC,
		I.cmpFeCAlt as FCALT,
		I.cmpFeCAlt as FCALTAAM,
		cast( funciones.padl( year( I.cmpFeCAlt ), 4 , '0') + '-' + 
				funciones.padl( Month( I.cmpFeCAlt ), 2 , '0') as char( 7 ) ) as FCALTAME,
		cast( funciones.Proper( case when I.cmpFeCAlt = '1900-01-01' and I.FeBaVig = '1900-01-01' then @EstadoNI Else 
			case when I.cmpFeCAlt = '1900-01-01' and I.FeBaVig <> '1900-01-01' then @EstadoNO Else
			case when I.cmpFeCAlt <> '1900-01-01' and I.FeBaVig = '1900-01-01' then EST.codFZ Else
			case when I.cmpFeCAlt <> '1900-01-01' and I.FeBaVig > @FechaFoto Then EST.codFZ Else @EstadoNO
			end end end end ) as char(2) ) as activo,
		isnull( case when left( i.Codart, 3 ) = i.Contadm + '-' 
				THEN substring( i.Codart,4, len( i.Codart ) - 3 ) 
				ELSE i.Codart END, '' ) AS Art_Cod,
		'000' as TOTCENTR,
		isnull( PR.PDIRECTO, 0 ) as ART_PRECIO,
		isnull( ART.Descr, '' ) as ART_DESC,
		isnull( case when medpago = 'CC' then 0 else 
				case when medpago in ( 'BAN', 'AMEX', 'MAST', 'FRA', 'VISA', 'PRE' ) 
				then 1 else case when medpago = '' 
				then 2 end end end, 0 ) as rz_facsn,
		case when RZ.medpago = 'CC' Then 'NO' else RZ.medpago end as TARJETA,
		isnull( ART.CodLince, '' )  as codlince
from zl.itemserv I
left join zl.RazonSocial RZ on I.Crass = RZ.cmpCod
left join zl.Clientes CLI on CLI.cmpcodigo = RZ.Cliente
left join zl.Clasific CLA on CLA.Codigo = CLI.cmpClasif
left join zl.Contrato CON on CON.Codigo = I.Contadm
left join zl.Precioar PR on PR.ARTICULO = I.Codart
left join zl.ISARTICU ART on ART.cCod = I.Codart
left join zl.Series SE on SE.Nroserie = I.Nroserie
left join zl.Usos USO on USO.Codigo = SE.Usosadm
left join ( select A.nrz, E.codFZ from zl.ASESTRZAD A
			left join zl.estado E on A.cEstado = E.Codigo
			where numero in ( select max( numero ) as numero from zl.ASESTRZAD  group by nrz ) ) EST on EST.nrz = I.cRass
Left join zl.relaciontiis RIS on RIS.ccod = I.cCod
left join zl.ASESCOMAC AC on I.Crass = AC.Nrz
left join zl.esqcom EQ on AC.cRegimen = EQ.cCod
left join zl.Comasisesc CD on I.cCod = CD.Codis
left join zl.esqcom EQ2 on CD.cRegimen = EQ2.cCod
order by I.nroserie 

end


