Use SCMBD
Go

/*

Declare
   @PsProcedimiento Sysname       = Null,
   @PnEstatus       Integer       = 0,
   @PsMensaje       Varchar(250)  = ' '

Begin
   Execute dbo.Spc_Lista_Det_Procedimientos @PsProcedimiento     = @PsProcedimiento,
                                            @PnEstatus           = @PnEstatus Output,
                                            @PsMensaje           = @PsMensaje Output

   If @PnEstatus != 0
      Begin
         Select @PnEstatus, @PsMensaje
      End

   Return

End
Go

*/


Create Or Alter Procedure dbo.Spc_Lista_Det_Procedimientos
  (@PsProcedimiento  Sysname       = Null,
   @PnEstatus        Integer       = 0    Output,
   @PsMensaje        Varchar(250)  = Null Output)
As

Declare
   @w_desc_error              Varchar( 250),
   @w_Error                   Integer,
   @w_registros               Integer;

Begin  
/*
Objetivo: lista las Caracteristicas de los procedimientos.
Versión:  1

*/

   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    Off
   Set Ansi_Warnings On
   Set Ansi_Padding  On
   
   Select @PnEstatus       = 0,
          @PsMensaje       = ' ';

   Create table #Tempsps  
   (secuencia              Integer Not Null Identity (1, 1) Primary Key,
    BD                     Varchar(100),  
    objeto_id              Integer,  
    Primero                Tinyint,   
    Nombre                 Varchar(150),
    [Nombre SP]            Varchar(150),  
    Posicion               Smallint,  
    [Tipo Parametro]       Varchar(10),  
    [Nombre Parametro]     Varchar(100),  
    [Tipo de Dato]         Varchar(30),  
    Longitud               Integer,  
    [Precision Numerica]   Integer,  
    Escala                 Integer,
    Collation              Varchar(150),  
    [Fecha Creacion]       Varchar(50),
    [Fecha Modificacion]   Varchar(50));  

    Begin Try
       Insert into #Tempsps
       (BD,              objeto_id,         Primero,               Nombre,
        [Nombre SP],     Posicion,          [Tipo Parametro],      [Nombre Parametro],
        [Tipo de Dato],  Longitud,          [Precision Numerica],  Escala,
        Collation,       [Fecha Creacion],  [Fecha Modificacion])
       Select p.specific_catalog,      s.id,              0,                 p.specific_name,     p.specific_name,   
              p.ordinal_position,      p.parameter_mode,  p.parameter_name,  p.data_type,         p.character_maximum_length,  
              p.numeric_precision,     p.numeric_scale,   p.collation_name,  Convert(Varchar,     r.created, 121),    
              Convert(Varchar,         r.last_altered, 121)  
       From   information_schema.parameters p  
       Join   information_schema.routines r   
       On     r.specific_name = p.specific_name   
       Join   sysobjects s   
       On     s.name    = r.specific_name       
       Where  s.uid     = 1
	   And    s.type    = 'P'
       And    s.name Like Iif(@PsProcedimiento Is Null, s.name,  '%' + @PsProcedimiento + '%')
       Order By p.specific_name, p.ordinal_position;
       Set @w_registros = @@Rowcount
   End Try

   Begin Catch
      Select  @w_Error      = @@Error,
              @w_desc_error = Substring (Error_Message(), 1, 230)
   End   Catch

   If Isnull(@w_Error, 0) <> 0
      Begin
         Select @PnEstatus = @w_Error,
                @PsMensaje = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar))) + ' ' + @w_desc_error
         
         Set Xact_Abort Off
         Return
      End

   If Isnull(@w_registros, 0) = 0
      Begin
         Select @PnEstatus = 99, 
                @PsMensaje = dbo.Fn_Busca_MensajeError(@PnEstatus)

         Set Xact_Abort Off
         Return      
      End 
     
   Update #Tempsps 
   Set    Primero  = 1 
   Where  Posicion = 1
   or     Posicion = 0;  
   
   Update #Tempsps 
   Set    [Nombre SP] = ''
   Where  Primero <> 1;
   
   Update #Tempsps 
   Set    [Fecha Creacion]     = '',
          [Fecha Modificacion] = ''
   Where  [Nombre SP] = '';  
   
     
   Select   BD,                 objeto_id,             IsNull([Nombre SP],'') [Nombre SP],      
            Posicion,           [Tipo Parametro],      [Nombre Parametro],    [Tipo de Dato],    
            Longitud,           [Precision Numerica],  Escala,                Collation,         
            [Fecha Creacion],   [Fecha Modificacion]  
   From #Tempsps   
   Order By Nombre,Posicion;  
   
   Set Xact_Abort Off
   Return

End
Go 

--
-- Comentarios
--

Declare
   @w_valor          Nvarchar(250) = 'Procedimiento que lista las Caracteristicas de los procedimientos.',
   @w_procedimiento  NVarchar(250) = 'Spc_Lista_Det_Procedimientos';

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