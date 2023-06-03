
Select *
From DigitalMediaStore.dbo.Customers

-- Write a query to retrieve the customer name, email, and total amount 
-- spent for all customers who have made at least two purchases, excluding those from the USA.

SELECT Cus.FirstName, Cus.LastName, Cus.Email, SUM(inv.Total) AS TotalAmountSpent
FROM DigitalMediaStore.dbo.Customers AS Cus
JOIN DigitalMediaStore.dbo.invoices AS inv 
	ON Cus.CustomerId = inv.CustomerId
WHERE Cus.Country NOT LIKE '%USA%'
GROUP BY Cus.FirstName, Cus.LastName, Cus.Email
HAVING COUNT(*) >= 2;

--Write a query to retrieve the employee first name, last name, and the mumber of 
-- customers they have assisted, ordered by the number of customers in descending order.


SELECT emp.FirstName, emp.LastName, COUNT(cus.CustomerId) AS NumberOfCustomersAssisted
FROM DigitalMediaStore.dbo.employees AS emp
LEFT JOIN DigitalMediaStore.dbo.customers AS cus
	ON emp.EmployeeId = cus.SupportRepId
GROUP BY emp.EmployeeId, emp.FirstName, emp.LastName
ORDER BY NumberOfCustomersAssisted DESC;


-- Write a query to retrieve the artist name and the total duration (in seconds)
-- of all tracks for artists who have more than 50 tracks in the database.

SELECT art.Name AS ArtistName, SUM(cast(tra.Milliseconds as float))/1000 AS TotalDurationInSeconds
FROM DigitalMediaStore.dbo.artists AS art
JOIN DigitalMediaStore.dbo.albums AS alb 
	ON art.ArtistId = alb.ArtistId
JOIN DigitalMediaStore.dbo.tracks AS tra 
	ON alb.AlbumId = tra.AlbumId
GROUP BY art.ArtistId, art.Name
HAVING COUNT(tra.TrackId) > 50;


-- Write a query to retrieve the track name, album title, and composer 
-- for all tracks that are longer than the average duration of tracks in their respective albums.


SELECT tra.Name AS TrackName, alb.Title AS AlbumTitle, tra.Composer
FROM DigitalMediaStore.dbo.tracks AS tra
JOIN DigitalMediaStore.dbo.albums AS alb ON tra.AlbumId = alb.AlbumId
WHERE tra.Milliseconds > (
    SELECT AVG(tra2.Milliseconds)
    FROM DigitalMediaStore.dbo.tracks AS tra2
    WHERE tra2.AlbumId = tra.AlbumId
)
ORDER BY alb.Title, tra.Name;


-- Write a query to retrieve the album title, track name, and genre name for 
-- all tracks that belong to albums where the average track duration is longer than 
-- the average track duration of all albums in the database. Include only tracks 
-- with a duration longer than the average track duration of their respective albums.


SELECT alb.Title AS AlbumTitle, tra.Name AS TrackName, gen.Name AS GenreName
FROM DigitalMediaStore.dbo.tracks AS tra
JOIN DigitalMediaStore.dbo.albums AS alb ON tra.AlbumId = alb.AlbumId
JOIN DigitalMediaStore.dbo.genres AS gen ON tra.GenreId = gen.GenreId
WHERE tra.Milliseconds > (
    SELECT AVG(tra2.Milliseconds)
    FROM DigitalMediaStore.dbo.tracks AS tra2
    WHERE tra2.AlbumId = tra.AlbumId
)
AND alb.AlbumId IN (
    SELECT alb2.AlbumId
    FROM DigitalMediaStore.dbo.tracks AS tra2
    JOIN DigitalMediaStore.dbo.albums AS alb2 ON tra2.AlbumId = alb2.AlbumId
    GROUP BY alb2.AlbumId
    HAVING AVG(tra2.Milliseconds) > (
        SELECT AVG(tra3.Milliseconds)
        FROM DigitalMediaStore.dbo.tracks AS tra3
    )
)
ORDER BY alb.Title, tra.Name;




