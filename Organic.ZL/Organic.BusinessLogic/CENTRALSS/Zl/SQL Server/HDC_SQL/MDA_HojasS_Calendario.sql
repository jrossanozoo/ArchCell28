USE [ZL]
GO

/****** Object:  UserDefinedFunction [ZL].[MDA_HojasS_Calendario]    Script Date: 05/21/2013 15:31:14 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[MDA_HojasS_Calendario]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [ZL].[MDA_HojasS_Calendario]
GO

USE [ZL]
GO

/****** Object:  UserDefinedFunction [ZL].[MDA_HojasS_Calendario]    Script Date: 05/21/2013 15:31:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =========================================================================================
-- Author:		MatiasB
-- Create date: 09/10/2009
-- Description:	Función usada para el calendario de Hojas de Servicio de Reporting Services
-- Ejemplo:		select * from [ZL].[MDA_HojasS_Calendario] ('20100404','20100413')
-- Modified: HCORREA
-- Modified date: 21/05/2013 
-- SE MODIFICO PARA REMPLAZAR "DEP" POR "DEPTO"
--  SE AGREGO ".ar" A LA URL DE BUSQUEDA PARA GOOGLE MAPS
-- =========================================================================================

CREATE FUNCTION [ZL].[MDA_HojasS_Calendario] 
(	
	-- Add the parameters for the function here
	@FechaPdesde datetime,
	@FechaPhasta datetime
)
RETURNS TABLE 
AS
RETURN 
(

	SELECT  Nume AS Numero
		,case when LTRIM(RTRIM(Asiga))=''  then 'Sin Asignar' else zl.funciones.alltrim(Asiga) end as Asiga
		,DateName(weekday,FechaP) as NombreDia
		,datepart(year,FechaP)as anio
		,datepart(month,FechaP) as mes
		,datepart(day,FechaP) as dia
		,/*se establece una marca para servicios de instalaciones de lince o guepardo-preparado de bolsas  desde ATC*/
		
		case when 
		(select count(*) from zl.hojserv as hoja inner join zl.dshs on hoja.nume = zl.dshs.codigo 
			where hoja.nume = zl.hojserv.nume
			and zl.dshs.ccon in ('00001','00046','00036','00049', '00054') 
		) >= 1 
		then 'i' else '' end as EsInstalacion
		
		,case when (select count(*) from zl.hojserv as hoja inner join zl.dshs on hoja.nume = zl.dshs.codigo 
					where hoja.nume = zl.hojserv.nume
						and zl.dshs.ccon in ('00116') --formulario de adhesión
					)
					>= 1 
		then 'f' else '' end as FormAdh
		
		,Horap
		,Minutop
		,zl.funciones.alltrim(ZL.TOLHS.DESCR) AS Tolerancia
		,Horap+3 as HoraFin
		,zl.funciones.alltrim(zl.clientes.cmpnombre) + ' - ' + zl.funciones.alltrim(zl.razonsocial.descrip) as RS
		,Contactos.Direccion
		,Contactos.DireccionWebGoogleMaps
		,fechap
		--,case when LTRIM(RTRIM(Asiga))=''  then 'Sin Asignar' else
		--			ZL.SectorSegunFechayUsuarioSinSGCniDIR(FechaP,LTRIM(RTRIM(Asiga)))
		--			end
		--			as Sectores
		,IsNull(r.subsector,'Sin Asignar') as Sectores			
		,datepart(week,Fechap) as NroSemana
		
		,case when month(dateadd(wk,datediff(wk,0,FechaP),0)) < month(FechaP) 
		/*si el primer dia de la semana es en el mes anterior, entonces cortar la semana al primer dia del mes*/
					then dateadd(mm,datediff(mm,0,FechaP),0) 
					else dateadd(wk,datediff(wk,0,FechaP),0) end as PrimerDiaSemana
		
		, case when month(dateadd(wk,datediff(wk,0,FechaP),6)) > month(FechaP) 
		/*si el ultimo dia de la semana se da en el mes proximom entonces tomar hasta el ultimo dia del mes*/
				then dateadd(dd,-1,dateadd(mm,0,dateadd(mm,datediff(mm,0,FechaP)+1,0)))
				else dateadd(wk,datediff(wk,0,FechaP),6) end as UltimoDiaSemana

		,TECNICOLOR.color 
		,(select case when count(*) > 0 then 'Si' else  'No' end as Verificada
			from zl.DACMDA where zl.DACMDA.codigo = ZL.Hojserv.nume and zl.DACMDA.taccio = '0002' ) as Verificada
		
		, (select top 1 zl.funciones.alltrim(descr) from 
						zl.dshs where zl.dshs.codigo  = ZL.Hojserv.nume
						and ccon not in ('00061','00062','00063')
						order by ccon) as Servicio
	
