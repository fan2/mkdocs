---
title: python中的日期时间处理类——datetime
authors:
  - xman
date:
    created: 2019-12-06T09:10:00
categories:
    - python
tags:
    - datetime
comments: true
---

本文梳理了 python 中的日期时间处理类 datetime，记录了一些日常用法。

<!-- more -->

## UTC

[What is UTC or GMT Time?](https://www.nhc.noaa.gov/aboututc.shtml)

- `GMT`: Greenwich Mean Time
- `UTC`: Universal Time Coordinated

[UTC – The World's Time Standard](https://www.timeanddate.com/time/aboututc.html)

- `UTC` is A Standard, Not a Time Zone;  
- `GMT` is now a Time Zone.  

[Coordinated Universal Time (UTC, GMT, CUT)](https://www.techtarget.com/whatis/definition/Coordinated-Universal-Time-UTC-GMT-CUT)

**时间服务器**：

- [Epoch Clock](https://www.epoch101.com/epochclock)  
- [Unix Epoch Clock](https://www.epochconverter.com/clock)  

- [World Time Server](https://www.worldtimeserver.com/)  
- [TIME.IS](https://time.is/): [UTC](https://time.is/UTC): [Unix Time](https://time.is/Unix_time), [Beijing Time](https://time.is/zh/Beijing)  

**Epoch Converter**：

- [Unix Timestamp - Epoch Converter](https://unixtime.org/)  
- [Unix Time Stamp - Epoch Converter](https://www.unixtimestamp.com/)  
- [Epoch Converter - Unix Timestamp Converter](https://www.epochconverter.com/)  
- [Convert Epoch/Unix Timestamp](https://www.epoch101.com/#epochConvertToReadable-Container)  

## datetime

[datetime](https://docs.python.org/3/library/datetime.html)  

```
NAME
    datetime - Fast implementation of the datetime type.

CLASSES
    builtins.object
        date
            datetime
        time
        timedelta
        tzinfo
            timezone
```

class `datetime.date`

- An idealized naive date, assuming the current Gregorian calendar always was, and always will be, in effect. Attributes: [year](https://docs.python.org/3/library/datetime.html#datetime.date.year), [month](https://docs.python.org/3/library/datetime.html#datetime.date.month), and [day](https://docs.python.org/3/library/datetime.html#datetime.date.day).

class `datetime.time`

- An idealized time, independent of any particular day, assuming that every day has exactly 24*60*60 seconds. (There is no notion of “leap seconds” here.) Attributes: [hour](https://docs.python.org/3/library/datetime.html#datetime.time.hour), [minute](https://docs.python.org/3/library/datetime.html#datetime.time.minute), [second](https://docs.python.org/3/library/datetime.html#datetime.time.second), [microsecond](https://docs.python.org/3/library/datetime.html#datetime.time.microsecond), and [tzinfo](https://docs.python.org/3/library/datetime.html#datetime.time.tzinfo).

class `datetime.datetime`

- A combination of a date and a time. Attributes: [year](https://docs.python.org/3/library/datetime.html#datetime.datetime.year), [month](https://docs.python.org/3/library/datetime.html#datetime.datetime.month), [day](https://docs.python.org/3/library/datetime.html#datetime.datetime.day), [hour](https://docs.python.org/3/library/datetime.html#datetime.datetime.hour), [minute](https://docs.python.org/3/library/datetime.html#datetime.datetime.minute), [second](https://docs.python.org/3/library/datetime.html#datetime.datetime.second), [microsecond](https://docs.python.org/3/library/datetime.html#datetime.datetime.microsecond), and [tzinfo](https://docs.python.org/3/library/datetime.html#datetime.datetime.tzinfo).

class `datetime.timedelta`

- A duration expressing the difference between two [date](https://docs.python.org/3/library/datetime.html#datetime.date), [time](https://docs.python.org/3/library/datetime.html#datetime.time), or [datetime](https://docs.python.org/3/library/datetime.html#datetime.datetime) instances to microsecond resolution.

### strftime

datetime.**strftime**(*format*)

**strftime**: Return a string representing the date

按格式输出日期字符串：

```shell
>>> import datetime

>>> datetime_now = datetime.datetime.now()
>>> datetime_now
datetime.datetime(2018, 4, 24, 15, 51, 2, 399371)
>>> datetime_now.strftime('%Y-%m-%d %H:%M:%S')
'2018-04-24 15:51:02'
```

type-specific formatting 等效写法：

```shell
>>> import datetime
>>> d=datetime.datetime(2018, 4, 25, 13, 0, 0)
>>> '{:%Y-%m-%d %H:%M:%S}'.format(d)
'2018-04-25 13:00:00'
```

### strptime

*classmethod* datetime.**strptime**(*date_string*, *format*)

**strptime**: Return a datetime corresponding to date_string, parsed according to format.

```shell
>>> datetime_now = datetime.datetime.strptime('20180424', '%Y%m%d')
>>> datetime_begin = datetime.datetime.strptime('20180323', '%Y%m%d')
>>> datetime_count = datetime_now-datetime_begin
>>> datetime_count
datetime.timedelta(32)
>>> datetime_count.days
32
```

## timestamp

Unix 时间戳是从1970年1月1日（UTC/GMT的午夜）开始所经过的秒数（不考虑闰秒），是一个浮点数。
英文为 [Unix time](https://en.wikipedia.org/wiki/Unix_time), POSIX time, Unix epoch 或 Unix timestamp。

- The Current Epoch Unix Timestamp: Seconds since Jan 01 1970. (UTC)
- The Unix epoch is the number of seconds that have elapsed since January 1, 1970 at midnight UTC time minus the leap seconds.

time和datetime都是Python中的内置模块，都可以对时间进行获取，对时间格式进行转换，如时间戳和时间字符串的相互转换。

- [Python中time和datetime时间戳和时间字符串相互转换](https://blog.csdn.net/weixin_43790276/article/details/90674297)

### time

time 模块定义的 `time()` 函数返回当前时间，是一个秒级时间戳浮点数。

```Shell
FUNCTIONS

    time(...)
        time() -> floating point number

        Return the current time in seconds since the Epoch.
```

对于 `time()` 返回的秒级时间戳，乘以1000即可求得毫秒级：

```Python
import time, math

sTimestamp = time.time() # 6位小数
print(sTimestamp)
msTimestamp = time.time() * 1000
print(msTimestamp)
print(math.floor(msTimestamp)) # 向下取整，忽略us
print(round(msTimestamp)) # 四舍五入
```

运行输出：

```
1669000141.6891751
1669000141689.566
1669000141690
1669000141689
```

基于 `time_ns()` 接口返回高精度的纳秒级时间戳，来换算更粗粒度的毫秒单位，可能更为合理：

```Python
import time

sTimestamp = time.time() # 秒，6位小数
print(sTimestamp)
nsTimestamp = time.time_ns() # 纳秒
print(nsTimestamp)
msTimestamp = nsTimestamp / (1000 * 1000) # 毫秒
print(msTimestamp)
```

```
1669000543.659899
1669000543660408000
1669000543660.408
```

### datetime

class datetime 的实例方法 `timestamp()`：Return POSIX timestamp as float.

```Python
import datetime;

current_time = datetime.datetime.now()
time_stamp = current_time.timestamp()
print("timestamp:", time_stamp)
```

也可调用类方法 datetime.timestamp(dt)，其中dt为datetime对象实例：

```Python
from datetime import datetime

now = datetime.now()
timestamp = datetime.timestamp(now)
print("timestamp =", timestamp)
```

#### fromtimestamp

```
classmethod datetime.fromtimestamp(timestamp, tz=None)
Return the local date and time corresponding to the POSIX timestamp, such as is returned by time.time(). 
```

也可调用类方法 datetime.timestamp(ts)，其中ts为秒级时间戳：

```Shell
>>> datetime.fromtimestamp(time.time())
datetime.datetime(2022, 11, 21, 11, 42, 7, 720789)
```

## timedelta

```shell
>>> # 获取当前时间
>>> d0 = datetime.datetime.now()
>>> # 基于日期字符串创建日期对象
>>> str_begin_date = '20180314'
>>> d1 = datetime.datetime.strptime(str_begin_date, '%Y%m%d')
>>> d2 = datetime.datetime(2018,2,2)
>>> # 计算日期相隔天数
>>> dd1=d0-d1
>>> dd1.days
43
>>> dd2=d1-d2
>>> dd2.days
40
>>> # 计算32天前的日期
>>> d3 = d0 - datetime.timedelta(days=32)
>>> d3
datetime.datetime(2018, 3, 25, 22, 37, 55, 465668)
```

## Examples

- [Examples of Usage: date](https://docs.python.org/3/library/datetime.html#examples-of-usage-date)
- [Examples of Usage: datetime](https://docs.python.org/3/library/datetime.html#examples-of-usage-datetime)
- [Examples of Usage: time](https://docs.python.org/3/library/datetime.html#examples-of-usage-time)
- [Examples of usage: timedelta](https://docs.python.org/3/library/datetime.html#examples-of-usage-timedelta)