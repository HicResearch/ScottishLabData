create table DaSH_v2 as
select *, 
substring(Reference_Range, 1, CHARINDEX('{', Reference_Range)-1) as 'low',
substring(Reference_Range, CHARINDEX('{', Reference_Range)+1, LEN(Reference_Range) ) as 'high'
from DaSH;