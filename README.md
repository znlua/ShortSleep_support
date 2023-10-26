# ShortSleep_support
## Abstract
&emsp;This app is designed for short-term sleep and wakes the user up just before they enter deep sleep. It utilizes the heart rate data from the Apple Watch to estimate the user's sleep stage and determines the optimal time to wake the user based on the transitions between different sleep stages.    
&emsp;This app based on a countdown timer app, it collects the user's heart rate data while counting down and simultaneously estimates the user's sleep stage at that time.
## Frame

## Predict Sleep Stage
### Referring Research[^1]
<div align=center>
  <img src="https://github.com/znlua/ShortSleep_support/blob/main/CircleTimer-main/images/RRI.png" alt="RR Intervial" style="width:50%; height:auto;">
  <p>fig1. RR Interval</p>
</div>    
&emsp;RR interval is an interval between the first wave peak R and the following wave peak R, which is the most distinguishable peak of the electrocardiogram. And, the RRI<sub>n</sub> means the Nth RR interval.

<div align=center>
  <img src="https://github.com/znlua/ShortSleep_support/blob/main/CircleTimer-main/images//Lorenz_plot.png"
    alt="RR Intervial" style="width:45%; height:auto;"/>
  <img src="https://github.com/znlua/ShortSleep_support/blob/main/CircleTimer-main/images/LZ.png"
    alt="RR Intervial" style="width:45%; height:auto;"/>
    <p>fig2. Lorenz Plot</p>
</div>

&emsp;In these Lorenz plot, the horizontal axis is composed of the Nth RRI, and vertical axis is composed of the N+1th RRI. Then, LP is projected to the y-x axis and y--x axis, and evaluated using the center of distribution, and the area of oval made by a variation of $\sigma$ on y-x axis(x) and $\sigma$ on y--x axis(-x).   

<div align=center>
  <img src="https://github.com/znlua/ShortSleep_support/blob/main/CircleTimer-main/images/center.png"
    alt="RR Intervial" style="width:45%; height:auto;"/>
  <img src="https://github.com/znlua/ShortSleep_support/blob/main/CircleTimer-main/images/area.png"
    alt="RR Intervial" style="width:45%; height:auto;"/>
  <p>fig3. Center & Area Plot</p>
</div>

&emsp;The results of paper[^1] is, as the sleep stage becomes deeper, the center of distribution rises and gradually becomes stable, and the change in area becomes smaller.  

### Mine
&emsp;In the referring research[^1], it is possible to calculate the RRI (R-R interval) of heartbeats using an electrocardiogram (ECG). Although the Apple Watch can also capture an electrocardiogram (ECG), it only provides 30 seconds of recording. Due to the Apple Watch's ability to update heart rate every 5 seconds, the average RRI(Ave\_RRI) is used as the RRI for these five seconds.

$$ Ave\\_RRI = \frac{60s}{bpm} $$

&emsp;Here, I am using 12 consecutive 1-minute RRI to infer sleep stages.  

Center of the 1-minute RRI:

$$ y_{center}=x_{center}=\frac{1}{12}\cdot\sum_{n=1}^{12}\frac{Ave\\_RRI\_{n} + Ave\\_RRI\_{n+1}}{2} $$

Variation $\sigma$ of the 1-minute RRI on y-x axis(x) and y--x axis(-x):

$$ \sigma_{(x)}=\sqrt{\frac{1}{6}\cdot\sum_{n=1}^{12}[(x\_n-x\_{center})]^2} $$

$$ \sigma_{(-x)}=\sqrt{\frac{1}{6}\cdot\sum_{n=1}^{12}x\_n^2} $$

Area of ellipse:

$$ s=\frac{\pi}{4}\times\sigma_{(x)}\times\sigma_{(-x)} $$

&emsp;According to fig3, as the sleep stage becomes deeper, the change in area becomes smaller. Here I assessed sleep depth by the change in ellipse area over a five minute period.

<div align=center>
  <img src="https://github.com/znlua/ShortSleep_support/blob/main/CircleTimer-main/images/figure7.png" alt="RR Intervial" style="width:50%; height:auto;">
  <p>fig4. Area Variation</p>
</div>    

## swift UI & countdown
based on XXX

[^1]: 谷田陽介, 萩原啓. 心拍 RRI のローレンツプロット情報に着目した入眠移行期の簡易推定法[J]. 生体医工学, 2006, 44(1): 156-162.
