/* Creating Sales Representatives Table to know their details */

CREATE TABLE sales_reps
(
	id integer not null,
	name bpchar,
 	primary key(id)  
);


/* Creating Accounts table to store details */

CREATE TABLE accounts 
(
	id integer ,                  
	name bpchar,                  
	website bpchar,            
	lat numeric(11,8),       
	long numeric(11,8),
	primary_poc bpchar, 
   	primary key(id) 
);


/* Creating Web events table to store details */

CREATE TABLE web_events 
(
	id integer not null,
	occurred_at timestamp,
	channel bpchar,            
 	primary key(id)                       
);


CREATE TABLE region (
	id integer,
	name bpchar,
	primary key(id)
);


/* Creating Orders table comprising details of other tables */

CREATE TABLE orders 
(
	id integer not null ,
	account_id integer not null,
	region_id integer not null,
	sales_reps_id integer not null,
	web_events_id integer not null,
	occurred_at timestamp,
	standard_qty integer,
	gloss_qty integer,
	poster_qty integer,
	total integer,
	standard_amt_usd numeric(10,2),
	gloss_amt_usd numeric(10,2),
	poster_amt_usd numeric(10,2),
	total_amt_usd numeric(10,2),
	primary key(id),
	constraint fk_orders_accounts foreign key(account_id)
	references accounts(id),
	constraint fk_orders_region foreign key(region_id)
	references region(id),
	constraint fk_orders_salesreps foreign key(sales_reps_id)
	references sales_reps(id),
	constraint fk_orders_webevents foreign key(web_events_id)
	references web_events(id)
);




















