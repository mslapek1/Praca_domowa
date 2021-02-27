/*Partner tui sugeruje, ¿e wnioski s¹ prób¹ wy³udzenia odszkodowania.
PrzeprowadŸ analizê (podstawowe):*/

--1. Jaka jest dynamika miesiêczna (MoM) zmiany liczby wniosków dla tego partnera w
--roku 2017? Skorzystaj ze sk³adni podzapytania CTE. [8%]

with zmiana_liczby_wnioskow as (
select w.id
,	to_char(data_utworzenia,'YYYY-MM')as miesiac
,	count(id)  as obecna
,	lag(w.id) over() as poprzedni_miesiac
from wnioski w 
where to_char(data_utworzenia, 'YYYY')='2017'
group by miesiac 
)
select *
,	round(obecna-poprzedni_miesiac*100.0 /poprzedni_miesiac , 2) as zmiana
from zmiana_liczby_wnioskow;


--Jak zmienia siê suma wyp³aconych rekompensat w kolejnych miesi¹cach 2017 roku?
--Policz MoM z wykorzystaniem podzapytania CTE. [8%]
WITH suma_wyplaconych_rekompensat AS (
select to_char(data_utworzenia, 'YYYY-MM') as miesiac
,	sum(kwota_rekompensaty) as suma
,	lag(sum(kwota_rekompensaty)) over() as suma_lag
from wnioski
where to_char(data_utworzenia, 'YYYY')='2017'
group by 1
)
select *
,	round((suma-suma_lag)*100.0 /suma_lag, 2) as zmiana 
from suma_wyplaconych_rekompensat;



/*3. Jak kwota rekompensaty jest skorelowana z liczb¹ pasa¿erów dla ró¿nych typów
podró¿y i typów wniosków (pola typ_podrozy i typ_wniosku)? Analizê wykonaj dla
roku 2017. [8%]*/
select typ_podrozy 
,	typ_wniosku 
,	corr(kwota_rekompensaty_oryginalna, liczba_pasazerow)
from wnioski
where to_char(data_utworzenia, 'YYYY')='2017'
group by 1,2 ;

/*4. Jak wygl¹da œrednia, mediana i moda rekompensaty dla ró¿nych typów podró¿y i
typów wniosków (pola typ_podrozy i typ_wniosku)? Analizê wykonaj dla roku 2017.
[4%]*/
select to_char(data_utworzenia, 'YYYY-MM') as miesiac
,	typ_podrozy 
,	typ_wniosku 
,	avg(kwota_rekompensaty) as srednia
,	percentile_disc(0.5) within group(order by kwota_rekompensaty) as mediana
,	mode() within group (order by kwota_rekompensaty) as moda_rekom
from wnioski w2 
where to_char(data_utworzenia, 'YYYY')='2017'
group by 1,2,3;


/*5. Czy wnioski biznesowe s¹ czêœciej oceniane przez operatora (procentowo) ni¿ inne
typy wniosów? Porównaj dane w latach 2016 i 2017 dla partnera tui i dla innych
partnerów. [12%]*/
with wnioski_biznesowe as (
select partner 
,	to_char(data_utworzenia, 'YYYY')as rok
,	count(id) as wszystkie_wnioski
,	(select count(typ_wniosku) from wnioski where partner='tui')as wnioski_tui
from wnioski w 
where to_char(data_utworzenia,'YYYY') in('2016','2017')
group by partner, rok )
select *
,	round((wnioski_tui-wszystkie_wnioski)*100.0 /wszystkie_wnioski , 2) as procent_wnioskow_biznesowych_tui
from wnioski_biznesowe ;

/*6. Oblicz dystrybujê procentow¹ typów wniosków dla tego partnera (jak¹ czêœæ
wszystkich wniosków stanowi¹ wnioski danego typu). [8%]*/
with dystrybucja_procentowa as (
select w2.typ_wniosku
,	count(w2.id) as wszystkie_wnioski
,   (select count(w3.id) from wnioski w3 where w3.partner = 'tui') as wnioski_tui
from wnioski w2
group by 1)
select *
,	((wszystkie_wnioski-wnioski_tui )*100.0 / wszystkie_wnioski ,2) as procent_typów_wniosków
from dystrybucja_procentowa;

