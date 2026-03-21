IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Interfaz_AFIPRG4523_RetencionesRealizadas_IVA]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Interfaz_AFIPRG4523_RetencionesRealizadas_IVA];
GO;

CREATE FUNCTION [Interfaces].[Interfaz_AFIPRG4523_RetencionesRealizadas_IVA] 
(
	@FechaComprobanteDesde varchar(10),
	@FechaComprobanteHasta varchar(10)
)
RETURNS TABLE
AS
RETURN
(
	select cast('0100' as char(4)) as Version,																												-- Cpo: 1,  Long: 4,  Pos: 1-4
		cast(' ' as char(36)) as CodigoDeTrazabilidad,																										-- Cpo: 2,  Long: 36,  Pos: 5-40
		cast('216' as char(3)) as Impuesto,																													-- Cpo: 3,  Long: 3,  Pos: 41-43
		cast(case when DatosExpo.Regimen is null then '000' else funciones.padl(funciones.Alltrim(DatosExpo.Regimen),3,'0') end as char(3) ) as Regimen,	-- Cpo: 4,  Long: 3,  Pos: 44-46
		cast(DatosExpo.FechaDeRetPerc as char(10)) as FechaDeRetPerc,																						-- Cpo: 5,  Long: 10,  Pos: 47-56
		cast(DatosExpo.Condicion as char(2)) as Condicion,																									-- Cpo: 6,  Long: 2,  Pos: 57-58
		cast(DatosExpo.ImposibilidadRetPerc as char(1)) as ImposibilidadRetPerc,																			-- Cpo: 7,  Long: 1,  Pos: 59
		cast('' as char(30)) as MotivoNoRetencion,																											-- Cpo: 8,  Long: 30, Pos: 60-89
		cast(funciones.padl(coalesce(DatosExpo.ImporteRetPerc,0),14,'0') as char(14)) as ImporteRetPerc,													-- Cpo: 9,  Long: 14,  Pos: 90-103
		cast(funciones.padl(coalesce(DatosExpo.ImporteBaseCalcCant,0),14,'0') as char(14)) as ImporteBaseCalcCant,											-- Cpo: 10, Long: 14,  Pos: 104-117
		cast(DatosExpo.RegimenExclusion as char(1)) as RegimenExclusion,																					-- Cpo: 11, Long: 1,  Pos: 118
		cast(case when DatosExpo.RegimenExclusion = '1' then '100.00' else '000.00' end  as char(6)) as PorcentajeExclusion,								-- Cpo: 12, Long: 6, Pos: 119-124
		cast(funciones.padl(DatosExpo.FechaDePublicacion,10,' ') as char(10)) as FechaDePublicacion,														-- Cpo: 13, Long: 10, Pos: 125-134
		cast(funciones.padl(DatosExpo.TipoComprobante,2,'0') as char(2)) as TipoComprobante,																-- Cpo: 14, Long: 2,  Pos: 135-136
		cast(DatosExpo.FechaDeComprobante as char(10)) as FechaDeComprobante,																				-- Cpo: 15, Long: 10, Pos: 137-146
		cast(funciones.padl(DatosExpo.NroComprobante,16,' ') as char(16)) as NroComprobante,																-- Cpo: 16, Long: 16,  Pos: 147-162
		cast('' as char(12)) as COE,																														-- Cpo: 17, Long: 12,  Pos: 163-174
		cast('' as char(12)) as COEOriginal,																												-- Cpo: 18, Long: 12,  Pos: 175-186
		cast('' as char(14)) as CAE,																														-- Cpo: 19, Long: 14,  Pos: 187-200
		cast(funciones.padl(DatosExpo.ImporteComprobante,14,'0') as char(14)) as ImporteComprobante,														-- Cpo: 20, Long: 14, Pos: 201-214
		cast(funciones.padl(coalesce(DatosExpo.MotivoEmisionNC,''),30,' ') as char(30)) as MotivoEmisionNC,													-- Cpo: 21, Long: 30,  Pos: 215-244
		cast(funciones.padl(coalesce(DatosExpo.RetenidoPercibido,''),11,'0') as char(11)) as RetenidoPercibido,												-- Cpo: 22, Long: 11,  Pos: 245-255
		cast('' as char(25)) as CertificadoOriginal,																										-- Cpo: 23, Long: 25,  Pos: 256-280
		cast('' as char(10)) as CertOrigFechaReten,																											-- Cpo: 24, Long: 10,  Pos: 281-290
		cast('' as char(14)) as CertOrigImporte,																											-- Cpo: 25, Long: 14,  Pos: 291-304
		cast('' as char(1)) as MotivoAnulacion																												-- Cpo: 26, Long: 1,  Pos: 305-305
		
	from (
			select
			case when c_impuesto.REGIMENIMP = '831' then '01' else '00' end as Condicion,
			c_impuesto.REGIMENIMP as Regimen,
			convert(varchar(10),c_ordpago.FFCH,103) as FechaDeRetPerc,
			cast(c_crimpdet.MONTO as numeric(11,2)) as ImporteRetPerc,
			cast(c_crimpdet.MONTOBASE as numeric(11,2)) as ImporteBaseCalcCant,
			case when c_impodp.CODIGO is null then 1 else 0 end as ImposibilidadRetPerc,
			c_prov.EXRETIVA as RegimenExclusion,
			case when c_prov.EXRETIVA = 0 then 0 else 100 end as PorcentajeExclusion,
			case when c_prov.EXRETIVA = 1 then convert(varchar(10),c_prov.PVHASTAIVA,103) else '' end as FechaDePublicacion,
			case when c_conver.valdest is null then c_ordpago.FACTTIPO else c_conver.VALDEST end as TipoComprobante,
			convert(varchar(10),c_ordpago.FFCH,103) as FechaDeComprobante,
			funciones.padl(c_ordpago.FPTOVEN,4,'0') + funciones.padl(c_ordpago.fnumcomp,8,'0') as NroComprobante,
			'' as CAE,
			c_ordpago.ftotal as ImporteComprobante,
			'' as MotivoEmisionNC,
			c_prov.clcuit as RetenidoPercibido
			from
			ZooLogic.ORDPAGO as c_ordpago
			left join ZooLogic.IMPODP as c_impodp on c_ordpago.CODIGO = c_impodp.CODIGO 
			left join ZooLogic.IMPUESTO as c_impuesto on c_impodp.CODIMP = c_impuesto.CODIGO 
			left join zoologic.crimpdet AS c_crimpdet on c_crimpdet.codigo = c_impodp.CODIgocdr 
			inner join ZooLogic.PROV as c_prov on c_ordpago.FPERSON = c_prov.CLCOD
			left join ORGANIZACION.CONVERVAL as c_conver on c_conver.conversion = 'SIRETIPOCOMPROBANTE' and c_ordpago.FACTTIPO = c_conver.VALORIG
			WHERE C_IMPODP.TIPOIMP = 'IVA' AND ( c_crImpDet.SIRECERT = '' )
			  and c_crimpdet.MONTOBASE <> 0.00 and c_crimpdet.MONTO <> 0.00
			  and ( ( @FechaComprobanteDesde is null ) or ( c_ordpago.FFch >= @FechaComprobanteDesde ) ) 
			  and ( ( @FechaComprobanteHasta is null ) or ( c_ordpago.FFch <= @FechaComprobanteHasta ) )
	          and c_impuesto.RegimenImp is not null and c_impuesto.RegimenImp IN (15, 16,17,18,208,209,210,211,212,214,215,216,217,218,219,225,234,280,499,689,690,777,831,966)
			   -- EXPORTAR SOLO LOS QUE TENGAN REGIMEN VALIDO PARA EL IMPUESTO 216
	) as DatosExpo
)