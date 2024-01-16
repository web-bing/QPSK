%%%%%%%%%%%%%%%%%%%%%  QPSK调制解调器仿真 %%%%%%%%%%%%%%%%%

clc
clear
close all

symbol_rate=2400;%符号率(传信速率2400bps)
sps=16;
Fs=38400;
Fc=2000;%载波频率
bit_rate=2*symbol_rate;%比特率4800

EbN0=11;

%原始序列
picture = imread('final1.bmp');
source=input_picture(picture);
picture(1);
imshow(picture);
title("原始图片");

one=sum(source);
row_source=source'+1;

%% 信源编码
counts = [one,length(row_source)-one];%信源序列不同符合的出现次数
msg_source=arithenco(row_source,counts);%算术二进制编码

 figure(2);
 subplot(211);stem(source);
 title('原始序列');
  subplot(212);stem(msg_source);
  title('信源编码后序列');
 xlabel('时间');
 ylabel('幅值');
%% 双极性信号
bipolar_msg_source=2*msg_source-1;
n=length(msg_source);

%% 串并转换
    a=mod(n,2);
if a~=0
    n=n+1;
    bipolar_msg_source=[bipolar_msg_source,0];
end   
qpsk_msg_ich=zeros(1,n/2);
qpsk_msg_qch=zeros(1,n/2);
qpsk_msg_ich(1:end)=bipolar_msg_source(1:2:end);
qpsk_msg_qch(1:end)=bipolar_msg_source(2:2:end);

figure(3);
subplot(211);stem(qpsk_msg_ich);
title('I路时域波形');
subplot(212);stem(qpsk_msg_qch);
title('Q路时域波形');
xlabel('时间');
 ylabel('幅值');

%% 滤波器
 %滚降滤波器
 rcos_fir=rcosdesign(0.5,6,sps);
%  freqz(rcos_fir);
 %plot(rcos_fir);
up16_qpsk_msg_ich=upsample(qpsk_msg_ich,16);
up16_qpsk_msg_qch=upsample(qpsk_msg_qch,16);

qpsk_msg_source_ich=conv(rcos_fir,up16_qpsk_msg_ich);
qpsk_msg_source_qch=conv(rcos_fir,up16_qpsk_msg_qch);

figure(4);
subplot(211);plot(qpsk_msg_source_ich(1:1024));
title('I路通过成型滤波器的时域波形');
subplot(212);plot(abs(fft(qpsk_msg_source_ich)));
title('I路通过成型滤波器的频域波形');


%% 信道
%加载波复信号
time = 1:length(qpsk_msg_source_ich);
qpsk_source_signal =qpsk_msg_source_ich.*cos(2*pi*Fc.*time/Fs) - qpsk_msg_source_qch.*sin(2*pi*Fc.*time/Fs);


%噪声   
%spow=sum(qpsk_source_signal.^2)/n;
spow=sum(qpsk_msg_source_ich.*qpsk_msg_source_ich+qpsk_msg_source_qch.*qpsk_msg_source_qch)/n;
attn_pow=0.5*spow*symbol_rate/bit_rate*10.^(-EbN0/10);
attn=sqrt(attn_pow);

inoise = attn*randn(1,length(qpsk_source_signal));
qnoise = attn*randn(1,length(qpsk_source_signal));

%% 接收端
%带通滤波
inoise = filter(BP,inoise);
qnoise = filter(BP,qnoise);
qpsk_signal=qpsk_source_signal+inoise.*cos(2*pi*Fc.*time/Fs)-qnoise.*sin(2*pi*Fc.*time/Fs);


%相干解调
qpsk_addnoise_ich=qpsk_signal.*cos(2*pi*Fc.*time/Fs);
qpsk_addnoise_qch=qpsk_signal.*(-sin(2*pi*Fc.*time/Fs));


%低通滤波
fir_lp=fir1(128,0.2);                                                       %%%%%%%
qpsk_lp_ich=conv(fir_lp,qpsk_addnoise_ich);                 
qpsk_lp_qch=conv(fir_lp,qpsk_addnoise_qch);  


%匹配滤波，滚降
deqpsk_MF_ich=conv(rcos_fir,qpsk_lp_ich);
deqpsk_MF_qch=conv(rcos_fir,qpsk_lp_qch);

%最佳采样点
decision_site=160;%(96+128+96)/2                            ************************
% 两个滚降滤波器长度N为阶数6*16+1=97，其延时为（N-1）/2
% 低通滤波器fir1长度为N为其阶数128+1=129，其延时为（N-1）/2
%decision_site2=164;


%每个符号选取一个采样点判决
qpsk_option_ich=deqpsk_MF_ich(decision_site+1:sps:end);
qpsk_option_qch=deqpsk_MF_qch(decision_site+1:sps:end);

qpsk_option=zeros(1,n);
qpsk_option(1:2:(n-1))=qpsk_option_ich(1,1:n/2)>=0;
qpsk_option(2:2:n)=qpsk_option_qch(1,1:n/2)>=0;


%信源译码
qpsk_decode=arithdeco(qpsk_option,counts,length(row_source));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%信宿%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%误码率
nErrors = biterr(row_source,qpsk_decode);
nod=length(source);

qpsk_decode=qpsk_decode-1;
bit_err_ratio=nErrors/nod;
fprintf('%d\t%d\t%e\n',nErrors,nod,bit_err_ratio);


%图片恢复
de_pic=output_picture(qpsk_decode);
figure(5);
imshow(de_pic);
title("恢复图像");





