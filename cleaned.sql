-- Data Cleaning

select * from layoffs;

-- Steps 
-- 1. Removing Duplicate 
-- 2. Standardize the Data
-- 3. Null or blank Values
-- 4. Removing rows and columns

-- when cleaning data it's more important you
-- creat a copy of the original data for your work so as
-- you can layback to the data when there is issues
create table layoffs_stag1 
like layoffs;

select * from layoffs_stag1;

-- inserting the data from the orighinal data to the new table i created
INSERT layoffs_stag1 
select * from layoffs;

-- CREATING A NEW COLUMN SO AS TO BE ABLE TO REMOVE DUPPLICATE WHERE THEERE'S NO KEY IDENTIFYER LIKE
-- PRIMARY ID
 select *,
 row_number() over(
 partition by company, industry, total_laid_off, percentage_laid_off, 'date' ) as row_num
 from layoffs_stag1;
 
 with duplicate_cte as
 (
 select *,
 row_number() over(
 partition by company, location, industry, total_laid_off, percentage_laid_off, stage, country, funds_raised, 'date') as row_num
 from layoffs_stag1
 )
 select *
 from duplicate_cte 
 where row_num > 1;
 
 select * from layoffs_stag1 where company = '2U';
 
 
 -- creating new table and deleting duplicate from the new table where number are greater than 1
 CREATE TABLE `layoffs_stag2` (
  `company` text,
  `location` text,
  `total_laid_off` text,
  `date` text,
  `percentage_laid_off` text,
  `industry` text,
  `source` text,
  `stage` text,
  `funds_raised` text,
  `country` text,
  `date_added` text,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * from layoffs_stag2;


-- Inserting the data into the new table
insert into layoffs_stag2
select *,
 row_number() over(
 partition by company, location, industry, total_laid_off, percentage_laid_off, stage, country, funds_raised, 'date') as row_num
 from layoffs_stag1;


delete from layoffs_stag2
where row_num > 1;


-- Setting my SQL to a temporary mode for so i can delet a row
SET SQL_SAFE_UPDATES = 0;

-- deleting a row from the table layoffs_stag2
delete from layoffs_stag2
where row_num > 1;

-- Returning back my sql safe_mode systems baack to defualt 
SET SQL_SAFE_UPDATES = 1;

-- Standardizing Data
select distinct(company)
from layoffs_stag2;

-- Trimming of company name, remover spaces and wrong spelling in the names
select company, trim(company)
from layoffs_stag2;

SET SQL_SAFE_UPDATES = 0;
update layoffs_stag2
set company = trim(company);

select distinct(industry)
from layoffs_stag2;

select * from layoffs_stag2 where industry like 'Travel';

update layoffs_stag2
set industry = 'Transportation'
where industry like 'Transportation by Vehicle%';

select distinct industry
from layoffs_stag2;

update layoffs_stag2
set industry = 'Transportation'
where industry like 'Travel%';


select distinct country
from layoffs_stag2;

update layoffs_stag2
set location = trim(Trailing ',Non-U.S.' from location);

select *
from layoffs_stag2;

-- Updating the date formate from text to date
select distinct(date) from layoffs_stag2;

update layoffs_stag2
set `date` = str_to_date(`date`, '%m/%d/%Y');

select * from layoffs_stag2;

alter table layoffs_stag2
modify `date` date;

alter table layoffs_stag2
drop `source`;

select * from layoffs_stag2
where industry is NULL 
or industry = '';

select * from layoffs_stag2
where company  = 'Product Hunt';


select t1.total_laid_off, t2.total_laid_off
from layoffs_stag2 t1
join layoffs_stag2 t2
	on t1.company = t2.company
where (t1.total_laid_off is Null or t1.total_laid_off = '')
and t2.total_laid_off is not null;


delete from layoffs_stag2
where company = 'Eyeo';

update layoffs_stag2
set total_laid_off = Null,
percentage_laid_off = Null,
funds_raised = null
where total_laid_off ='' or
percentage_laid_off = '' or
funds_raised = '';

select * FROM layoffs_stag2
WHERE total_laid_off is Null
and percentage_laid_off is Null;

DELETE 
FROM layoffs_stag2
WHERE total_laid_off is Null
and percentage_laid_off is Null;

select * from layoffs_stag2;

alter table layoffs_stag2
drop column row_num;
