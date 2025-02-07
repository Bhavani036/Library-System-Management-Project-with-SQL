select * from books;
select * from branch;
select * from employees;
select * from issued_status;
select * from return_status;
select * from members;

---CRUD OPERATIONS---
--Task 1. Create a New Book Record --("978-1-60129-456-2","To kill a mockingbird","classic",6.00,"yes","Harper Lee","J.B.Lippincott & co.")
insert into books(isbn,book_title,category,rental_price,status,author,publisher)
values('978-1-60129-456-2','To kill a mockingbird','classic',6.00,'yes','Harper Lee','J.B.Lippincott & co.');

select * from books;

--Task 2. Update an existing member's address
update members
set member_address = '150 Main St'
where member_id = 'C101';

select * from members;

--Task 3: Delete a Record from the issued status Table
--Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
DELETE FROM issued_status
where issued_id = 'IS121';

--Task 4: Retreive All Books Issued by a specific Employee
--Objective: Select all books issued by the employee with emp_id='E101'
select * from issued_status
where issued_emp_id='E101';

--Task 5: List Members who have issued more than one Book 
--Objective: use Group by to find members who have issued more than one book
select issued_emp_id,count(issued_id) as total_book_issued
from issued_status
group by issued_emp_id
Having count(issued_id) > 1;

--Task 6: CTAS(Create Table as Select)
--Create Summary Tables: used CTAS to generate new tables based on query results
--each book and total  book_issued_cnt
Create Table book_Counts
As
select b.isbn,b.book_title,count(i.issued_id) as no_of_issued
from books as b
join
issued_status as i
on i.issued_book_isbn = b.isbn
group by 1,2;

select * from book_counts;

--Task 7:Retreive All books in a specific category
select * from books
where category = 'History';

--Task 8: find total rental income by category
select b.category,sum(b.rental_price),count(*)
from books as b
join
issued_status i
on i.issued_book_isbn = b.isbn
group by 1;

--Task 9: List Members who registered in the last 180 days:
select * from members
where reg_date>=Current_date - Interval '180 days'

insert into members(member_id,member_name,member_address,reg_date)
values('C120','Bob','145 main st','2024-11-01'),
('C121','Ken','133 main st','2021-12-01');

--Task 10: List the employees with their Branch manager's name and their branch details:
select e1.*,b.manager_id,e2.emp_name as manager
from employees as e1
join 
branch as b
on b.branch_id = e1.branch_id
join employees as e2
on b.manager_id = e2.emp_id

--Task 11: Create a Table of Books with Rental Price Above a Certain Threshold 10USD:
create table Books_rental_info
AS
select * from books
where rental_price > 7

select * from books_rental_info;

--Task 12: Retrieve the list of books not yet returned
select Distinct ist.issued_book_name
from issued_status as ist
left join
return_status as rst
on ist.issued_id=rst.issued_id
where rst.return_id is null

--Task 13:Identify members with overdue Books
--objective:write a query to identify members who have overdue books(assume a 30-day return period).
--Display the member's_id,member's name,book title,issue date, and days overdue
select ist.issued_member_id,m.member_name,bk.book_title,ist.issued_date,rst.return_date
current_date - ist.issued_date as over_due_days
from issued_status as ist
join
members as m
on m.member_id = ist.issued_member_id
join
Books as bk
on bk.isbn = ist.issued_book_isbn
left join 
return_status as rst
on rst.issued_id = ist.issued_id
where rst.return_date is null
and (current_date - ist.issued_date) > 30
order by 1;

--Task 14: Update Book Status on Return
--objective : write a query to update the status of books in the books table to "yes" when they are returned
--(based on entries in the return_status table).
update books
set status = 'no'
where isbn = '978-0-525-47535-5';

select * from books
where isbn = '978-0-525-47535-5';

select * from issued_status
where issued_book_isbn = '978-0-525-47535-5';

select * from return_status
where issued_id = 'IS138';

