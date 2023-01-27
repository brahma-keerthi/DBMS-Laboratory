drop table if exists person;
create table person (
    did VARCHAR(5),
    dname varchar(10),
    address varchar(10),

    PRIMARY KEY ( did )
);

drop table if exists car;
create table car(
    regno varchar(10),
    model varchar(10),
    year integer,

    PRIMARY KEY (regno)
);

drop table if exists owns;
create table owns(
    did varchar(5),
    regno varchar(10),

    foreign key ( did ) references person(did) on delete cascade,
    foreign key ( regno ) references car(regno) on delete cascade
);

drop table if exists accident;   
create table accident(
    repnum integer,
    accdate date,
    location varchar(10),

    primary key ( repnum )
);

drop table if exists participated;
create table participated(
    did varchar(5),
    regno varchar(10),
    repnum integer,
    damageamt integer,

    foreign key ( did ) references person(did) on delete cascade,
    foreign key ( regno ) references car(regno) on delete cascade,
    foreign key ( repnum ) references accident(repnum ) on delete cascade
);

insert into person values 
("d001", "Ajay", "Mysuru"),
("d002", "Virat", "Delhi"),
("d003", "VadPav", "Mumbai"),
("d004", "Jadeja", "Rajkot"),
("d005", "Dhoni", "Ranchi"),
("d006", "Rahul", "Bangalore");

insert into car values 
("kar-001", "Maruti", "2020"),
("kar-003", "Tata", "2020"),
("kar-004", "Ford", "2023"),
("kar-005", "Ferrai", "2017"),
("kar-006", "Suzuti", "2010"),
("kar-002", "Renault", "2000");

insert into owns VALUES
("d001", "kar-001"),
("d001", "kar-002"),
("d002", "kar-003"),
("d003", "kar-004"),
("d004", "kar-005");

insert into accident VALUES
(123, "2020-09-29", "Mysuru"),
(124, "2021-09-29", "Ranchi"),
(125, "2025-09-29", "Mumbai"),
(126, "2023-08-29", "Chennai"),
(127, "2020-09-23", "JSSSTU"),
(128, "2020-04-29", "Delhi");

insert into participated VALUES
("d001", "kar-001", 123, 5600),
("d002", "kar-003", 124, 54600),
("d003", "kar-004", 125, 4600),
("d001", "kar-002", 126, 5659),
("d004", "kar-005", 127, 5609);

-- 1. Find the total number of people who owned cars that were involved in accidents in 2021.
-- 2. Find the number of accidents in which the cars belonging to "Ajay" were involved.
-- 3. Add a new accident to the database; assume any values for required attributes.
-- 4. Delete the Maruti belonging to "Ajay".
-- 5. Update the damage amount for the car with license number "kar-003" in the accident
-- with report.
-- 6. A view that shows models and year of cars that are involved in accident.
-- 7. A trigger that prevents driver with total damage amount >rs.50,000 from owning a car.

-- 1
SELECT COUNT( DISTINCT pp.did )
from accident a, participated pp 
where a.accdate like "2021%"
and a.repnum = pp.repnum;

-- 2
select count( a.repnum )
from accident a, participated pp
where pp.did in ( select did from person where dname = "Ajay" ) 
and a.repnum = pp.repnum;

-- 3
insert into accident VALUES
(129, "2021-09-29", "Mysuru");
insert into participated VALUES
("d003", "kar-004", 129, 90600);

-- 4
delete from car c
where c.model = "Maruti" 
and regno in (select regno from owns where did in (select did from person where dname = "Ajay"));

select * from car;
select * from owns;

-- 5
update participated 
set damageamt = 88888
where regno = "kar-003";

select * from participated;

-- 6
create view view2 as
select c.model, c.year
from car c, participated pp
where c.regno = pp.regno;

select * from view2;

-- 7
delimiter //
create trigger if not exists ARB before insert on owns for each row
begin
if new.did in (select did from participated
where damageamt in ( select sum(damageamt) from participated )
and damageamt > 50000)
then
signal sqlstate '45000'
set message_text = "Greater than 500000";
end if;
end;

//
delimiter ;

insert into owns VALUES
("d002", "kar-001");