FROM         
		ZL.Hojserv 
		left join ZL.RrhhPuestosHistoricos  as r on r.empleado = LTRIM(RTRIM(Hojserv.asiga)) 
													and Hojserv.FechaP between r.finicio and r.ffin

		INNER JOIN ZL.TOLHS  ON ZL.Hojserv.TOLER = ZL.TOLHS.CCOD 
		inner join zl.razonsocial on ZL.Hojserv.razonsoc= zl.razonsocial.cmpcod
		inner join zl.clientes on ZL.Hojserv.ccliente = zl.clientes.cmpcodigo
		left join 
					(select distinct NumeroHS, Direccion, DireccionWebGoogleMaps from 
					
					(
					select	ZL.Hojserv.Nume as NumeroHS,
							case when Cdiruni = '' then contactos.[Dirección Completa]
													else [Vista_Direcciones].DireccionCompleta
								end as Direccion,
										
					'http://maps.google.com.ar/maps?q=' + 
					replace(
					replace(
					replace(
					replace(
					replace(
					replace (
					case when Cdiruni = '' then contactos.[Dirección Completa]
													else [Vista_Direcciones].DireccionCompletaWeb
													end
									
					,'ú','u'),'ó','o'),'í','i'),'é','e'),'á','a'),' ','+')
					as DireccionWebGoogleMaps   

					from ZL.Hojserv
							INNER JOIN
							 ZL.Dchser ON ZL.Hojserv.Nume = ZL.Dchser.Codigo 
							 LEFT JOIN
							zl.contactos on ZL.Dchser.Ccon = contactos.[Código Contacto]
							LEFT JOIN (SELECT 
										codigoDireccion, 
										RTRIM(Calle)+' '+RTRIM(Num)+' '+RTRIM(Localidad)+' '+RTRIM(ProvinciaNombre) AS DireccionCompletaWeb
										,DireccionCompleta
									   FROM 
										ZL.Vista_Direcciones) AS [Vista_Direcciones] on [Vista_Direcciones].codigoDireccion = ZL.Hojserv.Cdiruni
					)
					as repetidos
					
					
					)
		as Contactos on ZL.Hojserv.Nume = Contactos.NumeroHS

		LEFT JOIN 

		(SELECT * FROM 

			(							

				select Dueno, Row_Number()  over (order by Dueno) as Codigo, Sector

				from (							

				select distinct case when zl.funciones.alltrim( Asiga) ='' 
												then 'Sin Asignar' 
												else  zl.funciones.alltrim( Asiga) end as Dueno,
												lh.sector
				FROM         ZL.Hojserv  

				left join ZL.RrhhPuestosHistoricos as lh on LTRIM(RTRIM(ZL.Hojserv.Asiga)) = lh.empleado
				and zl.hojserv.FechaP between lh.finicio and lh.ffin
				where		zl.hojserv.FechaP >= '20090301' and lh.sector in ('SAL',NULL, 'MDA', 'ATC', 'IMP', 'DYC')
				and lh.ffin = '2999-12-31 00:00:00.000'
				) AS T

			)as  TECNICOS

				LEFT JOIN 

				(	/*SELECT 1 AS COD, '#A91616' as Color Union all
					SELECT 2 AS COD, '#FF0000' as Color Union all
					SELECT 3 AS COD, '#FA5858' as Color Union all
					SELECT 4 AS COD, '#DF7401' as Color Union all
					SELECT 5 AS COD, '#FE9A2E' as Color Union all
					SELECT 6 AS COD, '#F7BE81' as Color Union all
					SELECT 7 AS COD, '#868A08' as Color Union all
					SELECT 8 AS COD, '#D7DF01' as Color Union all
					SELECT 9 AS COD, '#F7FE2E' as Color Union all
					SELECT 10 AS COD, '#F3F781' as Color Union all
					SELECT 11 AS COD, '#088A08' as Color Union all
					SELECT 12 AS COD, '#62DE62' as Color Union all
					SELECT 13 AS COD, '#088A4B' as Color Union all
					SELECT 14 AS COD, '#01DF74' as Color Union all
					SELECT 15 AS COD, '#58FAAC' as Color Union all
					SELECT 16 AS COD, '#088A85' as Color Union all
					SELECT 17 AS COD, '#01DFD7' as Color Union all
					SELECT 18 AS COD, '#58FAF4' as Color Union all
					SELECT 19 AS COD, '#81F7F3' as Color Union all
					SELECT 20 AS COD, '#084B8A' as Color Union all
					SELECT 21 AS COD, '#2E9AFE' as Color Union all
					SELECT 22 AS COD, '#81BEF7' as Color Union all
					SELECT 23 AS COD, '#5656D3' as Color Union all
					SELECT 24 AS COD, '#5858FA' as Color Union all
					SELECT 25 AS COD, '#8181F7' as Color Union all
					SELECT 26 AS COD, '#7401DF' as Color Union all
					SELECT 27 AS COD, '#8A0886' as Color Union all
					SELECT 28 AS COD, '#E3F6CE' as Color Union all
					SELECT 29 AS COD, '#F6E3CE' as Color Union all
					SELECT 30 AS COD, '#5FB404' as Color Union all
					SELECT 31 AS COD, '#8A4B08' as Color Union all
					SELECT 32 AS COD, '#CD9E8A' as Color Union all
					SELECT 33 AS COD, '#5B8464' as Color Union all
					SELECT 34 AS COD, '#A44B5A' as Color */
					SELECT 1 AS COD, '#A91616' as Color Union all
					SELECT 2 AS COD, '#FF0000' as Color Union all
					SELECT 3 AS COD, '#FA5858' as Color Union all
					SELECT 4 AS COD, '#DF7401' as Color Union all
					SELECT 5 AS COD, '#FE9A2E' as Color Union all
					SELECT 6 AS COD, '#F7BE81' as Color Union all
					SELECT 7 AS COD, '#868A08' as Color Union all
					SELECT 8 AS COD, '#D7DF01' as Color Union all
					SELECT 9 AS COD, '#F7FE2E' as Color Union all
					SELECT 10 AS COD, '#F3F781' as Color Union all
					SELECT 11 AS COD, '#088A08' as Color Union all
					SELECT 12 AS COD, '#62DE62' as Color Union all
					SELECT 13 AS COD, '#088A4B' as Color Union all
					SELECT 14 AS COD, '#01DF74' as Color Union all
					SELECT 15 AS COD, '#58FAAC' as Color Union all
					SELECT 16 AS COD, '#088A85' as Color Union all
					SELECT 17 AS COD, '#01DFD7' as Color Union all
					SELECT 18 AS COD, '#58FAF4' as Color Union all
					SELECT 19 AS COD, '#81F7F3' as Color Union all
					SELECT 20 AS COD, '#084B8A' as Color Union all
					SELECT 21 AS COD, '#2E9AFE' as Color Union all
					SELECT 22 AS COD, '#81BEF7' as Color Union all
					SELECT 23 AS COD, '#5656D3' as Color Union all
					SELECT 24 AS COD, '#5858FA' as Color Union all
					SELECT 25 AS COD, '#8181F7' as Color Union all
					SELECT 26 AS COD, '#7401DF' as Color Union all
					SELECT 27 AS COD, '#8A0886' as Color Union all
					SELECT 28 AS COD, '#E3F6CE' as Color Union all
					SELECT 29 AS COD, '#F6E3CE' as Color Union all
					SELECT 30 AS COD, '#5FB404' as Color Union all
					SELECT 31 AS COD, '#8A4B08' as Color Union all
					SELECT 32 AS COD, '#CD9E8A' as Color Union all
					SELECT 33 AS COD, '#5B8464' as Color Union all
					SELECT 34 AS COD, '#A44B5A' as Color Union all 
					SELECT 35 AS COD, '#FFCC99' as Color Union all 
					SELECT 36 AS COD, '#FF6600' as Color Union all
					SELECT 37 AS COD, '#CC9966' as Color Union all
					SELECT 38 AS COD, '#99CCCC' as Color Union all
					SELECT 39 AS COD, '#339966' as Color  Union all
					SELECT 40 AS COD, '#CCCCFF' as Color Union all
					SELECT 41 AS COD, '#B89480' as Color Union all 
					SELECT 42 AS COD, '#FF6633' as Color Union all 
					SELECT 43 AS COD, '#FFCCCC' as Color 
					)
					AS COLORES ON COLORES.COD = TECNICOS.CODIGO


			) AS TECNICOLOR ON TECNICOLOR.Dueno = zl.funciones.alltrim(zl.hojserv.Asiga)


