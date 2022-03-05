--delete all the FK
DECLARE @ESQL VARCHAR(1000);
DECLARE FCursor CURSOR -- define float cursor
FOR (SELECT  'ALTER TABLE '+O.name+' DROP  CONSTRAINT '+F.name+';'  AS  CommandSQL  from   SYS.FOREIGN_KEYS  F    
JOIN  SYS.ALL_OBJECTS  O  ON F.PARENT_OBJECT_ID = O.OBJECT_ID WHERE O.TYPE = 'U' AND F.TYPE = 'F') -- find set we need and put into float cursor
OPEN FCursor; -- open float cursor
FETCH NEXT FROM FCursor INTO @ESQL; -- read first line data
WHILE @@FETCH_STATUS = 0
  BEGIN
  exec(@ESQL);
 FETCH NEXT FROM FCursor INTO @ESQL; -- read next line data
 END
CLOSE FCursor; -- close float cursor
DEALLOCATE FCursor; -- deallocate float cursor
GO


-- Clear all tables
declare @tname varchar(8000) 
set @tname='' 
select @tname=@tname+Name+','from sysobjects where xtype='U' 
select @tname='drop table '+ left(@tname,len(@tname)-1) 
exec(@tname)