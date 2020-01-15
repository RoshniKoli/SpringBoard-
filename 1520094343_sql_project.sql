/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */
select name
from country_club.Facilities where membercost>0;


/* Q2: How many facilities do not charge a fee to members? */
select name
from country_club.Facilities where membercost>0;


/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
select facid,name, membercost,monthlymaintenance
from country_club.Facilities where membercost<(0.2* monthlymaintenance) and membercost>0;


/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */
select *
from country_club.Facilities where facid in (1,5)


/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */
select name, monthlymaintenance,
case when monthlymaintenance>100 then 'expensive'
	else 'cheap' end as costwise
from country_club.Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */
SELECT firstname,surname,joindate 
FROM  country_club.Members 
where joindate in (select max(joindate) from country_club.Members)

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SElect distinct concat(Members.firstname," ",name)as member_fac from Members join ( Select Bookings.memid, Facilities.name
from Bookings join Facilities 
on Bookings.facid = Facilities.facid
where name like 'Tennis%') as temp
on Members.memid= temp.memid 
order by member_fac

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
Select case when Members.memid=0 then slots*guestcost
			else slots*membercost end as tot_cost,
		concat(firstname," ",name)
from Bookings join Facilities
on Bookings.facid = Facilities.facid 
join Members on Bookings.memid=Members.memid 
where starttime like '2012-09-14%' 
having tot_cost>30
order by tot_cost desc 

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
Select concat(Members.firstname," ",name), Cost 
from Members 
join (Select Facilities.facid, name, guestcost,membercost,memid,slots,bookid,
		case when memid =0 then guestcost * slots 
		else membercost*slots end as Cost 
		from Facilities
		join(SELECT * FROM `Bookings` WHERE starttime like '2012-09-14%') as book
		on Facilities.facid = book.facid) as temp
on Members.memid = temp.memid
where Cost>30
order by Cost desc

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
Select name,(membercost*member + guestcost*guest -monthlymaintenance) as revenue from Facilities join(SELECT facid, sum(case when memid = 0 then slots end) as guest,
	sum(case when memid!= 0 then slots end) as member 
FROM Bookings
group by facid)temp
on Facilities.facid = temp.facid
having revenue<1000
order by revenue desc