where	zl.hojserv.FechaP between (@FechaPdesde) and (@FechaPhasta)
and Hojserv.nume not in (select codigo  from ZL.Dacmda where taccio = '0009' )
and IsNull(r.subsector,'Sin Asignar') <>'IMP'
	--	and (ZL.SectorSegunFechayUsuarioSinSGCniDIR(FechaP,zl.funciones.alltrim(Asiga)) in (@Sector))
		--and (case when zl.funciones.alltrim( Asiga) ='' then 'Sin Asignar' else   zl.funciones.alltrim(Asiga) end in (@Dueno))
		and  Nume not in (
	
							select nume from zl.hojserv
							where zl.hojserv.FechaP between (@FechaPdesde) and (@FechaPhasta)
								and ZL.SectorSegunFechayUsuarioSinSGCniDIR(FechaP,zl.funciones.alltrim(Asiga))='SAL'
							and nume not in ( /*números que no tengan servicio domiciliario como servicio o que 
										no tengan mas de una instalación en el mismo lugar el mismo dia y la misma persona*/
									/*hojas de servicio de mesa de ayuda con mas de una instalacion por lugar -  tienen que ir*/
											select nume from zl.hojserv inner join zl.DCHSER on zl.hojserv.nume = zl.DCHSER.codigo
														inner join (
																	select zl.funciones.alltrim(zl.hojserv.Asiga) duenio, 
																			zl.hojserv.fechap, zl.DCHSER.ccon, count(*) cantidad
																			from zl.hojserv
																					inner join zl.DCHSER  on zl.hojserv.nume = zl.DCHSER.codigo
																			where	zl.hojserv.FechaP between (@FechaPdesde) and (@FechaPhasta)
																					and ZL.SectorSegunFechayUsuarioSinSGCniDIR(FechaP,zl.funciones.alltrim(Asiga))='SAL'
																			group by zl.funciones.alltrim(zl.hojserv.Asiga),  zl.hojserv.fechap, zl.DCHSER.ccon
																			having count(*) > 1
								
																	) as Masde1Serie

															on  zl.funciones.alltrim(zl.hojserv.Asiga) = Masde1Serie.duenio 
															and Masde1Serie.fechap =zl.hojserv.fechap and  Masde1Serie.ccon =zl.DCHSER.ccon 
														where zl.hojserv.FechaP between (@FechaPdesde) and (@FechaPhasta)
							
											group by nume
					
											union all

											/*hojas de servicio de mda con servicio domiciliario - tienen que ir*/
											select nume from zl.hojserv
											where zl.hojserv.FechaP between (@FechaPdesde) and (@FechaPhasta)
											and ZL.SectorSegunFechayUsuarioSinSGCniDIR(FechaP,zl.funciones.alltrim(Asiga))='SAL'
											and 
											nume in ( /*números que no tengan servicio domiciliario como servicio*/
														select  codigo from zl.dshs
														where ccon in ( select codigo from zl.servicioot
														where descrip like '%domicil%' or codigo in ('00129','00130','00131')
																		)	
													)
										)

						 )
						 
						 
						 
						 
						 
)



GO