--Zadania SQL od podstaw
--1 Podstawy DQL:
--a Wypisz zam�wienia pracownik�w 2,4,5. Znajd� imiona i nazwiska tych pracownik�w
select 	o."OrderID" 
,		e2."EmployeeID" 
,		e2."FirstName" 
,		e2."LastName" 
from orders o
join employees e2 on o."EmployeeID" = e2."EmployeeID"
where o."EmployeeID" in (2,4,5)
order by e2."EmployeeID" 
;

--b Wypisz zam�wienia pracownik�w o ID parzystym
select 	o."OrderID" 
,		e2."EmployeeID" 
,		e2."FirstName" 
,		e2."LastName" 
from orders o
join employees e2 on o."EmployeeID" = e2."EmployeeID"
where o."EmployeeID" % 2 = 0
;

--c Wypisz imiona Pracownik�w � tak aby poszczeg�lne imi� wy�wietlono jeden raz. Wy�wietl je wielkimi literami.
select distinct
	upper(e."FirstName") 
from employees e 
;

--d. Wypisz zam�wienia z 1996roku.
select * 
from orders o
where date_part('year',"OrderDate") = 1996
;

/*e Wyznacz z tabeli z pracownikami Pracownika o ID=1, 
dodaj do wynik�w zmienn� losow� 
Je�eli zmienna losowa ma warto�� >0.7 dodaj komunikat � dodatkowy dzie� wolny�, 
je�eli b�dzie pomi�dzy 0.1 a 0.7 dodaj komunikat �brak nagrody�, 
je�eli b�dzie mniejsza od 0.1 podaj komunikat �musisz zrobi� nadgodziny�. 
Wykonaj skrypt kilka razy. 
Czy komunikat si� zmienia?*/

select 
	e."EmployeeID" 
,	e."FirstName" 
,	e."LastName"
,	random() as losowanie
,	case 	when random()>0.7 then 'dodatkowy dzen wolny'
			when random()<=0.7 and random()>0.1 then 'brak nagrody'
			when random()<0.1 then 'musisz zrobic nadgodziny' end as nagroda
from employees e 
where e."EmployeeID"=1
;

--f Wyznacz terytorium dzia�ania ka�dego pracownika.
select 
	e."EmployeeID" 
,	e2."TerritoryID" 
,	t."TerritoryDescription" 
from employees e 
join employeeterritories e2 on e."EmployeeID" = e2."EmployeeID" 
join territories t on t."TerritoryID" = e2."TerritoryID"
order by e."EmployeeID" 
;

/*
 * h Wyznacz produkty wraz z nazw� kategorii oraz nazw� dostawcy, 
 * dla kt�rych w magazynie jest mniej ni� 15 jednostek lub s� przecenione.
*/

select 
	p."ProductID" 
,	p."ProductName" 
,	c."CategoryName"
,	s."CompanyName" 
from products p 
join categories c on c."CategoryID" = p."CategoryID" 
join suppliers s on s."SupplierID" = p."SupplierID"
join order_details od on od."ProductID" = p."ProductID" 
where p."UnitsInStock" < 15 or od."Discount" > 0
;
--2 DQL � JOIN, UNION, FUNKCJE AGREGUJ�CE:
--a Sprawd� ilu jest w bazie pracownik�w ze stanowiskiem (TITLE) zawieraj�cych s�owo: �Manager�.
select 
	count(e."EmployeeID") 
from employees e
where (e."Title") ilike '%Manager%'
;

--b Policz ilu jest pracownik�w, kt�rzy pracuj� w firmie poszczeg�ln� liczb� lat.

select  count(e."EmployeeID")
,		round((('1996-10-01')-e."HireDate")/365,0)
from employees e
group by round((('1996-10-01')-e."HireDate")/365,0)
;

--c Wyznacz wiek Pracownik�w w dniu zatrudnienia. Jaka jest maksymalna warto��?
select 
	e."FirstName" 
,	e."LastName" 
,	e."BirthDate" 
,	e."HireDate" 
,	DATE_PART('year', e."HireDate") - DATE_PART('year', e."BirthDate") as wiek_zatrudnienia
from employees e 
order by wiek_zatrudnienia desc 
;

/*
d Do zestawienia liczby pracownik�w w departamentach dodaj (zak�adamy, �e DZI� MAMY 1 LISTOPADA 2013 ROKU):
i Liczb� pracownik�w po 50 r.�.
ii Liczb� pracownik�w w wieku emerytalnym (uwzgl�dnij p�e�)
iii Liczb� pracownik�w pracuj�cych ponad 3 lata
iv �redni, maksymalny, minimalny, sta� pracy
*/

