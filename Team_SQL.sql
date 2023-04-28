
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------  --
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------  --
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------  --
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------  --

-- Declare variable
SET @F_Year = 2015;
SET @Last_Year = @F_Year-1;
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------  --
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------  --
-- Let's create BS

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------  --
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------  --
SELECT 
	'','','','','','','','',
    SUM(ASSETS), SUM(LIABILITIES), SUM(EQUITY)

FROM 
	(SELECT
		CASE 
			-- CURRENT ASSETS
				WHEN balance_sheet_section_id = 61 AND credit IS NULL THEN debit
				WHEN balance_sheet_section_id = 61 AND debit IS NULL THEN -credit 
			-- FIXED ASSETS
				WHEN balance_sheet_section_id = 62 AND credit IS NULL THEN debit
				WHEN balance_sheet_section_id = 62 AND debit IS NULL THEN -credit 
				ELSE 0 
		END AS ASSETS, 
		
			-- CURRENT LIABILITIES
		CASE 
				WHEN balance_sheet_section_id = 64 AND credit IS NULL THEN debit
				WHEN balance_sheet_section_id = 64 AND debit IS NULL THEN -credit 
				ELSE 0 
		END AS LIABILITIES,
		
			-- EQUITY
		CASE 
				WHEN (balance_sheet_section_id = 67 OR profit_loss_section_id IN (68,74,76,77,78,79)) AND credit IS NULL THEN debit
				WHEN (balance_sheet_section_id = 67 OR profit_loss_section_id IN (68,74,76,77,78,79)) AND debit IS NULL THEN -credit 
				ELSE 0 
		END AS EQUITY 
	FROM journal_entry_line_item AS je 
	INNER JOIN account AS a
		ON a.account_id = je.account_id
	INNER JOIN journal_entry AS J 
		ON je.journal_entry_id = J.journal_entry_id 
	LEFT JOIN statement_section AS sb
		ON a.balance_sheet_section_id = sb.statement_section_id 
	LEFT JOIN statement_section AS sp
		ON a.profit_loss_section_id = sp.statement_section_id 
	WHERE visible_for_posting = 1 
		AND debit_credit_balanced = 1 
		AND cancelled = 0 
		AND closing_type = 0 
		AND DATE_FORMAT(entry_date, '%Y') = @F_Year 
	) as New_Table
    
UNION ALL

SELECT 	
    entry_date, 
    DATE_FORMAT(entry_date, '%Y') AS `YEAR`, 
    statement_section_id,
    statement_section,
    journal_entry, 
    line_item, 
    `account`, 
    `description`,
       -- Current year
    CASE 
		-- CURRENT ASSETS
			WHEN sb.statement_section_id = 61 AND credit IS NULL THEN debit
			WHEN sb.statement_section_id = 61 AND debit IS NULL THEN -credit 
		-- FIXED ASSETS
			WHEN sb.statement_section_id = 62 AND credit IS NULL THEN debit
			WHEN sb.statement_section_id = 62 AND debit IS NULL THEN -credit 
			ELSE 0 
	END AS ASSETS, 
    CASE 
		-- CURRENT LIABILITIES
			WHEN sb.statement_section_id = 64 AND credit IS NULL THEN debit
			WHEN sb.statement_section_id = 64 AND debit IS NULL THEN -credit 
			ELSE 0 
	END AS LIABILITIES,
    CASE 
		-- EQUITY
			WHEN  (sb.statement_section_id = 67 OR sp.statement_section_id IN (68,74,76,77,78,79)) AND credit IS NULL THEN debit
			WHEN  (sb.statement_section_id = 67 OR sp.statement_section_id IN (68,74,76,77,78,79)) AND debit IS NULL THEN -credit 
			ELSE 0 
		END AS EQUITY 
