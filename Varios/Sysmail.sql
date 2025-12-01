Execute msdb.dbo.sysmail_help_account_sp

Execute msdb.dbo.sysmail_delete_account_sp 
        @account_id = 1, @account_name = 'Incidencias'

Execute msdb.dbo.sysmail_add_account_sp   @account_name     = N'Incidencias',      
                                          @description      = N'Incidencias' ,      
                                          @email_address    = N'pfzambrano@gmail.com'  ,     
                                          @display_name     = 'Correo de Incidencias',      
                                          @username         = '98de164ddb25e8ade1cbc8991e4f515a',    
                                          @password         = '6be98a492d78d18ac43a9d0ceffae1bf',     
                                          @port             = 587,
                                          @enable_ssl       = 1,                          
                                          @mailserver_name  = 'in-v3.mailjet.com'
                                                



Execute msdb.dbo.sysmail_add_profile_sp   @profile_name     = N'Incidencias' ,      
                                          @description      = N'Incidencias'      
            
      -- Add the account to the profile      
	  
Execute msdb.dbo.sysmail_add_profileaccount_sp  @profile_name    = N'Incidencias',      
                                                @account_name    = N'Incidencias',      
                                                @sequence_number = 1 
                                                      
EXEC msdb.dbo.sp_send_dbmail
    @profile_name = 'Incidencias',
    @recipients = 'pfzambrano@gmail.com',
    @body = 'Correo enviado desde la BD Docker',
    @subject = 'TEST EMAIL',
    @importance ='HIGH'
    

EXEC msdb.dbo.sysmail_delete_log_sp
    @logged_before = '2025-11-29';
GO


Execute msdb.dbo.sysmail_delete_mailitems_sp
    @sent_before = '2025-11-29';
GO
--------------------------------------------------------------

Select *
from  msdb.dbo.sysmail_allitems

Select *
from  msdb.dbo.sysmail_sentitems


Select *
from  msdb.dbo.sysmail_faileditems
