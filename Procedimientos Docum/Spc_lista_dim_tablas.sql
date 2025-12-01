
/*
Declare
   @PsTabla      Varchar( 60) = Null,
   @PnFilas      Integer      = 0,
   @PnEstatus    Integer      = 0,
   @PsMensaje    Varchar(250) = ' ';
Begin
   Execute dbo.Spc_lista_dim_tablas @PsTabla   = @PsTabla,
                                    @PnFilas   = @PnFilas,
                                    @PnEstatus = @PnEstatus Output,
                                    @PsMensaje = @PsMensaje Output;

   If @PnEstatus != 0
      Begin
         Select @PnEstatus, @PsMensaje;
      End

   Return

End
*/

Create Or Alter Procedure dbo.Spc_lista_dim_tablas
  (@PsTabla             Sysname        = Null,
   @PnFilas             Integer        = 0,
   @PnEstatus           Integer        = 0    Output,
   @PsMensaje           Varchar(250)   = ' '  Output)
As

Declare
   @w_Error                  Integer,
   @w_operacion              Integer,
   @w_desc_error             Varchar ( 250),
   @w_tabla                  Sysname,
   @w_id                     Integer,
   @w_pages                  Integer,
   @w_sql                    Varchar(Max),
   @w_comilla                Char(1),
   @w_linea                  Integer;

