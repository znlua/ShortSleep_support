# ShortSleep_support
## Abstract
&emsp;This app is designed for short-term sleep and wakes the user up just before they enter deep sleep. It utilizes the heart rate data from the Apple Watch to estimate the user's sleep stage and determines the optimal time to wake the user based on the transitions between different sleep stages.    
&emsp;This app based on a countdown timer app, it collects the user's heart rate data while counting down and simultaneously estimates the user's sleep stage at that time.
## Frame

## Predict Sleep Stage[^1]
<div align=center>
  <img src="https://github.com/znlua/ShortSleep_support/blob/main/CircleTimer-main/images/RRI.png" alt="RR Intervial" style="width:50%; height:auto;">
  <p>(RR Interval)</p>
</div>    
&emsp;RR interval is an interval between the first wave peak R and the following wave peak R, which is the most distinguishable peak of the electrocardiogram.

<div align=center>
  <img src="https://github.com/znlua/ShortSleep_support/blob/main/CircleTimer-main/images//Lorenz_plot.png"
    alt="RR Intervial" style="width:45%; height:auto;"/>
  <img src="https://github.com/znlua/ShortSleep_support/blob/main/CircleTimer-main/images/LZ.png"
    alt="RR Intervial" style="width:45%; height:auto;"/>
    <p>(Lorenz Plot)</p>
</div>



## swift UI & countdown
based on XXX

[^1]: 谷田陽介, 萩原啓. 心拍 RRI のローレンツプロット情報に着目した入眠移行期の簡易推定法[J]. 生体医工学, 2006, 44(1): 156-162.