--
insert into return_status(return_id,issued_id,return_date)
values
('RS126','IS138',CURRENT_DATE);

select * from return_status
where issued_id = 'IS138';

--Store Procedures
CREATE OR REPLACE PROCEDURE add_return_records(p_return_id VARCHAR(10), p_issued_id VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE
    v_isbn VARCHAR(50);
    v_book_name VARCHAR(80);
    
BEGIN
    -- all your logic and code
    -- inserting into returns based on users input
    INSERT INTO return_status(return_id, issued_id, return_date)
    VALUES
    (p_return_id, p_issued_id, CURRENT_DATE);

    SELECT 
        issued_book_isbn,
        issued_book_name
        INTO
        v_isbn,
        v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;

    UPDATE books
    SET status = 'yes'
    WHERE isbn = v_isbn;

    RAISE NOTICE 'Thank you for returning the book: %', v_book_name;
    
END;
$$

-- Testing FUNCTION add_return_records

issued_id = IS135
ISBN = WHERE isbn = '978-0-307-58837-1'

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT * FROM return_status
WHERE issued_id = 'IS135';

-- calling function 
CALL add_return_records('RS138', 'IS135');

-- calling function 
CALL add_return_records('RS148', 'IS140');

--Task 15: Branch Performance Report
--Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

SELECT * FROM branch;

SELECT * FROM issued_status;

SELECT * FROM employees;

SELECT * FROM books;

SELECT * FROM return_status;

CREATE TABLE branch_reports
AS
SELECT 
    b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id) as number_book_issued,
    COUNT(rs.return_id) as number_of_book_return,
    SUM(bk.rental_price) as total_revenue
FROM issued_status as ist
JOIN 
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
JOIN 
books as bk
ON ist.issued_book_isbn = bk.isbn
GROUP BY 1, 2;

SELECT * FROM branch_reports;

-- Task 16: CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

CREATE TABLE active_members
AS
SELECT * FROM members
WHERE member_id IN (SELECT 
                        DISTINCT issued_member_id   
                    FROM issued_status
                    WHERE 
                        issued_date >= CURRENT_DATE - INTERVAL '2 month'
                    );

SELECT * FROM active_members;


-- Task 17: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

SELECT 
    e.emp_name,
    b.*,
    COUNT(ist.issued_id) as no_book_issued
FROM issued_status as ist
JOIN
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
GROUP BY 1, 2

/*
Task 18: Stored Procedure Objective: 

Create a stored procedure to manage the status of books in a library system. 

Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 

The procedure should function as follows: 

The stored procedure should take the book_id as an input parameter. 

The procedure should first check if the book is available (status = 'yes'). 

If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 

If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.
*/

SELECT * FROM books;

SELECT * FROM issued_status;


CREATE OR REPLACE PROCEDURE issue_book(p_issued_id VARCHAR(10), p_issued_member_id VARCHAR(30), p_issued_book_isbn VARCHAR(30), p_issued_emp_id VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE
-- all the variabable
    v_status VARCHAR(10);

BEGIN
-- all the code
    -- checking if book is available 'yes'
    SELECT 
        status 
        INTO
        v_status
    FROM books
    WHERE isbn = p_issued_book_isbn;

    IF v_status = 'yes' THEN

        INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
        VALUES
        (p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);

        UPDATE books
            SET status = 'no'
        WHERE isbn = p_issued_book_isbn;

        RAISE NOTICE 'Book records added successfully for book isbn : %', p_issued_book_isbn;


    ELSE
        RAISE NOTICE 'Sorry to inform you the book you have requested is unavailable book_isbn: %', p_issued_book_isbn;
    END IF;

    
END;
$$

SELECT * FROM books;
-- "978-0-553-29698-2" -- yes
-- "978-0-375-41398-8" -- no
SELECT * FROM issued_status;

CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');
CALL issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');


SELECT * FROM books
WHERE isbn = '978-0-375-41398-8'

----End of the Project----