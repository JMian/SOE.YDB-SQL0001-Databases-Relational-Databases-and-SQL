/*** SQL Movie-Rating Query Exercises - Solution ***/

/* Q1. Find the titles of all movies directed by Steven Spielberg. */
select title
from Movie 
where director = 'Steven Spielberg';

/* Q2. Find all years that have a movie that received a rating of 4 or 5, 
 and sort them in increasing order. */
select distinct M.year
from Movie M, Rating R
where M.mID = R.mID and R.stars in (4,5)
order by M.year asc;

/* Q3. Find the titles of all movies that have no ratings.*/
select title
from Movie 
where mID not in (select mID from Rating);

/* Q4. Some reviewers didn't provide a date with their rating. 
 * Find the names of all reviewers who have ratings with a NULL value for the date. */
select name
from Reviewer
where rID in (select rID from Rating where ratingDate is null);

/* Q5. Write a query to return the ratings data in a more readable format: 
 * reviewer name, movie title, stars, and ratingDate. 
 * Also, sort the data, first by reviewer name, then by movie title, and lastly by number of stars. */
select RV.name, M.title, R.stars, R.ratingDate
from Reviewer RV, Movie M, Rating R
where RV.rID = R.rID and R.mID = M.mID 
order by RV.name, M.title, R.stars;

/* Q6. For all cases where the same reviewer rated the same movie twice and gave it
 * a higher rating the second time, return the reviewer's name and the title of the movie. */
select RV.name, M.title
from Rating R1 join Rating R2 on 
		(R1.rID = R2.rID and R1.mID = R2.mID and 
			(R1.rID, R1.mID) in (select rID, mID from Rating
									group by rID, mID having count(*)=2) 
		and R1.ratingDate < R2.ratingDate and R1.stars < R2.stars)
	join Movie M on (M.mID = R1.mID)
	join Reviewer RV on (RV.rID = R1.rID);


/* Q7. For each movie that has at least one rating, find the highest number of stars 
 * that movie received. Return the movie title and number of stars. Sort by movie title. */
--select M.title, R.maxStar
--from Movie M join (select mID, max(stars) as maxStar from Rating group by mID) as R
--where M.mID = R.mID
--order by M.title;
select M.title, max(R.stars)
from Movie M join Rating R on (R.mID = M.mID)
group by R.mID 
order by M.title;
		
--select mID, (select max(stars) as maxStar from Rating group by mID)
--from Rating; 

/* Q8. For each movie, return the title and the 'rating spread', that is, 
 * the difference between highest and lowest ratings given to that movie. 
 * Sort by rating spread from highest to lowest, then by movie title. */
select M.title, (max(R.stars) - min(R.stars)) as ratingSpread
from Movie M, Rating R on (M.mID = R.mID)
group by R.mID 
order by ratingSpread desc, M.title;

/* Q9. Find the difference between the average rating of movies released before 1980 and 
 * the average rating of movies released after 1980. (Make sure to calculate the average 
 * rating for each movie, then the average of those averages for movies before 1980 and 
 * movies after. Don't just calculate the overall average rating before and after 1980.) */
select avg(pre1980.avgrating) - avg(post1980.avgrating)
from (select avg(stars) as avgrating 
		from Rating 
		join Movie on (Movie.mID = Rating.mID and Movie.year < 1980)
		group by Rating.mID) as pre1980
	join (select avg(stars) as avgrating 
		from Rating 
		join Movie on (Movie.mID = Rating.mID and Movie.year > 1980)
		group by Rating.mID) as post1980;

	
/*** SQL Movie-Rating Query Exercises Extras - Solution ***/
	
/* Q1. Find the names of all reviewers who rated Gone with the Wind. */
--select Reviewer.name
--from Reviewer
--where Reviewer.rID in 
--	(select Rating.rID 
--	from Rating 
--	join Movie on (Rating.mID = Movie.mID and Movie.title = "Gone with the Wind"));
select distinct Reviewer.name
from Reviewer 
	join Rating on Reviewer.rID = Rating.rID 
	join Movie on Movie.mID = Rating.mID 
where Movie.title = "Gone with the Wind";

/* Q2. For any rating where the reviewer is the same as the director of the movie, 
 * return the reviewer name, movie title, and number of stars. */
select Reviewer.name, Movie.title, Rating.stars 
from Reviewer 
	join Rating on Rating.rID = Reviewer.rID
	join Movie on Movie.mID = Rating.mID
where Reviewer.name = Movie.director;
	
/* Q3. Return all reviewer names and movie names together in a single list, alphabetized. 
 * (Sorting by the first name of the reviewer and first word in the title is fine; 
 * no need for special processing on last names or removing "The".) */
