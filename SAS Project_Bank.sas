LIBNAME HC "C:\Users\HarryC\Desktop\HC";

/* Reading project4 dataset of Bank Customer Profiling into SAS dataset "proj_dat" */
DATA HC.proj_dat;
	SET HC.project4;
RUN; 

/* Check data properties and variable list */
PROC CONTENTS DATA = HC.proj_dat VARNUM;
RUN;

/* Check original data set,conduct Study Framework on variables of interest */

* Check correlation between selected predictor variables and target variable (credit score) to define relevance;
PROC CORR DATA = HC.proj_dat;
  VAR Income AcctAge Age LORes ILSBal MTGBal CCBal;
  WITH CRScore;
RUN;

/* Univariate analysis on variables of interest*/
* Select 9 X variables + 1 Target variable of interest for analysis;

PROC SQL;
  CREATE TABLE HC.data AS
  SELECT Income,HMOwn,AcctAge,Age,NSF,LORes,ILSBal,MTGBal,CCBal,CRScore
  FROM HC.proj_dat;
QUIT;
PROC PRINT; RUN;

/* Descriptive Statistics */
* Check Missing value and Min, Max;
TITLE "Descriptive Statistics of Continuous Variables of Interest";

PROC MEANS DATA = HC.data MAXDEC=2 N NMISS MIN MEAN MAX STD;
  VAR _NUMERIC_;
RUN;

PROC FREQ DATA = HC.data;
  TABLE HMOwn/MISSING;
RUN;

PROC FREQ DATA = HC.data;
  TABLE NSF/MISSING;
RUN;

/* Drop Missing values in dataset: data */

PROC SQL;
  CREATE TABLE HC.data_01 AS
  SELECT * 
  FROM HC.data
  WHERE (Income is nnot null) & (HMOwn is not null)
        & (AcctAge is not null) & (Age is not null)
		& (LORes is not null) & (CCBal is not null)
		& (CRScore is not null)
  ;
QUIT;
PROC PRINT DATA = HC.data_01; RUN;

/* Check totla obs of data_01, and verify no missing values */
PROC MEANS DATA = HC.data_01 MAXDEC=2 N NMISS MIN MEAN MAX;
  VAR _NUMERIC_;
RUN;

/* - Segmentation on Income, Age, and Credit Score - */
* Check P25,P50,P75 value on Income and Age ;
PROC MEANS DATA = HC.data_01 MAXDEC=2 P25 P50 P75 MAX ;
  VAR Age Income;
RUN;

* Segmentation;
PROC FORMAT;
  VALUE  AgeGrp   
         Low -<38 = "<38yr"
		 38 -<48 = "38-47yr"
		 48 -<58 = "48-57yr"
		 58 -high = "58+ yr";
  VALUE  IncomeGrp
         Low -<20 = "<20K"
		 20 -<34 = "20-34K"
		 34 -<54 = "34-54K"
		 54 -high = "54+ K";
  VALUE  CRScoreGrp
         Low -<600 = "300-599:Poor"
		 600 -<650 = "600-649:Fair"
		 650 -<720 = "650-719:Good"
		 720 -<800 = "720-799:VeryGood"
		 800 -high = "800-900:Excellent";
RUN;

DATA HC.data_02;
  SET HC.data_01;
  LENGTH AgeGrp $8 IncomeGrp $8 CRScoreGrp $18;

  IF Age le 37 THEN AgeGrp = "<38yr";
  ELSE IF 37 < Age <= 47 THEN AgeGrp = "38-47yr";
  ELSE IF 47 < Age <= 57 THEN AgeGrp = "48-57yr";
  ELSE IF Age gt 57 THEN AgeGrp = "58+ yr";

  IF Income lt 20 THEN IncomeGrp = "<20K";
  ELSE IF 20 <= Income < 34 THEN IncomeGrp = "20-34K";
  ELSE IF 34 <= Income < 54 THEN IncomeGrp = "34-54K";
  ELSE IF Income ge 54 THEN IncomeGrp = "54+ K";

  IF CRScore lt 600 THEN CRScoreGrp = "300-599:Poor";
  ELSE IF 600 <= CRScore < 650 THEN CRScoreGrp = "600-649:Fair";
  ELSE IF 650 <= CRScore < 720 THEN CRScoreGrp = "650-719:Good";
  ELSE IF 720 <= CRScore < 800 THEN CRScoreGrp = "720-799:VeryGood";
  ELSE IF CRScore >= 800 THEN CRScoreGrp = "800-900:Excellent";
RUN;


/* Visualization */
ODS GRAPHICS ON;

