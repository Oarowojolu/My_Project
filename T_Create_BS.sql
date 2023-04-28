
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------  --
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------  --
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------  --
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------  --

-- For paper, 
-- We need to join all four tables because, 
-- Journal_entry table has entry date that we need to filter with fiscal year
-- Journal_entry_line_item table has debit&credit information
-- account item has information on bs or pl
-- statement_section has information on which section of bs or pl
-- account and statement section need to be left join to keep all section_id on account. If not, either bs section or pl section will be filtered out. 

-- Statement_section table has statement_section_id as primary key with 37 rows
/*
SELECT statement_section_id, COUNT(*)
FROM statement_section
GROUP BY statement_section_id;

*/

-- balance_sheet section and profit loss sheet section has separate group of statement_section_id
-- balance_sheet 
-- 61 : Current Asset
-- 62: Fixed Assets
-- 64 : Current Liabilities
-- 67: Equity
SELECT sb.statement_section, sb.statement_section_id, balance_sheet_section_id, profit_loss_section_id
FROM journal_entry_line_item AS je 
INNER JOIN account AS a
	ON a.account_id = je.account_id
INNER JOIN statement_section AS sb 
	ON a.balance_sheet_section_id = sb.statement_section_id 
INNER JOIN statement_section AS sp 
	ON a.profit_loss_section_id = sp.statement_section_id 
GROUP BY statement_section_id
ORDER BY sb.statement_section_id

;

-- profit_loss
-- 68: Revenue
-- 74: COGS
-- 76: SElling Expenses
-- 77: Other expenses
-- 78: Other Income
-- 79 : Income tax
SELECT sp.statement_section, sp.statement_section_id, balance_sheet_section_id, profit_loss_section_id
FROM journal_entry_line_item AS je 
INNER JOIN account AS a
	ON a.account_id = je.account_id
INNER JOIN statement_section AS sb 
	ON a.balance_sheet_section_id = sb.statement_section_id 
INNER JOIN statement_section AS sp 
	ON a.profit_loss_section_id = sp.statement_section_id 
GROUP BY statement_section_id
ORDER BY sp.statement_section_id
;

-- To make sure, Either we join account table on either profit_loss_section_id or balance_sheet_section_id
-- When statement_section_id = 0, no valid information on statement_section

-- Join with profit_loss_section_id
SELECT *
FROM journal_entry_line_item AS je 
INNER JOIN account AS a
	ON a.account_id = je.account_id
INNER JOIN statement_section AS s 
	ON a.profit_loss_section_id = s.statement_section_id 
WHERE s.statement_section_id = 0 AND s.statement_section != '';


-- Join on balance_sheet_section_id
SELECT *
FROM journal_entry_line_item AS je 
INNER JOIN account AS a
	ON a.account_id = je.account_id
INNER JOIN statement_section AS s 
	ON a.balance_sheet_section_id = s.statement_section_id 
WHERE s.statement_section_id = 0 AND s.statement_section != ''
;




-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------  --
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------  --
-- Let's create BS
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------  --
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------  --
SELECT 
	
    entry_date, 
    DATE_FORMAT(entry_date, '%Y') AS `YEAR`, 
    sb.statement_section,
    journal_entry, 
    line_item, 
    `account`, 
    `description`, 
    
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
		-- EQUITY
			WHEN sb.statement_section_id = 67 AND credit IS NULL THEN debit
			WHEN sb.statement_section_id = 67 AND debit IS NULL THEN -credit 
			ELSE 0 
	END AS LIABILITIES,
    CASE 
		-- CURRENT LIABILITIES
			WHEN sb.statement_section_id = 64 AND credit IS NULL THEN debit
			WHEN sb.statement_section_id = 64 AND debit IS NULL THEN -credit 
			ELSE 0 
	END AS EQUITY 
FROM journal_entry_line_item AS je 
INNER JOIN account AS a
	ON a.account_id = je.account_id
INNER JOIN journal_entry AS J 
	ON je.journal_entry_id = J.journal_entry_id 
INNER JOIN statement_section AS sp 
	ON a.profit_loss_section_id = sp.statement_section_id 
INNER JOIN statement_section AS sb
	ON a.balance_sheet_section_id = sb.statement_section_id 
WHERE visible_for_posting = 1 
	AND debit_credit_balanced = 1 
	AND cancelled = 0 
    AND closing_type = 0 
    AND DATE_FORMAT(entry_date, '%Y') = 2015 
;