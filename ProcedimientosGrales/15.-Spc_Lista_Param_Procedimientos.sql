/*

Procedimiento que lista los campos de una Tabla

Declare
   @PsProcedimiento     Varchar(250) = Null,
   @PnEstatus           Integer      = 0,
   @PsMensaje           Varchar(250) = ' '
   
Begin
   Execute Spc_Lista_Param_Procedimientos @PsProcedimiento   = @PsProcedimiento,
                                          @PnEstatus         = @PnEstatus Output,
                                          @PsMensaje         = @PsMensaje Output;

   If @PnEstatus != 0
      Begin
         Select @PnEstatus, @PsMensaje
      End
   
   Return

End
Go
*/

Create Or Alter Procedure dbo.Spc_Lista_Param_Procedimientos
  (@PsProcedimiento     Varchar(250) = Null,
   @PnEstatus           Integer      = 0   Output,
   @PsMensaje           Varchar(250) = ' ' Output)
As 
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
           
    Create Table #tempSps(
    Id                   Integer Identity(1,1) Primary Key,
    BD                   Varchar(100),
    Nombre_SP            Varchar(150), 
    Parametro_Orden      Smallint,
    Nombre_Parametro     Varchar(100),
    Tipo_Dato            Varchar(30),
    Longitud_Caracter    Integer,
    Precision_Numerica   Integer,
    Escala               Integer,
    Collation            Varchar(150),
    Set_Caracteres       Varchar(50),
    Tipo_Parametro       Varchar(10));
    
    Insert Into #tempSps
        (BD,          Nombre_SP,            Parametro_Orden,        Nombre_Parametro,
         Tipo_Dato,   Longitud_Caracter,    Precision_Numerica,     Escala,
         Collation,   Set_Caracteres,       Tipo_Parametro)     
    Select b.SPECIFIC_CATALOG,  a.name,                       b.ORDINAL_POSITION,    b.PARAMETER_NAME, 
           b.DATA_TYPE,         b.CHARACTER_MAXIMUM_LENGTH,   b.NUMERIC_PRECISION,   b.NUMERIC_SCALE, 
           b.COLLATION_NAME,    b.CHARACTER_SET_NAME,         b.PARAMETER_MODE 
    From  sys.procedures a 
    Join  INFORMATION_SCHEMA.PARAMETERS b On b.SPECIFIC_NAME = a.name 
    Where a.type      = 'P' 
    And   a.name   like Iif(@PsProcedimiento  Is Null, a.name,  '%' + @PsProcedimiento + '%') 
    And   a.name    Not In ('sp_alterdiagram','sp_creatediagram','sp_dropdiagram','sp_helpdiagramdefinition','sp_helpdiagrams','sp_renamediagram','sp_upgraddiagrams')
    Order by a.name, b.ORDINAL_POSITION
    
    Update #tempSps 
    Set    BD = '' 
    Where  Id > 1;

    Update #tempSps 
    Set    Nombre_SP = '' 
    Where  Parametro_Orden > 1
    
    Select BD,                                                                     Nombre_SP,               Parametro_Orden,                                                          
           Nombre_Parametro,                                                       Tipo_Dato,               
           Case When IsNull(Cast(Longitud_Caracter As Varchar),'') = '-1' 
                Then 'Max' 
                Else IsNull(Cast(Longitud_Caracter As Varchar),'') 
           End As Longitud_Caracter,    
           IsNull(Cast(Precision_Numerica As Varchar),'') Precision_Numerica,      IsNull(Cast(Escala As Varchar),'') Escala,      
           IsNull(Cast(Collation As Varchar),'')          Collation,   
           IsNull(Cast( Set_Caracteres As Varchar),'')    Set_Caracteres,          Tipo_Parametro  
    From #tempSps;

   Set Xact_Abort    Off
   Return

End
Go

--
-- Comentarios
--

Declare
   @w_valor          Nvarchar(250) = 'Procedimiento que Consulta los Parámetros de los procedimientos compilados en la base de datos.',
   @w_procedimiento  NVarchar(250) = 'Spc_Lista_Param_Procedimientos';

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
