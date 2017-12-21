Identify subscribers with a gap of 3 or more months in thier subscription?

  Three solutions

   WPS/PROC R
   WPS/SAS Arrays
   WPS/SAS long and skinny (normalized)

   There is a very elegant solution using a single string, but I did not
   have enough room in the margin to write it down?

SOAPBOX ON;

  OFF TOPIC

  He is testament to 'more is less'.
  Google " R remove rownames " and you will
  get many pages of hits.

  This is one of the weaknesses of R.
  We need a reduced readable R, R for production or R modelled after IML?

  Also tighter regulation of packages?

SOAPBOX OFF


INPUT
=====

WORK.HAVE total obs=7

 CLIENT  JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC

 Client1 123 768 678 452 213 123 55  010   0   0   0   0    Gap     Sep-Nov
 Client2 549 542 021 321 031 059 998   0 546 980   0 987    No gap
 Client3 500   0 500   0   0   0 500   0 500   0 500   0    Gap     Apr-Jul
 Client4 126 545 315   0 268 126 056   0   0 099   0   0    No gap
 Client5 546 546   0   0 033   0   0   0   0   0 066   0    Gap     Jun-Aug
 Client6   0   0   0 025 078 563 698 631 230 053   0   0    Gap     Jan-Mar
 Client7   0   0   0   0   0   0   0   0   0   0   0   0    Gap     Jan-Mar


PROCESS
=======

  WPS/SAS/R (working code - left out interfase with SAS)

     want <- c();
     for ( i in (1:ncols(have)-1) ) {
       flips<-tapply(rle(have[i,])$lengths,rle(have[i,])$values,FUN=max);
       want=rbind(want,flips);
     };


  WPS/SAS ARRAY

     %utl_submit_wps64('
     libname wrk sas7bdat "%sysfunc(pathname(work))";
     data wantwps(keep=client subscription);;
       set wrk.have;
       array mons[12] _numeric_;
       do i=1 to 12;
         if mons[i] eq 0 then cnt=1;
         else do;cnt=0;cntmax=0; end;
         cntmax=sum(cntmax,cnt);
         if cntmax=3 then do;
            subscription="Gap    ";
            output;
            cnt=0;
            cntmax=0;
            leave;
         end;
        else if i=12 then do;
           subscription="No Gap    ";
           output;
            cnt=0;
            cntmax=0;
            leave;
        end;
       end;
     run;quit;
     proc print;
     run;quit;
     ');


  WPS/SAS NORMALIZED

    %utl_submit_wps64('
    libname wrk sas7bdat "%sysfunc(pathname(work))";
    proc transpose data=wrk.have out=havxpo;
    by client;
    run;quit;

    data want2nd(keep=client subscription);
      retain cnt 0 cntmax 0 subscription "subscription";
      do zro=1 to 1 until(last.client);
        set havxpo;
        by client;
        if col1=0 then cnt=1;
        else do;cnt=0;cntmax=0;end;
        cntmax=sum(cntmax,cnt);
        if cntmax=3 then subscription="Gap    ";;
        if last.client then do;
           output;
           cntmax=0;
           subscription="No Gap    ";
           cnt=0;
        end;
      end;
    run;
    proc print;
    run;quit;
    ');




OUTPUT
======

 WPS/SAS

  CLIENT     SUBSCRIPTION

  Client1      Gap
  Client2      No Gap
  Client3      Gap
  Client4      No Gap
  Client5      Gap
  Client6      Gap
  Client7      Gap


 R

  CLIENT     MAX_GAP    SUBSCRIPTION

  Client1        4         Gap
  Client2        1         No Gap
  Client3        3         Gap
  Client4        2         No Gap
  Client5        5         Gap
  Client6        3         Gap
  Client7       12         Gap

*                _              _       _
 _ __ ___   __ _| | _____    __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/ | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|

;

options validvarname=upcase;
libname sd1 "d:/sd1";
data sd1.have;
 input client$ Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec ;
cards4;
Client1 123 768 678 452 213 123 55 10 0 0 0 0
Client2 549 542 21 321 31 59 998 0 546 980 0 987
Client3 500 0 500 0 0 0 500 0 500 0 500 0
Client4 126 545 315 0 268 126 56 0 0 99 0 0
Client5 546 546 0 0 33 0 0 0 0 0 66 0
Client6 0 0 0 25 78 563 698 631 230 53 0 0
Client7 0 0 0 0 0 0 0 0 0 0 0 0
;;;;
run;quit;

*                                 _ _             _
 _ __   ___  _ __ _ __ ___   __ _| (_)_______  __| |
| '_ \ / _ \| '__| '_ ` _ \ / _` | | |_  / _ \/ _` |
| | | | (_) | |  | | | | | | (_| | | |/ /  __/ (_| |
|_| |_|\___/|_|  |_| |_| |_|\__,_|_|_/___\___|\__,_|

;

%utl_submit_wps64('
libname wrk sas7bdat "%sysfunc(pathname(work))";
proc transpose data=wrkhave out=havxpo;
by client;
run;quit;

data want;
  retain cnt 0 cntmax 0 purchase 'Purchasing';
  do zro=1 to 1 until(last.client);
    set havxpo;
    by client;
    if col1=0 then cnt=1;
    else do;cnt=0;cntmax=0;end;
    cntmax=sum(cntmax,cnt);
    if cntmax=3 then purchase='Stopped';
    if last.client then do;
       output;
       cntmax=0;
       purchase='Purchasing';
       cnt=0;
    end;
  end;
run;quit;
proc print;
run;quit;
');

*
  __ _ _ __ _ __ __ _ _   _
 / _` | '__| '__/ _` | | | |
| (_| | |  | | | (_| | |_| |
 \__,_|_|  |_|  \__,_|\__, |
                      |___/
;

%utl_submit_wps64('
libname wrk sas7bdat "%sysfunc(pathname(work))";
data wantwps(keep=client subscription);;
  set wrk.have;
  array mons[12] _numeric_;
  do i=1 to 12;
    if mons[i] eq 0 then cnt=1;
    else do;cnt=0;cntmax=0; end;
    cntmax=sum(cntmax,cnt);
    if cntmax=3 then do;
       subscription="Gap      ";
       output;
       cnt=0;
       cntmax=0;
       leave;
    end;
   else if i=12 then do;
      subscription="No Gap    ";
      output;
       cnt=0;
       cntmax=0;
       leave;
   end;
  end;
run;quit;
proc print;
run;quit;
');

*____
|  _ \
| |_) |
|  _ <
|_| \_\

;

%utl_submit_wps64('
libname sd1 "d:/sd1";
options set=R_HOME "C:/Program Files/R/R-3.3.1";
libname wrk "%sysfunc(pathname(work))";
libname hlp "C:\Program Files\SASHome\SASFoundation\9.4\core\sashelp";
proc r;
submit;
library(haven);
have<-read_sas("d:/sd1/have.sas7bdat");
head(have);
have<-1*(have==0);
want <- c();
for ( i in (1:7) ) {
  flips<-tapply(rle(have[i,])$lengths,rle(have[i,])$values,FUN=max);
  want=rbind(want,flips);
};
rownames(want) <- c();
want<-as.data.frame(want);
colnames(want)<-c("max_no_gap","max_gap");
want;
endsubmit;
import r=want  data=wrk.want_r;
run;quit;
');

data want(drop=max_no_gap);
  merge have(keep=client) want_r;
  if max_gap>2 then subscription="Gap      ";
  else  subscription="No Gap     ";
run;quit;


