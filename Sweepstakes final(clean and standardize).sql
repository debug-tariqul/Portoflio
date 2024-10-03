-- Data Cleaning
SELECT *
FROM bakery.customer_sweepstakes;

-- the first thing we need to remember that we can't mess with the raw file. so we will import the same file again.
-- We will rename the file customer_sweepstakes_staging
-- We see some problem with the column name. Let's fixed the column namefirst

ALTER TABLE customer_sweepstakes RENAME COLUMN `ï»¿sweepstake_id` TO `sweepstake_id`;

-- We will try to find out which has more than one means duplicate. 
SELECT  customer_id, count(customer_id)
FROM customer_sweepstakes
Group by customer_id
Having count(customer_id)>1
;

-- We can find the same thing by WINDOW functions. Alternate ways to do it
SELECT *
FROM (SELECT customer_id,
ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY customer_id ) AS Row_num
FROM customer_sweepstakes) as Table_row
where Row_num>1
;

-- Now we have to delete the duplicate. 
DELETE from customer_sweepstakes
WHERE sweepstake_id IN(
	SELECT sweepstake_id
		FROM (SELECT sweepstake_id,
		ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY customer_id ) AS Row_num
		FROM customer_sweepstakes) as Table_row
		where Row_num >1
        );

-- Standardize the data
-- Let's go with the date column first. We have to replace all the extra sign from the column by using regexp_replaced
SELECT phone, regexp_replace(phone, '[-()/]','') as New_phone -- this AS might not work on the update table. For update we have to use the function we've used here. 
from customer_sweepstakes;

SELECT PHONE
FROM customer_sweepstakes;
-- Then update the old phone to the new phone column
UPDATE customer_sweepstakes
set phone = regexp_replace(phone, '[-()/]','');

-- Now using substring we can divide the numbers according to our choice and the concatinate to the sinle column again for final formatting

SELECT phone, concat( substring(phone,1,3),'-', substring(phone,4,3),'-', substring(phone,7,4))
FROM customer_sweepstakes;

-- Now update the phn column
UPDATE customer_sweepstakes
SET phone = concat( substring(phone,1,3),'-', substring(phone,4,3),'-', substring(phone,7,4));

-- lET'S FIX THE DATE OF BIRTH 
SELECT BIRTH_DATE,
str_to_date(BIRTH_DATE,'%m/%d/%Y'),
str_to_date(BIRTH_DATE,'%Y/%d/%m')
FROM bakery.customer_sweepstakes;

SELECT BIRTH_DATE,
IF (str_to_date(BIRTH_DATE,'%m/%d/%Y') is not null, str_to_date(BIRTH_DATE,'%m/%d/%Y'), str_to_date(BIRTH_DATE,'%Y/%d/%m')),
str_to_date(BIRTH_DATE,'%m/%d/%Y'),
str_to_date(BIRTH_DATE,'%Y/%d/%m')
FROM bakery.customer_sweepstakes;


SELECT *
FROM customer_sweepstakes;


update customer_sweepstakes
set BIRTH_DATE = IF (str_to_date(BIRTH_DATE,'%m/%d/%Y') is not null, str_to_date(BIRTH_DATE,'%m/%d/%Y'), str_to_date(BIRTH_DATE,'%Y/%d/%m')); # unfortunately if statement doesn't work with update command. 

#Let's try substring for the particular probelem. 
SELECT birth_date, concat(substring(birth_date,9,2),'/', substring(birth_date,6,2),'/', substring(birth_date,1,4))
FROM customer_sweepstakes;


select *
from customer_sweepstakes;

update customer_sweepstakes
set birth_date = concat(substring(birth_date,9,2),'/', substring(birth_date,6,2),'/', substring(birth_date,1,4))
where sweepstake_id in (9,11)
;


update customer_sweepstakes
set birth_date = str_to_date(birth_date,'%m/%d/%Y')
;

#Let's work on age column. We will use CASE statement for this


Select `Are you over 18?`,
CASE 
	WHEN `Are you over 18?` = 'yes' then 'Y'
    WHEN `Are you over 18?` = 'No' then 'N'
    else `Are you over 18?`
END
from customer_sweepstakes;


UPDATE customer_sweepstakes
set `Are you over 18?` = CASE 
	WHEN `Are you over 18?` = 'yes' then 'Y'
    WHEN `Are you over 18?` = 'No' then 'N'
    else `Are you over 18?`
END;

# Now finally we will take care of the address column. 

Select address
from customer_sweepstakes;

Select address, substring_index (ADDRESS, ',',1)
from customer_sweepstakes;

Select address, substring_index (ADDRESS, ',',-1)
from customer_sweepstakes;

Select address,substring_index(substring_index (ADDRESS, ',',2),',',-1)
from customer_sweepstakes;


Select address,
substring_index (ADDRESS, ',',1) as Street,
substring_index(substring_index (ADDRESS, ',',2),',',-1) as City,
substring_index (ADDRESS, ',',-1) as State;

Select *
from customer_sweepstakes;

ALTER Table customer_sweepstakes
ADD column Street VARCHAR (50) after address,
ADD column City VARCHAR (50) after Street,
ADD column State VARCHAR (50) after City
;

update customer_sweepstakes
set Street = substring_index (ADDRESS, ',',1);

update customer_sweepstakes
set City = substring_index(substring_index (ADDRESS, ',',2),',',-1);

update customer_sweepstakes
set State = substring_index (ADDRESS, ',',-1);

Select *
from customer_sweepstakes;

Update customer_sweepstakes
set state = upper(State);