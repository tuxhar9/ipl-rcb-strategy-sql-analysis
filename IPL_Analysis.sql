-- Ipl strategy  by Tushar Naha

USE ipl;
SHOW TABLES;

-- Q1: List the different data types of columns in ball_by_ball table

SELECT 
COLUMN_NAME,
DATA_TYPE
FROM information_schema.columns
WHERE table_schema = 'ipl'
AND table_name = 'ball_by_ball';

-- Q2: What is the total number of runs scored in 1st season by RCB (bonus: also include the extra runs using the extra runs table)

SELECT 
    SUM(b.Runs_Scored) AS Regular_Runs,
    COALESCE(SUM(e.Extra_Runs), 0) AS Extra_Runs,
    SUM(b.Runs_Scored) + COALESCE(SUM(e.Extra_Runs), 0) AS Total_Runs
FROM Ball_by_Ball b
JOIN Matches m 
    ON b.Match_Id = m.Match_Id
LEFT JOIN Extra_Runs e 
    ON b.Match_Id = e.Match_Id
    AND b.Over_Id = e.Over_Id
    AND b.Ball_Id = e.Ball_Id
    AND b.Innings_No = e.Innings_No
WHERE b.Team_Batting = 2
AND m.Season_Id = 6;

-- Q3: Number of players aged more than 25 during season 2014?

SELECT 
    COUNT(DISTINCT p.Player_Id) AS Players_Above_25
FROM Player p
JOIN Player_Match pm 
    ON p.Player_Id = pm.Player_Id
JOIN Matches m 
    ON pm.Match_Id = m.Match_Id
JOIN Season s 
    ON m.Season_Id = s.Season_Id
WHERE s.Season_Year = 2014
AND TIMESTAMPDIFF(YEAR, p.DOB, m.Match_Date) > 25;

-- Q4: Number of matches won by RCB in 2013?

SELECT 
    COUNT(*) AS RCB_Wins_2013
FROM Matches m
JOIN Season s 
    ON m.Season_Id = s.Season_Id
JOIN Team t 
    ON m.Match_Winner = t.Team_Id
WHERE s.Season_Year = 2013
AND t.Team_Name = 'Royal Challengers Bangalore';

-- Q5: Top 10 players by strike rate in last 4 seasons

SELECT 
    p.Player_Name,
    COUNT(*) AS Balls_Faced,
    SUM(b.Runs_Scored) AS Total_Runs,
    ROUND((SUM(b.Runs_Scored) * 100.0 / COUNT(*)), 2) AS Strike_Rate
FROM Ball_by_Ball b
JOIN Matches m 
    ON b.Match_Id = m.Match_Id
JOIN Season s 
    ON m.Season_Id = s.Season_Id
JOIN Player p 
    ON b.Striker = p.Player_Id
WHERE s.Season_Year >= (SELECT MAX(Season_Year) - 3 FROM Season)
GROUP BY p.Player_Id, p.Player_Name
HAVING COUNT(*) >= 200
ORDER BY Strike_Rate DESC
LIMIT 10;

-- Q6: Average runs scored by each batsman across all seasons

SELECT 
    p.Player_Name,
    COUNT(DISTINCT m.Match_Id) AS Matches_Played,
    SUM(b.Runs_Scored) AS Total_Runs,
    ROUND(SUM(b.Runs_Scored) / COUNT(DISTINCT m.Match_Id), 2) AS Average_Runs
FROM Ball_by_Ball b
JOIN Player p 
    ON b.Striker = p.Player_Id
JOIN Matches m 
    ON b.Match_Id = m.Match_Id
GROUP BY p.Player_Id, p.Player_Name
HAVING COUNT(DISTINCT m.Match_Id) >= 10
ORDER BY Average_Runs DESC
LIMIT 15;

-- Q7: Average wickets taken by each bowler across all seasons?

SELECT 
    p.Player_Name,
    COUNT(DISTINCT b.Match_Id) AS Matches_Bowled,
    COUNT(w.Player_Out) AS Total_Wickets,
    ROUND(COUNT(w.Player_Out) / COUNT(DISTINCT b.Match_Id), 2) AS Average_Wickets
FROM Ball_by_Ball b
JOIN Player p 
    ON b.Bowler = p.Player_Id
LEFT JOIN Wicket_Taken w 
    ON b.Match_Id = w.Match_Id
    AND b.Over_Id = w.Over_Id
    AND b.Ball_Id = w.Ball_Id
    AND b.Innings_No = w.Innings_No
