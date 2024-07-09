-- SQL Project - Data Cleaning
-- https://www.kaggle.com/datasets/swaptr/layoffs-2022
-- -- For data cleaning project, we will be following these few steps
-- 1. check for duplicates and remove any
-- 2. standardize data and fix errors
-- 3. Look at null values and see what 
-- 4. remove any columns and rows that are not necessary - few ways


-- 1. Remove duplicates
# first let's check for duplicates

select *
from layoffs;

create table layoffs_copy
like layoffs;

select *
from layoffs_copy
where company='Beyond Meat'
;

insert into layoffs_copy
select * from layoffs;

-- Now let's put a row number to find out if the data has more than one row

Select company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised,
row_number() over (partition by company, location, industry, total_laid_off, 
percentage_laid_off, `date`, stage, country, funds_raised) as row_num
from layoffs_copy;

-- Then just find the duplicates like this/ use CTE to find out the duplicates

WITH duplicate_cte as
(
Select company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised,
row_number() over (partition by company, location, industry, total_laid_off, 
percentage_laid_off, `date`, stage, country, funds_raised) as row_num
from layoffs_copy
)
select*
from duplicate_cte
where row_num>1;

-- this is for the delete comand. Now we can't delete from the existing table so we have to copy the same table and insert the data with additional row_numer

CREATE TABLE `layoffs_copy2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` text,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised` text,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select *
from layoffs_copy2;

insert into layoffs_copy2
Select company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised,
row_number() over (partition by company, location, industry, total_laid_off, 


percentage_laid_off, `date`, stage, country, funds_raised) as row_num
from layoffs_copy;

select *
from layoffs_copy2
where row_num>1;


-- 2. standardize data and fix errors
select *
from layoffs_copy2;
-- Trim to remove all the extra space from both side
Select company, trim(company)
from layoffs_copy2;

select distinct INDUSTRY
FROM  layoffs_copy2
ORDER BY industry;

update layoffs_copy2
Set company = trim(company);

-- 2. If there is a .(dot) at the end of word, we can remove it like
select distinct country, trim(trailing '.' from country) 
FROM  layoffs_copy2
;
update layoffs_copy2
set country=trim(trailing '.' from country)
where country like 'United States%';

select *
from layoffs_copy2
where country= 'United States';

select distinct country
FROM  layoffs_copy2
;

-- Date formattig 
select `date`,
STR_TO_DATE(`date`, '%m/d/Y')
from layoffs_copy2;

update layoffs_copy2
set `date` = STR_TO_DATE(`date`, '%m/d/Y');

-- date text to Int 
ALTER TABLE  layoffs_copy2
modify COLUMN `date` DATE;

-- try to find all the null and blank values
select *
from layoffs_copy2
where location is null
or location =''; 

select *
from layoffs_copy2
where total_laid_off=''
and percentage_laid_off=''
; 


Delete
from layoffs_copy2
where total_laid_off=''
and percentage_laid_off=''
; 

-- for deleting extra column like we don't need row_num now, so we can delete this. 
alter table layoffs_copy2
drop column row_num;
