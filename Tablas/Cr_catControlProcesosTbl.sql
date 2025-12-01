Use SCMBD
Go

If Exists (Select Top 1 1
           From   sysobjects
           Where  Uid  = 1
           And    Type = 'U'
           And    Name = 'catControlProcesosTbl')
   Begin 
      Drop Table dbo.catControlProcesosTbl
   End
Go

Create Table dbo.catControlProcesosTbl
  (idProceso           Smallint     Not Null,
   descripcion         Varchar(100) Not Null,
   procedimiento       Sysname      Not Null,
   tablaLog            Sysname      Not Null,
   mensaje             Varchar(Max) Not Null Default '',
   mensajeError        Varchar(Max) Not Null Default '',
   idTipoNotificacion  Tinyint      Not Null Default 1,
   enviaNotificacion   Tinyint      Not Null Default 2,
   idFiltraError       Bit          Not Null Default 1,
   link                Varchar(512)     Null,
   codigoGrupoCorreo   Varchar( 20)     Null,
   periodicidad        Varchar( 60)     Null,
   ultFechaEjecucion   Datetime         Null,
   idEstatus           Bit          Not Null Default 1,
   fechaAct            Datetime     Not Null Default Getdate(),
   procedimientoNotif  Sysname          Null,
   ultFechaNotifif     Datetime         Null,
Constraint catControlProcesosPk
Primary Key (idProceso),
Constraint catControlProcesosCk01
Check (idTipoNotificacion In (0, 1, 2))

)
Go

--
-- Comentarios
--

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Tabla de Procesos de Mantenimientos a las Bases de Datos' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'catControlProcesosTbl'

Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Identificador Correlativo del Proceso de Mantenimiento.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'catControlProcesosTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'idProceso'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Descripción del Proceso de Mantenimiento.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'catControlProcesosTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'descripcion'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Nombre del Procedimiento Relacionado al Proceso de Mantenimiento.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'catControlProcesosTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'procedimiento'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Nombre de la Tabla que Contiene el Log de Proceso.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'catControlProcesosTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'tablaLog'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Mensaje del Proceso.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'catControlProcesosTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'mensaje'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Mensaje de Error Para el Proceso.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'catControlProcesosTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'mensajeError'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Identificador del Tipo de Notificación para la Notificación.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'catControlProcesosTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'idTipoNotificacion'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Identificador de Filtro de Información solo por Procesos en Error' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'catControlProcesosTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'idFiltraError'
Go


Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Identificador del Estatus del Registro.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'catControlProcesosTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'idEstatus'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Última Fecha de Actualización del Registro.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'catControlProcesosTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'fechaAct'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Flag que indica si envia Notitificación. 0 = No, 1 = Solo con Errores, 2 = Siempre' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'catControlProcesosTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'enviaNotificacion'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Link de Información Adicional' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'catControlProcesosTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'link'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Grupo de Usuarios a los Cuales se les informará sobre el resultado del proceso' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'catControlProcesosTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'codigoGrupoCorreo'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Información sobre la periodicidad de ejecución del proceso.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'catControlProcesosTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'periodicidad'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Última fecha de ejecución del proceso.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'catControlProcesosTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'ultFechaEjecucion'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Procedimiento que notifica el resultado del proceso.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'catControlProcesosTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'procedimientoNotif'
Go

Execute sys.sp_addextendedproperty @name       = 'MS_Description', 
                                   @value      = 'Última fecha de Notificación del proceso.' , 
                                   @level0type = 'Schema',
                                   @level0name = 'dbo', 
                                   @level1type = 'Table',
                                   @level1name = 'catControlProcesosTbl', 
                                   @level2type = 'Column',
                                   @level2name = 'ultFechaNotifif'
Go

