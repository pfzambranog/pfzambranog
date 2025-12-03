Use SCMBD
GO

Create or Alter Trigger dbo.TrinscatMantenimentoTablasTbl
On     dbo.catMantenimentoTablasTbl
After  Insert, update
AS

Set Ansi_nulls        On
Set Quoted_identifier On
Set Nocount           On

Declare
  @w_idTipoDep	           Tinyint,
  @w_baseDatos             Sysname,
  @w_procedimiento         Sysname,
  @w_tabla                 Sysname,
  @w_tablaProceso          Sysname,
  @w_column                Sysname,
  @w_columnProceso         Sysname,
  @w_dias                  Smallint,
  @w_comilla               Char(1),
  @w_mensaje               Varchar (500),
  @w_sql                   Varchar (Max),
  @w_status                Nvarchar(120);

Declare
   @t_tabla                Table
  (secuencia               Integer Not Null Identity Primary Key,
   tabla                   Sysname     Null,
   valor                   Integer     Null);

Begin

   Select @w_baseDatos             = baseDatos,
          @w_procedimiento         = procedimiento,
          @w_tabla                 = tabla,
          @w_column                = campo,
          @w_idTipoDep             = idTipoDep,         
          @w_dias                  = dias,
          @w_comilla               = Char(39),
          @w_tablaProceso          = 'catMantenimentoTablasTbl',
          @w_columnProceso         = 'idTipoDep'
   From   Inserted
   If @@Rowcount = 0
      Begin
         Return
      End

   Select Top 1 @w_status = state_desc
   From   sys.databases
   Where  name = @w_baseDatos;
   If @@Rowcount = 0
      Begin
         Set @w_mensaje = Concat('La Base de Datos Seleccionada  "', @w_baseDatos, '" no Existe: ');

         Raiserror (@w_mensaje, 16, 1)
         Rollback Transaction
         Return
      End

   If @w_status != 'ONLINE'
      Begin
         Set @w_mensaje = Concat('La Base de Datos Seleccionada  "', @w_baseDatos, '" no esta en Línea: ');

         Raiserror (@w_mensaje, 16, 1)
         Rollback Transaction
         Return
      End


   Set @w_sql = Concat('Select  Top 1 b.name ',
                       'From   ',  @w_baseDatos, '.sys.tables  b ',
                       'Where  b.name      = ', @w_comilla, @w_tabla, @w_comilla);

   Insert Into @t_tabla
   (tabla)
   Execute (@w_sql);
   If @@Rowcount = 0
      Begin
         Set @w_mensaje = Concat('La Tabla "', @w_tabla, '" no Existe en la Base de Datos.: ', @w_baseDatos);

         Raiserror (@w_mensaje, 16, 1)
         Rollback Transaction
         Return
      End

   Set @w_sql = Concat('Select a.name ',
                       'From   ',  @w_baseDatos, '.sys.columns a ',
                       'Join   ',  @w_baseDatos, '.sys.tables  b ',
                       'On     b.object_id = a.object_id ',
                       'And    b.name      = ', @w_comilla,  @w_tabla,         @w_comilla, ' ',
                       'And    a.name      = ', @w_comilla,  @w_column, @w_comilla);

   Insert Into @t_tabla
   (tabla)
   Execute (@w_sql);
   If @@Rowcount = 0
      Begin
         Set @w_mensaje = Concat('La Columna Seleccionada "', @w_column, '" no Existe en la Tabla.: ', @w_tabla);

         Raiserror (@w_mensaje, 16, 1)
         Rollback Transaction
         Return
      End

   Set @w_sql = Concat('Select Top 1 valor ',
                       'From   ',  @w_baseDatos, '..catGeneralesTbl a ',
                       'Where  tabla   = ', @w_comilla, @w_tablaProceso,  @w_comilla, ' ',
                       'And    columna = ', @w_comilla, @w_columnProceso, @w_comilla, ' ',
                       'And    valor   = ', @w_idTipoDep);

   Insert Into @t_tabla
   (valor)
   Execute (@w_sql);

   If @@Rowcount = 0
      Begin
         Set @w_mensaje = Concat('El Tipo de Depuración Selecciondo "', @w_idTipoDep, '" no es Válido. ');

         Raiserror (@w_mensaje, 16, 1)
         Rollback Transaction
         Return
      End

   If @w_idTipoDep = 2
      Begin
         Set @w_sql = Concat('Select a.name ',
                             'From   ',  @w_baseDatos, '.sys.procedures a ',
                             'Join   ',  @w_baseDatos, '.sys.schemas    b ',
                             'On     b.schema_id = a.schema_id ',
                             'Join   ',  @w_baseDatos, '.information_schema.schemata c ',
                             'On     c.SCHEMA_NAME  = b.name ',
                             'And    c.CATALOG_NAME = ', @w_comilla, @w_baseDatos,     @w_comilla, ' ',
                             'Where  a.name         = ', @w_comilla, @w_procedimiento, @w_comilla);
         
         Insert Into @t_tabla
         (tabla)
         Execute (@w_sql);
         
         If @@Rowcount = 0
            Begin
               Set @w_mensaje = 'El Procedimiento "' + @w_procedimiento + '" no Existe en la Base de Datos.: ' + @w_baseDatos;
         
               Raiserror (@w_mensaje, 16, 1)
               Rollback Transaction
               Return
            End
      End

   If Isnull(@w_dias, 0) = 0
      Begin
         Set @w_mensaje = Concat('El Parámetro de dias Seleccionado "',  @w_dias, '" no es Válido. Debe ser mayor a Cero');

         Raiserror (@w_mensaje, 16, 1)
         Rollback Transaction
         Return
      End

   Return

End
Go

--
-- Comentarios.
--

Declare
   @w_valor          Varchar(1500) = 'Disparador de Insert / Update de la entidad catMantenimentoTablasTbl.',
   @w_tabla          Sysname       = 'catMantenimentoTablasTbl',
   @w_objeto         Sysname       = 'TrinscatMantenimentoTablasTbl';


If Not Exists (Select Top 1 1
               From   sys.extended_properties a
               Join   sysobjects  b
               On     b.xtype   = 'Tr'
               And    b.name    = @w_objeto
               And    b.id      = a.major_id)

   Begin
      Execute  sp_addextendedproperty @name       = N'MS_Description',
                                      @value      = @w_valor,
                                      @level0type = 'Schema',
                                      @level0name = N'Dbo',
                                      @level1type = 'table',
                                      @level1name = @w_tabla,
                                      @level2type = 'Trigger',
                                      @level2name = @w_objeto;

   End
Else
   Begin
      Execute sp_updateextendedproperty @name       = 'MS_Description',
                                        @value      = @w_valor,
                                        @level0type = 'Schema',
                                        @level0name = N'Dbo',
                                        @level1type = 'table',
                                        @level1name = @w_tabla,
                                        @level2type = 'Trigger',
                                        @level2name = @w_objeto;
   End
Go

