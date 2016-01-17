//
//  Tony.h
//  博杰获取设备名
//
//  Created by Hanoi on 16/1/10.
//  Copyright (c) 2016年 Tony. All rights reserved.
//

#ifndef ________Tony_h
#define ________Tony_h
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <Cocoa/Cocoa.h>
#include <fcntl.h>
#include <unistd.h>
#include <termios.h>
#include<string>
#include <vector>
#include <fstream>

using namespace std;
bool FindKeyWords(const char *name,const char *keyWords)
{
    NSLog(@"\nname = %s   keywords=%s\n",name,keyWords);
    string path(name);
    int nIndex = (int)path.find("-");
    string temp;
    temp = path.substr(nIndex+1,path.length());
    string strKey(keyWords);
    if (temp == strKey)
    {
        return true;
    }
    return false;
}


/********************************************************************/
//Initial LED driver
/********************************************************************/
int InitialLEDDrive(const char *pPath,int &fd)
{
    
    int return_code = 0;
    return_code = open(pPath, O_RDWR | O_NONBLOCK);//O_NONBLOC 非堵塞标志
    if (return_code < 0)
    {
        return -1;
    }
    else
    {
        fd = return_code;
    }
    
    struct termios toptions;
    if(return_code >= 0)
    {
        return_code = tcgetattr(fd, &toptions);
    }
    if(return_code >= 0) { return_code = cfsetispeed(&toptions, B115200); }//change
    if(return_code >= 0) { return_code = cfsetospeed(&toptions, B115200); }//change
    
    // 8N1
    toptions.c_cflag &= ~PARENB;
    toptions.c_cflag &= ~CSTOPB;
    toptions.c_cflag &= ~CSIZE;
    toptions.c_cflag |= CS8;
    // no flow control
    toptions.c_cflag &= ~CRTSCTS;
    
    //toptions.c_cflag &= ~HUPCL; // disable hang-up-on-close to avoid reset
    
    toptions.c_cflag |= CREAD | CLOCAL;  // turn on READ & ignore ctrl lines
    toptions.c_iflag &= ~(IXON | IXOFF | IXANY); // turn off s/w flow ctrl
    
    toptions.c_lflag &= ~(ICANON | ECHO | ECHOE | ISIG); // make raw
    toptions.c_oflag &= ~OPOST; // make raw
    
    
    toptions.c_cc[VMIN]  = 0;
    //toptions.c_cc[VTIME] = 0;
    toptions.c_cc[VTIME] = 20;//设置超时时间
    
    
    if (return_code >= 0)
    {
        return_code = tcsetattr(fd, TCSANOW, &toptions);
    }
    
    if(return_code >= 0) { return_code = tcsetattr(fd, TCSAFLUSH, &toptions); }
    
    return 0;
}

bool CheckSoftwareVersion(const char *pPath,const char *version,int len)
{
    int fd = 0;
    int return_code = 0;
    return_code = InitialLEDDrive(pPath,fd);
    if(return_code != 0)
    {
        return false;
    }
    
    //开始写数据
    int trynumber = 0;
    int writeNum = 0;
    char writrBuffer[] = "version\n";
    while(trynumber < 10)
    {
        writeNum = (int)write(fd,writrBuffer,strlen(writrBuffer));
        if(writeNum != -1)
        {
            break;
        }
        trynumber++;
        usleep(500000);
    }
    if(trynumber >= 10)
    {
        return false;
    }
    usleep(500000);
    
    //开始读数据
    trynumber = 0;
    int readNum = 0;
    char readBuffer[256] = {0};
    while(trynumber < 10)
    {
        readNum = (int)read(fd,readBuffer,256);
        if(readNum != -1 && strstr(readBuffer, "version") && (strlen(readBuffer) > strlen(version)+2))
        {
            break;
        }
        trynumber++;
        usleep(500000);
    }
    if(trynumber >= 10)
    {
        return false;
    }
    
    
    string strReadBuffer(readBuffer);
    strReadBuffer = strReadBuffer.substr(strlen(version),strReadBuffer.length());
    int nIndex = (int)strReadBuffer.find("version");
    string temp = strReadBuffer.substr(nIndex,len);
    string tempVersion(version);
    //开始对比数据
    if(tempVersion == temp)
    {
         return true;
    }
    close(fd);
    return false;
}

std::string& trim(std::string &s)
{
    if (s.empty())
    {
        return s;
    }
    
    s.erase(0,s.find_first_not_of(" "));
    s.erase(s.find_last_not_of(" ") + 1);
    return s;
}

bool GetProduceName(vector<string>&productname)
{
    fstream readFile("/usr/博杰自动扫描设备名/product.txt",ios::in);
    string temp;
    int nIndex = 0;
    string keywords;
    if(readFile.is_open())
    {
        while(getline(readFile,temp))
        {
            nIndex = (int)temp.find("=");
            if(nIndex < 0)
            {
                continue;
            }
            //keywords = temp.substr(nIndex+1,temp.length());
            keywords = trim(temp);
            productname.push_back(keywords);
        }
    }
    else
    {
        return false;
    }
    return true;
}

bool DealString(string &stringCombox)
{
    int nIndex = 0;
    nIndex = (int)stringCombox.find("=");
    if(nIndex < 0)
    {
        return -1;
    }
    stringCombox = stringCombox.substr(nIndex+1,stringCombox.length());
    stringCombox = trim(stringCombox);
    return true;
}
#endif
