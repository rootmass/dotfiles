#!/usr/bin/env python
#-*- coding: utf-8 -*-

from email.mime.text import MIMEText
import smtplib

def sendmail(subject,From,To,message):
        '''发邮件函数
        调用本地SMTP服务器发送邮件'''
        msg = MIMEText(message)
        msg["Subject"] = subject
        msg["From"] = From
        msg["To"] = To
        smtp = smtplib.SMTP("127.0.0.1")
        smtp.sendmail(From,To.split(","),msg.as_string())
        smtp.quit()
