/*The goal of this project is to apply data cleaning tools and techniques and
correct errors in data and prepare data for analysis ,
along with testing the data for normality and transforming it. */

FILENAME REFFILE '/home/u60732173/BAN110/Project/master.xlsx';

proc import DATAFILE=REFFILE dbms=XLSX out=suicide replace;
RUN;

title "Contents of the datasets";
proc contents data=suicide;
RUN;

title "Frequency distribution of Categorical Variables";
proc freq data=suicide;
	*tables country age country_year generation sex;
	tables country age generation sex;
run;
*Frequency distribution looks balanced among different values in the categorical variables;

title "Statistical Analysis for Variables";
Proc means data=suicide mean median max min n nmiss maxdec=3;
run;

title "Treating Errors in Variable Sex";

proc freq data=suicide;
tables sex;
run;

data suicide replace;
set suicide;
length sex_new $6;
if sex in ("Male","M","male") then sex_new="Male";
else if sex in ("female","F") then sex_new="Female";
drop sex;
rename sex_new=sex;
run;

proc freq data=suicide;
tables sex;
run;

proc format;
	value missingcount
 .='missing' other='notmissing';
	value $Missingchar ' '='Missing' other='NonMissing';
run;


title "Missing Character Variables";
proc freq data=suicide;
table country age country_year generation sex / missing;
format country $Missingchar. age $Missingchar. country_year $Missingchar. 
       generation $Missingchar. sex $Missingchar.;
run;

*No missing values observed in Categorical variables;

data suicide2 replace;
set suicide;

*Derived Variable Creation 1;
if sex="male" then derived_variable1=CAT(sex,age);
else derived_variable1=CAT(sex,age);

*Derived Variable Creation 2;
if generation="Generation X" then derived_variable2=CAT(country,generation);
else derived_variable2=CAT(country,generation);

*Combinig values in suicides_per_100k_pop for new categorical variable;
length suicide_rate $7;
if suicides_per_100k_pop > 0 and suicides_per_100k_pop<=20 then suicide_rate="Low";
else if suicides_per_100k_pop > 20 and suicides_per_100k_pop<=50 then suicide_rate="Medium";
else suicide_rate="High"; 
run;

proc freq data=suicide2;
tables suicide_rate;
run;

/* Correcting erros in Numerical variables */
data suicide;
set suicide(rename=(suicides_no=tmp_id));
	DIGITS=compress(tmp_id, , 'kd');

	if findc(tmp_id, 'a', 'i') then
		suicides_no=input(DIGITS, 5.);
drop tmp_id;
run;

/* Error in suicides_no corrected */
proc contents data=suicide;
RUN;

title "Missing Numerical Variables";
proc freq data=suicide;
table year suicides_no population suicides_per_100k_pop HDI_for_year gdp_for_year gdp_per_capita
 / missing;
format year missingcount. suicides_no missingcount. population missingcount. 
       suicides_per_100k_pop missingcount. HDI_for_year missingcount. 
       gdp_for_year missingcount. gdp_per_capita missingcount.;
run;
*Missing values observed in variabe HDI_for_year;

proc stdize data=suicide out=suicide_Imputed 
		oprefix=Orig_ reponly method=MEAN;
	var HDI_for_year;
run;

/* Treating Missing values observed in variabe HDI_for_year */
proc print data=suicide_Imputed  (obs=10);
	format Orig_HDI_for_year HDI_for_year 4.2;
	var Orig_HDI_for_year HDI_for_year;
run;

/* Checking disturbution */
proc univariate data=suicide plot ;
	var year suicides_no 
	population suicides_per_100k_pop HDI_for_year gdp_for_year gdp_per_capita;
	
/* Detecting Outliners */

proc means data=suicide noprint; 
var population ;
output out=Tmp 
Q1= 
Q3= 
QRange= / autoname; 
run;


data _null_; 
file print; 
set suicide(keep=population); 
if _n_=1 then 
set Tmp; 
if population le population_Q1 - 1.5*population_QRange and not missing(population) or 
population ge population_Q3 + 1.5*population_QRange then 
put "Possible Outlier for population: " population ; 
run;

/* Deleting Outliners */
proc means data=suicide noprint; 
var population;
output out=Tmp 
Q1= 
Q3= 
QRange= / autoname; 
run;

data suicide_OutliersRemoved; 
file print; 
set suicide; 
if _n_=1 then 
set Tmp; 

if population le population_Q1 - 1.5*population_QRange and not missing(population) or 
population ge population_Q3 + 1.5*population_QRange then
delete; 
run; 
title 'After removing outliers'; 
proc print data=suicide_OutliersRemoved (obs=5); 
run;



proc means data=suicide noprint; 
var suicides_no ;
output out=Tmp1 
Q1= 
Q3= 
QRange= / autoname; 
run;


data _null_; 
file print; 
set suicide(keep=suicides_no); 
if _n_=1 then 
set Tmp1; 
if suicides_no le suicides_no_Q1 - 1.5*suicides_no_QRange and not missing(suicides_no) or 
suicides_no ge suicides_no_Q3 + 1.5*suicides_no_QRange then 
put "Possible Outlier for suicides_no: " suicides_no ; 
run;

/* Deleting Outliners */
proc means data=suicide noprint; 
var suicides_no;
output out=Tmp1 
Q1= 
Q3= 
QRange= / autoname; 
run;

data suicide_OutliersRemoved1; 
file print; 
set suicide; 
if _n_=1 then 
set Tmp1; 

if suicides_no le suicides_no_Q1 - 1.5*suicides_no_QRange and not missing(suicides_no) or 
suicides_no ge suicides_no_Q3 + 1.5*suicides_no_QRange then
delete; 
run; 
title 'After removing outliers'; 
proc print data=suicide_OutliersRemoved1 (obs=5); 
run;

proc contents data=suicide_OutliersRemoved1 ; 
run;

/*Testing for normality amoung the economy variable*/
Proc Univariate data= suicide plot normaltest;
	var year suicides_no 
	population suicides_per_100k_pop gdp_for_year gdp_per_capita;
run;

/***********************************************************************/
/*Apply a transformation and test for normality 
again with histogram and QQ plot*/

data suicide_transformation;
   set suicide;
   logpop = log(population);
   logsuino = log (suicides_no);
   logperpop = log (suicides_per_100k_pop);
   loggdpyear = log (gdp_for_year);
   loggdpcap = log (gdp_per_capita);
run;

Proc Univariate data= suicide_transformation;
	var logpop logsuino logperpop loggdpyear loggdpcap;
	qqplot;
	
Proc Univariate data= suicide_transformation;
	var logpop logsuino logperpop loggdpyear loggdpcap;
	histogram;

	/* Checking for Normality */
	probplot logpop logsuino logperpop loggdpyear loggdpcap/ normal(mu=est 
		sigma=est);
run;

