# Report 1. Personal Client's Portfolio Report
SET @cid = 123;
WITH BASE AS(
SELECT	*
  FROM	(
			SELECT	B.quantity
						,C.sec_type
						,CASE # Data Cleansing For Major Asset Class
							WHEN major_asset_class = 'fixed_income' THEN 'fixed income'
							WHEN major_asset_class = 'fixed income corporate' THEN 'fixed income'
							WHEN major_asset_class = 'equty' THEN 'equity' 
							ELSE major_asset_class 
							END AS major_asset_class
						,CASE # Data Cleansing for Minor Asset Class
							WHEN major_asset_class = 'fixed income corporate' THEN 'corporate' 
							WHEN major_asset_class = 'equity' AND minor_asset_class = '' THEN 'equity'
							WHEN major_asset_class = 'alternatives' AND minor_asset_class = '' THEN 'alternatives'
							WHEN major_asset_class = 'fixed_income' AND minor_asset_class = '' THEN 'fixed income'
							ELSE minor_asset_class END AS minor_asset_class
						,B.ticker
						,D.date
						,D.value 
						,LAG(D.VALUE, 250) OVER(PARTITION BY D.ticker ORDER BY D.date ASC) AS LAG_VAL # Lagged Price By row
			  FROM	account_dim AS A
			  JOIN	holdings_current AS B
			    ON	A.account_id = B.account_id
			    		AND A.client_id = @cid # Client_ID
			  LEFT
			  JOIN	security_masterlist AS C
			    ON	B.ticker = C.ticker
			  LEFT
			  JOIN	pricing_daily_new AS D
			    ON	B.ticker = D.ticker 
				 		AND D.value IS NOT NULL
						AND D.date >= '2020-09-09' # Total Data start date. 
						AND D.price_type = 'Adjusted'
			) AS A
 WHERE	DATE >= '2021-09-09' # Initial Invest date
)
, BASE_BY_CLASS AS (
SELECT	*
			,ROR - AVG(ROR) OVER(PARTITION BY sec_type, major_asset_class) AS ROR_centered # (RoR - RoR_MEAN) for calculating Covariance
  FROM	(
			SELECT	sec_type
						,major_asset_class
						,date
						,SUM(VALUE) AS value
						,SUM(LAG_VAL) AS LAG_VAL
						,((SUM(VALUE) - SUM(LAG_VAL)) / SUM(LAG_VAL)) AS ROR # Rate Of Return
			  FROM	BASE
			 GROUP
			 	 BY	sec_type
			 	 		,major_asset_class
			 	 		,DATE
			) AS A
)
, WEIGHT_BY_CLASS AS(
SELECT	SEC_TYPE
			,major_asset_class
			,SUM(VALUE * quantity) AS amount # Initial Amount of all Portfolio Class
			,SUM(VALUE * quantity) / (SELECT SUM(VALUE * quantity) FROM BASE WHERE	DATE = @initial_invest_date ) AS WEIGHT # Initial Amount Weight of Each Portfolio
			,ROW_NUMBER() OVER() AS RNUM
  FROM	BASE
 WHERE	DATE = '2021-09-09'
 GROUP
 	 BY	SEC_TYPE
			,major_asset_class
)
, STATISTICS_BY_CLASS AS (
	SELECT 	sec_type
				,major_asset_class
				,AVG((VALUE - LAG_VAL) / LAG_VAL) AS Mu # Expected Return 
				,STD((VALUE - LAG_VAL) / LAG_VAL) AS Sigma # Risk of All Class
				,AVG((VALUE - LAG_VAL) / LAG_VAL) / STD((VALUE - LAG_VAL) / LAG_VAL) AS Adjuested_Return
	  FROM	BASE_BY_CLASS
	 GROUP
	 	 BY	sec_type
				,major_asset_class
) 
SELECT	'Expected Return of Portfolio', FORMAT(SUM(A.Mu * B.WEIGHT), 5) # Expected Return of total Portfolio
  FROM	STATISTICS_BY_CLASS AS A
  JOIN	WEIGHT_BY_CLASS AS B
    ON	A.sec_type = B.sec_type
    		AND A.major_asset_class = B.major_asset_class
UNION ALL
SELECT	CONCAT(sec_type, ' - ', major_asset_class)
			,CONCAT(FORMAT(Weight * 100, 2), '%')
  FROM	WEIGHT_BY_CLASS
