/*** Solution for SQL Social-Network Query Exercises & Extras ***/

/*** SQL Social Network Query Exercises - Solution ***/

/* Q1. Find the names of all students who are friends with someone named Gabriel. */
select Highschooler.name 
from Highschooler 
join Friend on Highschooler.ID = Friend.ID1
where Friend.ID2 in (
	select ID 
	from Highschooler 
	where name = "Gabriel");
	
/* solution option 2 */
select s2.name
from Highschooler s1, Highschooler s2, Friend f 
where s1.ID = f.ID1 and s1.name = "Gabriel" and s2.ID = f.ID2;

/* Q2. For every student who likes someone 2 or more grades younger than themselves, 
 * return that student's name and grade, and the name and grade of the student they like. */
select s1.name, s1.grade, s2.name, s2.grade
from Highschooler s1, Highschooler s2, Likes l
where s1.ID = l.ID1 and s2.ID = l.ID2 and s1.grade - s2.grade >= 2;

/* Q3. For every pair of students who both like each other, return the name and grade of 
 * both students. Include each pair only once, with the two names in alphabetical order. */
select s1.name, s1.grade, s2.name, s2.grade
from Highschooler s1, Highschooler s2, Likes l1, Likes l2
where s1.ID = l1.ID1 and s2.ID = l2.ID1 
	and l1.ID1 = l2.ID2 and l1.ID2 = l2.ID1 
	and s1.name < s2.name
order by s1.name, s2.name;

/* Q4. Find all students who do not appear in the Likes table (as a student who likes or is 
 * liked) and return their names and grades. Sort by grade, then by name within each grade. */
select s.name, s.grade
from Highschooler s 
where s.ID not in (select ID1 from Likes) 
	and s.ID not in (select ID2 from Likes)
order by s.grade, s.name;

/* Q5. For every situation where student A likes student B, but we have no information about 
 * whom B likes (that is, B does not appear as an ID1 in the Likes table), 
 * return A and B's names and grades. */
select s1.name, s1.grade, s2.name, s2.grade
from Highschooler s1, Highschooler s2, Likes l1
where s1.ID = l1.ID1 and s2.ID = l1.ID2 
	and l1.ID2 not in (select ID1 from Likes);

/* Q6. Find names and grades of students who only have friends in the same grade. 
 * Return the result sorted by grade, then by name within each grade. */
select name, grade 
from Highschooler
where ID not in (
	select s1.ID 
	from Highschooler s1, Friend f1, Highschooler s2
	where s1.ID = f1.ID1 and s2.ID = f1.ID2 and s2.grade <> s1.grade)
order by grade, name;
				
/* Q7. For each student A who likes a student B where the two are not friends, 
 * find if they have a friend C in common (who can introduce them!). For all such trios, 
 * return the name and grade of A, B, and C. */
select s1.name, s1.grade, s2.name, s2.grade, s3.name, s3.grade
from Highschooler s1, Highschooler s2, Highschooler s3, Likes l1, Friend f1, Friend f2
where s1.ID = l1.ID1 and s2.ID = l1.ID2 and s1.ID = f1.ID1 and s2.ID = f2.ID1
	and s2.ID not in (select ID2 from Friend where ID1 = s1.ID)
	and s3.ID = f1.ID2 and s3.ID = f2.ID2;

/* Q8. Find the difference between the number of students in the school and the number 
 * of different first names. */
select count(*) - count(distinct name)
from Highschooler;

/* Q9. Find the name and grade of all students who are liked by more than one other student. */
select s1.name, s1.grade
from Highschooler s1, Likes l1
where l1.ID2 = s1.ID 
group by l1.ID2 
having count(l1.ID1) > 1;

/*** SQL Social-Network Query Exercises Extras - Solution ***/

/* Q1. For every situation where student A likes student B, but student B likes a different 
 * student C, return the names and grades of A, B, and C. */
select s1.name, s1.grade, s2.name, s2.grade, s3.name, s3.grade
from Highschooler s1, Highschooler s2, Highschooler s3, Likes l1, Likes l2
where s1.ID = l1.ID1 and s2.ID = l1.ID2 
	and s2.ID = l2.ID1 and s3.ID = l2.ID2 and s1.ID <> l2.ID2;

/* Q2. Find those students for whom all of their friends are in different grades from 
 * themselves. Return the students' names and grades. */
select s.name, s.grade
from Highschooler s
where s.ID not in (
	select s2.ID 
	from Highschooler s1, Highschooler s2, Friend f1 
	where s1.ID = f1.ID1 and s2.ID = f1.ID2 and s1.grade = s2.grade);

/* solution option 2 */
select s1.name, s1.grade
from Highschooler s1
where s1.grade not in (
	select s2.grade
	from Highschooler s2, Friend f1 
	where s1.ID = f1.ID1 and s2.ID = f1.ID2);

/* Q3. What is the average number of friends per student? (Your result 
 * should be just one number.) */
select avg(countfriend)
from (
	select count(Friend.ID2) as countfriend
	from Friend 
	group by Friend.ID1);

/* Q4. Find the number of students who are either friends with Cassandra or are 
 * friends of friends of Cassandra. Do not count Cassandra, even though technically 
 * she is a friend of a friend. */
select count(distinct f2.ID1) + count(distinct f2.ID2)
from Highschooler s1, Friend f1, Friend f2
where s1.ID = f1.ID1 and s1.name = "Cassandra" and f1.ID2 = f2.ID1 
	and f2.ID2 in (select ID2 from Friend where ID1 = f1.ID2)
	and f2.ID2 <> s1.ID;

/* solution option 2 */
select count(*)
from Friend f2
where f2.ID1 in (
	select f1.ID2
	from Friend f1
	where f1.ID1 in (
		select ID
		from Highschooler
		where name = "Cassandra"
	)
);

/* Q5. Find the name and grade of the student(s) with the greatest number of friends. */
select s.name, s.grade
from Highschooler s
where s.ID in (
	select ID1 from Friend 
	group by ID1 having count(*) = (
		select max(countfriend) from (
			select count(*) as countfriend from Friend group by ID1)));

/* solution option 2 */
select s.name, s.grade
from Highschooler s join Friend f1 on (s.ID = f1.ID1)
group by f1.ID1
having count(*) = (
	select max(countfriend) from (
		select count(*) as countfriend from Friend group by ID1));