FROM(
	SELECT
		credit,debit,
		entry_date, 
		DATE_FORMAT(entry_date, '%Y') AS `YEAR`, 
		sb.statement_section_id,
		sb.statement_section,
		journal_entry, 
		line_item, 
		`account`, 
		`description`,
    -- Current year
    CASE 
		-- CURRENT ASSETS
			WHEN sb.statement_section_id = 61 AND credit IS NULL THEN debit
			WHEN sb.statement_section_id = 61 AND debit IS NULL THEN -credit 
		-- FIXED ASSETS
			WHEN sb.statement_section_id = 62 AND credit IS NULL THEN debit
			WHEN sb.statement_section_id = 62 AND debit IS NULL THEN -credit 
			ELSE 0 
	END AS ASSETS, 
    CASE 
		-- CURRENT LIABILITIES
			WHEN sb.statement_section_id = 64 AND credit IS NULL THEN debit
			WHEN sb.statement_section_id = 64 AND debit IS NULL THEN -credit 
			ELSE 0 
	END AS LIABILITIES,
    CASE 
		-- EQUITY
			WHEN  (sb.statement_section_id = 67 OR sp.statement_section_id IN (68,74,76,77,78,79))  AND credit IS NULL THEN debit
			WHEN  (sb.statement_section_id = 67 OR sp.statement_section_id IN (68,74,76,77,78,79)) AND debit IS NULL THEN -credit 
			ELSE 0 
		END AS EQUITY 
	FROM journal_entry_line_item AS je 
	INNER JOIN account AS a
		ON a.account_id = je.account_id
	INNER JOIN journal_entry AS J 
		ON je.journal_entry_id = J.journal_entry_id 
	LEFT JOIN statement_section AS sb
		ON a.balance_sheet_section_id = sb.statement_section_id 
	LEFT JOIN statement_section AS sp
		ON a.profit_loss_section_id = sb.statement_section_id 
	WHERE visible_for_posting = 1 
		AND debit_credit_balanced = 1 
		AND cancelled = 0 
		AND closing_type = 0 
		AND DATE_FORMAT(entry_date, '%Y') = @F_Year 
		AND sb.statement_section_id !=0
	ORDER BY LIABILITIES) as New_Table


;


-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------  --
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------  --
-- Let's create PL
-- Compare with last year value
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------  --
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------  --
SELECT 
    statement_section_id,
    statement_section,
    BALANCE_Selected_Year,
    BALANCE_Last_Year,
    (BALANCE_Last_Year - BALANCE_Selected_Year) / BALANCE_Selected_Year * 100 AS Yearly_Change_Perc
FROM
	(SELECT
		statement_section_id,
		statement_section,
		CASE 
			-- Profit and Loss
				WHEN sp.statement_section_id IN (68,74,76,77,78,79) AND DATE_FORMAT(entry_date, '%Y') = @F_Year AND credit IS NULL THEN debit
				WHEN sp.statement_section_id IN (68,74,76,77,78,79) AND DATE_FORMAT(entry_date, '%Y') = @F_Year AND debit IS NULL THEN -credit 
				ELSE 0 
		END AS BALANCE_Selected_Year, 
		
		CASE 
			-- Profit and Loss
				WHEN sp.statement_section_id IN (68,74,76,77,78,79) AND DATE_FORMAT(entry_date, '%Y') = @Last_Year AND credit IS NULL THEN debit
				WHEN sp.statement_section_id IN (68,74,76,77,78,79) AND DATE_FORMAT(entry_date, '%Y') = @Last_Year AND debit IS NULL THEN -credit 
				ELSE 0 
		END AS BALANCE_Last_Year

	FROM journal_entry_line_item AS je 
	INNER JOIN account AS a
		ON a.account_id = je.account_id
	INNER JOIN journal_entry AS J 
		ON je.journal_entry_id = J.journal_entry_id 
	INNER JOIN statement_section AS sp 
		ON a.profit_loss_section_id = sp.statement_section_id 
	WHERE visible_for_posting = 1 
		AND debit_credit_balanced = 1 
		AND cancelled = 0 
		AND closing_type = 0 ) as new_table
    
GROUP BY sp.statement_section_id
ORDER BY sp.statement_section_id
;