;



# STEP 2.
WITH BASE AS(
SELECT	*
  FROM	(
			SELECT	B.quantity
						,C.sec_type
						,CASE # Data Cleansing For Major Asset Class
							WHEN major_asset_class = 'fixed_income' THEN 'fixed income'
							WHEN major_asset_class = 'fixed income corporate' THEN 'fixed income'
							WHEN major_asset_class = 'equty' THEN 'equity' 
							ELSE major_asset_class 
							END AS major_asset_class
						,CASE # Data Cleansing for Minor Asset Class
							WHEN major_asset_class = 'fixed income corporate' THEN 'corporate' 
							WHEN major_asset_class = 'equity' AND minor_asset_class = '' THEN 'equity'
							WHEN major_asset_class = 'alternatives' AND minor_asset_class = '' THEN 'alternatives'
							WHEN major_asset_class = 'fixed_income' AND minor_asset_class = '' THEN 'fixed income'
							ELSE minor_asset_class END AS minor_asset_class
						,B.ticker
						,D.date
						,D.value 
						,LAG(D.VALUE, 250) OVER(PARTITION BY D.ticker ORDER BY D.date ASC) AS LAG_VAL # Lagged Price By row
			  FROM	account_dim AS A
			  JOIN	holdings_current AS B
			    ON	A.account_id = B.account_id
			    		AND A.client_id = @cid # Client_ID
			  LEFT
			  JOIN	security_masterlist AS C
			    ON	B.ticker = C.ticker
			  LEFT
			  JOIN	pricing_daily_new AS D
			    ON	B.ticker = D.ticker 
				 		AND D.value IS NOT NULL
						AND D.date >= '2020-09-09' # Total Data start date. 
						AND D.price_type = 'Adjusted'
			) AS A
 WHERE	DATE >= '2021-09-09' # Initial Invest date
)
, BASE_BY_CLASS AS (
SELECT	*
			,ROR - AVG(ROR) OVER(PARTITION BY sec_type, major_asset_class) AS ROR_centered # (RoR - RoR_MEAN) for calculating Covariance
  FROM	(
			SELECT	sec_type
						,major_asset_class
						,date
						,SUM(VALUE) AS value
						,SUM(LAG_VAL) AS LAG_VAL
						,((SUM(VALUE) - SUM(LAG_VAL)) / SUM(LAG_VAL)) AS ROR # Rate Of Return
			  FROM	BASE
			 GROUP
			 	 BY	sec_type
			 	 		,major_asset_class
			 	 		,DATE
			) AS A
)
, WEIGHT_BY_CLASS AS(
SELECT	SEC_TYPE
			,major_asset_class
			,SUM(VALUE * quantity) AS amount # Initial Amount of all Portfolio Class
			,SUM(VALUE * quantity) / (SELECT SUM(VALUE * quantity) FROM BASE WHERE	DATE = @initial_invest_date ) AS WEIGHT # Initial Amount Weight of Each Portfolio
			,ROW_NUMBER() OVER() AS RNUM
  FROM	BASE
 WHERE	DATE = '2021-09-09'
 GROUP
 	 BY	SEC_TYPE
			,major_asset_class
)
, STATISTICS_BY_CLASS AS (
	SELECT 	sec_type
				,major_asset_class
				,AVG((VALUE - LAG_VAL) / LAG_VAL) AS Mu # Expected Return 
				,STD((VALUE - LAG_VAL) / LAG_VAL) AS Sigma # Risk of All Class
				,AVG((VALUE - LAG_VAL) / LAG_VAL) / STD((VALUE - LAG_VAL) / LAG_VAL) AS Adjusted_Return
	  FROM	BASE_BY_CLASS
	 GROUP
	 	 BY	sec_type
				,major_asset_class
) 
SELECT	sec_type
			,major_asset_class
			,ROUND(Mu, 4) AS Mu
			,ROUND(Sigma, 4) AS Sigma
			,ROUND(Adjusted_Return, 4) AS Adjusted_Return
  FROM	STATISTICS_BY_CLASS
;