* Income of X variable;
TITLE "Histogram and Density Curve of 'Income'";
PROC SGPLOT DATA = HC.data_02;
  HISTOGRAM Income;
  DENSITY Income;
  DENSITY Income / type=kernel;
  keylegend / location=inside position=topright;
RUN;
TITLE "Bar Chart of 'IncomeGrp'";
PROC SGPLOT DATA = HC.data_02;
  VBAR IncomeGrp;
  XAXIS values=("<20K" "20-34K" "34-54K" "54+ K");
  keylegend / location=inside position=topleft;
RUN;
TITLE "Stacked Bar Chart of 'IncomeGrp' with Home Owner";
PROC SGPLOT DATA = HC.data_02;
  VBAR IncomeGrp/GROUP=HMOwn;
  XAXIS values=("<20K" "20-34K" "34-54K" "54+ K");
  keylegend / location=inside position=topleft;
RUN;
TITLE "Stacked Bar Chart of 'IncomeGrp' with Number Insufficient Fund";
PROC SGPLOT DATA = HC.data_02;
  VBAR IncomeGrp/GROUP=NSF;
  XAXIS values=("<20K" "20-34K" "34-54K" "54+ K");
  keylegend / location=inside position=topleft;
RUN;

* Age of X variable;
TITLE "Histogram and Density Curve of 'Age'";
PROC SGPLOT DATA = HC.data_02;
  HISTOGRAM Age;
  DENSITY Age;
  DENSITY Age / type=kernel;
  keylegend / location=inside position=topright;
RUN;
TITLE "Bar Chart of 'AgeGrp'";
PROC SGPLOT DATA = HC.data_02;
  VBAR AgeGrp;
  XAXIS values=("<38yr" "38-47yr" "48-57yr" "58+ yr");
  keylegend / location=inside position=topleft;
RUN;
TITLE "Stacked Bar Chart of 'IncomeGrp' with Home Owner";
PROC SGPLOT DATA = HC.data_02;
  VBAR AgeGrp/GROUP=HMOwn;
  XAXIS values=("<38yr" "38-47yr" "48-57yr" "58+ yr");
  keylegend / location=inside position=topleft;
RUN;
TITLE "Stacked Bar Chart of 'IncomeGrp' with Number Insufficient Fund";
PROC SGPLOT DATA = HC.data_02;
  VBAR AgeGrp/GROUP=NSF;
  XAXIS values=("<38yr" "38-47yr" "48-57yr" "58+ yr");
  keylegend / location=inside position=topleft;
RUN;
TITLE "Pie Chart of 'IncomeGrp'";
PROC GCHART DATA = HC.data_02;
  PIE AgeGrp /discrete value=inside percent=outside slice=outside;
RUN;

* CRScore variable;
TITLE "Histogram and Density Curve of 'Credit Score'";
PROC SGPLOT DATA = HC.data_02;
  HISTOGRAM CRScore;
  DENSITY CRScore;
  DENSITY CRScore / type=kernel;
  keylegend / location=inside position=topright;
RUN;
TITLE "Stacked Bar Chart of 'CRScoreGrp' with Home Owner";
PROC SGPLOT DATA = HC.data_02;
  VBAR CRScoreGrp/GROUP=HMOwn;
  XAXIS values=("300-599:Poor" "600-649:Fair" "650-719:Good" "720-799:VeryGood" "800-900:Excellent");
  keylegend / location=inside position=topleft;
RUN;
TITLE "Pie Chart of 'Credit Score Group'";
PROC GCHART DATA = HC.data_02;
  PIE CRScoreGrp /discrete value=inside percent=outside slice=inside;
RUN;

/* Boxplot on Length of Residence */
* Length of Residence vs Home Owner or not;
PROC SGPLOT DATA = HC.data_02
	(where=(HMOwn in (0 1)));
	VBOX LORes / category=HMOwn
				  group=HMOwn groupdisplay=cluster
				  lineattrs=(pattern=solid)
				  whiskerattrs=(pattern=solid);
	yaxis grid;
	keylegend / location=inside
				position=topright
				across=1;
	TITLE "Boxplot of Length-of-Residence between Home Owner & Non-Home-Owner";
RUN;

