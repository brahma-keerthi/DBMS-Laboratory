-- Creating tables
DROP TABLE IF EXISTS sailors;
CREATE TABLE sailors(
    sid INTEGER,
    sname VARCHAR(10),
    rating INTEGER,
    age INTEGER,

    PRIMARY KEY(sid)
);

DROP TABLE IF EXISTS boat;
CREATE TABLE boat(
    bid INTEGER,
    bname VARCHAR(10),
    color VARCHAR(10),

    PRIMARY KEY(bid)
);

DROP TABLE IF EXISTS reserves;
CREATE TABLE reserves(
    sid INTEGER,
    bid INTEGER,
    date DATE,

    PRIMARY KEY(sid, bid),
    FOREIGN KEY(sid) REFERENCES sailors(sid) ON DELETE CASCADE,
    FOREIGN KEY(bid) REFERENCES boat(bid) ON DELETE CASCADE
);


-- Inserting rows
INSERT INTO sailors VALUES
(100, "Albert", 8, 34),
(101, "Tonystorm", 3, 20),
(102, "Christt", 9, 18),
(103, "Jeremy", 8, 23),
(104, "Bob", 7, 67),
(105, "Alex", 5, 45);

INSERT INTO sailors VALUES
(109, "Nakustorm", 10, 22);

INSERT INTO boat VALUES
(100, "Astorm", "blue"),
(101, "Marsro", "red"),
(102, "Titono", "yellow"),
(103, "Interd", "white"),
(104, "Bform", "purple"),
(105, "Benne", "blue");
(106, "Bstorm", "red"),
(107, "Cstrom", "pink");

INSERT INTO reserves VALUES 
(100, 101, "2020-10-20"),
(100, 102, "2020-08-08"),
(100, 103, "2019-07-16"),
(100, 104, "2019-01-20"),
(100, 105, "2020-06-23"),
(102, 105, "2020-10-20"),
(103, 104, "2020-10-20"),
(103, 103, "2020-10-20"),
(104, 101, "2020-10-12");

INSERT INTO reserves VALUES 
(100, 106, "2020-10-20"),
(100, 107, "2020-10-20");


-- 1. Find the colours of boats reserved by Albert
-- 2. Find all sailor id's of sailors who have a rating of at least 8 or reserved boat 103
-- 3. Find the names of sailors who have not reserved a boat whose name contains the string
-- "storm". Order the names in ascending order.
-- 4. Find the names of sailors who have reserved all boats.
-- 5. Find the name and age of the oldest sailor.
-- 6. For each boat which was reserved by at least 3 sailors with age >= 20, find the boat id and
-- the average age of such sailors.
-- 7. A view that shows names and ratings of all sailors sorted by rating in descending order.
-- 8. A trigger that prevents boats from being deleted If they have active reservations.

-- 1
SELECT color 
from boat
where bid in ( select bid from reserves where sid in ( select sid from sailors where sname = "Albert"));

-- 2
select DISTINCT s.sid
from sailors s, reserves r
where rating >= 8 
AND 
s.sid = r.bid 
AND 
r.bid = 103;

-- 3
select DISTINCT s.sname 
from sailors s, boat b, reserves r
WHERE
s.sid NOT in ( select sid from reserves )
and
s.sname like "%storm%";

-- 4
-- select s.sname
-- from sailors s, reserves r, boat b
-- where b.bid in ( select bid from boat );

-- 5
select sname, age 
from sailors
where age in ( select max(age) from sailors);

-- 6
select b.bid , avg(s.age)
from sailors s, boat b, reserves r
WHERE r.sid=s.sid and r.sid=b.bid and s.age>=20
group by b.bid;

-- 7
create view view1 as 
select sname,rating 
from sailors order by rating desc;

SELECT * from view1;

-- 8
create trigger preventDeletion 
before delete on boat
for each row
begin
if old.bid in ( select bid from reserves )
then
signal sqlstate '45000'
set message_text = "Can't delete boat";
end if;
end;

delete from boat 
where bid = 105;
