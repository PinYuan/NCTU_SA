#!/bin/sh
# reference	http://wanggen.myweb.hinet.net/ach3/ach3.html?MywebPageId=2018301538296412183#awk
# awk 的指令間隔：
# 	所有 awk 的動作，亦即在 {} 內的動作，如果有需要多個指令輔助時，可利用分號『;』間隔， 
# 	或者直接以 [Enter] 按鍵來隔開每個指令，例如上面的範例中，鳥哥共按了三次 [enter] 喔！
ls -AlR | egrep "^[-d]" | sort -rnk 5,5 | \
awk 'BEGIN {
	dirNum=0
	fileNum=0
	total=0
}

NR < 6 { print NR":"$5, $9 }
/^d/ {dirNum+=1}
/^-/ {fileNum+=1}
{ total+=$5s }

END {
	print "Dir num:",dirNum,"\nFile num:",fileNum,"\nTotal:",total
}' 