/*7. Porównaj obliczon¹ dystrybucjê z dystrybucj¹ wniosków wszystkich innych partnerów
(ale nie wniosków bez partnera). Oblicz dla nich œredni¹. [8%]*/

with dystrybucja_procentowa as (
select typ_wniosku 
,	id 
,	count(id) as wszystkie_wnioski)
,	avg(procent_typow_wnioskow) 
(select count(id)from wnioski w3 
where partner != 'tui' and !='') as wnioski_innych_pastnerow
from wnioski w2 
group by 1)
select *
,	((wszystkie_wnioski-wnioski_innych_partnerow )*100.0 / wszystkie_wnioski ,2) as procent_typów_wniosków
from dystrybucja_procentowa;
--Pozosta³e zadania (zaawansowane):
/*1. Oblicz P25 i P75 wysokoœci wyp³aconych rekompensat. Ile wniosków otrzyma³o
rekompensaty poni¿ej i równe P25, a ile powy¿ej i równe P75? Skorzystaj
percentile_disc i z funkcji count w po³¹czeniu z case. [12%]*/
with wysokosci_wyplaconych_rekomp as(
select 	kwota_rekompensaty 
,	percentile_disc(0.25)within group (order by kwota_rekompensaty) as p25
,	percentile_disc(0.75)within group (order by kwota_rekompensaty) as p75
from wnioski w
group by 1)
select *
,	count(case when "kwota_rekompensaty" >= p25 then 1 end) 
,	count(case when "kwota_rekompensaty" >= p75 then 1 end)
from wysokosci_wyplaconych_rekomp;
/*2. Wyœwietl listê wniosków, których wyp³acona rekompensata by³a równa lub wy¿sza
ni¿ P75. [8%]*/

select id
,	kwota_rekompensaty 
,	percentile_disc(0.75)within group (order by kwota_rekompensaty) as p75
from wnioski w 
group by 1;

/*3. ZnajdŸ jaki powód operatora jest zg³aszany najczêœciej przez ka¿dego z operatorów.
[8%]*/
select powod_operatora 
,	mode() within group (order by powod_operatora) as moda_powod
from wnioski w 
group by 1;

/*4. Stwórz tabelê przestawn¹, gdzie rzêdami bêd¹ poszczególni operatorzy podró¿y, w
kolumnach typy wniosków, a wartoœciami bêd¹ œrednie kwoty rekompensaty. [4%]*/

select nazwa
,	typ_wniosku
,	avg(kwota_rekompensaty) 
from o_operatorzy oo 
join wnioski w2 on w2.id=oo.id
join podroze p2 on p2.id=oo.id
group by 1,2;

CREATE extension tablefunc;
select *
from crosstab(
'select nazwa
,	typ_wniosku
,	avg(kwota_rekompensaty)
from o_operatorzy oo 
join wnioski w2 on w2.id=oo.id
join podroze p2 on p2.id=oo.id
group by 1,2
order by 1,2'
)
as pivot ("nazwa" varchar
,		"anulowany" numeric 
,		"opozniony" numeric);


/*5. Przeanalizuj kampanie marketingowe (m_kampanie) w latach 2015-2017. Który typ
kampanii przynosi³ najwiêcej leadów zakoñczonych wyp³at¹ rekompensaty w
poszczególnych latach? [12%]*/


select typ_kampanii 
,	to_char(data_utworzenia, 'YYYY') as rok 
,	lead(kwota_rekompensaty) over (partition by typ_kampanii ORDER BY
kwota_rekompensaty desc)
from wnioski w2 
join m_kampanie mk on w2.id=mk.id
where to_char(data_utworzenia, 'YYYY')  between '2015' and '2017' and status = 'wyp³acone';

