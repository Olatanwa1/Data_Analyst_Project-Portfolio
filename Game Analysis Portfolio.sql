USE Game_Analysis;
alter table player_details modify L1_Status varchar(30);
alter table player_details  modify L2_Status varchar(30);
alter table player_details  modify P_ID int primary key;

alter table Level_details drop myunknowncolumn;
alter table  Level_details change timestamp start_datetime datetime;
alter table  Level_details modify Dev_Id varchar(10);
alter table  Level_details modify Difficulty varchar(15);
alter table  Level_details add primary key(P_ID,Dev_id,start_datetime);

-- Q1) Extract P_ID,Dev_ID,PName and Difficulty_level of all players 
-- at level 0
 Select Level_details.P_ID,Dev_ID,Player_details.Pname,Level_details.Difficulty FROM Level_details JOIN Player_details 
 ON Level_details.P_ID=Player_details.P_ID
 WHERE Level=0;
-- Q2) Find Level1_code wise Avg_Kill_Count where lives_earned is 2 and atleast
--    3 stages are crossed
SELECT Player_details.L1_Code,AVG(Kill_count) AS Average_Kill_count FROM Player_details JOIN Level_details 
ON Player_details.P_ID=Level_details.P_ID
WHERE Lives_Earned=2 AND Stages_crossed>=3
GROUP BY L1_code;
-- Q3) Find the total number of stages crossed at each diffuculty level
-- where for Level2 with players use zm_series devices. Arrange the result
-- in decsreasing order of total number of stages crossed.
SELECT Difficulty, SUM(Stages_Crossed) AS Total_Stages_crossed FROM Level_details 
WHERE Level=2 AND Dev_id LIKE "ZM%"
GROUP BY Difficulty
ORDER BY Total_stages_crossed DESC;
-- Q4) Extract P_ID and the total number of unique dates for those players 
-- who have played games on multiple days.
SELECT P_ID,COUNT(START_DATETIME) AS Unique_dates FROM Level_details
Group by P_ID;

-- Q5) Find P_ID and level wise sum of kill_counts where kill_count
-- is greater than avg kill count for the Medium difficulty.
SELECT P_ID,Level,SUM(Kill_Count) AS Total_kill_count FROM Level_details
 WHERE Kill_count> (SELECT avg(Kill_count) FROM Level_details WHERE Difficulty= "medium")
 AND Difficulty="Medium"
GROUP BY P_ID, Level;
-- Q6)  Find Level and its corresponding Level code wise sum of lives earned 
-- excluding level 0. Arrange in asecending order of level.
SELECT Level_details.level,L1_CODE,L2_CODE FROM level_details JOIN Player_details ON Level_details.P_ID=Player_details.P_id
WHERE LEVEL BETWEEN 1 AND 2
ORDER BY Level ASC;
-- Q7) Find Top 3 score based on each dev_id and Rank them in increasing order
-- using Row_Number. Display difficulty as well. 
SELECT Dev_id, MAX(Score) AS Top_Score FROM Level_details
GROUP BY Dev_id
ORDER BY Top_score DESC 
LIMIT 3 ;
-- Q8) Find first_login datetime for each device id
SELECT Dev_id,MIN(Start_datetime) AS First_login FROM Level_details
GROUP BY Dev_id;
-- Q9) Find Top 5 score based on each difficulty level and Rank them in 
-- increasing order using Rank. Display dev_id as well.
SELECT Dev_id,
SUM(Score) AS Top_score, Difficulty,
RANK() OVER(PARTITION BY dev_id ORDER BY dev_id DESC) AS ranking
FROM Level_details 
GROUP BY Difficulty, dev_id
ORDER BY Difficulty, Top_score LIMIT 5 ;
-- Q10) Find the device ID that is first logged in(based on start_datetime) 
-- for each player(p_id). Output should contain player id, device id and 
-- first login datetime
SELECT P_id, Dev_id, MIN(Start_Datetime) AS first_login
FROM Level_details
GROUP BY P_ID, Dev_id ORDER BY P_ID;
-- Q13) Extract top 3 highest sum of score for each device id and the corresponding player_id
SELECT P_id, Dev_id,
SUM(Score) OVER (PARTITION BY P_id ORDER BY Score DESC) AS Total_Score
FROM Level_details LIMIT 3;
-- Q14) Find players who scored more than 50% of the avg score scored by sum of 
-- scores for each player_id
WITH Player_Score AS 
(SELECT P_id,
SUM(Score) AS Total_Score
 FROM Level_details
 GROUP BY P_id),
 Average_score AS ( 
 SELECT AVG(score) AS Avg_score
 FROM Level_details)
 SELECT P_id, total_score
 FROM
 Player_score
 WHERE Total_score> (SELECT avg_score FROM Average_score)*0.5;
-- Q15) Create a stored procedure to find top n headshots_count based on each dev_id and Rank them in increasing order
-- using Row_Number. Display difficulty as well.
SELECT Dev_id, Difficulty,
COUNT(Headshots_Count) AS Top_headshot,
ROW_NUMBER () OVER(PARTITION BY Dev_id ORDER BY Dev_id) AS Ranking 
FROM Level_details
GROUP BY Dev_id, Difficulty;