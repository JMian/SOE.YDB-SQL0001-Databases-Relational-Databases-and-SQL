/*** Solution for SQL Social-Network Modification Exercises ***/

/*** SQL Social-Network Modification - Solution ***/

/* Q1. It's time for the seniors to graduate. Remove all 12th graders from Highschooler. */
delete from Highschooler 
where grade = 12;

/* Q2. If two students A and B are friends, and A likes B but not vice-versa, 
 * remove the Likes tuple. */
delete from Likes 
where ID1 in (
	select Likes.ID1 from Friend join Likes using(ID1) where Friend.ID2 = Likes.ID2) 
	and ID2 not in (
	select Likes.ID1 from Friend join Likes using(ID1) where Friend.ID2 = Likes.ID2);

delete from Likes as l1
where exists (select * from Friend f1 where f1.ID1 = l1.ID1 and f1.ID2 = l1.ID2)
and not exists (select * from Likes l2 where l1.ID2 = l2.ID1 and l1.ID1 = l2.ID2); 

/* Q3. For all cases where A is friends with B, and B is friends with C, add a new 
 * friendship for the pair A and C. Do not add duplicate friendships, friendships that 
 * already exist, or friendships with oneself. (This one is a bit challenging; 
 * congratulations if you get it right.) */ 
insert into Friend
select distinct *
from (select f1.ID1, f2.ID2 
		from Friend f1 
		join Friend f2 on (f1.ID2 = f2.ID1 and f1.ID1 <> f2.ID2)) t1 
where not exists (select * from Friend 
					where Friend.ID1 = t1.ID1 and Friend.ID2 = t1.ID2);
					
insert into Friend 
select distinct f1.ID1, f2.ID2 
from Friend f1, Friend f2 
where f1.ID2 = f2.ID1 and f1.ID1 <> f2.ID2
except 
select * from Friend;