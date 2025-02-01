cd "C:\Zhuofei Lu\OneDrive\Research\UKTUS2014_2015"

use "uktus15_individual.dta",replace 
//merge interview data with wide time-use data
merge 1:m serial pnum using "uktus15_diary_wide"
keep if _merge==3
drop _merge

//Begin: N=16533 diaries

//keep the diaries collected during working days (KindOfDay and those who are employee WorkSta)
//weekday N=2477
keep if KindOfDay ==1 & WorkSta ==2 & ddayw==1

//key variables 
keep serial pnum daynum DMSex WkArrang WkArran2-WkArran9 SatisOv SatBal Stressed dev1-dev144 wit1_1-wit1_144 wit4_1-wit4_144 ///
act1_1-act1_144 othact1_1-othact1_144 enj1-enj144 dnssec8 DM016 DM014 ind_wt Income DVAge WrkLoc EducCur Happy Anxious SatSoc SatJob Satis LongIll GenHlth


//gen unique id
egen pid = group( serial pnum daynum)
order pid
sort pid

egen pidp = group( serial pnum)
order pidp
sort pidp

//recode missing
foreach var of varlist pidp-dev144 {
replace `var' = . if `var'<0
}


//code time
//coding of paid working time
egen working=rcount( act1_1- act1_144 ), c(@==1100|@==1110|@==1210|@==9110|@==9100|@==9010|@==4190|@==9120|@==1399 ///
|@==1391|@==1390|@==4310|@==9400|@==6290|@==6200|@==4110|@==4100)

gen working_time=working*10

//food*****
egen food=rcount(act1_1-act1_144), c(@==3100 |@==3110 |@==3130 |@==4210 |@==3190 |@==3611)

gen food_time=food*10


//routine****
egen routine=rcount(act1_1-act1_144), c(@==3250 |@==3210|@==3230|@==3240|@==3310|@==3320|@==3613)

gen routine_time=routine*10

g routine2=routine_time+food_time


//nonroutine------
egen nonroutine=rcount(act1_1-act1_144), c(@==4230|@==4240|@==3220|@==3410|@==3420|@==3430|@==3490|@==3500|@==3510 ///
|@==3520|@==3530|@==3539|@==3540|@==3590)

gen nonroutine_time=nonroutine*10


//household care***********
egen household=rcount(act1_1-act1_144), c(@==9310|@==4200|@==4220|@==4281|@==4282|@==4283|@==4280|@==4289|@==9420|@==3290 ///
|@==3000|@==3710|@==3729|@==3910|@==3911|@==3914|@==3919|@==3920|@==3921|@==3924|@==3929 )

gen household_time=household*10


//childcare
egen childcare=rcount(act1_1-act1_144), c(@==4270 |@==4275|@==9380|@==4271|@==4272|@==4273|@==4274|@==4277|@==4278|@==4279|@==3800 ///
|@==3810|@==3811|@==3819|@==3820|@==3830|@==3840|@==3890)

gen childcare_time=childcare*10


//personal
egen personal=rcount(act1_1-act1_144), c(@==310|@==390|@==0)
g personal_time=personal*10


//coding of sleep time
egen sleep=rcount( act1_1-act1_144 ), c(@==110)

gen sleep_time=sleep*10

//free
g free=1440-working_time-household_time-routine_time-food_time-nonroutine_time-childcare_time-sleep_time-personal_time


//coding of paid working time
egen pwork=rcount( act1_1- act1_144 ), c(@==1100|@==1110|@==1210|@==9110|@==9100|@==4190|@==9120|@==1399 ///
|@==1391|@==1390|@==4310|@==9400|@==4110|@==4100|@==3120)

gen pwork_time=pwork*10


//free2
g free2=1440-pwork_time-household_time-routine_time-food_time-nonroutine_time-childcare_time-sleep_time-personal_time

g house=household_time+routine_time+food_time+nonroutine_time+childcare_time


//code variable
//fwa
g flex1=WkArrang
g flex2=WkArran2
g flex3=WkArran3
g flex4=WkArran4
g flex5=WkArran5
g flex6=WkArran6
g flex7=WkArran7
g flex8=WkArran8
g flex9=WkArran9

//drop strange cases
drop if WkArrang==1 & WkArran2==1 

g type=0
replace type=1 if WkArrang==1
replace type=2 if WkArran2==1 

//child
g child=DM016
recode child 0=0 1/max=1
//income
g loghinc=log((Income+10))
//class
g class=dnssec8
recode class 1/3=3 4/6=2 7/8=1



reg pwork_time i.type i.DMSex i.class i.child c.DVAge c.loghinc c.GenHlth [pw=ind_wt]
g s=1 if e(sample)

keep if s==1
duplicates report pidp, count
duplicates drop pidp,force

drop if WkArrang==.
drop if WkArran2==.
