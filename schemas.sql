---Library Management System---

--Creating Branch Table--
Create table branch(
branch_id varchar(10) primary key,
manager_id varchar(10),
branch_address varchar(30),
contact_no int
);

Alter table branch
alter column contact_no type varchar(20);

--Creating Employee Table--
Create Table employees(
emp_id varchar(10) primary key,
emp_name varchar(25),
position varchar(25),
salary int,
branch_id varchar(25)
)

alter table employees
alter column salary type varchar(15);

--Creating Books Table--
Create Table books(
isbn varchar(25) primary key,
book_title varchar(75),
category varchar(15),
rental_price float,
status varchar(15), 
author varchar(35),
publisher varchar(55)
)

alter table books
alter column category type varchar(20);

--Creating members table--
create table members(
member_id varchar(20) primary key,
member_name varchar(25),
member_address varchar(75),
reg_date Date
)

alter table members
alter column member_id type varchar(10);

--Creating issued_status table--
create table issued_status(
issued_id varchar(10) primary key,
issued_member_id varchar(10),
issued_book_name varchar(70),
issued_date Date,
issued_book_isbn varchar(25),
issued_emp_id varchar(10)
)

--Creating return_status table--
create table return_status(
return_id varchar(10) primary key,
issued_id varchar(10),
return_book_name varchar(75),
return_date Date,
return_book_isbn varchar(20)
)

--Foreign key--
Alter table issued_status
add constraint fk_members
foreign key (issued_member_id)
references members(member_id);

alter table issued_status
add constraint fk_books
foreign key (issued_book_isbn)
references books(isbn);

alter table issued_status
add constraint fk_employees
foreign key (issued_emp_id)
references employees(emp_id);

alter table employees
add constraint fk_branch
foreign key (branch_id)
references branch(branch_id);

alter table return_status
add constraint fk_issued_status
foreign key (issued_id)
references issued_status(issued_id);
