import socket
import select
import array
import numpy as np
import csv
import argparse

parser = argparse.ArgumentParser(description='Send CSV data to SCROD')
parser.add_argument('--InputFile', help='Path to where the test bench should be created',default="/home/belle2/Documents/tmp/simplearithmetictest_tb_csv.csv")
parser.add_argument('--OutputFile', help='Name of the entity Test bench',default="data_out.csv")


args = parser.parse_args()


class SCROD_ethernet:
    def __ToEventNumber(self, Data, Index):
        ret_h = 0
    
        ret_h += (Data[Index])
        ret_h += 0x100*(Data[Index+1])
        ret_h += 0x10000*(Data[Index+2])
        ret_h += 0x1000000*(Data[Index+3])
        return ret_h

    def __ArrayToHex(self,Data):
        ret = list()
        for j in range(0,len(Data),4):
            ret.append(hex(self.__ToEventNumber(Data,j)))
        
        return ret


    def __init__(self,IpAddress,PortNumber):
        self.IpAddress = IpAddress
        self.PortNumber = PortNumber
        self.clientSock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    
    def send(self,Data):
        message = []
        for x in Data:
            message+=(x.to_bytes(4,'little'))
        #print("UDP Target Address:", self.IpAddress)
        #print("UDP Target Port:", self.PortNumber)
        #print("Sent message...")
        #print("")

        str1=array.array('B', message).tobytes()
        #print(self.__ArrayToHex(str1))
        self.clientSock.sendto(str1, ( self.IpAddress, self.PortNumber))

    def receive(self):
        data, addr = self.clientSock.recvfrom(4096)

        #print("\n\nrecv message from ",addr)
        data = self.__ArrayToHex(data)
        #print (data)
        return data
    def hasData(self):
         rdy_read, rdy_write, sock_err = select.select([self.clientSock,], [], [],0.1)
         #print (rdy_read, rdy_write, sock_err)
         return len(rdy_read) > 0



class CsvLoader:
    def __init__(self,FileName):
        with open(FileName, newline='') as csvfile:
            
            self.contentLines = csvfile.readlines()
            self.numberOfRows = len(self.contentLines) 
         
        self.reader = csv.DictReader(FileName)
        self.fieldNames = self.reader.fieldnames 
   
        self.line = []
        self.index = 0
        self.content = list()
        message = list()
        message.append(self.numberOfRows)
        message.append(self.numberOfRows)
        self.content.append(message)
        
        lineCount = 0
        for row in self.contentLines:
            lineCount+=1
            if lineCount < 3:
                continue
        
            message = list()
            #message.append(2)
            row=row.strip()
            row = row.replace("\r\n","")
            rowsp = row.split(" ")
            for coll in rowsp:
   
                message.append(int(coll))


            self.content.append(message)











scrod1 = SCROD_ethernet("192.168.1.33",2001)
scrod1.hasData()
csv = CsvLoader(args.InputFile)

print("send data")
i = 0 
for row in csv.content:
        scrod1.send(row)
        print(i,row)
        i+= 1
print("receive data")
i = 0 
with open(args.OutputFile,"w",newline="") as f:
    while scrod1.hasData():
        data = scrod1.receive()
        line = ""
        start = ""
        for d in data:
            line += start + str(int(d,16)) 
            start = "; "
        f.write(line+"\n")
        print(i,line)
        i+= 1


print("end")