GROUP BY p.Player_Id, p.Player_Name
HAVING COUNT(DISTINCT b.Match_Id) >= 10
ORDER BY Average_Wickets DESC
LIMIT 15;

-- Q8: List all the players who have average runs scored greater than the overall average and who have taken wickets greater than the overall average


WITH Batting_Stats AS (
    SELECT 
        b.Striker AS Player_Id,
        COUNT(DISTINCT b.Match_Id) AS Matches_Batted,
        SUM(b.Runs_Scored) AS Total_Runs,
        ROUND(SUM(b.Runs_Scored) / COUNT(DISTINCT b.Match_Id), 2) AS Avg_Runs
    FROM Ball_by_Ball b
    GROUP BY b.Striker
),
Bowling_Stats AS (
    SELECT 
        b.Bowler AS Player_Id,
        COUNT(DISTINCT b.Match_Id) AS Matches_Bowled,
        COUNT(w.Player_Out) AS Total_Wickets,
        ROUND(COUNT(w.Player_Out) / COUNT(DISTINCT b.Match_Id), 2) AS Avg_Wickets
    FROM Ball_by_Ball b
    LEFT JOIN Wicket_Taken w 
        ON b.Match_Id = w.Match_Id
        AND b.Over_Id = w.Over_Id
        AND b.Ball_Id = w.Ball_Id
        AND b.Innings_No = w.Innings_No
    GROUP BY b.Bowler
)
SELECT 
    p.Player_Name,
    bat.Avg_Runs,
    bowl.Avg_Wickets
FROM Batting_Stats bat
JOIN Bowling_Stats bowl 
    ON bat.Player_Id = bowl.Player_Id
JOIN Player p 
    ON bat.Player_Id = p.Player_Id
WHERE bat.Avg_Runs > (SELECT AVG(Avg_Runs) FROM Batting_Stats)
AND bowl.Avg_Wickets > (SELECT AVG(Avg_Wickets) FROM Bowling_Stats)
ORDER BY bat.Avg_Runs DESC, bowl.Avg_Wickets DESC;


-- Q9:Create a table rcb_record table that shows the wins and losses of RCB in an individual venue.

DROP TABLE IF EXISTS rcb_record;

CREATE TABLE rcb_record 
SELECT 
    v.Venue_Name,
    COUNT(DISTINCT m.Match_Id) AS Total_Matches,
    SUM(CASE WHEN m.Match_Winner = 2 THEN 1 ELSE 0 END) AS Wins,
    SUM(CASE WHEN m.Match_Winner != 2 
        AND m.Match_Winner IS NOT NULL THEN 1 ELSE 0 END) AS Losses,
    SUM(CASE WHEN m.Match_Winner IS NULL THEN 1 ELSE 0 END) AS No_Result,
    ROUND(100 * SUM(CASE WHEN m.Match_Winner = 2 THEN 1 ELSE 0 END) 
        / COUNT(DISTINCT m.Match_Id), 2) AS Win_Percentage
FROM Matches m
JOIN Venue v 
    ON m.Venue_Id = v.Venue_Id
WHERE m.Team_1 = 2 OR m.Team_2 = 2
GROUP BY v.Venue_Name
ORDER BY Wins DESC;

SELECT * FROM rcb_record;

-- Q10: What is the impact of bowling style on wickets taken?

SELECT 
    bs.Bowling_skill AS Bowling_Style,
    COUNT(DISTINCT b.Bowler) AS Total_Bowlers,
    COUNT(w.Player_Out) AS Total_Wickets,
    COUNT(DISTINCT w.Match_Id) AS Total_Matches,
    ROUND(COUNT(w.Player_Out) / COUNT(DISTINCT w.Match_Id), 2) 
        AS Avg_Wickets_Per_Match
FROM Ball_by_Ball b
JOIN Wicket_Taken w 
    ON w.Match_Id = b.Match_Id
    AND w.Over_Id = b.Over_Id
    AND w.Ball_Id = b.Ball_Id
    AND w.Innings_No = b.Innings_No
JOIN Player p 
    ON b.Bowler = p.Player_Id
JOIN Bowling_Style bs 
    ON p.Bowling_skill = bs.Bowling_Id
GROUP BY bs.Bowling_skill
ORDER BY Total_Wickets DESC;


