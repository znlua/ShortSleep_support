# ShortSleep_support
## Abstract
&emsp;This app is designed for short-term sleep and wakes the user up just before they enter deep sleep. It utilizes the heart rate data from the Apple Watch to estimate the user's sleep stage and determines the optimal time to wake the user based on the transitions between different sleep stages.    
&emsp;This app based on a countdown timer app, it collects the user's heart rate data while counting down and simultaneously estimates the user's sleep stage at that time.
## Frame

## Predict Sleep Stage
### Referring Research[^1]
<div align=center>
  <img src="https://github.com/znlua/ShortSleep_support/blob/main/CircleTimer-main/images/RRI.png" alt="RR Intervial" style="width:50%; height:auto;">
  <p>fig.1 RR Interval</p>
</div>    
&emsp;RR interval is an interval between the first wave peak R and the following wave peak R, which is the most distinguishable peak of the electrocardiogram. And, the RRI<sub>n</sub> means the Nth RR interval.

<div align=center>
  <img src="https://github.com/znlua/ShortSleep_support/blob/main/CircleTimer-main/images//Lorenz_plot.png"
    alt="RR Intervial" style="width:45%; height:auto;"/>
  <img src="https://github.com/znlua/ShortSleep_support/blob/main/CircleTimer-main/images/LZ.png"
    alt="RR Intervial" style="width:45%; height:auto;"/>
    <p>fig.2 Lorenz Plot</p>
</div>

&emsp;In these Lorenz plot, the horizontal axis is composed of the Nth RRI, and vertical axis is composed of the N+1th RRI. Then, LP is projected to the y-x axis and y--x axis, and evaluated using the center of distribution, and the area of oval made by a variation of $\sigma$ on y-x axis(x) and $\sigma$ on y--x axis(-x).   

<div align=center>
  <img src="https://github.com/znlua/ShortSleep_support/blob/main/CircleTimer-main/images/center.png"
    alt="RR Intervial" style="width:45%; height:auto;"/>
  <img src="https://github.com/znlua/ShortSleep_support/blob/main/CircleTimer-main/images/area.png"
    alt="RR Intervial" style="width:45%; height:auto;"/>
  <p>fig.3 Center & Area Plot</p>
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

&emsp;According to fig3, as the sleep stage becomes deeper, the change in area becomes smaller. Here I assessed sleep depth by the change in ellipse area over a five minute period. The five-minute layout is as shown in fig.4, the first five minutes are updated only once, but after that, it is updated every minute. 

<div align=center>
  <img src="https://github.com/znlua/ShortSleep_support/blob/main/CircleTimer-main/images/variation.png" alt="RR Intervial" style="width:70%; height:auto;">
  <p>fig.4 Area Variation</p>
</div>    

&emsp;According to fig3, when the sleep depth reaches depth 2, the change in the area of the ellipse and the centre of the distribution approach a certain value. So, 
I utilized the least squares method for regression analysis.    

Regression function:

$$y = k\times\arctan(x) + b$$

<div align=center>
  <img src="https://github.com/znlua/ShortSleep_support/blob/main/CircleTimer-main/images/arctan.png" alt="RR Intervial" style="width:50%; height:auto;">
  <p>fig.5   y = arctan(x)</p>
</div>    

## swift UI & countdown
based on CircleTimer-main

[^1]: 谷田陽介, 萩原啓. 心拍 RRI のローレンツプロット情報に着目した入眠移行期の簡易推定法[J]. 生体医工学, 2006, 44(1): 156-162.


### 项目经历

**项目名称**: 基于Apple Watch的短期睡眠监测应用（独立开发者）  
**项目时间**: 2021年12月 - 2022年2月

#### 项目描述
该项目主要是设计一款用于短期睡眠的应用程序，能够在用户进入深度睡眠之前将其唤醒。应用程序利用Apple Watch的心率数据来估算用户的睡眠阶段，并根据不同睡眠阶段之间的过渡确定最佳唤醒时间。项目基于一个倒计时应用程序，在倒计时的同时收集用户的心率数据，并估算此时的睡眠阶段。

#### 个人工作
1. **心率数据处理**：通过Apple Watch获取用户的心率数据，并使用平均RRI（心跳间隔）来估算用户的睡眠阶段。
   - 利用公式 \( Ave\_RRI = \frac{60s}{bpm} \) 计算每5秒的平均RRI。
2. **睡眠阶段预测**：参考相关研究，利用心跳的RRI数据通过Lorenz图评估睡眠深度。
   - 计算12个连续1分钟的RRI的中心点和变化量，并推算椭圆面积。
   - 使用最小二乘法进行回归分析，确定睡眠深度的变化趋势。
3. **开发和实现**：使用Swift UI设计应用界面，并基于CircleTimer-main实现倒计时功能。
   - 实现心率数据的实时更新和处理，确保用户在最佳时间被唤醒。

#### 项目难点
1. **数据准确性**：由于Apple Watch只能提供30秒的心电图记录，如何有效利用5秒心率数据估算RRI成为关键。
   - 解决方法：采用平均RRI作为近似值，利用连续数据段进行评估。
2. **睡眠阶段估算**：准确区分不同睡眠阶段是应用的核心难点。
   - 解决方法：参考现有研究，通过Lorenz图的变化趋势和椭圆面积的稳定性评估睡眠深度。
3. **实时处理和响应**：确保心率数据的实时处理和倒计时功能的无缝结合。
   - 解决方法：优化数据处理算法，确保应用的流畅运行和用户体验。

#### 个人收获
1. **技术提升**：在项目开发过程中深入了解了心率数据处理和睡眠阶段预测的相关技术，熟练掌握了Swift UI的应用开发。
2. **问题解决能力**：通过解决项目中的数据处理和算法实现难题，提高了独立分析和解决问题的能力。
3. **项目管理**：作为独立开发者，培养了良好的项目管理能力，能够有效规划和推进项目进程，确保项目按时完成。

