SELECT       
      c.[UserId]
      ,u.UserName
      ,u.TypeUser
      ,uc.CompanyId
      ,cli.cmpnombre  as Company
	,cli.cmpcodigo as CompanyCodigoZL
      ,c.Anio
      ,c.Mes
      ,t.[Description] as Tipo
      ,un.[Description] as Unidad
      ,Valor
      ,c.[Method] as Metodo
  FROM
  (
  SELECT [UserId], year([Date]) as Anio, month([Date]) as Mes,[Unit] ,[Type], Sum([Value]) as Valor, [Method]
  FROM [zNubeProvisioning].[Accounting].[Consumption]
  WHERE [Date] BETWEEN @FechaDesde and @FechaHasta
  GROUP BY [UserId],year([Date]), month([Date])  ,[Unit] ,[Type], [Method]
  ) AS C
  
  INNER JOIN [zNubeProvisioning].[Accounting].[ConsumptionUnit] as un on c.[Unit] = un.Id
  INNER JOIN [zNubeProvisioning].[Accounting].[ConsumptionType] as t on c.[Type] = t.Id
  INNER JOIN [zNubeProvisioning].[Accounting].[User] as u on u.[UserId] = c.[UserId]
  INNER JOIN [zNubeProvisioning].[Accounting].[UserCompany] as uc on uc.[UserId] = c.[UserId]
  INNER JOIN [ZL].[ZL].[clientes] as cli with(nolock) on cli.codGuid = uc.CompanyID

	WHERE uc.CompanyID IN (@Company)

 Union All
  
  SELECT NULL AS UserId, 'Bases' as Username, 0 as TypeUser,d.CompanyId,  cli.cmpnombre  as Company
	,cli.cmpcodigo as CompanyCodigoZL, left(d.[Year_Month],4) as anio, right(d.[Year_Month],2) as mes, 
	'DB Size' as [Type] , 'Mb' as Unit, SUM(d.TotalSizeMB) as Valor,   d.ConnectionTypeName + ' - ' +  d.DbName as Metodo
	FROM [zNubeProvisioning].[Accounting].[DBSize] as d
	  INNER JOIN [ZL].[ZL].[clientes] as cli with(nolock) on cli.codGuid = d.CompanyID
	WHERE LEFT( convert(varchar(10),@FechaDesde,102),7) >= [Year_Month]
			and LEFT( convert(varchar(10),@FechaHasta,102),7)  <= [Year_Month]
			and CompanyID IN (@Company)
			
	GROUP BY CompanyId,cli.cmpnombre,cli.cmpcodigo , left([Year_Month],4), right([Year_Month],2), ConnectionTypeName + ' - ' +  DbName

	Union All	
		
	SELECT NULL AS UserId, 'Snapshots' as Username, 0 as TypeUser,s.[CompanyId], cli.cmpnombre  as Company
	,cli.cmpcodigo as CompanyCodigoZL, year(s.[Date]) as anio, MONTH(s.[Date]) as mes,
	'Snapshot Size' as [Type] , 'Mb' as Unit, Sum([Size]) as Valor, case when IsDefaultSnapshot = 1 then 'Snapshot Default' else s.[GrupoName] end as Descripcion     
  FROM [zNubeProvisioning].[Accounting].[SnapshotSize] as s
  INNER JOIN [ZL].[ZL].[clientes] as cli with(nolock) on cli.codGuid = s.CompanyID
  WHERE s.[Date] between  @FechaDesde and @FechaHasta
  and ([DeletedDate] is null or [DeletedDate]  between  @FechaDesde and @FechaHasta )
  and s.[CompanyId] IN (@Company)
  group by s.[CompanyId], cli.cmpnombre  ,cli.cmpcodigo , year(s.[Date]) , MONTH(s.[Date]) , case when IsDefaultSnapshot = 1 then 'Snapshot Default' else s.[GrupoName] end