-- Q11: Write the SQL query to provide a status of whether the performance of the team is better than the previous year's performance on the basis of the number of runs scored by the team in the season and the number of wickets taken 

WITH Team_Performance AS (
    SELECT 
        t.Team_Name,
        s.Season_Year,
        SUM(b.Runs_Scored) AS Total_Runs,
        COUNT(w.Player_Out) AS Total_Wickets
    FROM Ball_by_Ball b
    JOIN Matches m 
        ON b.Match_Id = m.Match_Id
    JOIN Team t 
        ON t.Team_Id = b.Team_Batting
    JOIN Season s 
        ON s.Season_Id = m.Season_Id
    LEFT JOIN Wicket_Taken w 
        ON w.Match_Id = b.Match_Id
        AND w.Over_Id = b.Over_Id
        AND w.Ball_Id = b.Ball_Id
        AND w.Innings_No = b.Innings_No
    GROUP BY t.Team_Name, s.Season_Year
),
Performance_With_Lag AS (
    SELECT 
        Team_Name,
        Season_Year,
        Total_Runs,
        Total_Wickets,
        LAG(Total_Runs) OVER(PARTITION BY Team_Name 
            ORDER BY Season_Year) AS Prev_Year_Runs,
        LAG(Total_Wickets) OVER(PARTITION BY Team_Name 
            ORDER BY Season_Year) AS Prev_Year_Wickets
    FROM Team_Performance
)
SELECT 
    Team_Name,
    Season_Year,
    Total_Runs,
    Prev_Year_Runs,
    CASE 
        WHEN Prev_Year_Runs IS NULL THEN 'First Season'
        WHEN Total_Runs > Prev_Year_Runs THEN 'Better'
        WHEN Total_Runs < Prev_Year_Runs THEN 'Worse'
        ELSE 'Same'
    END AS Runs_Status,
    Total_Wickets,
    Prev_Year_Wickets,
    CASE 
        WHEN Prev_Year_Wickets IS NULL THEN 'First Season'
        WHEN Total_Wickets > Prev_Year_Wickets THEN 'Better'
        WHEN Total_Wickets < Prev_Year_Wickets THEN 'Worse'
        ELSE 'Same'
    END AS Wickets_Status
FROM Performance_With_Lag
ORDER BY Team_Name, Season_Year;

-- Q12: KPI 1 - Powerplay run rate per team (overs 1-6)
SELECT
    t.Team_Name,
    SUM(b.Runs_Scored) AS Powerplay_Runs,
    COUNT(*) AS Balls_Bowled,
    ROUND(SUM(b.Runs_Scored) * 6.0 / COUNT(*), 2) AS Powerplay_Run_Rate
FROM Ball_by_Ball b
JOIN Team t ON b.Team_Batting = t.Team_Id
WHERE b.Over_Id BETWEEN 1 AND 6
GROUP BY t.Team_Name
ORDER BY Powerplay_Run_Rate DESC;

-- Q12: KPI 2 - Death over run rate per team (overs 16-20)
SELECT
    t.Team_Name,
    SUM(b.Runs_Scored) AS Death_Runs,
    COUNT(*) AS Balls_Bowled,
    ROUND(SUM(b.Runs_Scored) * 6.0 / COUNT(*), 2) AS Death_Over_Run_Rate
FROM Ball_by_Ball b
JOIN Team t ON b.Team_Batting = t.Team_Id
WHERE b.Over_Id BETWEEN 16 AND 20
GROUP BY t.Team_Name
ORDER BY Death_Over_Run_Rate DESC;

-- Q12: KPI 3 - Economy rate per bowler (top 10 most economical)
SELECT 
    p.Player_Name,
    COUNT(DISTINCT b.Match_Id) AS Matches,
    COUNT(*) AS Balls_Bowled,
    SUM(b.Runs_Scored) AS Runs_Given,
    ROUND(SUM(b.Runs_Scored) * 6.0 / COUNT(*), 2) AS Economy_Rate
FROM Ball_by_Ball b
JOIN Player p ON b.Bowler = p.Player_Id
GROUP BY p.Player_Id, p.Player_Name
HAVING COUNT(DISTINCT b.Match_Id) >= 10
ORDER BY Economy_Rate ASC
LIMIT 10;

