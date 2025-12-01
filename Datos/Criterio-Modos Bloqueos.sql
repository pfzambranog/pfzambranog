Use SCMBD
Go

Delete catCriteriosTbl
Where  criterio = 'ModoBloqueoBD'
Go

Insert Into catCriteriosTbl
Select 'ModoBloqueoBD', 1, 'Exclusivo', 'X'
Union
Select 'ModoBloqueoBD', 2, 'Compartido', 'S'
Union
Select 'ModoBloqueoBD', 3, 'Actualización', 'U'
Union
Select 'ModoBloqueoBD', 4, 'Intento', 'I'
Union
Select 'ModoBloqueoBD', 5, 'Diagrama', 'Sch'
Union
Select 'ModoBloqueoBD', 6, 'Actualización masiva', 'BU'