# Step 3. Suggestion
WITH BASE AS(
SELECT	*
  FROM	(
			SELECT	B.quantity
						,C.sec_type
						,CASE # Data Cleansing For Major Asset Class
							WHEN major_asset_class = 'fixed_income' THEN 'fixed income'
							WHEN major_asset_class = 'fixed income corporate' THEN 'fixed income'
							WHEN major_asset_class = 'equty' THEN 'equity' 
							ELSE major_asset_class 
							END AS major_asset_class
						,CASE # Data Cleansing for Minor Asset Class
							WHEN major_asset_class = 'fixed income corporate' THEN 'corporate' 
							WHEN major_asset_class = 'equity' AND minor_asset_class = '' THEN 'equity'
							WHEN major_asset_class = 'alternatives' AND minor_asset_class = '' THEN 'alternatives'
							WHEN major_asset_class = 'fixed_income' AND minor_asset_class = '' THEN 'fixed income'
							ELSE minor_asset_class END AS minor_asset_class
						,B.ticker
						,D.date
						,D.value 
						,LAG(D.VALUE, 250) OVER(PARTITION BY D.ticker ORDER BY D.date ASC) AS LAG_VAL # Lagged Price By row
			  FROM	account_dim AS A
			  JOIN	holdings_current AS B
			    ON	A.account_id = B.account_id
			    		AND A.client_id = @cid # Client_ID
			  LEFT
			  JOIN	security_masterlist AS C
			    ON	B.ticker = C.ticker
			  LEFT
			  JOIN	pricing_daily_new AS D
			    ON	B.ticker = D.ticker 
				 		AND D.value IS NOT NULL
						AND D.date >= '2020-09-09' # Total Data start date. 
						AND D.price_type = 'Adjusted'
			) AS A
 WHERE	DATE >= '2021-09-09' # Initial Invest date
)
, SIMULATED_HOLD AS ( # REMOVE STOCK 
SELECT	A.quantity
			,A.ticker
  FROM	holdings_current AS A
  JOIN	account_dim AS B
    ON	A.account_id = B.account_id
    		AND B.client_id = @cid
 WHERE	A.ticker NOT IN ('YOLO')
UNION		
SELECT	500  # Number of New Stocks
			,ticker
  FROM	security_masterlist AS A
 WHERE	ticker IN ('BCI', 'DJP', 'FTGC')
)
, BASE_SIM AS (
SELECT	*
  FROM	(
			SELECT	A.quantity
						,C.sec_type
						,CASE # Data Cleansing For Major Asset Class
							WHEN major_asset_class = 'fixed_income' THEN 'fixed income'
							WHEN major_asset_class = 'fixed income corporate' THEN 'fixed income'
							WHEN major_asset_class = 'equty' THEN 'equity' 
							ELSE major_asset_class 
							END AS major_asset_class
						,CASE # Data Cleansing for Minor Asset Class
							WHEN major_asset_class = 'fixed income corporate' THEN 'corporate' 
							WHEN major_asset_class = 'equity' AND minor_asset_class = '' THEN 'equity'
							WHEN major_asset_class = 'alternatives' AND minor_asset_class = '' THEN 'alternatives'
							WHEN major_asset_class = 'fixed_income' AND minor_asset_class = '' THEN 'fixed income'
							ELSE minor_asset_class END AS minor_asset_class
						,A.ticker
						,D.date
						,D.value 
						,LAG(D.VALUE, @lag_var) OVER(PARTITION BY D.ticker ORDER BY D.date ASC) AS LAG_VAL # Lagged Price By row
			  FROM	SIMULATED_HOLD AS A
			  LEFT
			  JOIN	security_masterlist AS C
			    ON	A.ticker = C.ticker
			  LEFT
			  JOIN	pricing_daily_new AS D
			    ON	A.ticker = D.ticker 
				 		AND D.value IS NOT NULL
						AND D.date >= '2020-09-09' # Total Data start date. 
						AND D.price_type = 'Adjusted'
			) AS A
 WHERE	DATE >= '2021-09-09' # Initial Invest date
)
, BASE_BY_CLASS AS (
SELECT	*
			,ROR - AVG(ROR) OVER(PARTITION BY sec_type, major_asset_class) AS ROR_centered # (RoR - RoR_MEAN) for calculating Covariance
  FROM	(
			SELECT	sec_type
						,major_asset_class
						,date
						,SUM(VALUE) AS value
						,SUM(LAG_VAL) AS LAG_VAL
						,((SUM(VALUE) - SUM(LAG_VAL)) / SUM(LAG_VAL)) AS ROR # Rate Of Return
			  FROM	BASE_SIM
			 GROUP
			 	 BY	sec_type
			 	 		,major_asset_class
			 	 		,DATE
			) AS A
)
, WEIGHT_BY_CLASS AS(
SELECT	SEC_TYPE
			,major_asset_class
			,SUM(VALUE * quantity) AS amount # Initial Amount of all Portfolio Class
			,SUM(VALUE * quantity) / (SELECT SUM(VALUE * quantity) FROM BASE WHERE	DATE = @initial_invest_date ) AS WEIGHT # Initial Amount Weight of Each Portfolio
			,ROW_NUMBER() OVER() AS RNUM
  FROM	BASE_SIM
 WHERE	DATE = '2021-09-09'
 GROUP
 	 BY	SEC_TYPE
			,major_asset_class
)
, STATISTICS_BY_CLASS AS (
	SELECT 	sec_type
				,major_asset_class
				,AVG((VALUE - LAG_VAL) / LAG_VAL) AS Mu # Expected Return 
				,STD((VALUE - LAG_VAL) / LAG_VAL) AS Sigma # Risk of All Class
				,STD((VALUE - LAG_VAL) / LAG_VAL) / AVG((VALUE - LAG_VAL) / LAG_VAL) AS CV # Coefficient of Variance Of All Class
				,VAR_SAMP((VALUE - LAG_VAL) / LAG_VAL) AS Var # Variance of All Class
	  FROM	BASE_BY_CLASS
	 GROUP
	 	 BY	sec_type
				,major_asset_class
) 

