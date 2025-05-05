create database Library;

CREATE TABLE branch(
branch_id varchar(10) primary key,
manager_id varchar(10),
branch_address varchar(30),
contact_no varchar(15)
);

create table employees(
emp_id varchar(10) Primary key,
emp_name varchar(30),
position varchar(30),
salary decimal (10,2),
branch_id varchar(10),
foreign key (branch_id) references branch(branch_id));

create table members(
member_id varchar(10) primary key,
member_name varchar(30),
member_address varchar(30),
reg_date DATE);

create table books(
isbn varchar(50) primary key,
book_title varchar(80),
category varchar(30),
rental_price decimal (10,2),
status_ varchar(10),
author varchar(30),
publisher varchar(30));

create table issued_status(
issued_id varchar(10) primary key,
issued_member_id varchar(30),
issued_book_name varchar(80),
issued_date DATE,
issued_book_isbn varchar(50),
issued_emp_id varchar(10),
foreign key (issued_member_id) references members(member_id),
foreign key (issued_emp_id) references employees(emp_id),
foreign key (issued_book_isbn) references books(isbn)
);

create table return_status(
return_id varchar(10) primary key,
issued_id varchar(30),
return_book_name varchar(80),
return_date DATE,
return_book_isbn varchar(50),
foreign key (return_book_isbn) references books(isbn));

-- queries

-- Q1 Create a New Book Record 
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.'"
alter table books;
insert into books (isbn,
book_title,
category,
rental_price,
status_ ,
author,
publisher) values ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

-- Q2 Update an Existing Member's Address
alter table members;
update members
set member_address = "124, Low Street"
where member_id = "C101";

-- Q3 Delete a Record from the Issued Status Table
-- Objective: Delete the record with issued_id = 'IS104' from the issued_status table.
Alter table issued_status;
delete from issued_status 
where issued_id = 'IS104';

-- Q4: Retrieve All Books Issued by a Specific Employee
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
SELECT employees.emp_id, employees.emp_name, books.category, issued_status.issued_emp_id, issued_status.issued_book_name, issued_status.issued_book_isbn
from employees join issued_status on employees.emp_id = issued_status.issued_emp_id
join books on issued_status.issued_book_isbn = books.isbn
where emp_id = 'E101';

-- Task 5: List Members Who Have Issued More Than One Book
-- Objective: Use GROUP BY to find members who have issued more than one book.
select members.member_name, count(issued_status.issued_member_id) as no_of_books
from members join issued_status on members.member_id = issued_status.issued_member_id
group by members.member_name, issued_status.issued_member_id
having count(issued_status.issued_member_id)>1
order by no_of_books;


-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
Create table Book_issued_count
as
select books.isbn, books.book_title, books.category, COUNT(issued_status.issued_id) as no_of_issued
from books join issued_status on books.isbn = issued_status.issued_book_isbn
group by books.isbn, books.book_title, books.category;

select * from book_issued_count;


-- Task 7. Retrieve All Books in a Specific Category:
select * from books
where books.category = 'classic';

-- Task 8: Find Total Rental Income by Category:
select books.category, sum(books.rental_price) as Total_Rental_Income from books
group by books.category
order by Total_Rental_Income;

-- task 10 List Employees with Their Branch Manager's Name and their branch details:
select e1.*, branch.manager_id, e2.emp_name as manager
from employees as e1 join branch on e1.branch_id = branch.branch_id
join employees as e2 on branch.manager_id = e2.emp_id;

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold 7USD:
create table No_of_books
as
select books.* from books
where books.rental_price > 7;

select * from No_of_books;


-- Task 12: Retrieve the List of Books Not Yet Returned
select issued_status.*, return_status.*
from issued_status
LEFT JOIN return_status
on issued_status.issued_id = return_status.issued_id
where return_status.return_id is null;

/*
Task 13: 
Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.
*/

-- issued_status == members == books == return_status
-- filter books which is return
-- overdue > 30 
select m.member_id, m.member_name, ist.issued_book_isbn, ist.issued_book_name, ist.issued_date, ist.issued_id, return_status.return_id, return_status.return_date
from members as m join issued_status as ist on m.member_id=ist.issued_member_id
LEFT JOIN return_status on return_status.issued_id=ist.issued_id
where return_id is null;


/*    
Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
*/
alter table books;

select ist.issued_id, ist.issued_book_isbn, books.category, rs.return_id
from issued_status as ist join books on ist.issued_book_isbn = books.isbn
LEFT JOIN return_status as rs on ist.issued_id=rs.issued_id;

update books set books.status_ = 'YES'
where books.status_ = 'NO' AND return_status.return_id is not null;

-- 14q is not right answer !! high level question 


/*
Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, 
and the total revenue generated from book rentals.
*/
SELECT 
    branch.branch_id,
    branch.branch_address,
    branch.manager_id,
    COUNT(ist.issued_id) AS number_book_issued,
    COUNT(rs.return_id) AS number_of_book_return,
    SUM(books.rental_price) AS total_revenue
FROM
   issued_status as ist join employees as e on e.emp_id = ist.issued_emp_id
   JOIN branch on e.branch_id = branch.branch_id
   LEFT JOIN
   return_status as rs on rs.issued_id=ist.issued_date
   join books on ist.issued_book_isbn=books.isbn
   GROUP BY branch.branch_id,
    branch.branch_address;