/*
* Exploratory Data Analysis (EDA) with Graphics/Visualization;
* Univariate analysis: Continuous variables;

ODS GRAPHICS ON;

TITLE "EDA Analysis on Univariate continuous variables";

* Income vs Mortgage;
PROC SGPLOT DATA = HC.project_data
	(where=(MTG in (0 1)));
	VBOX Income / category=MTG
				  group=MTG groupdisplay=cluster
				  lineattrs=(pattern=solid)
				  whiskerattrs=(pattern=solid);
	yaxis grid;
	keylegend / location=inside
				position=topright
				across=1;
RUN;

* Credit Score vs Mortgage;
PROC SGPLOT DATA = HC.project_data
	(where=(MTG in (0 1)));
	VBOX CRScore / category=MTG
				  group=MTG groupdisplay=cluster
				  lineattrs=(pattern=solid)
				  whiskerattrs=(pattern=solid);
	yaxis grid;
	keylegend / location=inside
				position=topright
				across=1;
RUN;

* Home Value vs Installment Loan;
PROC SGPLOT DATA = HC.project_data
	(where=(ILS in (0 1)));
	VBOX HMVal / category=ILS
				  group=ILS groupdisplay=cluster
				  lineattrs=(pattern=solid)
				  whiskerattrs=(pattern=solid);
	yaxis grid;
	keylegend / location=inside
				position=topright
				across=1;
RUN;
* Home Value vs Mortgage;
PROC SGPLOT DATA = HC.project_data
	(where=(MTG in (0 1)));
	VBOX HMVal / category=MTG
				  group=MTG groupdisplay=cluster
				  lineattrs=(pattern=solid)
				  whiskerattrs=(pattern=solid);
	yaxis grid;
	keylegend / location=inside
				position=topright
				across=1;
RUN;
*/

TITLE "Histogram of Age-of-Oldest-Account";
PROC UNIVARIATE DATA = HC.data_02;
  VAR AcctAge;
  HISTOGRAM;
RUN;


/* Bivariate analysis: Continuous to Continuous */
* Visualization of Correlation in Scatter Matrix;

ODS GRAPHICS ON;

ODS PDF FILE = "D:\My Documents\Personal\DSA Training\SAS Project\Project\PROJECT_REPORT.PDF";

TITLE "Correlation on Continuous Variables";
PROC CORR DATA = HC.data_02 pearson noprob PLOTS(MAXPOINTS=NONE)
  plots = matrix(histogram);
  VAR Income Age AcctAge ILSBal MTGBal CCBal LORes CRScore;
RUN;

PROC CORR DATA = HC.data_02 PLOTS = (SCATTER MATRIX) PLOTs(MAXPOINTS=NONE);
  VAR Income Age AcctAge ILSBal MTGBal CCBal LORes;
  WITH CRScore;
  TITLE "Correlation for Credit Score";
RUN;

ODS PDF CLOSE;

/*
PROC BOXPLOT DATA = HC.data_02;
  PLOT CRScore * AgeGrp / maxpanels= 650 grid odstitle=title nohlabel boxstyle=schematicID; 
  insetgroup Q2 N;
  TITLE 'Distribution of Credit Score by Age Group';
RUN;

PROC SORT DATA = HC.data_02 out=HC.data02_sort;
  BY Age/ascending;
RUN;
PROC BOXPLOT DATA = HC.data_02;
  PLOT CRScore * Age;
  FORMAT Age AgeGrp.;
  TITLE 'Distribution of Credit Score by Age Group';
RUN;
*/

PROC FREQ DATA = HC.data_02;
  TABLES LORes / plots=freqplot;
RUN;

PROC FREQ DATA = HC.data_02;
  TABLE HMOwn*CRScore / norow nocol
  plots=freqplot(twoway=stacked scale=grouppct) chisq;
  format crscore crscoregrp.;
  title 'Percent of Home Ownership by Credit Score Group';
RUN;
  
PROC FREQ DATA = HC.data_02;
  TABLE Income*CRScore / norow nocol
  plots=freqplot(twoway=stacked scale=grouppct) chisq;
  format income incomegrp. crscore crscoregrp.;
  title 'Percent of Income Group by Credit Score Group';
RUN;

/* Question 2 */

PROC SQL;
  CREATE TABLE HC.data_03 AS
  SELECT MM, SDB, LOC, Ins, CC, Inv, CRScore 
  FROM HC.proj_dat
  WHERE (MM is not null) & (SDB is not null)
        & (LOC is not null) & (Ins is not null)
		& (CC is not null) & (Inv is not null)
		& (CRScore is not null)
  ;
QUIT;
PROC PRINT DATA = HC.data_03; RUN;

DATA HC.data_04;
  SET HC.data_03;
  LENGTH CRScoreGrp $18;

  IF CRScore lt 600 THEN CRScoreGrp = "300-599:Poor";
  ELSE IF 600 <= CRScore < 650 THEN CRScoreGrp = "600-649:Fair";
  ELSE IF 650 <= CRScore < 720 THEN CRScoreGrp = "650-719:Good";
  ELSE IF 720 <= CRScore < 800 THEN CRScoreGrp = "720-799:VeryGood";
  ELSE IF CRScore >= 800 THEN CRScoreGrp = "800-900:Excellent";
