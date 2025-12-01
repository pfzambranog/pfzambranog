Select Object_name(object_id) Objeto, Object_definition(object_id) Texto
From   sys.objects
Where  Type = 'Tr'
Union
Select Object_name(object_id) Objeto, 'Go'
From   sys.objects
Where  Type = 'Tr'
Order by 1

--
Select Type, Object_name(object_id) Objeto, Object_definition(object_id) Texto
From   sys.objects
Where  Object_definition(object_id) Like '%tempObligacionesTbl%'
Order  by 1, 2