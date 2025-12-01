/*

Procedimiento que lista los campos de una Tabla

Declare
   @PsTabla      Varchar( 60) = Null,
   @PnEstatus    Integer      = 0,
   @PsMensaje    Varchar(250) = ' '
   
Begin
   Execute Spc_Lista_Det_Tablas @PsTabla   = @PsTabla,
                                @PnEstatus = @PnEstatus Output,
                                @PsMensaje = @PsMensaje Output;

   If @PnEstatus != 0
      Begin
         Select @PnEstatus, @PsMensaje
      End
   
   Return

End
Go
*/

Create Or Alter Procedure Spc_Lista_Det_Tablas
  (@PsTabla      Varchar( 60) = Null,
   @PnEstatus    Integer      = 0     Output,
   @PsMensaje    Varchar(250) = Null  Output)

As

Declare
  C_tablas Cursor For
  Select   Name, id
  from     Sysobjects 
  Where    Uid     = 1
  And      Type    = 'U'
  And      Name    = Case When @PsTabla Is Null
                          Then Name
                     Else @PsTabla
                 End
  Order    By 1

Declare
   @w_tabla             Sysname,
   @w_columna           Sysname,
   @w_idTabla           Integer,
   @w_column_id         Integer,
   @w_column_idx        Integer,
   @w_column_Fk         Integer,
   @w_TipoCampo         Varchar(250),
   @w_Longitud          Integer,
   @w_Decimales         Integer,
   @w_requerido         Char(2),
   @w_aplica            Bit,
   @w_desc_error        Varchar( 250),
   @w_Error             Integer,
   @w_descripcion       NVarchar(1500),
   @w_esFk              Char(2),
   @w_nombreFk          Varchar(100), 
   @w_tablaReferenciada Varchar(150),
   @w_campoReferenciado Varchar(150),
   @w_esIndex           Char(2),
   @w_indexType         Varchar(20),
   @w_indexName         Varchar(100),
   @w_dfConstraint      Varchar(100)

Begin

/*
Objetivo: Listar las caracteristicas de los campos que conforman una Tabla.
Versión:  2

*/