SELECT	'Expected Return of Portfolio', FORMAT(SUM(A.Mu * B.WEIGHT), 5) # Expected Return of total Portfolio
  FROM	STATISTICS_BY_CLASS AS A
  JOIN	WEIGHT_BY_CLASS AS B
    ON	A.sec_type = B.sec_type
    		AND A.major_asset_class = B.major_asset_class
UNION ALL
SELECT	CONCAT(sec_type, ' - ', major_asset_class)
			,CONCAT(FORMAT(Weight * 100, 2), '%')
  FROM	WEIGHT_BY_CLASS
;



# Step 3. Suggestion
WITH BASE AS(
SELECT	*
  FROM	(
			SELECT	B.quantity
						,C.sec_type
						,CASE # Data Cleansing For Major Asset Class
							WHEN major_asset_class = 'fixed_income' THEN 'fixed income'
							WHEN major_asset_class = 'fixed income corporate' THEN 'fixed income'
							WHEN major_asset_class = 'equty' THEN 'equity' 
							ELSE major_asset_class 
							END AS major_asset_class
						,CASE # Data Cleansing for Minor Asset Class
							WHEN major_asset_class = 'fixed income corporate' THEN 'corporate' 
							WHEN major_asset_class = 'equity' AND minor_asset_class = '' THEN 'equity'
							WHEN major_asset_class = 'alternatives' AND minor_asset_class = '' THEN 'alternatives'
							WHEN major_asset_class = 'fixed_income' AND minor_asset_class = '' THEN 'fixed income'
							ELSE minor_asset_class END AS minor_asset_class
						,B.ticker
						,D.date
						,D.value 
						,LAG(D.VALUE, 250) OVER(PARTITION BY D.ticker ORDER BY D.date ASC) AS LAG_VAL # Lagged Price By row
			  FROM	account_dim AS A
			  JOIN	holdings_current AS B
			    ON	A.account_id = B.account_id
			    		AND A.client_id = @cid # Client_ID
			  LEFT
			  JOIN	security_masterlist AS C
			    ON	B.ticker = C.ticker
			  LEFT
			  JOIN	pricing_daily_new AS D
			    ON	B.ticker = D.ticker 
				 		AND D.value IS NOT NULL
						AND D.date >= '2020-09-09' # Total Data start date. 
						AND D.price_type = 'Adjusted'
			) AS A
 WHERE	DATE >= '2021-09-09' # Initial Invest date
)
, SIMULATED_HOLD AS ( # 
SELECT	A.quantity
			,A.ticker
  FROM	holdings_current AS A
  JOIN	account_dim AS B
    ON	A.account_id = B.account_id
    		AND B.client_id = @cid
 WHERE	A.ticker NOT IN ('YOLO')
UNION		
SELECT	500  # Number of New Stocks
			,ticker
  FROM	security_masterlist AS A
 WHERE	ticker IN ('BCI', 'DJP', 'FTGC')
)
, BASE_SIM AS (
SELECT	*
  FROM	(
			SELECT	A.quantity
						,C.sec_type
						,CASE # Data Cleansing For Major Asset Class
							WHEN major_asset_class = 'fixed_income' THEN 'fixed income'
							WHEN major_asset_class = 'fixed income corporate' THEN 'fixed income'
							WHEN major_asset_class = 'equty' THEN 'equity' 
							ELSE major_asset_class 
							END AS major_asset_class
						,CASE # Data Cleansing for Minor Asset Class
							WHEN major_asset_class = 'fixed income corporate' THEN 'corporate' 
							WHEN major_asset_class = 'equity' AND minor_asset_class = '' THEN 'equity'
							WHEN major_asset_class = 'alternatives' AND minor_asset_class = '' THEN 'alternatives'
							WHEN major_asset_class = 'fixed_income' AND minor_asset_class = '' THEN 'fixed income'
							ELSE minor_asset_class END AS minor_asset_class
						,A.ticker
						,D.date
						,D.value 
						,LAG(D.VALUE, @lag_var) OVER(PARTITION BY D.ticker ORDER BY D.date ASC) AS LAG_VAL # Lagged Price By row
			  FROM	SIMULATED_HOLD AS A
			  LEFT
			  JOIN	security_masterlist AS C
			    ON	A.ticker = C.ticker
			  LEFT
			  JOIN	pricing_daily_new AS D
			    ON	A.ticker = D.ticker 
				 		AND D.value IS NOT NULL
						AND D.date >= '2020-09-09' # Total Data start date. 
						AND D.price_type = 'Adjusted'
			) AS A
 WHERE	DATE >= '2021-09-09' # Initial Invest date
)
, BASE_BY_CLASS AS (
SELECT	*
			,ROR - AVG(ROR) OVER(PARTITION BY sec_type, major_asset_class) AS ROR_centered # (RoR - RoR_MEAN) for calculating Covariance
  FROM	(
			SELECT	sec_type
						,major_asset_class
						,date
						,SUM(VALUE) AS value
						,SUM(LAG_VAL) AS LAG_VAL
						,((SUM(VALUE) - SUM(LAG_VAL)) / SUM(LAG_VAL)) AS ROR # Rate Of Return
			  FROM	BASE_SIM
			 GROUP
			 	 BY	sec_type
			 	 		,major_asset_class
			 	 		,DATE
			) AS A
)
, WEIGHT_BY_CLASS AS(
SELECT	SEC_TYPE
			,major_asset_class
			,SUM(VALUE * quantity) AS amount # Initial Amount of all Portfolio Class
			,SUM(VALUE * quantity) / (SELECT SUM(VALUE * quantity) FROM BASE WHERE	DATE = @initial_invest_date ) AS WEIGHT # Initial Amount Weight of Each Portfolio
			,ROW_NUMBER() OVER() AS RNUM
  FROM	BASE_SIM
 WHERE	DATE = '2021-09-09'
 GROUP
 	 BY	SEC_TYPE
			,major_asset_class
)
, STATISTICS_BY_CLASS AS (
	SELECT 	sec_type
				,major_asset_class
				,AVG((VALUE - LAG_VAL) / LAG_VAL) AS Mu # Expected Return 
				,STD((VALUE - LAG_VAL) / LAG_VAL) AS Sigma # Risk of All Class
				,AVG((VALUE - LAG_VAL) / LAG_VAL) / STD((VALUE - LAG_VAL) / LAG_VAL) AS Adjusted_Return
	  FROM	BASE_BY_CLASS
	 GROUP
	 	 BY	sec_type
				,major_asset_class
) 

SELECT	sec_type
			,major_asset_class
			,ROUND(Mu, 4) AS Mu
			,ROUND(Sigma, 4) AS Sigma
			,ROUND(Adjusted_Return, 4) AS Adjusted_Return
  FROM	STATISTICS_BY_CLASS
;