select name from Reviewer 
union
select title from Movie
order by Reviewer.name, Movie.title;

/* Q4. Find the titles of all movies not reviewed by Chris Jackson. */
select Movie.title 
from Movie
where Movie.mID not in 
	(select mID from Reviewer 
		join Rating using(rID) 
	where Reviewer.name = "Chris Jackson");

/* Q5. For all pairs of reviewers such that both reviewers gave a rating to the same movie, 
 * return the names of both reviewers. Eliminate duplicates, don't pair reviewers with 
 * themselves, and include each pair only once. For each pair, return the names in the pair 
 * in alphabetical order. */
select distinct rv1.name, rv2.name
from Reviewer rv1, Reviewer rv2, Rating rt1, Rating rt2
where rv1.rID = rt1.rID 
	and rv2.rID = rt2.rID 
	and rt1.mID = rt2.mID 
	and rv1.name < rv2.name
order by rv1.name

/* Q6. For each rating that is the lowest (fewest stars) currently in the database, 
 * return the reviewer name, movie title, and number of stars. */
select rv.name, m.title, rt.stars
from Reviewer rv 
	join Rating rt on rv.rID = rt.rID 
	join Movie m on m.mID = rt.mID 
where rt.stars = (select min(stars) from Rating);

/* Q7. List movie titles and average ratings, from highest-rated to lowest-rated. 
 * If two or more movies have the same average rating, list them in alphabetical order. */
select m.title, avg(rt.stars)
from Movie m join Rating rt using(mID)
group by rt.mID
order by avg(rt.stars) desc, m.title;

/* Q8. Find the names of all reviewers who have contributed three or more ratings. 
 * (As an extra challenge, try writing the query without HAVING or without COUNT.) */
select rv.name
from Reviewer rv join Rating rt using(rID)
group by rt.rID 
having count(*) >= 3;

select distinct rv.name
from Reviewer rv join Rating rt using(rID)
where (select count(*) 
		from Rating rt2 
		where rt2.rID = rt.rID) >= 3;

/* Q9. Some directors directed more than one movie. For all such directors, 
 * return the titles of all movies directed by them, along with the director name. 
 * Sort by director name, then movie title. (As an extra challenge, try writing the 
 * query both with and without COUNT.) */
select title, director
from Movie 
where director in 
		(select director from Movie 
			group by director having count(*) > 1)
order by director, title;

select m1.title, m2.director
from Movie m1 join Movie m2 using(director)
where m1.mID <> m2.mID 
order by m1.director, m1.title;

/* Q10. Find the movie(s) with the highest average rating. Return the movie title(s) 
 * and average rating. (Hint: This query is more difficult to write in SQLite than other 
 * systems; you might think of it as finding the highest average rating and then choosing 
 * the movie(s) with that average rating.) */
--select m.title, max(rt.avgstars)
--from Movie m 
--	join (select mID, avg(stars) as avgstars 
--			from Rating group by mID) rt
--where m.mID = rt.mID;

select m.title, rt1.avgstars
from Movie m 
	join (select mID, avg(stars) as avgstars 
			from Rating group by mID) rt1 using(mID)
where rt1.avgstars = (select max(avgstars) 
						from (select mID, avg(stars) as avgstars 
								from Rating group by mID));
							
select m.title, avg(stars) as avgstars
from Movie m 
	join Rating using(mID)
group by mID 
having avgstars = 
	(select max(avgstars2) 
		from (select avg(stars) as avgstars2
				from Rating group by mID));

/* Q11. Find the movie(s) with the lowest average rating. Return the movie title(s) and 
 * average rating. (Hint: This query may be more difficult to write in SQLite than other 
 * systems; you might think of it as finding the lowest average rating and then 
 * choosing the movie(s) with that average rating.) */
select m.title, rt1.avgstars
from Movie m 
	join (select mID, avg(stars) as avgstars 
			from Rating group by mID) rt1 using(mID)
where rt1.avgstars = (select min(avgstars) 
						from (select mID, avg(stars) as avgstars 
								from Rating group by mID));

select m.title, avg(stars) as avgstars
from Movie m 
	join Rating using(mID)
group by mID 
having avgstars = 
	(select min(avgstars2) 
		from (select avg(stars) as avgstars2
				from Rating group by mID));
					
/* Q12. For each director, return the director's name together with the title(s) 
 * of the movie(s) they directed that received the highest rating among all of 
 * their movies, and the value of that rating. Ignore movies whose director is NULL. */
select m.director, m.title, max(rt.stars)
from Movie m join Rating rt using(mID)
where m.director is not null
group by m.director
