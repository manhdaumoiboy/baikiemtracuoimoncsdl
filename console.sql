
create table Customer (
    customer_id varchar(5) primary key not null,
    customer_fullname varchar(100) not null ,
    customer_email varchar(100) not null ,
    customer_phone varchar(15) not null,
    customer_address varchar(255)not null

    );
create table Room
(
    room_id     varchar(5) primary key not null,
    room_type   varchar(50)            not null,
    room_price  decimal(10, 2)         not null,
    room_status varchar(20)            not null,
    room_area   int

);
create table Booking (
    booking_id int primary key not null,
    check_in_date date not null,
    check_out_date date not null,
    total_amount decimal(10,2)
    );
alter table Booking
add column customer_id varchar(5) references Customer(customer_id);
alter table Booking
add column  room_id varchar(5) references Room(room_id);



create table Payment(
    payment_id int primary key not null,
    booking_id int not null,
    payment_method varchar(50) not null,
    payment_date date not null,
    payment_amount decimal(10,2)

    );
alter table  Payment_
add column booking_id int references Booking(booking_id);

insert into Customer(customer_id, customer_fullname, customer_email, customer_phone, customer_address)
 values('C001','Nguyen Van Tu','tu.nguyen@example.com','0912345678','Hanoi,Vietnam'),
       ('C002',,'Tran Thi Mai','mai.tran@example.com','0923456789','Ho Chi Minh, Vietnam'),
 ('C003','Le Minh Hoang','hoang.le@example.com','0934567890','Danang, Vietnam'),
 ('C004','Pham Hoang Nam','nam.pham@example.com','0945678901','Hue, Vietnam'),
 ('C005','Vu Minh Thu','thu.vu@example.com','0956789012','Hai Phong, Vietnam');
insert into Room(room_id, room_type, room_price, room_status, room_area)
values( 'R001','Single','100.0','Available','25'),
      ( 'R002','Double','150.0','Booked','40'),
      ( 'R003','Suite','250.0','Available','60'),
      ( 'R004','Single','120.0','Booked','30'),
      ('R005','Double','160.0','Available','35');
insert into Booking(booking_id, room_id,check_in_date, check_out_date, total_amount)
values('C001','R001','2025-03-01','2025-03-05','400.0'),
      ('C002','R002','2025-03-02','2025-03-06','600.0'),
      ('C003','R003','2025-03-03','2025-03-07','1000.0'),
      ('C004','R004','2025-03-04','2025-03-08','480.0'),
      ('C005','R005','2025-03-05','2025-03-09','800.0');
insert into Payment(booking_id,payment_method,payment_date,payment_amount)
values ('1','cash','2025-03-05','400.0'),
       ('2','Credit Card','2025-03-06','600.0'),
       ('3','Bank Transfer','2025-03-07','1000.0'),
       ('4','Cash','2025-03-08','480.0'),
       ('5','Credit Card','2025-03-09','800.0');

select customer_fullname, room_id, check_in_date, check_out_date
from Customer c
         join Booking b on c.customer_id = b.customer_id;
select c.customer_id,customer_fullname,payment_method,payment_amount
from Customer c join Booking b on c.customer_id = b.customer_id
join Payment p on b.booking_id = p.booking_id
order by


    update Booking
set total_amount = total_amount * 0.9
where check_in_date < '3/3/2025';
delate from payment
where payment_method = 'Cash' and payment_amount < 500;

select*
from Customer
order by customer_fullname desc
limit 3
offset 1;

select c.customer_id, customer_fullname,count(room_id)
from Customer c join Booking b on c.customer_id = b.customer_id
group by c.customer_id,customer_fullname
having  count(room_id) >=2;


create or replace procedure  add_customer(customer_id_in varchar(5),customer_fullname_in varchar(100),customer_email_in varchar(100),customer_phone_in varchar(15),customer_address_in varchar(15)
                  language plpgsql as $$
                  begin
                  insert into Customer(customer_id,customer_fullname,customer_email,customer_phone,customer_address)
                  values(customer_id_in,customer_fullname_in,customer_email_in,customer_phone_in,customer_address_in);
                  end;
                  $$;
call add_customer( 'C006',  'Hoang Thi Lan',  'maitienmanh@gmail.com',  '0967890123',  'Can Tho, Vietnam')



select customer_id,customer_fullname,customer_email,customer_phone,customer_phone
                  from Customer
                  where customer_fullname ilike'%minh%' or customer_address ilike '%Hanoi%';

                  select c.customer_id,customer_fullname,room_id,sum(payment_amount)
                  from Customer c  join Booking b on c.customer_id = b.customer_id
                  join payment p on b.booking_id = p.booking_id
                 group by c.customer_id,customer_fullname,room_id
                  having sum(payment_amount)> 1000



                  create view Thong_tin_khac_hang as
                  select r.room_id,room_type,c.customer_id,customer_fullname
                      from Customer c join Booking b on c.customer_id = b.customer_id
                  join Room r on b.room_id = r.room_id
                  where check_in_date<= '2025-03-04';

create view Kich_thuoc_phong as
select customer_id,customer_fullname,room_id,room_area,check_out_date
from Customer c join Booking b on c.customer_id = b.customer_id
                join Room r on b.room_id = r.room_id
where room_area>30;



create or replace function func_check_insert_booking()
    returns trigger as $$
    begin
    if new.check_in_date < new.check_out_date then
    raise exception 'Ngay dat phong khong the sau ngay tra phong';
    end if;

    return new;
    end;
    $$ language plpgsql;

create trigger check_insert_booking
before insert on Booking
for each row
execute function func_check_insert_booking();

--11
select r.room_id,r.room_type,room_price,count(distinct b.customer_id)
    from Booking b join Room r on r.room_id = r.room_id
    group by r.room_id
having count(distinct b.customer_id) >=3;




-- 20
create or replace add_paymeent(p_booking_id int, p_payment_method varchar(50), p_payment_date date, p_payment_amount decimal(10,2))
language plpgsql as $$
begin
insert into Payment(payment_id,Payment_method,payment_date,payment_amount)
values (booking_id p_booking_id, payment_method p_payment_method, payment_date p_payment_date), payment_amount p_payment_amount);

end;
$$;