-- Q12: KPI 4 - Dot ball percentage per bowler
SELECT 
    p.Player_Name,
    COUNT(*) AS Total_Balls,
    SUM(CASE WHEN b.Runs_Scored = 0 THEN 1 ELSE 0 END) AS Dot_Balls,
    ROUND(SUM(CASE WHEN b.Runs_Scored = 0 THEN 1 ELSE 0 END) * 100.0 
        / COUNT(*), 2) AS Dot_Ball_Percentage
FROM Ball_by_Ball b
JOIN Player p ON b.Bowler = p.Player_Id
GROUP BY p.Player_Id, p.Player_Name
HAVING COUNT(*) >= 200
ORDER BY Dot_Ball_Percentage DESC
LIMIT 10;


-- Q12: KPI 5 - Boundary percentage per batsman
SELECT 
    p.Player_Name,
    COUNT(*) AS Total_Balls,
    SUM(CASE WHEN b.Runs_Scored = 4 THEN 1 ELSE 0 END) AS Fours,
    SUM(CASE WHEN b.Runs_Scored = 6 THEN 1 ELSE 0 END) AS Sixes,
    ROUND(SUM(CASE WHEN b.Runs_Scored IN (4,6) THEN 1 ELSE 0 END) 
        * 100.0 / COUNT(*), 2) AS Boundary_Percentage
FROM Ball_by_Ball b
JOIN Player p ON b.Striker = p.Player_Id
GROUP BY p.Player_Id, p.Player_Name
HAVING COUNT(*) >= 200
ORDER BY Boundary_Percentage DESC
LIMIT 10;


-- Q13: Using SQL, write a query to find out the average wickets taken by each bowler in each venue. Also, rank the gender according to the average value.


SELECT 
    p.Player_Name,
    v.Venue_Name,
    COUNT(DISTINCT w.Match_Id) AS Matches,
    COUNT(w.Player_Out) AS Total_Wickets,
    ROUND(COUNT(w.Player_Out) / COUNT(DISTINCT w.Match_Id), 2) 
        AS Avg_Wickets,
    DENSE_RANK() OVER(ORDER BY 
        ROUND(COUNT(w.Player_Out) / COUNT(DISTINCT w.Match_Id), 2) 
        DESC) AS Bowler_Rank
FROM Wicket_Taken w
JOIN Ball_by_Ball b 
    ON w.Match_Id = b.Match_Id
    AND w.Over_Id = b.Over_Id
    AND w.Ball_Id = b.Ball_Id
    AND w.Innings_No = b.Innings_No
JOIN Player p 
    ON b.Bowler = p.Player_Id
JOIN Matches m 
    ON w.Match_Id = m.Match_Id
JOIN Venue v 
    ON m.Venue_Id = v.Venue_Id
GROUP BY p.Player_Id, p.Player_Name, v.Venue_Id, v.Venue_Name
HAVING COUNT(DISTINCT w.Match_Id) >= 2
ORDER BY Bowler_Rank
LIMIT 20;

-- Q14: Which of the given players have consistently performed well in past seasons? (will you use any visualization to solve the problem)Players who have consistently performed well across seasons

SELECT 
    Player_Name,
    COUNT(DISTINCT Season_Year) AS Seasons_Played,
    SUM(Season_Runs) AS Total_Runs,
    ROUND(SUM(Season_Runs) / COUNT(DISTINCT Season_Year), 2) 
        AS Avg_Runs_Per_Season,
    MIN(Season_Runs) AS Min_Season_Runs,
    MAX(Season_Runs) AS Max_Season_Runs,
    ROUND(MAX(Season_Runs) - MIN(Season_Runs), 2) AS Performance_Range
FROM (
    SELECT 
        p.Player_Name,
        p.Player_Id,
        s.Season_Year,
        SUM(b.Runs_Scored) AS Season_Runs
    FROM Ball_by_Ball b
    JOIN Player p 
        ON b.Striker = p.Player_Id
    JOIN Matches m 
        ON b.Match_Id = m.Match_Id
    JOIN Season s 
        ON m.Season_Id = s.Season_Id
    GROUP BY p.Player_Id, p.Player_Name, s.Season_Year
) AS Season_Totals
GROUP BY Player_Id, Player_Name
HAVING COUNT(DISTINCT Season_Year) >= 4
ORDER BY Avg_Runs_Per_Season DESC
LIMIT 15;

-- Q14: Season wise run trend for top 5 consistent performers

SELECT 
    p.Player_Name,
    s.Season_Year,
    SUM(b.Runs_Scored) AS Season_Runs
