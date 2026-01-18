Use SCMBD
Go

/*
Declare
   @Jsondata              Nvarchar(Max),
   @PnEstatus             Integer      = 0,
   @PsMensaje             Varchar(250) = Null;
Begin
   Set @Jsondata = '{
    "tablas": [
        {
            "tabla": "logAnalisisLSTbl"
        },
        {
            "tabla": "catControlProcesosTbl"
        }
    ]
}';

  Execute dbo.spc_dependenciasTablas @Jsondata, @PnEstatus Output, @PsMensaje Output;

  If @PnEstatus != 0
     Begin
        Select @PnEstatus IdError, @PsMensaje Error;
     End

  Return

End;
Go

*/

Create Or Alter Procedure dbo.spc_dependenciasTablas
  (@Jsondata              Nvarchar(Max),
   @PnEstatus             Integer      = 0     Output,
   @PsMensaje             Varchar(250) = Null  Output)
As

Declare
   @w_error               Integer,
   @w_registros           Integer,
   @w_linea               Integer,
   @w_secuencia           Integer,
   @w_objeto              Sysname,
   @w_tabla               Sysname,
   @w_tipoObjeto          Char( 2),
   @w_desc_error          Varchar ( 250);

--
-- Procedimientos de Consulta de Objetos dependientes a una tabla.
--

Begin
   Set Nocount         On
   Set Xact_Abort      On
   Set Ansi_Nulls      Off
   Set Ansi_Warnings   Off

   Select @w_Error      = 0,
          @w_desc_error = '',
          @PnEstatus    = 0,
          @PsMensaje    = '';

--
-- Validar que el JSON sea válido
--

   If Isjson(@Jsondata) = 0
   Begin
      Select @PnEstatus = 9999,
             @PsMensaje = 'El Parámetro @Jsondata no tiene formato JSON válido.';

      Set Xact_Abort      Off
      Return
   End

--
-- Generación de tablas Temporales.
--

   If Object_id('tempdb..#TempTablasTbl') Is Not Null
      Begin
         Drop Table #TempTablasTbl;
      End

   Create Table #TempTablasTbl
  (tabla          Sysname        Not Null,
   Constraint     TempTablasPk
   Primary Key (tabla));

   If Object_id('tempdb..#TempTablasDetTbl') Is Not Null
      Begin
         Drop Table #TempTablasDetTbl;
      End

   Create Table #TempTablasDetTbl
  (Secuencia      Integer        Not Null Identity (1, 1),
   tabla          Sysname        Not Null,
   tipoObjeto     Char( 2)       Not Null,
   objeto         Sysname        Not Null,
   aplica         Bit            Not Null Default 0,
   Constraint     TempTablasDetPk
   Primary Key (Secuencia),
   Index TempTablasDetIdx Unique (tabla, tipoObjeto, objeto));


--
-- Lectura del Json
--
-- Insertar datos desde el JSON
--

   Begin Try

      Insert Into #TempTablasTbl
     (tabla)
      Select a.tabla
      From   Openjson(@Jsondata, '$.tablas')
      With  (tabla        Sysname '$.tabla') a
      Where  Exists ( Select Top 1 1
                      From   sys.tables
                      Where  name = a.tabla);
      Set @w_registros = @@Rowcount;
      If @w_registros = 0
         Begin
            Insert Into #TempTablasTbl
           (tabla)
            Select Distinct name
            From   sys.tables;
         End


   End Try

   Begin Catch
       Select  @w_Error      = @@Error,
               @w_desc_error = Substring (Error_Message(), 1, 230),
               @w_linea      = error_line();
   End Catch

   If Isnull(@w_Error, 0)  <> 0
      Begin
         Select @PnEstatus  = @w_Error,
                @PsMensaje  = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' En línea ', @w_linea);
         Return;
     End

--
-- Inicio de Proceso.
--

   Insert Into #TempTablasDetTbl
  (tabla, tipoObjeto, Objeto)
   Select Distinct b.name, c.type, c.name
   From   sys.sql_dependencies a
   Join   sys.tables b
   On     b.object_id = a.referenced_major_id
   Join   sysobjects c
   On     c.id      = a.object_id
   And    c.type   In ('V', 'P', 'Fn', 'TR')
   And    c.uid     = 1
   Join   #TempTablasTbl d
   On     d.tabla = b.name
   Order by 2, 3;

   Declare
      C_Objetos Cursor For
      Select Secuencia, tabla, tipoObjeto, Objeto
      From   #TempTablasDetTbl;
   Begin
      Open C_Objetos
      While @@Fetch_status < 1
      Begin
         Fetch C_Objetos Into @w_secuencia, @w_tabla, @w_tipoObjeto, @w_Objeto
         If @@Fetch_status != 0
            Begin
               Break
            End

        If Exists (Select Top 1 1
                   From   sys.objects
                   Where  Type                            = @w_tipoObjeto
                   And    Object_name(object_id)          = @w_Objeto
                   And    Object_definition(object_id) Like Concat('%Insert%', trim(@w_tabla), '%')
                   And   (Object_definition(object_id) Like '%Money%'
                   Or     Object_definition(object_id) Like '%Decimal%'
                   Or     Object_definition(object_id) Like '%Numeric%'))
           Begin
              Update #TempTablasDetTbl
              Set    aplica    = 1
              Where  Secuencia = @w_secuencia;
           End

      End
      Close      C_Objetos
      Deallocate C_Objetos
   End

   Select tabla, tipoObjeto, Objeto, aplica
   From   #TempTablasDetTbl
   Order  By 1, 2, 3;

   Set Xact_Abort   Off
   Return

End
Go

--
-- Comentarios.
--

Declare
   @w_valor          Nvarchar(250) = 'Procedimiento de Consulta de las dependencias de la tablas.',
   @w_procedimiento  NVarchar(250) = 'spc_dependenciasTablas';

If Not Exists (Select Top 1 1
               From   sys.extended_properties a
               Join   sysobjects  b
               On     b.xtype   = 'P'
               And    b.name    = @w_procedimiento
               And    b.id      = a.major_id)
   Begin
      Execute  sp_addextendedproperty @name       = N'MS_Description',
                                      @value      = @w_valor,
                                      @level0type = 'Schema',
                                      @level0name = N'dbo',
                                      @level1type = 'Procedure',
                                      @level1name = @w_procedimiento

   End
Else
   Begin
      Execute sp_updateextendedproperty @name       = 'MS_Description',
                                        @value      = @w_valor,
                                        @level0type = 'Schema',
                                        @level0name = N'dbo',
                                        @level1type = 'Procedure',
                                        @level1name = @w_procedimiento
   End
Go
