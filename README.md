# Calculating Series I Bond Values
* Calculate historical monthly values for the Series I (inflation-indexed) bonds issued by the U.S. Treasury.
* Calculate projected future values (through maturity) for Series I bonds based on an assumed rate of inflation.

### Details ###

Since [1998], the U.S. Treasury has issued Series I bonds to allow investors and savers to earn a guaranteed real rate of return, that is, a nominal rate in excess of the inflation rate.

Interest on an I Bond rates is a combination of two rates:

* A fixed rate of return which remains the same throughout the life of the I Bond and
* A variable inflation rate which we calculate twice a year, based on changes in the nonseasonally adjusted Consumer Price Index for all Urban Consumers (CPI-U) for all items, including food and energy (CPI-U for March compared with the CPI-U for September of the same year, and then CPI-U for September compared with the CPI-U for March of the following year).

Interest is earned on the bond every month. 

The interest is compounded semiannually:  Every six months, on the 6th and 12th month anniversaries of the issue date,  all interest the bond has earned in previous months is in the bond's new principal value on which interest is earned for the next 6 months.


### Caveats ###
This R script is intended as an estimate for informational purposes only, and is not meant to be a representation as to the value of any specific bond at any point in time. This script is not an offer to buy or sell any securities.

The [U.S. Treasury securities website](https://www.treasurydirect.gov) contains much more detailed information about Series I Savings Bonds. However, it is not clear precisely how the Treasury applies certain rounding conventions to the calculation of interest accruals. In addition, there may be floating-point errors that affect the precise calculation of reported results.