Objetivo:
   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    Off
   Set Ansi_Warnings On
   Set Ansi_Padding  On

   Select  @PnEstatus    = 0,
           @PsMensaje    = ''
   
   Create table #Tmp_Objectos
   (Orden             SmallInt     Not Null,
    BaseDatos         Sysname      Default ' ',
    Objeto            Sysname      Default ' ', 
    Tabla             Sysname      Default ' ',
    idcolumna         Integer      Null,
    Columna           Sysname      Default ' ',
    Tipo              Varchar(250) Default ' ',
    Longitud          Varchar(20)  Default ' ',
    Decimales         Varchar(20)  Default ' ',
    Requerido         Char(2)      Default ' ',
    Llave_Prim        Varchar(5)   Default ' ',
    Llave_For         Varchar(5)   Default ' ',
    Descripcion       NVarchar(1500),
    esFk              Char(2)      Default ' ' ,
    nombreFk          Varchar(100) Default ' ',
    tablaReferenciada Varchar(150) Default ' ',
    campoReferenciado Varchar(150) Default ' ',
    esIndex           Char(2)      Default ' ',
    indexType         Varchar(20)  Default ' ',
    indexName         Varchar(100) Default ' ',
    dfConstraint      Varchar(100) Default ' ')

   Insert Into #Tmp_Objectos
   (Orden, BaseDatos, Descripcion)
   Select 0, db_Name(), (Select Cast(Value As NVarchar(1550))
      From   fn_listextendedproperty('MS_Description', Null, Null, Null, Null, 
              Null, Null))

   Open  C_tablas
   While @@Fetch_status < 1
   Begin
      Fetch C_tablas Into @w_tabla, @w_idTabla
      If @@Fetch_status <> 0
         Begin
            Break
         End

      Set @w_descripcion = ''

      Select @w_descripcion = Cast(Value As NVarchar(1550))
      From   fn_listextendedproperty('MS_Description', 'SCHEMA', 'dbo', 'table', @w_tabla, 
              Null, Null)

      Insert Into #Tmp_Objectos
      (Orden, Objeto, tabla, Descripcion)
      Values (1, @w_tabla, @w_tabla, @w_descripcion)
      
      Declare
         C_columnas Cursor For
           Select Name, Column_id
           From   sys.columns 
           Where  Object_id = @w_idTabla
           Order  By Column_id
           
      Begin
         Open   C_columnas
         While  @@Fetch_Status < 1
         Begin
            Fetch C_columnas Into @w_columna, @w_column_id
            If @@Fetch_status <> 0
               Begin 
                  Break
               End

            Set  @w_column_idx  = 0

            Select @w_column_idx = b.key_ordinal
            From   sys.indexes i
            Join   sys.index_columns  b  
            On     i.object_id                         = b.object_id 
            And    Col_name(b.object_id, b.column_id)  = @w_columna
            Where  i.object_id                         = @w_idTabla
            And    i.is_primary_key                    = 1

            Set @w_column_fk = 0

            Select @w_column_idx = Isnull(@w_column_idx, 0),
                   @w_column_fk  = Isnull(@w_column_fk,  0)

            Set @w_esFk = 0
            Set @w_nombreFk = ''
            Set @w_tablaReferenciada = ''
            Set @w_campoReferenciado = '' 
            Select @w_esFk = 1, @w_nombreFk = fk.name, 
                   @w_tablaReferenciada = OBJECT_NAME (fk.referenced_object_id) , 
                   @w_campoReferenciado = COL_NAME(fkc.referenced_object_id, fkc.referenced_column_id)
            From sys.foreign_keys As fk
            Join sys.foreign_key_columns As fkc On fk.OBJECT_ID = fkc.constraint_object_id 
            Where fk.parent_object_id = @w_idTabla 
            And COL_NAME(fkc.parent_object_id, fkc.parent_column_id) = @w_columna 
        
            Select @w_esFk = Isnull(@w_esFk, 0) 

            Set @w_esIndex = 0
            Set @w_indexType = ''
            Set @w_indexName = ''

           Select @w_esIndex = 1, @w_indexType = Ix.type_desc, @w_indexName = Ix.name 
           From  sys.indexes Ix 
           Join  sys.index_columns Ixc  On  Ix.object_id =   Ixc.object_id And Ix.index_id   =  Ixc.index_id  
           Join  sys.columns c          On  Ix.object_id =   c.object_id And Ixc.column_id =  c.column_id     
           Join  sys.tables t           On  Ix.object_id = t.object_id
           Where t.object_id = @w_idTabla AND c.name = @w_columna 

           Select @w_esIndex = Isnull(@w_esIndex, 0) 

           Set @w_dfConstraint = ''

           Select @w_dfConstraint = dfc.definition 
           From  sys.default_constraints dfc
           Join  sys.columns sc On sc.column_id = dfc.parent_column_id
           And sc.object_id = dfc.parent_object_id 
           Where dfc.parent_object_id = @w_idTabla 
           And  sc.name = @w_columna 

            Set @w_descripcion = ' '

            Select @w_descripcion = Cast(Value As NVarchar(1550))
            From   fn_listextendedproperty('MS_Description', 'Schema', 'dbo', 'table', @w_tabla, 
                    'Column', @w_columna)
            
            Execute dbo.Spc_valida_longitud @w_Tabla,     @w_Columna,   
                                            @w_Aplica     Output,     @w_TipoCampo Output, @w_Longitud  Output,
                                            @w_Decimales  Output,     @w_requerido Output, @PnEstatus   Output,
                                            @PsMensaje    Output 
  
            If @PnEstatus = 0
               Begin
                  Begin Try
                     Insert Into #Tmp_Objectos
                    (Orden,             Objeto,      idcolumna,  Columna,      Tipo,       Longitud,  Decimales,
                     Requerido,         Llave_Prim,  Llave_For,  Descripcion,  esFk,       nombreFk,  tablaReferenciada, 
                     campoReferenciado, esIndex,     indexType,  indexName,    dfConstraint )
                     Select  2, @w_tabla, @w_column_id, @w_columna, @w_TipoCampo,
                            Cast(@w_longitud As Varchar(20)), 
                            Case When @w_decimales = 0
                                 Then ' '
                                 Else Cast(@w_decimales As Varchar)
                            End, @w_requerido,
                            Case When @w_column_idx = 0
                                 Then ' '
                                 Else Cast(@w_column_idx As Varchar)
                            End,
                            Case When @w_column_fk  = 0
                                 Then ' '
                                 Else 'Si'
                            End, @w_descripcion
                            , Case When @w_esFk  = 0
                                 Then ' '
                                 Else 'Si'
                            End, @w_nombreFk, @w_tablaReferenciada, @w_campoReferenciado, 
                            Case When @w_esIndex  = 0
                                 Then ' '
                                 Else 'Si'
                            End, @w_indexType, @w_indexName, @w_dfConstraint 
                  End Try

                  Begin Catch
                     Select  @w_Error      = @@Error,
                             @w_desc_error = Substring (Error_Message(), 1, 230)
                  End   Catch

                  If Isnull(@w_Error, 0) <> 0
                     Begin
                        Select @PnEstatus = @w_Error,
                               @PsMensaje = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar))) + ' ' + @w_desc_error
                        Select @PsMensaje

                        Set Xact_Abort Off
                        Return
                     End
               End
            Else
               Begin
                  Select @PnEstatus, @PsMensaje
               End
         End
         Close      C_columnas
         Deallocate C_columnas
      End
      
   End
   Close      C_tablas
   Deallocate C_tablas
   
   Select BaseDatos "Base de Datos", Tabla, Columna, tipo "Tipo de Dato", Case When longitud = -1 
                                                                               Then 'Max'
                                                                               Else longitud
                                                                           End +
                                                           Case When Decimales != ' '
                                                           Then ', ' + Decimales
                                                           Else ' '
                                                       End Longitud,
          Requerido, Llave_Prim "Llave Primaria",  dfConstraint "Valor Default", Descripcion "Descripción", 
          esFk "Es FK", 
          tablaReferenciada "Tabla Referenciada", campoReferenciado "Campo Referenciado", 
          esIndex "Es IX" 
   From   #Tmp_Objectos
   Order By Objeto, idcolumna
   
End
Go

--
-- Comentarios
--

Declare
   @w_valor          Nvarchar(250) = 'Procedimiento que Consulta los Campos de las tablas.',
   @w_procedimiento  NVarchar(250) = 'Spc_Lista_Det_Tablas';

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