Begin
   Set Quoted_identifier Off
   Set Nocount            On
   Set Xact_Abort         On
   Set Ansi_Nulls         Off
   Set Ansi_Warnings      On
   Set Ansi_Padding       On

   Select @PnEstatus    = 0,
          @PsMensaje    = Null,
          @w_operacion  = 9999,
          @w_comilla    = Char(39)

   Set @w_sql = 'Declare '                                    +
                    'C_tablas Cursor Fast_Forward For '       +
                    'Select Name, id '                        +
                    'From   sysobjects a '                    +
                    'Where  Uid        = 1 '                  +
                    'And    Type       = ' + @w_comilla + 'U' + @w_comilla

   If @PsTabla Is Not Null
      Begin
         Set @w_sql = @w_sql + ' And    Name = ' + @w_comilla + @PsTabla + @w_comilla

      End

   Set @w_sql = @w_sql + ' Order by 1'

   Begin Try
      Execute (@w_sql)
   End Try

   Begin Catch
      Select  @w_Error      = @@Error,
              @w_desc_error = Substring (Error_Message(), 1, 230)
   End   Catch

   If Isnull(@w_Error, 0) <> 0
      Begin
         Select @PnEstatus = @w_error,
                @PsMensaje = 'Error.: ' + dbo.Fn_Busca_MensajeError(@PnEstatus)

         Set Xact_Abort Off
         Return
      End

   Begin Try
      Create Table #TempDimTablas
     (Filas          Integer         Null ,
      Reservado      numeric (18, 0) Null ,
      Usado_Data     numeric (18, 0) Null ,
      Usado_Index    numeric (18, 0) Null ,
      Sin_Uso        numeric (18, 0) Null)
   End Try

   Begin Catch
      Select  @w_Error      = @@Error,
              @w_desc_error = Substring (Error_Message(), 1, 230)
   End   Catch

   If Isnull(@w_Error, 0) <> 0
      Begin
         Select @PnEstatus = @w_error,
                @PsMensaje = 'Error.: ' + dbo.Fn_Busca_MensajeError(@PnEstatus)

         Set Xact_Abort Off
         Return
      End

   Begin Try
      Create Table #TempDimensionamientoTablas
     (Tabla          Sysname         Not Null,
      Filas          Integer             Null ,
      Reservado      numeric (18, 0)     Null ,
      Usado_Data     numeric (18, 0)     Null ,
      Usado_Index    numeric (18, 0)     Null ,
      Sin_Uso        numeric (18, 0)     Null)
   End Try

   Begin Catch
      Select  @w_Error      = @@Error,
              @w_desc_error = Substring (Error_Message(), 1, 230)
   End   Catch

   If Isnull(@w_Error, 0) <> 0
      Begin
         Select @PnEstatus = @w_error,
                @PsMensaje = 'Error.: ' + dbo.Fn_Busca_MensajeError(@PnEstatus)

         Set Xact_Abort Off
         Return
      End

   Open  C_tablas
   While @@fetch_Status < 1
   Begin
      Fetch C_tablas Into @w_tabla, @w_id

      If @@Fetch_Status <> 0
         Begin
            Break
         End

      Delete #TempDimTablas

      Set @w_pages = 0

      Insert Into #TempDimTablas (Reservado)
      Select sum(reserved)
      From   sysindexes
      Where  indid in (0, 1, 255)
      And    id     = @w_id

      Select @w_pages = sum(dpages)
      From   sysindexes
      Where  indid < 2
      And    id    = @w_id

      Select @w_pages = @w_pages + isnull(sum(used), 0)
      From   sysindexes
      Where  indid = 255
      And    id    = @w_id

      Update #TempDimTablas
      Set    Usado_Data = @w_pages

      Update #TempDimTablas
      Set    Usado_Index = (Select sum(used)
                            From   sysindexes
                            Where  indid in (0, 1, 255)
                            And    id     = @w_id) -  a.Usado_data
      From   #TempDimTablas a

      Update #TempDimTablas
      Set    Sin_uso = a.reservado - (Select sum(used)
                                     From   sysindexes
                                     Where  indid in (0, 1, 255)
                                     And    id     = @w_id)
      From   #TempDimTablas a

      Update #TempDimTablas
      Set    Filas = i.rows
      From   sysindexes i
      Where  i.indid < 2
      And    i.id    = @w_id

      Set @w_sql = Concat('Select object_name(', @w_id, '), ',
                                  'Filas, ',
                                  'reservado   * d.low   / 1024, ',
                                  'Usado_Data  * d.low   / 1024, ',
                                  'Usado_Index * d.low   / 1024, ',
                                  'Sin_uso     * d.low   / 1024 ',
                                  'From   #TempDimTablas, master.dbo.spt_values d ',
                                  'Where  d.number = 1 ',
                                  'And    d.Type   = ', @w_comilla, 'E', @w_comilla);
      Begin Try
         Insert Into #TempDimensionamientoTablas
         Execute (@w_sql)
      End Try

      Begin Catch
         Select  @w_Error      = @@Error,
                 @w_desc_error = Substring (Error_Message(), 1, 230),
                 @w_linea      = error_line();
      End   Catch

   If Isnull(@w_Error, 0) <> 0
      Begin
         Select @PnEstatus = @w_error,
                @PsMensaje = 'Error.: ' + dbo.Fn_Busca_MensajeError(@PnEstatus)

         Close      C_tablas
         Deallocate C_tablas

         Set Xact_Abort Off
         Return
      End

   End
   Close      C_tablas
   Deallocate C_tablas

   Select Tabla, Filas, Reservado, Usado_Data, Usado_Index,
          Sin_Uso
   From   #TempDimensionamientoTablas
   Where  Filas >= Isnull(@PnFilas, 0)
   Order  by 2 desc

   Begin Try
      Drop Table #TempDimTablas
   End Try

   Begin Catch
      Select  @w_Error      = @@Error,
              @w_desc_error = Substring (Error_Message(), 1, 230)
   End   Catch

   If Isnull(@w_Error, 0) <> 0
      Begin
         Select @PnEstatus = @w_error,
                @PsMensaje = 'Error.: ' + dbo.Fn_Busca_MensajeError(@PnEstatus)

         Set Xact_Abort Off
         Return
      End

   Begin Try
      Drop Table #TempDimensionamientoTablas
   End Try

   Begin Catch
      Select  @w_Error      = @@Error,
              @w_desc_error = Substring (Error_Message(), 1, 230)
   End   Catch

   If Isnull(@w_Error, 0) <> 0
      Begin
         Select @PnEstatus = @w_error,
                @PsMensaje = 'Error.: ' + dbo.Fn_Busca_MensajeError(@PnEstatus)

         Set Xact_Abort Off
         Return
      End

   Set Xact_Abort Off
   Return

End
Go

--
-- Comentarios
--

Declare
   @w_valor          Nvarchar(250) = 'Procedimiento que Consulta el detalle de las tablas declaradas en la base de datos.',
   @w_procedimiento  NVarchar(250) = 'Spc_lista_dim_tablas';

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

