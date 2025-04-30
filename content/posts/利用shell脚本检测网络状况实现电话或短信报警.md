---
title: "利用shell脚本检测网络状况实现电话或短信报警"
categories: [ "linux" ]
tags: [ "linux","监控","运维" ]
draft: false
slug: "利用shell脚本检测网络状况实现电话或短信报警-利用shell脚本检测网络状况实现电话或短信报警"
date: "2018-12-25 15:27:36"
---



> 腾讯云有语音接口 可以实现任务内容通知

[https://console.cloud.tencent.com/sms][1]

## 脚本如下


```python
#!/usr/bin/env bash

# /root/check/check.sh 脚本存放位置
# */5 * * * * /bin/bash /root/check/check.sh > /dev/null   cron命令

# 日志路径
LOGFILE=/root/check/check_ip.log

# 腾讯云语音appid
SDKAPPID="12345678"
# appkey
strAppKey="abcdefg"
# 语音模板
VOICE_TMP_ID=123456
# 通知的手机号
ALERT_PHONE=18888888888
# ping丢包触发百分比
GE_RATE=20

# 第一个参数为ping测试的ip
# 第二个参数为丢包率
# 第三个参数为通知的手机号
call_phone()
{
    # 模板: 接口{1}丢包率为{2}，请在5分钟内处理！
    strMobile=$3
    strRand=$RANDOM
    strTime=$(date +%s)
    strSig="appkey=${strAppKey}&random=${strRand}&time=${strTime}&mobile=${strMobile}"
    sig=$(echo -n ${strSig} | sha256sum | cut -d " " -f 1)

    api_url="https://cloud.tim.qq.com/v5/tlsvoicesvr/sendtvoice?sdkappid=${SDKAPPID}&random=${strRand}"

    response=$(curl "${api_url}" \
        -H "Accept: application/json" \
        -H "Content-Type:application/json" \
        --data @<(cat <<EOF
{
  "tpl_id": ${VOICE_TMP_ID},
  "params": ["$1","$2"],
  "playtimes": 3,
  "sig": "${sig}",
  "tel": {
    "mobile": "${strMobile}",
    "nationcode": "86"
  },
  "time": ${strTime}
}
EOF
))
    echo ${response} >> ${LOGFILE}
}

# 第一个参数为 ping的ip
# 第二个参数为 失败切换的网卡名字
do_check()
{
    ip=$1 
    change_dev=$2
    date="`date "+%Y-%m-%d %H:%M:%S"`"
    lost_rate=`ping -c 8 -w 8 $ip | grep "packet loss" \
    | awk -F"packet loss" "{ print $1 }" \
    | awk "{ print $NF }" | sed "s/%//g"`

    if [ ${lost_rate} -eq 0 ] # 等于0
        then
            echo "network_ok 【${ip}】 【${date}】 " >> ${LOGFILE}
    elif [ ${lost_rate} -ge ${GE_RATE} ] # 大于等于10
        then
            echo "network_error loss 【${lost_rate}】 【${date}】 【${ip}"】 >> ${LOGFILE}
            # ip route change ${ip} dev ${change_dev}
            call_phone ${ip} ${lost_rate} ${ALERT_PHONE}
    else
        echo "network_check loss 【${lost_rate}】 【${date}】 【${ip}】 " >> ${LOGFILE}
    fi

}

IP_ARRAY[0]="10.3.3.2"
#IP_ARRAY[1]="10.3.3.2"

CHANGE_ARRAY[0]="wg1"
#CHANGE_ARRAY[1]="wg2"

for i in "${!IP_ARRAY[@]}"; do 
    check_ip=${IP_ARRAY[$i]}
    change_dev=${CHANGE_ARRAY[$i]}
    echo "check ip ${check_ip} change_dev ${change_dev}" >> ${LOGFILE}
    do_check ${check_ip} ${change_dev}
done

```


## 2019年1月7日更新 增加多用户报警


```python
#!/usr/bin/env bash

# /root/check/check.sh
# */5 * * * * /bin/bash /root/check/check.sh >> /dev/null

LOGFILE=/root/check/check_ip.log

# 腾讯云语音appid
SDKAPPID="12345678"
# appkey
strAppKey="abcdefghdawdawd"
# 语音模板
VOICE_TMP_ID=66666
# 通知的手机号
ALERT_PHONE[0]=16688868686
ALERT_PHONE[1]=13333333333
# 触发阈值 大于这个就会打电话报警
GE_RATE=5

# 第一个参数为模板的第一个参数 这里是网卡名称或者服务器所在地区
# 第二个参数为丢包率
# 第三个参数为通知的手机号
call_phone()
{
        # call_message="专线接口$1丢包率百分之$2"
        strMobile=$3
        strRand=$RANDOM
        strTime=$(date +%s)
        strSig="appkey=${strAppKey}&random=${strRand}&time=${strTime}&mobile=${strMobile}"
        sig=$(echo -n ${strSig} | sha256sum | cut -d " " -f 1)

        api_url="https://cloud.tim.qq.com/v5/tlsvoicesvr/sendtvoice?sdkappid=${SDKAPPID}&random=${strRand}"

        response=$(curl "${api_url}" \
                -H "Accept: application/json" \
                -H "Content-Type:application/json" \
                --data @<(cat <<EOF
{
  "tpl_id": ${VOICE_TMP_ID},
  "params": ["$1","$2"],
  "playtimes": 3,
  "sig": "${sig}",
  "tel": {
    "mobile": "${strMobile}",
    "nationcode": "86"
  },
  "time": ${strTime}
}
EOF
))
        echo ${response} >> ${LOGFILE}
}

# 第一个参数为 ping的ip
# 第二个参数为 失败切换的网卡名字
do_check()
{
        ip=$1
        change_dev=$2
        date="`date "+%Y-%m-%d %H:%M:%S"`"
        lost_rate=`ping -c 100 -w 100 $ip | grep "packet loss" \
        | awk -F"packet loss" "{ print $1 }" \
        | awk "{ print $NF }" | sed "s/%//g"`

        if [ ${lost_rate} -eq 0 ] # 等于0
                then
                        echo "network_ok 【${ip}】 【${date}】 " >> ${LOGFILE}
        elif [ ${lost_rate} -ge ${GE_RATE} ] # 大于等于10
                then
                        echo "network_error loss 【${lost_rate}】 【${date}】 【${ip}"】 >> ${LOGFILE}
                        # ip route change ${ip} dev ${change_dev}
            for index in "${!ALERT_PHONE[@]}"; do
                alert_phone_index=${ALERT_PHONE[$index]}
                call_phone ${change_dev} ${lost_rate} ${alert_phone_index}
            done
        else
                echo "network_check loss 【${lost_rate}】 【${date}】 【${ip}】 " >> ${LOGFILE}
        fi

}

#ping的网管
IP_ARRAY[0]="10.200.200.101"
#IP_ARRAY[1]="10.3.3.2"

#网关的名字
CHANGE_ARRAY[0]="上海端"
#CHANGE_ARRAY[1]="wg2"

for i in "${!IP_ARRAY[@]}"; do
        check_ip=${IP_ARRAY[$i]}
        change_dev=${CHANGE_ARRAY[$i]}
        #echo "check ip ${check_ip} change_dev ${change_dev}" >> ${LOGFILE}
    do_check ${check_ip} ${change_dev}
done

```


 [1]: https://console.cloud.tencent.com/sms "https://console.cloud.tencent.com/sms"