select 
	count(e."EmployeeID")
from employees e
where ('2013-11-01'- e."BirthDate")/365 > 50
;

select count(e."EmployeeID")
from employees e
where ((('2013-11-01'- e."BirthDate")/365 > 60) 
and (lower(e."TitleOfCourtesy") in ('ms.','mrs.'))) 
or ((('2013-11-01'- e."BirthDate")/365 > 65) 
and (lower(e."TitleOfCourtesy") in ('mr.','dr.')))
;

select 
	count(e."EmployeeID")
from employees e
where ('2013-11-01'- e."HireDate")/365 > 3
;

select round(avg(('2013-11-01'- e."HireDate")/365),2) as sr_staz_pracy_w_latach
,	   abs(min(('2013-11-01'- e."HireDate")/365)) as min_staz_pracy_w_latach
,	   max(('2013-11-01'- e."HireDate")/365) as max_staz_pracy_w_latach
from employees e
;
--e Sprawd� dat� pierwszego i ostatniego zam�wienia
select 
	min(o."OrderDate")
,	max(o."OrderDate")
from orders o 
;

/*
f. Stw�rz zestawienie sprzeda�y dla Klient�w naj�wie�szy rok 
Wyniki podziel na kwarta�y. wy�wietl liczb� zam�wie�, �redni�, maksymaln�, 
minimaln� warto�� oraz sum� z p�l Freight, oraz z kwoty zam�wienia.
*/

select c."CompanyName",
	   o."OrderDate",
	   count(o."OrderID") liczba_zam,
	   round(min(od."UnitPrice"*od."Quantity"*(1-od."Discount"))::numeric,2) min_kwota_zam,
	   round(max(od."UnitPrice"*od."Quantity"*(1-od."Discount"))::numeric,2) max_kwota_zam,
	   round(avg(od."UnitPrice"*od."Quantity"*(1-od."Discount"))::numeric,2) sr_kwota_zam,
	   round(sum(od."UnitPrice"*od."Quantity"*(1-od."Discount"))::numeric,2) sum_kwota_zam,
	   round(min(o."Freight")::numeric,2) min_wart_freight,
	   round(max(o."Freight")::numeric,2) max_wart_freight,
	   round(avg(o."Freight")::numeric,2) sr_wart_freight,
	   round(sum(o."Freight")::numeric,2) sum_wart_freight,
	   case
	   when date_part('month',o."OrderDate") in (1,2,3) then 1
	   when date_part('month',o."OrderDate") in (4,5,6) then 2
	   when date_part('month',o."OrderDate") in (7,8,9) then 3
	   when date_part('month',o."OrderDate") in (10,11,12) then 4
	   end which_quarter
from orders o
join customers c on o."CustomerID" = c."CustomerID"
join order_details od on o."OrderID" = od."OrderID" 
where date_part('year',o."OrderDate") = (select date_part('year',max(o."OrderDate")) from orders o)
group by which_quarter, o."OrderDate", o."OrderID", c."CompanyName"
;

;

--g Stw�rz zestawienie sprzeda�y dla sklep�w za najstarszy rok. 
--Wyniki podziel na z kwarta�y. wy�wietl liczb� zam�wie�, �redni�, maksymaln�, 
--minimaln� warto�� oraz sum� z p�l Freight, SUBTOTAL, oraz TOTALDUE.

select c."CompanyName",
	   o."OrderDate",
	   count(o."OrderID") liczba_zam,
	   round(min(o."Freight")::numeric,2) min_wart_freight,
	   round(max(o."Freight")::numeric,2) max_wart_freight,
	   round(avg(o."Freight")::numeric,2) sr_wart_freight,
	   round(sum(o."Freight")::numeric,2) sum_wart_freight,
	   case
	   when date_part('month',o."OrderDate") in (1,2,3) then 1
	   when date_part('month',o."OrderDate") in (4,5,6) then 2
	   when date_part('month',o."OrderDate") in (7,8,9) then 3
	   when date_part('month',o."OrderDate") in (10,11,12) then 4
	   end which_quarter
from orders o
join customers c on o."CustomerID" = c."CustomerID"
join order_details od on o."OrderID" = od."OrderID" 
where date_part('year',o."OrderDate") = (select date_part('year',min(o."OrderDate")) from orders o)
group by which_quarter, o."OrderDate", o."OrderID", c."CompanyName";

