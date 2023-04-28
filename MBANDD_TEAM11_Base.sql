SELECT	* 
  FROM	
			(
			SELECT	B.ticker	
						,B.quantity
						,D.date
						,D.value AS Current_value
						,LAG(D.value, 250) OVER(PARTITION BY D.ticker ORDER BY D.date ASC) AS Lagged_price
						,(D.value - LAG(D.value, 250) OVER(PARTITION BY D.ticker ORDER BY D.date ASC)) / LAG(D.value, 250) OVER(PARTITION BY D.ticker ORDER BY D.date ASC) AS ROR
			  FROM	account_dim AS A
			  JOIN	holdings_current AS B
			    ON	A.account_id = B.account_id
						AND A.client_id = 123
			  LEFT
			  JOIN	security_masterlist AS C
			    ON	B.ticker = C.ticker
			  LEFT
			  JOIN	pricing_daily_new  AS D
			    ON	B.ticker = D.ticker
			    		AND D.price_type = 'Adjusted'
			    		AND D.value IS NOT NULL
			    		AND D.date > '2020-09-09'
			) AS A
 WHERE	DATE > '2021-09-09';
   
   