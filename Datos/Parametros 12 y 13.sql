Declare
   @w_caracter           Char(1)          = Char(92);

Declare
   @PsDescripcion        Varchar(  100)   = 'Dirección Física de Alojamiento  de Logs',
   @PnParametroNumber    Integer          = Null,
   @PsParametroChar      Varchar(  120)   = Concat('C:', @w_caracter, 'Sites',@w_caracter, 'Api' + @w_caracter + 'Dearrollo',@w_caracter, 'LogsDba',@w_caracter, ''),
   @PdParametroFecha     Datetime         = Null,
   @PnIdUsuarioAct       Smallint         = 1,
   @PsIpAct              Varchar(   30)   = Null,
   @PsMacAddressAct      Varchar(   30)   = Null,
   @PnEstatus            Integer          = 0,
   @PsMensaje            Varchar(  250)   = ' '

Begin

   Execute Spa_conParametrosGralesTbl @PsDescripcion     = @PsDescripcion    , 
                                      @PnParametroNumber = @PnParametroNumber, 
                                      @PsParametroChar   = @PsParametroChar  , 
                                      @PdParametroFecha  = @PdParametroFecha , 
                                      @PnIdUsuarioAct    = @PnIdUsuarioAct   , 
                                      @PsIpAct           = @PsIpAct          , 
                                      @PsMacAddressAct   = @PsMacAddressAct  , 
                                      @PnEstatus         = @PnEstatus Output ,       
                                      @PsMensaje         = @PsMensaje Output        
                  
   Select @PnEstatus, @PsMensaje

   Select @PsDescripcion   = 'Dirección URL de Alojamiento  de Logs',
          @PsParametroChar = 'http://localhost/LogsDba/';

   Execute Spa_conParametrosGralesTbl @PsDescripcion     = @PsDescripcion    , 
                                      @PnParametroNumber = @PnParametroNumber, 
                                      @PsParametroChar   = @PsParametroChar  , 
                                      @PdParametroFecha  = @PdParametroFecha , 
                                      @PnIdUsuarioAct    = @PnIdUsuarioAct   , 
                                      @PsIpAct           = @PsIpAct          , 
                                      @PsMacAddressAct   = @PsMacAddressAct  , 
                                      @PnEstatus         = @PnEstatus Output ,       
                                      @PsMensaje         = @PsMensaje Output        
                  
   Select @PnEstatus, @PsMensaje

   Select @PsDescripcion   = 'Sufijo Nombre Archivo de Salida de Tiempos',
          @PsParametroChar = 'RepTiempoProc';

   Execute Spa_conParametrosGralesTbl @PsDescripcion     = @PsDescripcion    , 
                                      @PnParametroNumber = @PnParametroNumber, 
                                      @PsParametroChar   = @PsParametroChar  , 
                                      @PdParametroFecha  = @PdParametroFecha , 
                                      @PnIdUsuarioAct    = @PnIdUsuarioAct   , 
                                      @PsIpAct           = @PsIpAct          , 
                                      @PsMacAddressAct   = @PsMacAddressAct  , 
                                      @PnEstatus         = @PnEstatus Output ,       
                                      @PsMensaje         = @PsMensaje Output        
                  
   Select @PnEstatus, @PsMensaje

   Select @PsDescripcion     = 'Minutos de Espera para Emitir Próximo Correo Informativo.',
          @PsParametroChar   = Null,
          @PnParametroNumber = 38;

   Execute Spa_conParametrosGralesTbl @PsDescripcion     = @PsDescripcion    , 
                                      @PnParametroNumber = @PnParametroNumber, 
                                      @PsParametroChar   = @PsParametroChar  , 
                                      @PdParametroFecha  = @PdParametroFecha , 
                                      @PnIdUsuarioAct    = @PnIdUsuarioAct   , 
                                      @PsIpAct           = @PsIpAct          , 
                                      @PsMacAddressAct   = @PsMacAddressAct  , 
                                      @PnEstatus         = @PnEstatus Output ,       
                                      @PsMensaje         = @PsMensaje Output;       
                  
   Select @PnEstatus, @PsMensaje

   Select @PsDescripcion     = 'Porcentaje de espacio libre para Archivo de BD',
          @PsParametroChar   = Null,
          @PnParametroNumber = 26;

   Execute Spa_conParametrosGralesTbl @PsDescripcion     = @PsDescripcion    , 
                                      @PnParametroNumber = @PnParametroNumber, 
                                      @PsParametroChar   = @PsParametroChar  , 
                                      @PdParametroFecha  = @PdParametroFecha , 
                                      @PnIdUsuarioAct    = @PnIdUsuarioAct   , 
                                      @PsIpAct           = @PsIpAct          , 
                                      @PsMacAddressAct   = @PsMacAddressAct  , 
                                      @PnEstatus         = @PnEstatus Output ,       
                                      @PsMensaje         = @PsMensaje Output;       
                  
   Select @PnEstatus, @PsMensaje;
   
   
   Return

End
Go