--h Po��cz wyniki z dw�ch poprzednich zapyta� za pomoc� UNION.

select c."CompanyName",
	   o."OrderDate",
	   count(o."OrderID") liczba_zam,
	   round(min(o."Freight")::numeric,2) min_wart_freight,
	   round(max(o."Freight")::numeric,2) max_wart_freight,
	   round(avg(o."Freight")::numeric,2) sr_wart_freight,
	   round(sum(o."Freight")::numeric,2) sum_wart_freight,
	   case
	   when date_part('month',o."OrderDate") in (1,2,3) then 1
	   when date_part('month',o."OrderDate") in (4,5,6) then 2
	   when date_part('month',o."OrderDate") in (7,8,9) then 3
	   when date_part('month',o."OrderDate") in (10,11,12) then 4
	   end which_quarter
from orders o
join customers c on o."CustomerID" = c."CustomerID"
join order_details od on o."OrderID" = od."OrderID" 
where date_part('year',o."OrderDate") = (select date_part('year',max(o."OrderDate")) from orders o)
group by which_quarter, o."OrderDate", o."OrderID", c."CompanyName"
union 
select c."CompanyName",
	   o."OrderDate",
	   count(o."OrderID") liczba_zam,
	   round(min(o."Freight")::numeric,2) min_wart_freight,
	   round(max(o."Freight")::numeric,2) max_wart_freight,
	   round(avg(o."Freight")::numeric,2) sr_wart_freight,
	   round(sum(o."Freight")::numeric,2) sum_wart_freight,
	   case
	   when date_part('month',o."OrderDate") in (1,2,3) then 1
	   when date_part('month',o."OrderDate") in (4,5,6) then 2
	   when date_part('month',o."OrderDate") in (7,8,9) then 3
	   when date_part('month',o."OrderDate") in (10,11,12) then 4
	   end which_quarter
from orders o
join customers c on o."CustomerID" = c."CustomerID"
join order_details od on o."OrderID" = od."OrderID" 
where date_part('year',o."OrderDate") = (select date_part('year',min(o."OrderDate")) from orders o)
group by which_quarter, o."OrderDate", o."OrderID", c."CompanyName"
;

-- i Stw�rz to samo zestawienie, co w powy�szym zadaniu bez u�ycia UNION, a modyfikuj�c zapytanie.

select c."CompanyName",
	   o."OrderDate",
	   count(o."OrderID") liczba_zam,
	   round(min(o."Freight")::numeric,2) min_wart_freight,
	   round(max(o."Freight")::numeric,2) max_wart_freight,
	   round(avg(o."Freight")::numeric,2) sr_wart_freight,
	   round(sum(o."Freight")::numeric,2) sum_wart_freight,
	   case
	   when date_part('month',o."OrderDate") in (1,2,3) then 1
	   when date_part('month',o."OrderDate") in (4,5,6) then 2
	   when date_part('month',o."OrderDate") in (7,8,9) then 3
	   when date_part('month',o."OrderDate") in (10,11,12) then 4
	   end which_quarter
from orders o
join customers c on o."CustomerID" = c."CustomerID"
join order_details od on o."OrderID" = od."OrderID" 
where date_part('year',o."OrderDate") = (select date_part('year',max(o."OrderDate")) from orders o)
	or date_part('year',o."OrderDate") = (select date_part('year',min(o."OrderDate")) from orders o)
group by which_quarter, o."OrderDate", o."OrderID", c."CompanyName"
;

--j. Czy w tabeli wyst�puj� wielokrotnie te same imiona i nazwiska?
select count("FirstName") count_imion
,	   count("LastName") count_nazwisk
,	   count(distinct "FirstName") count_uniq_imion
,	   count(distinct "LastName") count_uniq_nazwisk
from employees e
;
--3 J�zyk DML:
--a Baza NORTHWIND:

--i. Dodaj nowego pracownika, ktory obejmie stanowisko CEO.

insert into employees 
values (10,'Hayek', 'Salma', 'CEO', 'Mrs.', '1965-11-05', '1995-06-01', 'Sunset Boulevard 34', 'Los Angeles', 'CA', '90024', 'USA')
;

--ii Zaktualizuj date zatrudnienia na pierwszy dzien przyszlego miesiaca
update employees 
set "HireDate" = '2021-02-01'
where lower("LastName") = 'hayek'
;

--iii Wszystkim pracownikom, ktorzy maja pole reportsto puste, przypisz id CEO.
update employees 
set "ReportsTo" = 10
where "ReportsTo" is null
;