FROM Ball_by_Ball b
JOIN Player p ON b.Striker = p.Player_Id
JOIN Matches m ON b.Match_Id = m.Match_Id
JOIN Season s ON m.Season_Id = s.Season_Id
WHERE p.Player_Name IN (
    'V Kohli', 'DA Warner', 'AB de Villiers', 
    'RG Sharma', 'RV Uthappa')
GROUP BY p.Player_Id, p.Player_Name, s.Season_Year
ORDER BY p.Player_Name, s.Season_Year;


-- Q15: Are there players whose performance is more suited to specific venues or conditions? (how would you present this using charts?) 

SELECT 
    p.Player_Name,
    v.Venue_Name,
    COUNT(DISTINCT b.Match_Id) AS Matches,
    SUM(b.Runs_Scored) AS Total_Runs,
    ROUND(SUM(b.Runs_Scored) / COUNT(DISTINCT b.Match_Id), 2) 
        AS Avg_Runs,
    ROUND(SUM(b.Runs_Scored) * 100.0 / COUNT(*), 2) AS Strike_Rate
FROM Ball_by_Ball b
JOIN Player p 
    ON b.Striker = p.Player_Id
JOIN Matches m 
    ON b.Match_Id = m.Match_Id
JOIN Venue v 
    ON m.Venue_Id = v.Venue_Id
GROUP BY p.Player_Id, p.Player_Name, v.Venue_Id, v.Venue_Name
HAVING COUNT(DISTINCT b.Match_Id) >= 3
ORDER BY p.Player_Name, Avg_Runs DESC
LIMIT 20;

-- Subjective Q1: How does the toss decision affect the result of the match? (which visualizations could be used to present your answer better) And is the impact limited to only specific venues?

-- Overall toss decision impact

