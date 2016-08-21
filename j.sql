-- ./psqlmad -f j.sql -v qry="'helloworld'"
drop table dropme;
create table dropme (txt text);
insert into dropme values('helloworld');
select * from dropme where txt = 'helloworld';
select * from dropme where txt = :qry ;