RUN;

PROC FORMAT;
  VALUE  CRScoreGrp
         Low -<600 = "300-599:Poor"
		 600 -<650 = "600-649:Fair"
		 650 -<720 = "650-719:Good"
		 720 -<800 = "720-799:VeryGood"
		 800 -high = "800-900:Excellent";
RUN;

PROC FREQ DATA = HC.data_04;
  TABLE MM*CRScore / norow nocol
  plots=freqplot(twoway=stacked scale=grouppct) chisq;
  format CRScore CRScoreGrp.;
  title 'Percent of Money Market by Credit Score Group';
RUN;

PROC FREQ DATA = HC.data_04;
  TABLE Ins*CRScore / norow nocol
  plots=freqplot(twoway=stacked scale=grouppct) chisq;
  format CRScore CRScoreGrp.;
  title 'Percent of Insurance by Credit Score Group';
RUN;

PROC FREQ DATA = HC.data_04;
  TABLE CC*CRScore / norow nocol
  plots=freqplot(twoway=stacked scale=grouppct) chisq;
  format CRScore CRScoreGrp.;
  title 'Percent of Credit Card by Credit Score Group';
RUN;

PROC FREQ DATA = HC.data_04;
  TABLE Inv*CRScore / norow nocol
  plots=freqplot(twoway=stacked scale=grouppct) chisq;
  format CRScore CRScoreGrp.;
  title 'Percent of Investment by Credit Score Group';
RUN;

===================  SAS Modeling: Linear Regression   ==============================

/* Build SAS Linear Regression prediction modeling */

ODS GRAPHICS ON;

ODS PDF FILE = "D:\My Documents\Personal\DSA Training\SAS Project\Project\Report_Modeling.PDF";

PROC PLOT DATA = HC.data_02;
  PLOT CRScore* (Income AcctAge Age LORes ILSBal MTGBal CCBal);
RUN;

/* Modeling: Linear Regression */

PROC REG DATA = HC.data_02 PLOTS(MAXPOINTS=NONE);
  MODEL CRScore = Income AcctAge Age LORes ILSBal MTGBal CCBal HMOwn NSF;
RUN;

PROC GLM DATA=HC.data_02 PLOTS(MAXPOINTS=NONE);
  CLASS HMOwn NSF;
  MODEL CRScore = Income AcctAge Age LORes ILSBal MTGBal CCBal HMOwn NSF;
RUN;

ODS PDF CLOSE;


/***       END      ***/

/*
PROC CORR DATA = HC.project_data PEARSON SPEARMAN;
	VAR Age Income HMVal MTGBal ILSBal CCBal;
	WITH CRScore;
RUN;

PROC UNIVARIATE DATA = HC.project_data;
	VAR CRScore;
	HISTOGRAM;
RUN;
TITLE;

* Bivariate analysis: Categorical variables;
* Chi-square: Categorical vs Categorical;

TITLE "EDA Analysis on Bivariate variables";

PROC FREQ DATA = HC.project_data;
	TABLE LOC * MTG / CHISQ NOCOL NOROW;
RUN;

PROC FREQ DATA = HC.project_data;
	TABLE CC * MTG / CHISQ NOCOL NOROW;
RUN;

* Analysis for ANOVA;

PROC ANOVA DATA = HC.project_data;
	CLASS HMOwn;
	MODEL CRScore = HMOwn;
	MEANS HMOwn/Scheffe;
	TITLE;
RUN;

PROC ANOVA DATA = HC.project_data;
	CLASS HMOwn;
	MODEL Age = HMOwn;
	MEANS HMOwn/Scheffe;
	TITLE;
RUN;

PROC ANOVA DATA = HC.project_data;
	CLASS MTG;
	MODEL Income = MTG;
	MEANS MTG/Scheffe;
	TITLE;
RUN;

PROC ANOVA DATA = HC.project_data;
	CLASS CC;
	MODEL Income = CC;
	MEANS CC/Scheffe;
	TITLE;
RUN;

PROC ANOVA DATA = HC.project_data;
	CLASS NSF;
	MODEL CRScore = NSF;
	MEANS NSF/Scheffe;
	TITLE;
RUN;

* Exploratory Data Analysis (EDA) with Graphics/Visualization;
* Bivariate analysis: Continuous variables; 

ODS GRAPHICS ON;

PROC CORR DATA = HC.project_data PLOTS =(SCATTER MATRIX);
	VAR Income Age HMVal MTGBal ILSBal CCBal;
	WITH CRScore;
	TITLE "Correlation for Credit Score";
	TITLE2 'With Income,Age,Home Value,Mortgage Balance,Loan Balance and Credit Card Balance';
RUN;
*/