SELECT 
    td.Toss_Name AS Toss_Decision,
    COUNT(*) AS Total_Matches,
    SUM(CASE WHEN m.Toss_Winner = m.Match_Winner 
        THEN 1 ELSE 0 END) AS Wins_After_Toss,
    SUM(CASE WHEN m.Toss_Winner != m.Match_Winner 
        THEN 1 ELSE 0 END) AS Losses_After_Toss,
    ROUND(SUM(CASE WHEN m.Toss_Winner = m.Match_Winner 
        THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Win_Percentage
FROM Matches m
JOIN Toss_Decision td 
    ON m.Toss_Decide = td.Toss_Id
GROUP BY td.Toss_Name;

-- Venue specific toss impact

SELECT 
    v.Venue_Name,
    td.Toss_Name AS Toss_Decision,
    COUNT(*) AS Total_Matches,
    SUM(CASE WHEN m.Toss_Winner = m.Match_Winner 
        THEN 1 ELSE 0 END) AS Wins_After_Toss,
    ROUND(SUM(CASE WHEN m.Toss_Winner = m.Match_Winner 
        THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Win_Percentage
FROM Matches m
JOIN Toss_Decision td 
    ON m.Toss_Decide = td.Toss_Id
JOIN Venue v 
    ON m.Venue_Id = v.Venue_Id
GROUP BY v.Venue_Name, td.Toss_Name
HAVING COUNT(*) >= 3
ORDER BY Win_Percentage DESC
LIMIT 20;

-- Subjective Q2: Suggest some of the players who would be best fit for the team.


SELECT 
    p.Player_Name,
    COUNT(DISTINCT m.Match_Id) AS Matches_Played,
    SUM(b.Runs_Scored) AS Total_Runs,
    ROUND(SUM(b.Runs_Scored) / COUNT(DISTINCT m.Match_Id), 2) AS Avg_Runs,
    ROUND(SUM(b.Runs_Scored) * 100.0 / COUNT(*), 2) AS Strike_Rate,
    COUNT(DISTINCT s.Season_Year) AS Seasons_Active,
    ROUND((SUM(b.Runs_Scored) / COUNT(DISTINCT m.Match_Id)) *
        (SUM(b.Runs_Scored) * 100.0 / COUNT(*)) / 100, 2) AS Composite_Score
FROM Ball_by_Ball b
JOIN Player p ON b.Striker = p.Player_Id
JOIN Matches m ON b.Match_Id = m.Match_Id
JOIN Season s ON m.Season_Id = s.Season_Id
GROUP BY p.Player_Id, p.Player_Name
HAVING COUNT(DISTINCT m.Match_Id) >= 20
ORDER BY Composite_Score DESC
LIMIT 15;


-- Subjective Q3: What are some of the parameters that should be focused on while selecting the players?

                                      -- No code
                                      
                                      

-- Subjective Q4: Which players offer versatility in their skills and can contribute effectively with both bat and ball? (can you visualize the data for the same)


WITH Batting AS (
    SELECT 
        b.Striker AS Player_Id,
        SUM(b.Runs_Scored) AS Total_Runs,
        ROUND(SUM(b.Runs_Scored) * 100.0 / COUNT(*), 2) AS Strike_Rate,
        COUNT(DISTINCT b.Match_Id) AS Matches_Batted
    FROM Ball_by_Ball b
    GROUP BY b.Striker
),
Bowling AS (
    SELECT 
        b.Bowler AS Player_Id,
        COUNT(wt.Player_Out) AS Total_Wickets,
        ROUND(SUM(b.Runs_Scored) * 6.0 / COUNT(*), 2) AS Economy_Rate,
        COUNT(DISTINCT b.Match_Id) AS Matches_Bowled
    FROM Ball_by_Ball b
    LEFT JOIN Wicket_Taken wt 
        ON wt.Match_Id = b.Match_Id
        AND wt.Over_Id = b.Over_Id
        AND wt.Ball_Id = b.Ball_Id
        AND wt.Innings_No = b.Innings_No
    GROUP BY b.Bowler
)
SELECT 
    p.Player_Name,
    bat.Total_Runs,
    bat.Strike_Rate,
    bat.Matches_Batted,
    bowl.Total_Wickets,
    bowl.Economy_Rate,
    bowl.Matches_Bowled
FROM Batting bat
JOIN Bowling bowl 
    ON bat.Player_Id = bowl.Player_Id
JOIN Player p 
    ON bat.Player_Id = p.Player_Id
WHERE bat.Total_Runs > 200
AND bowl.Total_Wickets > 10
ORDER BY bat.Total_Runs DESC
LIMIT 15;


-- Subjective Q5: Are there players whose presence positively influences the morale and performance of the team? (justify your answer using visualization)


SELECT 
    p.Player_Name,
    COUNT(*) AS MOTM_Awards,
    COUNT(DISTINCT m.Season_Id) AS Seasons
FROM Matches m
JOIN Player p 
    ON m.Man_of_the_Match = p.Player_Id
JOIN Player_Match pm 
    ON p.Player_Id = pm.Player_Id
    AND m.Match_Id = pm.Match_Id
WHERE pm.Team_Id = 2
GROUP BY p.Player_Id, p.Player_Name
ORDER BY MOTM_Awards DESC
LIMIT 10;


-- Subjective Q6: What would you suggest to RCB before going to the mega auction? 

SELECT 
    s.Season_Year,
    COUNT(DISTINCT m.Match_Id) AS Matches_Played,
    SUM(CASE WHEN m.Match_Winner = 2 THEN 1 ELSE 0 END) AS Wins,
    SUM(CASE WHEN m.Match_Winner != 2 
        AND m.Match_Winner IS NOT NULL 
        THEN 1 ELSE 0 END) AS Losses,
    ROUND(SUM(CASE WHEN m.Match_Winner = 2 THEN 1 ELSE 0 END) 
        * 100.0 / COUNT(DISTINCT m.Match_Id), 2) AS Win_Percentage
FROM Matches m
JOIN Season s 
    ON m.Season_Id = s.Season_Id
WHERE m.Team_1 = 2 OR m.Team_2 = 2
GROUP BY s.Season_Year
ORDER BY s.Season_Year;


-- Subjective Q7: What do you think could be the factors contributing to the high-scoring matches and the impact on viewership and team strategies


SELECT 
    m.Match_Id,
    v.Venue_Name,
    s.Season_Year,
    SUM(b.Runs_Scored) AS Total_Runs,
    COUNT(DISTINCT b.Innings_No) AS Innings,
    ROUND(SUM(b.Runs_Scored) / COUNT(DISTINCT b.Innings_No), 2) 
        AS Avg_Runs_Per_Innings,
    COUNT(CASE WHEN b.Runs_Scored = 6 THEN 1 END) AS Sixes,
    COUNT(CASE WHEN b.Runs_Scored = 4 THEN 1 END) AS Fours,
    COALESCE(SUM(e.Extra_Runs), 0) AS Extra_Runs
FROM Ball_by_Ball b
JOIN Matches m ON b.Match_Id = m.Match_Id
JOIN Venue v ON m.Venue_Id = v.Venue_Id
JOIN Season s ON m.Season_Id = s.Season_Id
LEFT JOIN Extra_Runs e 
    ON b.Match_Id = e.Match_Id
    AND b.Over_Id = e.Over_Id
    AND b.Ball_Id = e.Ball_Id
    AND b.Innings_No = e.Innings_No
GROUP BY m.Match_Id, v.Venue_Name, s.Season_Year
ORDER BY Total_Runs DESC
LIMIT 15;


-- Subjective Q8: Analyze the impact of home-ground advantage on team performance and identify strategies to maximize this advantage for RCB.


SELECT 
    CASE 
        WHEN m.Venue_Id = 1 THEN 'Home (Chinnaswamy)'
        ELSE 'Away'
    END AS Match_Type,
    COUNT(*) AS Total_Matches,
    SUM(CASE WHEN m.Match_Winner = 2 THEN 1 ELSE 0 END) AS Wins,
    SUM(CASE WHEN m.Match_Winner != 2 
        AND m.Match_Winner IS NOT NULL 
        THEN 1 ELSE 0 END) AS Losses,
    ROUND(SUM(CASE WHEN m.Match_Winner = 2 THEN 1 ELSE 0 END) 
        * 100.0 / COUNT(*), 2) AS Win_Percentage
FROM Matches m
WHERE m.Team_1 = 2 OR m.Team_2 = 2
GROUP BY Match_Type
ORDER BY Win_Percentage DESC;


-- Subjective Q9: Come up with a visual and analytical analysis of the RCB's past season's performance and potential reasons for them not winning a trophy.



SELECT 
    s.Season_Year,
    COUNT(DISTINCT m.Match_Id) AS Matches_Played,
    SUM(CASE WHEN m.Match_Winner = 2 THEN 1 ELSE 0 END) AS Wins,
    SUM(CASE WHEN m.Match_Winner != 2 
        AND m.Match_Winner IS NOT NULL 
        THEN 1 ELSE 0 END) AS Losses,
    bat.Total_Runs_Scored,
    ROUND(bat.Total_Runs_Scored / COUNT(DISTINCT m.Match_Id), 2) 
        AS Avg_Runs_Per_Match,
    bat.Total_Wickets_Taken,
    ROUND(bat.Total_Wickets_Taken / COUNT(DISTINCT m.Match_Id), 2) 
        AS Avg_Wickets_Per_Match,
    ROUND(SUM(CASE WHEN m.Match_Winner = 2 THEN 1 ELSE 0 END) 
        * 100.0 / COUNT(DISTINCT m.Match_Id), 2) AS Win_Percentage
FROM Matches m
JOIN Season s ON m.Season_Id = s.Season_Id
JOIN (
    SELECT 
        m2.Season_Id,
        SUM(b.Runs_Scored) AS Total_Runs_Scored,
        COUNT(w.Player_Out) AS Total_Wickets_Taken
    FROM Ball_by_Ball b
    JOIN Matches m2 ON b.Match_Id = m2.Match_Id
    LEFT JOIN Wicket_Taken w 
        ON b.Match_Id = w.Match_Id
        AND b.Over_Id = w.Over_Id
        AND b.Ball_Id = w.Ball_Id
        AND b.Innings_No = w.Innings_No
    WHERE (m2.Team_1 = 2 OR m2.Team_2 = 2)
    AND b.Team_Batting = 2
    GROUP BY m2.Season_Id
) bat ON m.Season_Id = bat.Season_Id
WHERE m.Team_1 = 2 OR m.Team_2 = 2
GROUP BY s.Season_Year, bat.Total_Runs_Scored, bat.Total_Wickets_Taken
ORDER BY s.Season_Year;


-- Subjective Q10: How would you approach this problem, if the objective and subjective questions weren't given?

                                                 -- No code
                                                 
                                                 

-- Subjective Q11:In the "Match" table, some entries in the "Opponent_Team" column are incorrectly spelled as "Delhi_Capitals" instead of "Delhi_Daredevils". Write an SQL query to replace all occurrences of "Delhi_Capitals" with "Delhi_Daredevils".


UPDATE Matches
SET Opponent_Team = 'Delhi_Daredevils'
WHERE Opponent_Team = 'Delhi_Capitals';

-- Verify the update
SELECT DISTINCT Opponent_Team
FROM Matches
WHERE Opponent_Team = 'Delhi_Daredevils';




