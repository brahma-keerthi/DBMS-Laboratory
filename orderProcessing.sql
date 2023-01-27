drop table if exists customer;
create table customer (
    cid integer,
    cname varchar(10),
    city varchar(10),

    primary key(cid)
);

drop table if exists orderT;
create table orderT(
    oid integer,
    odate DATE,
    cid integer,
    oamt integer,

    primary key (oid),
    foreign key (cid) references customer(cid) on delete cascade
);

drop table if exists orderI;
create table orderI(
    oid integer,
    iid integer,
    qty integer,

    foreign key (iid) references item(iid) on delete cascade,
    foreign key (oid) references orderT(oid) on delete cascade
);

drop table if exists item;
create table item(
    iid integer ,
    uprice integer,

    primary key ( iid )
);

drop table if exists warehouse;
create table warehouse(
    wid integer,
    city varchar(10),

    primary key ( wid )
);

drop table if exists shipment;
create table shipment(
    oid integer ,
    wid integer,
    shipdate DATE,

    foreign key ( oid)  references orderT (oid) on delete cascade,
    foreign key ( wid) references warehouse(wid) on delete cascade

);

insert into customer VALUES
(1, "Virat", "Delhi"),
(2, "Vadpav", "Mumbai"),
(3, "Jadeja", "Rajkot"),
(4, "Pant", "Delhi"),
(5, "Dhoni", "Ranchi");

insert into orderT VALUES
(1, "2020-07-29", 1, 345),
(2, "2021-07-29", 1, 3450),
(3, "2023-07-29", 2, 35),
(4, "2010-07-29", 3, 45),
(5, "2020-03-29", 4, 37),
(6, "2020-07-12", 5, 39);

insert into item VALUES
(1, 345),
(2, 3450),
(3, 35),
(4, 45),
(5, 345),
(6, 37),
(7, 39);

insert into orderI VALUES
(1, 1, 2),
(2, 3, 1),
(3, 1, 2),
(4, 2, 3);

insert into warehouse VALUES
(1, "Delhi"),
(2, "Mumbai"),
(3, "Bangalore"),
(4, "Mysuru"),
(5, "Delhi");

insert into shipment VALUES
(1, 2, "2020-12-23"),
(2, 4, "2021-12-23"),
(3, 1, "2023-12-23"),
(4, 3, "2010-12-23"),
(5, 5, "2020-08-23");

-- Order Processing Database
-- 1. List the Order# and Ship_date for all orders shipped from Warehouse# 2.
-- 2. List the Warehouse information from which the Customer named "Virat" was supplied
-- his orders. Produce a listing of Order#, Warehouse#.
-- 3. Produce a listing: Cname, #ofOrders, Avg_Order_Amt, where the middle column is the
-- total number of orders by the customer and the last column is the average order
-- amount for that customer. (Use aggregate functions)
-- 4. Delete all orders for customer named "Virat".
-- 5. Find the item with the maximum unit price.
-- 6. Create a view to display orderID and shipment date of all orders shipped from a
-- warehouse 2.
-- 7. Create a trigger that does not allow customer to order if they have pending orders

-- 1
select Distinct o.oid , o.odate
from shipment s, warehouse w, orderT o
where s.wid = 2 
and o.oid = s.oid;

-- 2
select s.oid, s.wid 
from shipment s, warehouse w, orderT o, customer c
where c.cid in ( select cid from customer where cname = "Virat")
and o.cid = c.cid
and o.oid = s.oid
and s.wid = w.wid;

-- 3
-- select c.cname , sum()

-- 4
Delete from orderT
where orderT.cid in ( select cid from customer where cname = "Virat");

select * from orderT;

-- 5
select * 
from item
where uprice in ( select max(uprice) from item);

-- 6
create view view3 as 
select Distinct o.oid , o.odate
from shipment s, warehouse w, orderT o
where s.wid = 2 
and o.oid = s.oid;

select * from view3;

-- 7
create trigger  if not exists orddd
before insert on orderT 
for each row 
begin
if new.cid in ( select cid from orderT ) 
then 
signal sqlstate '45000'
set message_text = "Person has order pending";
end if;
end;

insert into orderT VALUES
(1, "2020-07-29", 4, 345);